function plot_source_activity_example(subjects)

spm('defaults','eeg');

methods={'ds_surf_norm','cps','orig_surf_norm','link_vector','variational'};

subj_whole_erf_dir=fullfile('../../output/data',subjects(1).subj_id,'whole_erf');

peak_verts=[];
ind_max_tcs=[];
ds_max_tcs=[];

fname='pial_mpdots_rcinstr_Tafdf_ds_surf_norm_1_t-2500_-2000_f0_256_1.gii';    
g=gifti(fullfile(subj_whole_erf_dir, fname));
ds_peak_vert=find(g.cdata(:)==max(g.cdata(:)));
    
method_labels={};

for m_idx=1:length(methods)
    method=methods{m_idx};
    method_labels{m_idx}=strrep(method,'_',' ');
    
    fname=sprintf('pial_mpdots_rcinstr_Tafdf_%s_1_t-2500_-2000_f0_256_1.gii', method);    
    g=gifti(fullfile(subj_whole_erf_dir, fname));
    peak_vert=find(g.cdata(:)==max(g.cdata(:)));
    peak_verts(m_idx)=peak_vert;
    
    fname=sprintf('pial_mpdots_rcinstr_Tafdf_%s.mat', method);
    D=spm_eeg_load(fullfile(subj_whole_erf_dir, fname));
    full_times=(D.time--2.4).*1000;
    
    MU=D.inv{1}.inverse.M*D.inv{1}.inverse.U{1};
    megchans=D.indchantype('MEG','good');
    source_tc=MU(peak_vert,:)*squeeze(D(megchans,:,:));
    ind_max_tcs(m_idx,:)=source_tc;
    
    source_tc=MU(ds_peak_vert,:)*squeeze(D(megchans,:,:));
    ds_max_tcs(m_idx,:)=source_tc;
end

dots_peak_coords=[];
dots_peak_vert_dists=[];
dots_ind_max_rmses=[];
dots_ds_max_rmses=[];

instr_peak_coords=[];
instr_peak_vert_dists=[];
instr_ind_max_rmses=[];
instr_ds_max_rmses=[];

resp_peak_coords=[];
resp_peak_vert_dists=[];
resp_ind_max_rmses=[];
resp_ds_max_rmses=[];

