function plot_coregerr_sims(subj_info, varargin)
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

% Coregistration error levels to simulate at
%coregerr_levels=[0:.1:1];
coregerr_levels=[0:.1:.1];

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
    % For each coregistration error level
    for c_idx=1:length(coregerr_levels)
        coregerr=coregerr_levels(c_idx);
                
        % Invert at 10 different orientations
        %for ori_idx=1:10
        for ori_idx=1:8
            load(fullfile(output_dir, sprintf('sim_%s_vertex_%d_ori_idx_%d_coregerr_%d.mat',...
                subj_info.subj_id, sim_vertex, ori_idx, coregerr)));
            f_vals(v_idx,c_idx,ori_idx)=results.F;
        end
    end
end

labels={};
for c_idx=1:length(coregerr_levels)
    err=round(coregerr_levels(c_idx)*10);
    labels{c_idx}=sprintf('%dmm-%ddeg',err,err);
end

for v_idx=1:n_sim_locations
    % For each coregistration error level
    for c_idx=1:length(coregerr_levels)
        f_vals(v_idx,c_idx,:)=f_vals(v_idx,c_idx,:)-f_vals(v_idx,c_idx,1);
    end
end

f_vals=squeeze(mean(f_vals,1));

figure();
hold all
for c_idx=1:length(coregerr_levels)
    %plot((([1:10]-1)*70/10),f_vals(c_idx,:));
    plot((([1:8]-1)*70/10),f_vals(c_idx,:));
end
legend(labels);
disp('done');
