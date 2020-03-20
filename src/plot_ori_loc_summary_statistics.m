function plot_ori_loc_summary_statistics(surf_type)

ori_surfaces={'pial','white','white-pial'};
loc_surfaces={'pial','white','white-pial'};
surf_colors=[195 31 75; 60 118 188; 121 118 188]./255.0;
methods={'ds_surf_norm','cps','orig_surf_norm','link_vector','variational'};

all_dots_fvals=NaN(8,length(ori_surfaces),length(loc_surfaces),length(methods));
all_instr_fvals=NaN(8,length(ori_surfaces),length(loc_surfaces),length(methods));
all_resp_fvals=NaN(8,length(ori_surfaces),length(loc_surfaces),length(methods));
dots_cond_vals={};
instr_cond_vals={};
resp_cond_vals={};

for ori_surf_idx=1:length(ori_surfaces)
    ori_surface=ori_surfaces{ori_surf_idx}
    
    for loc_surf_idx=1:length(loc_surfaces)
        loc_surface=loc_surfaces{loc_surf_idx}     
        
        if strcmp(ori_surface,loc_surface)
            result_path=fullfile('../output',loc_surface,'visual_erf',sprintf('%s_surfs',surf_type));
            load(fullfile(result_path, 'dots_results.mat'));            
            for m_idx=1:length(methods)
                idx=find(strcmp(results.methods,methods{m_idx}));
                all_dots_fvals(:,ori_surf_idx,loc_surf_idx,m_idx)=results.fvals(:,idx);
                dots_cond_vals{ori_surf_idx,loc_surf_idx,m_idx}=sprintf('%s %s %s', ori_surfaces{ori_surf_idx}, loc_surfaces{loc_surf_idx}, methods{m_idx});
            end
            
            load(fullfile(result_path, 'instr_results.mat'));
            for m_idx=1:length(methods)
                idx=find(strcmp(results.methods,methods{m_idx}));
                all_instr_fvals(:,ori_surf_idx,loc_surf_idx,m_idx)=results.fvals(:,idx);
                instr_cond_vals{ori_surf_idx,loc_surf_idx,m_idx}=sprintf('%s %s %s', ori_surfaces{ori_surf_idx}, loc_surfaces{loc_surf_idx}, methods{m_idx});
            end
            
            result_path=fullfile('../output',loc_surface,'motor_erf', sprintf('%s_surfs',surf_type));
            load(fullfile(result_path, 'resp_results.mat'));
            for m_idx=1:length(methods)
                idx=find(strcmp(results.methods,methods{m_idx}));
                all_resp_fvals(:,ori_surf_idx,loc_surf_idx,m_idx)=results.fvals(:,idx);
                resp_cond_vals{ori_surf_idx,loc_surf_idx,m_idx}=sprintf('%s %s %s', ori_surfaces{ori_surf_idx}, loc_surfaces{loc_surf_idx}, methods{m_idx});
            end
            
        elseif ~strcmp(ori_surface,'white-pial')
            
            result_path=fullfile('../output',loc_surface,'visual_erf',sprintf('%s_surfs',surf_type));
            load(fullfile(result_path, sprintf('ori_%s.loc_%s.dots_results.mat',ori_surface,loc_surface)));
            for m_idx=1:length(methods)
                idx=find(strcmp(results.methods,methods{m_idx}));
                all_dots_fvals(:,ori_surf_idx,loc_surf_idx,m_idx)=results.fvals(:,idx);
                dots_cond_vals{ori_surf_idx,loc_surf_idx,m_idx}=sprintf('%s %s %s', ori_surfaces{ori_surf_idx}, loc_surfaces{loc_surf_idx}, methods{m_idx});
            end
            
            load(fullfile(result_path, sprintf('ori_%s.loc_%s.instr_results.mat',ori_surface,loc_surface)));
            for m_idx=1:length(methods)
                idx=find(strcmp(results.methods,methods{m_idx}));
                all_instr_fvals(:,ori_surf_idx,loc_surf_idx,m_idx)=results.fvals(:,idx);
                instr_cond_vals{ori_surf_idx,loc_surf_idx,m_idx}=sprintf('%s %s %s', ori_surfaces{ori_surf_idx}, loc_surfaces{loc_surf_idx}, methods{m_idx});
            end
            
            result_path=fullfile('../output',loc_surface,'motor_erf', sprintf('%s_surfs',surf_type));
            load(fullfile(result_path, sprintf('ori_%s.loc_%s.resp_results.mat',ori_surface,loc_surface)));
            for m_idx=1:length(methods)
                idx=find(strcmp(results.methods,methods{m_idx}));
                all_resp_fvals(:,ori_surf_idx,loc_surf_idx,m_idx)=results.fvals(:,idx);
                resp_cond_vals{ori_surf_idx,loc_surf_idx,m_idx}=sprintf('%s %s %s', ori_surfaces{ori_surf_idx}, loc_surfaces{loc_surf_idx}, methods{m_idx});
            end
            
        else
            for m_idx=1:length(methods)
                idx=find(strcmp(results.methods,methods{m_idx}));
                dots_cond_vals{ori_surf_idx,loc_surf_idx,m_idx}=sprintf('%s %s %s', ori_surfaces{ori_surf_idx}, loc_surfaces{loc_surf_idx}, methods{m_idx});
            end
            
            for m_idx=1:length(methods)
                idx=find(strcmp(results.methods,methods{m_idx}));
                instr_cond_vals{ori_surf_idx,loc_surf_idx,m_idx}=sprintf('%s %s %s', ori_surfaces{ori_surf_idx}, loc_surfaces{loc_surf_idx}, methods{m_idx});
            end
            
            for m_idx=1:length(methods)
                idx=find(strcmp(results.methods,methods{m_idx}));
                resp_cond_vals{ori_surf_idx,loc_surf_idx,m_idx}=sprintf('%s %s %s', ori_surfaces{ori_surf_idx}, loc_surfaces{loc_surf_idx}, methods{m_idx});
            end
        end
    end