for s_idx=1:length(subjects)
    s_idx
    subj_whole_erf_dir=fullfile('../../output/data',subjects(s_idx).subj_id,'whole_erf');
    subj_woi_dir=fullfile('../../output/data',subjects(s_idx).subj_id);
    subj_surf_dir=fullfile('../../../../inProgress/beta_burst_layers/data/surf',sprintf('%s-synth',subjects(s_idx).subj_id),'surf');
    
    subj_pial_inflated_fname=fullfile(subj_surf_dir,'pial.ds.inflated.gii');
    subj_pial_original_fname=fullfile(subj_surf_dir,'pial.gii');
    subj_pial_fname=fullfile(subj_surf_dir,'pial.ds.gii');
    subj_wm_inflated_fname=fullfile(subj_surf_dir,'white.ds.inflated.gii');
    subj_wm_original_fname=fullfile(subj_surf_dir,'white.gii');
    subj_wm_fname=fullfile(subj_surf_dir,'white.ds.gii');
    subj_pial=gifti(subj_pial_fname);

    subj_peak_vert_dists=[];
    subj_peak_verts=[];
    for m_idx=1:length(methods)
        method=methods{m_idx};
        fname=sprintf('pial_mpdots_rcinstr_Tafdf_%s_1_t-2500_-2000_f0_256_1.gii', method);    
        g=gifti(fullfile(subj_whole_erf_dir, fname));
        peak_vert=find(g.cdata(:)==max(g.cdata(:)));
        subj_peak_verts(m_idx)=peak_vert;
        dots_peak_coords(s_idx,m_idx,:)=subj_pial.vertices(peak_vert,:);
    end
    for m_idx1=1:length(methods)
        for m_idx2=1:length(methods)
            dist=sqrt(sum((subj_pial.vertices(subj_peak_verts(m_idx1),:)-subj_pial.vertices(subj_peak_verts(m_idx2),:)).^2,2));
            subj_peak_vert_dists(m_idx1,m_idx2)=dist;
        end
    end
    dots_peak_vert_dists(s_idx,:,:)=subj_peak_vert_dists;
    
    subj_peak_vert_dists=[];
    subj_peak_verts=[];
    for m_idx=1:length(methods)
        method=methods{m_idx};
        fname=sprintf('pial_mpinstr_rcinstr_Tafdf_%s_1_t0_400_f0_256_1.gii', method);    
        g=gifti(fullfile(subj_whole_erf_dir, fname));
        peak_vert=find(g.cdata(:)==max(g.cdata(:)));
        subj_peak_verts(m_idx)=peak_vert;
        instr_peak_coords(s_idx,m_idx,:)=subj_pial.vertices(peak_vert,:);
    end
    for m_idx1=1:length(methods)
        for m_idx2=1:length(methods)
            dist=sqrt(sum((subj_pial.vertices(subj_peak_verts(m_idx1),:)-subj_pial.vertices(subj_peak_verts(m_idx2),:)).^2,2));
            subj_peak_vert_dists(m_idx1,m_idx2)=dist;
        end
    end
    instr_peak_vert_dists(s_idx,:,:)=subj_peak_vert_dists;
    
    subj_peak_vert_dists=[];
    subj_peak_verts=[];
    for m_idx=1:length(methods)
        method=methods{m_idx};
        fname=sprintf('pial_mprcresp_Tafdf_%s_1_t-200_300_f0_256_1.gii', method);    
        g=gifti(fullfile(subj_whole_erf_dir, fname));
        peak_vert=find(g.cdata(:)==max(g.cdata(:)));
        subj_peak_verts(m_idx)=peak_vert;
        resp_peak_coords(s_idx,m_idx,:)=subj_pial.vertices(peak_vert,:);
    end
    for m_idx1=1:length(methods)
        for m_idx2=1:length(methods)
            dist=sqrt(sum((subj_pial.vertices(subj_peak_verts(m_idx1),:)-subj_pial.vertices(subj_peak_verts(m_idx2),:)).^2,2));
            subj_peak_vert_dists(m_idx1,m_idx2)=dist;
        end
    end
    resp_peak_vert_dists(s_idx,:,:)=subj_peak_vert_dists;
    
    subj_ind_max_sses=[];
    subj_ds_max_sses=[];
    subj_ind_max_tcs=[];
    subj_ds_max_tcs=[];
    for m_idx=1:length(methods)
        method=methods{m_idx};
        fname=sprintf('pial_mpdots_rcinstr_Tafdf_%s.mat', method);
        D=spm_eeg_load(fullfile(subj_woi_dir, fname));
    
        MU=D.inv{1}.inverse.M*D.inv{1}.inverse.U{1};
        megchans=D.indchantype('MEG','good');
        source_tc=MU(subj_peak_verts(m_idx),:)*squeeze(D(megchans,:,:));
        subj_ind_max_tcs(m_idx,:)=source_tc;
        
        source_tc=MU(subj_peak_verts(1),:)*squeeze(D(megchans,:,:));
        subj_ds_max_tcs(m_idx,:)=source_tc;
    end
    for m_idx1=1:length(methods)
        for m_idx2=1:length(methods)
            sse=sqrt(sum((subj_ind_max_tcs(m_idx1,:)-subj_ind_max_tcs(m_idx2,:)).^2,2));
            subj_ind_max_sses(m_idx1,m_idx2)=sse;
            
            sse=sqrt(sum((subj_ds_max_tcs(m_idx1,:)-subj_ds_max_tcs(m_idx2,:)).^2,2));
            subj_ds_max_sses(m_idx1,m_idx2)=sse;
        end
    end
    dots_ind_max_rmses(s_idx,:,:)=subj_ind_max_sses;
    dots_ds_max_rmses(s_idx,:,:)=subj_ds_max_sses;
    
    subj_ind_max_sses=[];
    subj_ds_max_sses=[];
    subj_ind_max_tcs=[];
    subj_ds_max_tcs=[];
    for m_idx=1:length(methods)
        method=methods{m_idx};
        fname=sprintf('pial_mpinstr_rcinstr_Tafdf_%s.mat', method);
        D=spm_eeg_load(fullfile(subj_woi_dir, fname));
    
        MU=D.inv{1}.inverse.M*D.inv{1}.inverse.U{1};
        megchans=D.indchantype('MEG','good');
        source_tc=MU(subj_peak_verts(m_idx),:)*squeeze(D(megchans,:,:));
        subj_ind_max_tcs(m_idx,:)=source_tc;
        
        source_tc=MU(subj_peak_verts(1),:)*squeeze(D(megchans,:,:));
        subj_ds_max_tcs(m_idx,:)=source_tc;
    end
    for m_idx1=1:length(methods)
        for m_idx2=1:length(methods)
            sse=sqrt(sum((subj_ind_max_tcs(m_idx1,:)-subj_ind_max_tcs(m_idx2,:)).^2,2));
            subj_ind_max_sses(m_idx1,m_idx2)=sse;
            
            sse=sqrt(sum((subj_ds_max_tcs(m_idx1,:)-subj_ds_max_tcs(m_idx2,:)).^2,2));
            subj_ds_max_sses(m_idx1,m_idx2)=sse;
        end
    end
    instr_ind_max_rmses(s_idx,:,:)=subj_ind_max_sses;
    instr_ds_max_rmses(s_idx,:,:)=subj_ds_max_sses;
    
    subj_ind_max_sses=[];
    subj_ds_max_sses=[];
    subj_ind_max_tcs=[];
    subj_ds_max_tcs=[];
    for m_idx=1:length(methods)
        method=methods{m_idx};
        fname=sprintf('pial_mprcresp_Tafdf_%s.mat', method);
        D=spm_eeg_load(fullfile(subj_woi_dir, fname));
    
        MU=D.inv{1}.inverse.M*D.inv{1}.inverse.U{1};
        megchans=D.indchantype('MEG','good');
        source_tc=MU(subj_peak_verts(m_idx),:)*squeeze(D(megchans,:,:));
        subj_ind_max_tcs(m_idx,:)=source_tc;
        
        source_tc=MU(subj_peak_verts(1),:)*squeeze(D(megchans,:,:));
        subj_ds_max_tcs(m_idx,:)=source_tc;
    end
    for m_idx1=1:length(methods)
        for m_idx2=1:length(methods)
            sse=sqrt(sum((subj_ind_max_tcs(m_idx1,:)-subj_ind_max_tcs(m_idx2,:)).^2,2));
            subj_ind_max_sses(m_idx1,m_idx2)=sse;
            
            sse=sqrt(sum((subj_ds_max_tcs(m_idx1,:)-subj_ds_max_tcs(m_idx2,:)).^2,2));
            subj_ds_max_sses(m_idx1,m_idx2)=sse;
        end
    end
    resp_ind_max_rmses(s_idx,:,:)=subj_ind_max_sses;
    resp_ds_max_rmses(s_idx,:,:)=subj_ds_max_sses;
