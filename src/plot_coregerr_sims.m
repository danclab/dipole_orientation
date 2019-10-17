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

files=ls(fullfile(output_dir,sprintf('sim_%s*coreg*.mat',subj_info.subj_id)));
simvertind=[];
for f=1:length(files)
    parts=strsplit(files(f,:),'_');
    v=str2num(parts{4});
    if length(find(simvertind==v))==0
        simvertind(end+1)=v;
    end
end
    

% Get downsampled pial surface
subj_surf_dir=fullfile(params.surf_dir, sprintf('%s-synth', subj_info.subj_id), 'surf');
ds_pial=gifti(fullfile(subj_surf_dir, 'pial.ds.gii'));

% Coregistration error levels to simulate at
%coregerr_levels=[0:.1:1];
coregerr_levels=[0.0 0.2 0.4 0.6 0.8 1.0];
%coregerr_levels=[1:9];

% Randomize simulation vertices
nverts=size(ds_pial.vertices,1);
rng('default');
rng(0);
%simvertind=randperm(nverts);
% Number of locations to simulate at
n_sim_locations=100;

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
        for ori_idx=1:10
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

mean_fvals=squeeze(mean(f_vals,1));
stderr_fvals=squeeze(std(f_vals)./sqrt(n_sim_locations));
angle_diffs=(([1:10]-1)*70/10);

colors=[255,247,251;236,231,242;208,209,230;166,189,219;116,169,207;54,144,192;5,112,176;4,90,141;2,56,88;37,37,37;0,0,0];

figure();
hold all
for coregerr_idx=1:length(coregerr_levels)
    shadedErrorBar(angle_diffs,mean_fvals(coregerr_idx,:),stderr_fvals(coregerr_idx,:),'lineProps',{'color',colors(coregerr_idx,:)./255});    
end
legend(labels);
plot(xlim(),[-3 -3],'k--','HandleVisibility','off');
plot(xlim(),[3 3],'k--','HandleVisibility','off');
ylim([-70 10]);
xlabel('Angular error (deg)');
ylabel('\Delta F');