end

for m_idx=1:length(methods)
    figure();
    subplot(1,3,1);
    imagesc(squeeze(mean(all_dots_fvals(:,:,:,m_idx))));
    set(gca,'ydir','normal')
    set(gca,'XTick',1:numel(loc_surfaces))
    set(gca,'XTickLabel',loc_surfaces);
    set(gca,'YTick',1:numel(ori_surfaces))
    set(gca,'YTickLabel',ori_surfaces);

    subplot(1,3,2);
    imagesc(squeeze(mean(all_instr_fvals(:,:,:,m_idx))));
    set(gca,'ydir','normal')
    set(gca,'XTick',1:numel(loc_surfaces))
    set(gca,'XTickLabel',loc_surfaces);
    set(gca,'YTick',1:numel(ori_surfaces))
    set(gca,'YTickLabel',ori_surfaces);

    subplot(1,3,3);
    imagesc(squeeze(mean(all_resp_fvals(:,:,:,m_idx))));
    set(gca,'ydir','normal')
    set(gca,'XTick',1:numel(loc_surfaces))
    set(gca,'XTickLabel',loc_surfaces);
    set(gca,'YTick',1:numel(ori_surfaces))
    set(gca,'YTickLabel',ori_surfaces);

    dots_fvals=reshape(squeeze(all_dots_fvals(:,:,:,m_idx)),size(all_dots_fvals,1),length(ori_surfaces)*length(loc_surfaces));
    instr_fvals=reshape(squeeze(all_instr_fvals(:,:,:,m_idx)),size(all_instr_fvals,1),length(ori_surfaces)*length(loc_surfaces));
    resp_fvals=reshape(squeeze(all_resp_fvals(:,:,:,m_idx)),size(all_resp_fvals,1),length(ori_surfaces)*length(loc_surfaces));
    fvals=[dots_fvals instr_fvals resp_fvals];
    data_labels=[reshape(dots_cond_vals(:,:,m_idx),1,length(ori_surfaces)*length(loc_surfaces)) reshape(instr_cond_vals(:,:,m_idx),1,length(ori_surfaces)*length(loc_surfaces)) reshape(resp_cond_vals(:,:,m_idx),1,length(ori_surfaces)*length(loc_surfaces))];
    for i=1:length(data_labels)
        parts=strsplit(data_labels{i}, ' ');
        data_labels{i}=sprintf('%s %s', parts{1}, parts{2});
    end
    keep_cols=find(all(~isnan(fvals),1));
    fvals=fvals(:,keep_cols);
    data_labels=data_labels(keep_cols);
    twoway_family('orientation', ori_surfaces, surf_colors,...
        'location', loc_surfaces, surf_colors, fvals, data_labels)