end
    
plot_coordinates(subjects(1), methods, squeeze(dots_peak_coords(1,:,:)), 'back');

figure();
subplot(3,2,3);
hold all;
for m_idx=1:length(methods)
    plot(full_times,ind_max_tcs(m_idx,:));    
end
xlim([full_times(1) full_times(end)]);
xlabel('Time (ms)');
ylabel('Source amp');
legend(method_labels);

subplot(3,2,5);
hold all;
for m_idx=1:length(methods)
    plot(full_times,ds_max_tcs(m_idx,:));    
end
xlim([full_times(1) full_times(end)]);
xlabel('Time (ms)');
ylabel('Source amp');
legend(method_labels);

ax=subplot(3,2,1);
plot_coordinates(subjects(1), methods, squeeze(dots_peak_coords(1,:,:)), 'back', 'ax', ax);

subplot(3,4,3);
all_peak_verts=zeros(length(subjects),3,length(methods),length(methods));
all_peak_verts(:,1,:,:)=dots_peak_vert_dists;
all_peak_verts(:,2,:,:)=instr_peak_vert_dists;
all_peak_verts(:,3,:,:)=resp_peak_vert_dists;
all_peak_verts=squeeze(mean(all_peak_verts,2));
mean_dists=squeeze(mean(all_peak_verts));
min_mean_dist=min(mean_dists(mean_dists(:)>0));
max_mean_dist=max(mean_dists(mean_dists(:)>0));
disp(sprintf('Dists=%.4f-%.4fmm', min_mean_dist, max_mean_dist));
imagesc(mean_dists);
clim=get(gca,'clim');
axis square;
set(gca,'Xtick',[1:length(methods)],'YtickLabel',method_labels);
set(gca,'Xtick',[1:length(methods)],'XtickLabel',method_labels,'XTickLabelRotation',45);
colorbar();

