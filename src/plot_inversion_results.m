function plot_inversion_results(subj_info, stim, evt, woi, varargin)

defaults = struct('surf_dir', '../../beta_burst_layers/data/surf','mpm_surfs', true);  %define default values
params = struct(varargin{:});
for f = fieldnames(defaults)',  
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

view='back';
if strcmp(stim,'resp')
    view='topdown';
end

% Subject surfaces
if params.mpm_surfs
    subj_surf_dir=fullfile(params.surf_dir, sprintf('%s-synth',...
        subj_info.subj_id),'surf');
else
    subj_surf_dir=fullfile(params.surf_dir, subj_info.subj_id,'surf');
end
pial_fname=fullfile(subj_surf_dir,'pial.ds.inflated.gii');

pial=gifti(pial_fname);

if strcmp(stim,'resp')
    ds_surf_norm_results=gifti(fullfile('../output/data',subj_info.subj_id,...
        sprintf('pial_mprc%s_Tafdf_ds_surf_norm_1_t%d_%d_f0_256_1.gii', stim, woi(1), woi(2))));

    orig_surf_norm_results=gifti(fullfile('../output/data',subj_info.subj_id,...
        sprintf('pial_mprc%s_Tafdf_orig_surf_norm_1_t%d_%d_f0_256_1.gii', stim, woi(1), woi(2))));

    link_vector_results=gifti(fullfile('../output/data',subj_info.subj_id,...
        sprintf('pial_mprc%s_Tafdf_link_vector_1_t%d_%d_f0_256_1.gii', stim, woi(1), woi(2))));

    anat_link_results=gifti(fullfile('../output/data',subj_info.subj_id,...
        sprintf('pial_mprc%s_Tafdf_fs_anat_link_1_t%d_%d_f0_256_1.gii', stim, woi(1), woi(2))));
else
    ds_surf_norm_results=gifti(fullfile('../output/data',subj_info.subj_id,...
        sprintf('pial_mp%s_rc%s_Tafdf_ds_surf_norm_1_t%d_%d_f0_256_1.gii', stim, evt, woi(1), woi(2))));

    orig_surf_norm_results=gifti(fullfile('../output/data',subj_info.subj_id,...
        sprintf('pial_mp%s_rc%s_Tafdf_orig_surf_norm_1_t%d_%d_f0_256_1.gii', stim, evt, woi(1), woi(2))));

    link_vector_results=gifti(fullfile('../output/data',subj_info.subj_id,...
        sprintf('pial_mp%s_rc%s_Tafdf_link_vector_1_t%d_%d_f0_256_1.gii', stim, evt, woi(1), woi(2))));

    anat_link_results=gifti(fullfile('../output/data',subj_info.subj_id,...
        sprintf('pial_mp%s_rc%s_Tafdf_fs_anat_link_1_t%d_%d_f0_256_1.gii', stim, evt, woi(1), woi(2))));
end

max_abs=max([max(abs(log10(ds_surf_norm_results.cdata(:)))) max(abs(log10(orig_surf_norm_results.cdata(:)))) max(abs(log10(link_vector_results.cdata(:)))) max(abs(log10(anat_link_results.cdata(:))))]);
limits=[-max_abs max_abs];

% fig=figure('Position',[1 1 1900 400],'PaperUnits','points',...
%     'PaperPosition',[1 1 900 200],'PaperPositionMode','manual');
% 
% ax=subplot(1,4,1);
% [ax,~]=plot_surface_metric(pial, log10(ds_surf_norm_results.cdata(:)), 'ax', ax,...
%     'clip_vals', false, 'limits', limits);
% set(ax,'CameraViewAngle',6.028);
% set(ax,'CameraUpVector',subj_info.camera_up_vector(view));
% set(ax,'CameraPosition',subj_info.camera_position(view));
% %freezeColors;
% 
% ax=subplot(1,4,2);
% [ax,~]=plot_surface_metric(pial, log10(orig_surf_norm_results.cdata(:)), 'ax', ax,...
%     'clip_vals', false, 'limits', limits);
% set(ax,'CameraViewAngle',6.028);
% set(ax,'CameraUpVector',subj_info.camera_up_vector(view));
% set(ax,'CameraPosition',subj_info.camera_position(view));
% %freezeColors;
% 
% ax=subplot(1,4,3);
% [ax,~]=plot_surface_metric(pial, log10(link_vector_results.cdata(:)), 'ax', ax,...
%     'clip_vals', true, 'limits', limits);
% set(ax,'CameraViewAngle',6.028);
% set(ax,'CameraUpVector',subj_info.camera_up_vector(view));
% set(ax,'CameraPosition',subj_info.camera_position(view));
% %freezeColors;
% 
% ax=subplot(1,4,4);
% [ax,~]=plot_surface_metric(pial, log10(anat_link_results.cdata(:)), 'ax', ax,...
%     'clip_vals', true, 'limits', limits);
% set(ax,'CameraViewAngle',6.028);
% set(ax,'CameraUpVector',subj_info.camera_up_vector(view));
% set(ax,'CameraPosition',subj_info.camera_position(view));
% %freezeColors;
% 
[ax,~]=plot_surface_metric(pial, link_vector_results.cdata(:)-ds_surf_norm_results.cdata(:),...
    'clip_vals', false);