end

dots_fvals=reshape(squeeze(all_dots_fvals(:,:,:,:)),size(all_dots_fvals,1),length(ori_surfaces)*length(loc_surfaces)*length(methods));
instr_fvals=reshape(squeeze(all_instr_fvals(:,:,:,:)),size(all_instr_fvals,1),length(ori_surfaces)*length(loc_surfaces)*length(methods));
resp_fvals=reshape(squeeze(all_resp_fvals(:,:,:,:)),size(all_resp_fvals,1),length(ori_surfaces)*length(loc_surfaces)*length(methods));
fvals=[dots_fvals instr_fvals resp_fvals];
data_labels=[reshape(dots_cond_vals(:,:,:),1,length(ori_surfaces)*length(loc_surfaces)*length(methods)) reshape(instr_cond_vals(:,:,:),1,length(ori_surfaces)*length(loc_surfaces)*length(methods)) reshape(resp_cond_vals(:,:,:),1,length(ori_surfaces)*length(loc_surfaces)*length(methods))];
for i=1:length(data_labels)
    parts=strsplit(data_labels{i}, ' ');
    data_labels{i}=sprintf('%s %s', parts{1}, parts{2});
end
keep_cols=find(all(~isnan(fvals),1));
fvals=fvals(:,keep_cols);
data_labels=data_labels(keep_cols);
twoway_family('orientation', ori_surfaces, surf_colors,...
    'location', loc_surfaces, surf_colors, fvals, data_labels)

figure();
colors=get(gca,'ColorOrder');
ax=subplot(3,1,1);
dots_fvals=reshape(squeeze(all_dots_fvals(:,:,:,:)),size(all_dots_fvals,1),length(ori_surfaces)*length(loc_surfaces)*length(methods));
instr_fvals=reshape(squeeze(all_instr_fvals(:,:,:,:)),size(all_instr_fvals,1),length(ori_surfaces)*length(loc_surfaces)*length(methods));
resp_fvals=reshape(squeeze(all_resp_fvals(:,:,:,:)),size(all_resp_fvals,1),length(ori_surfaces)*length(loc_surfaces)*length(methods));
fvals=[dots_fvals instr_fvals resp_fvals];
data_labels=[reshape(dots_cond_vals(:,:,:),1,length(ori_surfaces)*length(loc_surfaces)*length(methods)) reshape(instr_cond_vals(:,:,:),1,length(ori_surfaces)*length(loc_surfaces)*length(methods)) reshape(resp_cond_vals(:,:,:),1,length(ori_surfaces)*length(loc_surfaces)*length(methods))];
for i=1:length(data_labels)
    parts=strsplit(data_labels{i}, ' ');
    data_labels{i}=parts{1};
end
keep_cols=find(all(~isnan(fvals),1));
fvals=fvals(:,keep_cols);
data_labels=data_labels(keep_cols);
oneway_family('orientation', ori_surfaces, surf_colors, fvals, data_labels, 'ax', ax);

ax=subplot(3,1,2);
dots_fvals=reshape(squeeze(all_dots_fvals(:,:,:,:)),size(all_dots_fvals,1),length(ori_surfaces)*length(loc_surfaces)*length(methods));
instr_fvals=reshape(squeeze(all_instr_fvals(:,:,:,:)),size(all_instr_fvals,1),length(ori_surfaces)*length(loc_surfaces)*length(methods));
resp_fvals=reshape(squeeze(all_resp_fvals(:,:,:,:)),size(all_resp_fvals,1),length(ori_surfaces)*length(loc_surfaces)*length(methods));
fvals=[dots_fvals instr_fvals resp_fvals];
data_labels=[reshape(dots_cond_vals(:,:,:),1,length(ori_surfaces)*length(loc_surfaces)*length(methods)) reshape(instr_cond_vals(:,:,:),1,length(ori_surfaces)*length(loc_surfaces)*length(methods)) reshape(resp_cond_vals(:,:,:),1,length(ori_surfaces)*length(loc_surfaces)*length(methods))];
for i=1:length(data_labels)
    parts=strsplit(data_labels{i}, ' ');
    data_labels{i}=parts{2};
end
keep_cols=find(all(~isnan(fvals),1));
fvals=fvals(:,keep_cols);
data_labels=data_labels(keep_cols);
oneway_family('location', loc_surfaces, surf_colors, fvals, data_labels, 'ax', ax);