subplot(3,4,4);
imagesc(squeeze(std(all_peak_verts)));
set(gca,'clim',clim);
axis square;
set(gca,'Xtick',[1:length(methods)],'YtickLabel',method_labels);
set(gca,'Xtick',[1:length(methods)],'XtickLabel',method_labels,'XTickLabelRotation',45);
colorbar();

subplot(3,4,7);
all_ind_max_rmses=zeros(length(subjects),3,length(methods),length(methods));
all_ind_max_rmses(:,1,:,:)=dots_ind_max_rmses;
all_ind_max_rmses(:,2,:,:)=instr_ind_max_rmses;
all_ind_max_rmses(:,3,:,:)=resp_ind_max_rmses;
all_ind_max_rmses=squeeze(mean(all_ind_max_rmses,2));
imagesc(squeeze(mean(all_ind_max_rmses)));
mean_clim=get(gca,'clim');
axis square;
set(gca,'Xtick',[1:length(methods)],'YtickLabel',method_labels);
set(gca,'Xtick',[1:length(methods)],'XtickLabel',method_labels,'XTickLabelRotation',45);
colorbar();

subplot(3,4,8);
imagesc(squeeze(std(all_ind_max_rmses)));
set(gca,'clim',mean_clim);
axis square;
set(gca,'Xtick',[1:length(methods)],'YtickLabel',method_labels);
set(gca,'Xtick',[1:length(methods)],'XtickLabel',method_labels,'XTickLabelRotation',45);
colorbar();

subplot(3,4,11);
all_ds_max_rmses=zeros(length(subjects),3,length(methods),length(methods));
all_ds_max_rmses(:,1,:,:)=dots_ds_max_rmses;
all_ds_max_rmses(:,2,:,:)=instr_ds_max_rmses;
all_ds_max_rmses(:,3,:,:)=resp_ds_max_rmses;
all_ds_max_rmses=squeeze(mean(all_ds_max_rmses,2));
imagesc(squeeze(mean(all_ds_max_rmses)));
set(gca,'clim',mean_clim);
axis square;
set(gca,'Xtick',[1:length(methods)],'YtickLabel',method_labels);
set(gca,'Xtick',[1:length(methods)],'XtickLabel',method_labels,'XTickLabelRotation',45);
colorbar();

subplot(3,4,12);
imagesc(squeeze(std(all_ds_max_rmses)));
set(gca,'clim',mean_clim);
axis square;
set(gca,'Xtick',[1:length(methods)],'YtickLabel',method_labels);
set(gca,'Xtick',[1:length(methods)],'XtickLabel',method_labels,'XTickLabelRotation',45);
colorbar();