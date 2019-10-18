function simulation_snr_analysis(subj_info, varargin)
%%
% Runs simulations at random source locations with different SNR levels.
% Simulates dipole at orientation given by link vectors, inverts at
% orientation 0-70 deg away
%%
%addpath('/mnt/data/maxime/dipole_moment_priors/spm12')
defaults = struct('base_dir','../data',...
    'surf_dir', '../data/surf',...
    'mri_dir', '../data/mri');  %define default values
params = struct(varargin{:});
for f = fieldnames(defaults)',  
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

spm('defaults', 'EEG');
spm_jobman('initcfg'); 
spm('CmdLine');

output_dir='../output/data/sim';
mkdir(output_dir);

% Get downsampled pial surface
subj_surf_dir=fullfile(params.surf_dir, sprintf('%s-synth', subj_info.subj_id), 'surf');
ds_pial=gifti(fullfile(subj_surf_dir, 'pial.ds.gii'));
     
% Compute link vector normals
method='link_vector';
ds_pial.normals=compute_surface_normals(params.surf_dir,...
    sprintf('%s-synth', subj_info.subj_id), 'pial', method);            
method_fname=sprintf('pial.ds.%s.gii',method);
save(ds_pial,fullfile(subj_surf_dir, method_fname));
if exist(fullfile(subj_surf_dir,'FWHM5.00_pial.ds.mat'),'file')==2
    copyfile(fullfile(subj_surf_dir,'FWHM5.00_pial.ds.mat'),...
        fullfile(subj_surf_dir,sprintf('FWHM5.00_pial.ds.%s.mat',method)));
end

% SNR levels to simulate at
snr_levels=[-50 -40 -30 -20 -10 0];

% Randomize simulation vertices
nverts=size(ds_pial.vertices,1);
rng('default');
rng(0);
simvertind=randperm(nverts);
% Number of locations to simulate at
n_sim_locations=100;

% For each simulation location
for v_idx=1:n_sim_locations    
    % Get vertex and normal vector
    sim_vertex=simvertind(v_idx);
    sim_ori=ds_pial.normals(sim_vertex, :);
    
    % For each SNR level
    for snr_idx=1:length(snr_levels)
        snr=snr_levels(snr_idx);
        
        % Run simulation
        sim_signal=simulate_dipole(subj_info, method_fname, sim_vertex, sim_ori, snr,...
            'base_dir', params.base_dir, 'surf_dir', params.surf_dir,...
            'mri_dir', params.mri_dir);

        % Invert at 10 different orientations
        for ori_idx=1:10
            % Compute new orientation
            desired_angle_diff=((ori_idx-1)*70/10)*pi/180.0;
            
            new_normals=ds_pial.normals(:, :);
            for j=1:nverts
                orig_ori=new_normals(j,:);
                if sum(abs(orig_ori))>0
                    %% Generating the second vector with the secified angle with respect to the first vector
                    [sim_sph(1), sim_sph(2), sim_sph(3)] = cart2sph(orig_ori(1), orig_ori(2), orig_ori(3)); % The first vector in spherical coordinate system
                    new_sph = sim_sph;
                    new_sph(2) = new_sph(2) + desired_angle_diff; % For the second vector just need to change the 'elevation' parameter (second argument) in spherical coordinate system
                    new_ori = nan(1, 3); % size(vec2_sph)
                    [new_ori(1), new_ori(2), new_ori(3)] = sph2cart(new_sph(1), new_sph(2), new_sph(3)); % Transform to Cartesian coordinate system
                    angle_rot = 2*pi*rand();
                    new_ori = rodrigues_rot(new_ori, orig_ori, angle_rot);
                    new_normals(j,:)=new_ori;
                end
            end
            angle_diff=atan2(norm(cross(sim_ori,new_normals(sim_vertex,:))),dot(sim_ori,new_normals(sim_vertex,:)));
            
            % Run inversion and get free energy
            fval=invert_simulated_dipole(subj_info, method_fname,...
                new_normals, 'base_dir',params.base_dir, 'surf_dir', params.surf_dir,...
                'mri_dir',params.mri_dir);
                        
            % Save results
            results=[];
            results.sim_vertex=sim_vertex;
            results.subj_info=subj_info;
            results.sim_ori=sim_ori;
            results.snr=snr;
            results.sim_signal=sim_signal;
            results.method=method;
            results.inv_ori=new_ori;
            results.angle_diff=angle_diff;
            results.F=fval;
            save(fullfile(output_dir, sprintf('sim_%s_vertex_%d_ori_idx_%d_snr_%d.mat',...
                subj_info.subj_id, sim_vertex, ori_idx, snr)),'results');
        end
    end
end

disp('done');