set(ax,'CameraViewAngle',6.028);
set(ax,'CameraUpVector',subj_info.camera_up_vector(view));
set(ax,'CameraPosition',subj_info.camera_position(view));

% ds_surf_norm_max_v_idx=find(ds_surf_norm_results.cdata(:)==max(ds_surf_norm_results.cdata(:)));
% orig_surf_norm_max_v_idx=find(orig_surf_norm_results.cdata(:)==max(orig_surf_norm_results.cdata(:)));
% link_vector_max_v_idx=find(link_vector_results.cdata(:)==max(link_vector_results.cdata(:)));
% anat_link_max_v_idx=find(anat_link_results.cdata(:)==max(anat_link_results.cdata(:)));
% disp('');

% vertices=[pial.vertices(ds_surf_norm_max_v_idx,:);
%     pial.vertices(orig_surf_norm_max_v_idx,:);
%     pial.vertices(link_vector_max_v_idx,:);
%     pial.vertices(anat_link_max_v_idx,:)];
% ax=plot_surface_coordinates(pial, vertices,[53 42 134;6 156 207;165 190 106;248 250 13]./255.0,'coord_radius',1);
% set(ax,'CameraViewAngle',6.028);
% set(ax,'CameraUpVector',subj_info.camera_up_vector(view));
% set(ax,'CameraPosition',subj_info.camera_position(view));

if strcmp(stim,'resp')
    D=spm_eeg_load(fullfile('..\output\data',subj_info.subj_id,sprintf('pial_mprc%s_Tafdf_ds_surf_norm.mat',evt)));
    MU=D.inv{1}.inverse.M*D.inv{1}.inverse.U{1};
    chans=D.indchantype('MEG','good');
    ds_surf_norm_data=MU*squeeze(D(chans,:,1));

    D=spm_eeg_load(fullfile('..\output\data',subj_info.subj_id,sprintf('pial_mprc%s_Tafdf_orig_surf_norm.mat',evt)));
    MU=D.inv{1}.inverse.M*D.inv{1}.inverse.U{1};
    chans=D.indchantype('MEG','good');
    orig_surf_norm_data=MU*squeeze(D(chans,:,1));

    D=spm_eeg_load(fullfile('..\output\data',subj_info.subj_id,sprintf('pial_mprc%s_Tafdf_link_vector.mat',evt)));
    MU=D.inv{1}.inverse.M*D.inv{1}.inverse.U{1};
    chans=D.indchantype('MEG','good');
    link_vector_data=MU*squeeze(D(chans,:,1));

    D=spm_eeg_load(fullfile('..\output\data',subj_info.subj_id,sprintf('pial_mprc%s_Tafdf_fs_anat_link.mat',evt)));
    MU=D.inv{1}.inverse.M*D.inv{1}.inverse.U{1};
    chans=D.indchantype('MEG','good');
    fs_anat_link_data=MU*squeeze(D(chans,:,1));
