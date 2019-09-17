function plot_snr_sims(subj_info, varargin)
% % % defaults = struct('base_dir','../data',...
% % %     'surf_dir', '../../beta_burst_layers/data/surf',...
% % %     'mri_dir', '../../beta_burst_layers/data/mri');  %define default values
defaults = struct('base_dir','../data',...
    'surf_dir', '../data/surf');  %define default values
params = struct(varargin{:});
for f = fieldnames(defaults)',  
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

spm('defaults', 'EEG');
spm_jobman('initcfg');

output_dir='../output/data/sim';

% Get downsampled pial surface
subj_surf_dir=fullfile(params.surf_dir, sprintf('%s-synth', subj_info.subj_id), 'surf');
ds_pial=gifti(fullfile(subj_surf_dir, 'pial.ds.gii'));

% SNR levels to simulate at
snr_levels=[-50 -40 -30 -20 -10 0];

% Randomize simulation vertices
nverts=size(ds_pial.vertices,1);
rng('default');
rng(0);
simvertind=randperm(nverts);
% Number of locations to simulate at
n_sim_locations=1;

f_vals=[];

% For each simulation location
for v_idx=1:n_sim_locations
    % Get vertex and normal vector
    sim_vertex=simvertind(v_idx);
    
    % For each SNR level
    for snr_idx=1:length(snr_levels)
        snr=snr_levels(snr_idx);
                
        % Invert at 10 different orientations
        for ori_idx=1:10
            load(fullfile(output_dir, sprintf('sim_%s_vertex_%d_ori_idx_%d_snr_%d.mat',...
                subj_info.subj_id, sim_vertex, ori_idx, snr)));
            f_vals(v_idx,snr_idx,ori_idx)=results.F;
        end
    end
end

for v_idx=1:n_sim_locations
    % For each SNR level
    for snr_idx=1:length(snr_levels)
        f_vals(v_idx,snr_idx,:)=f_vals(v_idx,snr_idx,:)-f_vals(v_idx,snr_idx,1);
    end
end

f_vals=squeeze(mean(f_vals,1));

figure();
hold all
for snr_idx=1:length(snr_levels)
    plot((([1:10]-1)*70/10),f_vals(snr_idx,:));
end
disp('done');