ax=subplot(3,1,3);
dots_fvals=reshape(squeeze(all_dots_fvals(:,:,:,:)),size(all_dots_fvals,1),length(ori_surfaces)*length(loc_surfaces)*length(methods));
instr_fvals=reshape(squeeze(all_instr_fvals(:,:,:,:)),size(all_instr_fvals,1),length(ori_surfaces)*length(loc_surfaces)*length(methods));
resp_fvals=reshape(squeeze(all_resp_fvals(:,:,:,:)),size(all_resp_fvals,1),length(ori_surfaces)*length(loc_surfaces)*length(methods));
fvals=[dots_fvals instr_fvals resp_fvals];
data_labels=[reshape(dots_cond_vals(:,:,:),1,length(ori_surfaces)*length(loc_surfaces)*length(methods)) reshape(instr_cond_vals(:,:,:),1,length(ori_surfaces)*length(loc_surfaces)*length(methods)) reshape(resp_cond_vals(:,:,:),1,length(ori_surfaces)*length(loc_surfaces)*length(methods))];
for i=1:length(data_labels)
    parts=strsplit(data_labels{i}, ' ');
    data_labels{i}=parts{3};
end
keep_cols=find(all(~isnan(fvals),1));
fvals=fvals(:,keep_cols);
data_labels=data_labels(keep_cols);
oneway_family('method', methods, colors, fvals, data_labels, 'ax', ax);



for surf_idx=1:length(loc_surfaces)
    dots_fvals=reshape(squeeze(all_dots_fvals(:,:,surf_idx,:)),size(all_dots_fvals,1),length(ori_surfaces)*length(methods));
    instr_fvals=reshape(squeeze(all_instr_fvals(:,:,surf_idx,:)),size(all_instr_fvals,1),length(ori_surfaces)*length(methods));
    resp_fvals=reshape(squeeze(all_resp_fvals(:,:,surf_idx,:)),size(all_resp_fvals,1),length(ori_surfaces)*length(methods));
    fvals=[dots_fvals instr_fvals resp_fvals];
    data_labels=[reshape(dots_cond_vals(:,surf_idx,:),1,length(ori_surfaces)*length(methods)) reshape(instr_cond_vals(:,surf_idx,:),1,length(ori_surfaces)*length(methods)) reshape(resp_cond_vals(:,surf_idx,:),1,length(ori_surfaces)*length(methods))];
    for i=1:length(data_labels)
        parts=strsplit(data_labels{i}, ' ');
        data_labels{i}=sprintf('%s %s', parts{1}, parts{3});
    end
    keep_cols=find(all(~isnan(fvals),1));
    fvals=fvals(:,keep_cols);
    data_labels=data_labels(keep_cols);
    twoway_family('orientation', ori_surfaces, surf_colors,...
        'method', methods, colors, fvals, data_labels)
end



for surf_idx=1:length(ori_surfaces)
    dots_fvals=reshape(squeeze(all_dots_fvals(:,surf_idx,:,:)),size(all_dots_fvals,1),length(loc_surfaces)*length(methods));
    instr_fvals=reshape(squeeze(all_instr_fvals(:,surf_idx,:,:)),size(all_instr_fvals,1),length(loc_surfaces)*length(methods));
    resp_fvals=reshape(squeeze(all_resp_fvals(:,surf_idx,:,:)),size(all_resp_fvals,1),length(loc_surfaces)*length(methods));
    fvals=[dots_fvals instr_fvals resp_fvals];
    data_labels=[reshape(dots_cond_vals(surf_idx,:,:),1,length(loc_surfaces)*length(methods)) reshape(instr_cond_vals(surf_idx,:,:),1,length(loc_surfaces)*length(methods)) reshape(resp_cond_vals(surf_idx,:,:),1,length(loc_surfaces)*length(methods))];
    for i=1:length(data_labels)
        parts=strsplit(data_labels{i}, ' ');
        data_labels{i}=sprintf('%s %s', parts{2}, parts{3});
    end
    keep_cols=find(all(~isnan(fvals),1));
    fvals=fvals(:,keep_cols);
    data_labels=data_labels(keep_cols);
    twoway_family('location', loc_surfaces, surf_colors,...
        'method', methods, colors, fvals, data_labels)
end