else
    D=spm_eeg_load(fullfile('..\output\data',subj_info.subj_id,sprintf('pial_mp%s_rc%s_Tafdf_ds_surf_norm.mat',stim,evt)));
    MU=D.inv{1}.inverse.M*D.inv{1}.inverse.U{1};
    chans=D.indchantype('MEG','good');
    ds_surf_norm_data=MU*squeeze(D(chans,:,1));

    D=spm_eeg_load(fullfile('..\output\data',subj_info.subj_id,sprintf('pial_mp%s_rc%s_Tafdf_orig_surf_norm.mat',stim,evt)));
    MU=D.inv{1}.inverse.M*D.inv{1}.inverse.U{1};
    chans=D.indchantype('MEG','good');
    orig_surf_norm_data=MU*squeeze(D(chans,:,1));

    D=spm_eeg_load(fullfile('..\output\data',subj_info.subj_id,sprintf('pial_mp%s_rc%s_Tafdf_link_vector.mat',stim,evt)));
    MU=D.inv{1}.inverse.M*D.inv{1}.inverse.U{1};
    chans=D.indchantype('MEG','good');
    link_vector_data=MU*squeeze(D(chans,:,1));

    D=spm_eeg_load(fullfile('..\output\data',subj_info.subj_id,sprintf('pial_mp%s_rc%s_Tafdf_fs_anat_link.mat',stim,evt)));
    MU=D.inv{1}.inverse.M*D.inv{1}.inverse.U{1};
    chans=D.indchantype('MEG','good');
    fs_anat_link_data=MU*squeeze(D(chans,:,1));
end

%ds_surf_norm_peak_vtx=find(var(ds_surf_norm_data,[],2)==max(var(ds_surf_norm_data,[],2)));
[ds_surf_norm_peak_vtx,~]=find(abs(ds_surf_norm_data)==max(abs(ds_surf_norm_data(:))));
%orig_surf_norm_peak_vtx=find(var(orig_surf_norm_data,[],2)==max(var(orig_surf_norm_data,[],2)));
[orig_surf_norm_peak_vtx,~]=find(abs(orig_surf_norm_data)==max(abs(orig_surf_norm_data(:))));
%link_vector_peak_vtx=find(var(link_vector_data,[],2)==max(var(link_vector_data,[],2)));
[link_vector_peak_vtx,~]=find(abs(link_vector_data)==max(abs(link_vector_data(:))));
%fs_anat_link_peak_vtx=find(var(fs_anat_link_data,[],2)==max(var(fs_anat_link_data,[],2)));
[fs_anat_link_peak_vtx,~]=find(abs(fs_anat_link_data)==max(abs(fs_anat_link_data(:))));

% vertices=[pial.vertices(ds_surf_norm_peak_vtx,:);
%     pial.vertices(orig_surf_norm_peak_vtx,:);
%     pial.vertices(link_vector_peak_vtx,:);
%     pial.vertices(fs_anat_link_peak_vtx,:)];
% ax=plot_surface_coordinates(pial, vertices,[53 42 134;6 156 207;165 190 106;248 250 13]./255.0,'coord_radius',1);
% set(ax,'CameraViewAngle',6.028);
% set(ax,'CameraUpVector',subj_info.camera_up_vector(view));
% set(ax,'CameraPosition',subj_info.camera_position(view));

figure();
hold all
plot(D.time,ds_surf_norm_data(ds_surf_norm_peak_vtx,:),'Color',[53 42 134]./255.0);
plot(D.time,orig_surf_norm_data(ds_surf_norm_peak_vtx,:),'Color',[6 156 207]./255.0);
plot(D.time,link_vector_data(ds_surf_norm_peak_vtx,:),'Color',[165 190 106]./255.0);
plot(D.time,fs_anat_link_data(ds_surf_norm_peak_vtx,:),'Color',[248 250 13]./255.0);
legend('ds surf norm','orig surf norm','link vector','variational vector field');
xlabel('Time (s)');

figure();
hold all
plot(D.time,ds_surf_norm_data(link_vector_peak_vtx,:),'Color',[53 42 134]./255.0);
plot(D.time,orig_surf_norm_data(link_vector_peak_vtx,:),'Color',[6 156 207]./255.0);
plot(D.time,link_vector_data(link_vector_peak_vtx,:),'Color',[165 190 106]./255.0);
plot(D.time,fs_anat_link_data(link_vector_peak_vtx,:),'Color',[248 250 13]./255.0);
legend('ds surf norm','orig surf norm','link vector','variational vector field');
xlabel('Time (s)');