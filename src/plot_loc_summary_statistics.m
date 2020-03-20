function plot_loc_summary_statistics(surf_type)

surfaces={'pial','white','white-pial'};
surf_colors=[195 31 75; 60 118 188; 121 118 188]./255.0;
methods={'ds_surf_norm','cps','orig_surf_norm','link_vector','variational'};

all_dots_loc_fvals=NaN(8,length(surfaces),length(methods));
all_instr_loc_fvals=NaN(8,length(surfaces),length(methods));
all_resp_loc_fvals=NaN(8,length(surfaces),length(methods));
all_dots_fvals=NaN(8,length(surfaces),length(methods));
all_instr_fvals=NaN(8,length(surfaces),length(methods));
all_resp_fvals=NaN(8,length(surfaces),length(methods));
dots_loc_cond_vals={};
instr_loc_cond_vals={};
resp_loc_cond_vals={};
dots_cond_vals={};
instr_cond_vals={};
resp_cond_vals={};

for surf_idx=1:length(surfaces)
    surface=surfaces{surf_idx}
    
    result_path=fullfile('../output',surface,'visual_erf',sprintf('%s_surfs',surf_type));
    load(fullfile(result_path, 'loc_dots_results.mat'));            
    for m_idx=1:length(methods)
        idx=find(strcmp(results.methods,methods{m_idx}));
        all_dots_loc_fvals(:,surf_idx,m_idx)=results.fvals(:,idx);
        dots_loc_cond_vals{surf_idx,m_idx}=sprintf('loc %s %s', surfaces{surf_idx}, methods{m_idx});
    end
    load(fullfile(result_path, 'dots_results.mat'));            
    for m_idx=1:length(methods)
        idx=find(strcmp(results.methods,methods{m_idx}));
        all_dots_fvals(:,surf_idx,m_idx)=results.fvals(:,idx);
        dots_cond_vals{surf_idx,m_idx}=sprintf('normal %s %s', surfaces{surf_idx}, methods{m_idx});
    end

    load(fullfile(result_path, 'loc_instr_results.mat'));
    for m_idx=1:length(methods)
        idx=find(strcmp(results.methods,methods{m_idx}));
        all_instr_loc_fvals(:,surf_idx,m_idx)=results.fvals(:,idx);
        instr_loc_cond_vals{surf_idx,m_idx}=sprintf('loc %s %s', surfaces{surf_idx}, methods{m_idx});
    end
    
    load(fullfile(result_path, 'instr_results.mat'));
    for m_idx=1:length(methods)
        idx=find(strcmp(results.methods,methods{m_idx}));
        all_instr_fvals(:,surf_idx,m_idx)=results.fvals(:,idx);
        instr_cond_vals{surf_idx,m_idx}=sprintf('normal %s %s', surfaces{surf_idx}, methods{m_idx});
    end

    result_path=fullfile('../output',surface,'motor_erf', sprintf('%s_surfs',surf_type));
    load(fullfile(result_path, 'loc_resp_results.mat'));
    for m_idx=1:length(methods)
        idx=find(strcmp(results.methods,methods{m_idx}));
        all_resp_loc_fvals(:,surf_idx,m_idx)=results.fvals(:,idx);
        resp_loc_cond_vals{surf_idx,m_idx}=sprintf('loc %s %s', surfaces{surf_idx}, methods{m_idx});
    end
    
    load(fullfile(result_path, 'resp_results.mat'));
    for m_idx=1:length(methods)
        idx=find(strcmp(results.methods,methods{m_idx}));
        all_resp_fvals(:,surf_idx,m_idx)=results.fvals(:,idx);
        resp_cond_vals{surf_idx,m_idx}=sprintf('normal %s %s', surfaces{surf_idx}, methods{m_idx});
    end
end

dots_loc_fvals=reshape(squeeze(all_dots_loc_fvals(:,:,:)),size(all_dots_loc_fvals,1),length(surfaces)*length(methods));
instr_loc_fvals=reshape(squeeze(all_instr_loc_fvals(:,:,:)),size(all_instr_loc_fvals,1),length(surfaces)*length(methods));
resp_loc_fvals=reshape(squeeze(all_resp_loc_fvals(:,:,:)),size(all_resp_loc_fvals,1),length(surfaces)*length(methods));
dots_fvals=reshape(squeeze(all_dots_fvals(:,:,:)),size(all_dots_fvals,1),length(surfaces)*length(methods));
instr_fvals=reshape(squeeze(all_instr_fvals(:,:,:)),size(all_instr_fvals,1),length(surfaces)*length(methods));
resp_fvals=reshape(squeeze(all_resp_fvals(:,:,:)),size(all_resp_fvals,1),length(surfaces)*length(methods));
fvals=[dots_loc_fvals instr_loc_fvals resp_loc_fvals dots_fvals instr_fvals resp_fvals];
data_labels=[reshape(dots_loc_cond_vals(:,:),1,length(surfaces)*length(methods)) reshape(instr_loc_cond_vals(:,:),1,length(surfaces)*length(methods)) reshape(resp_loc_cond_vals(:,:),1,length(surfaces)*length(methods)) reshape(dots_cond_vals(:,:),1,length(surfaces)*length(methods)) reshape(instr_cond_vals(:,:),1,length(surfaces)*length(methods)) reshape(resp_cond_vals(:,:),1,length(surfaces)*length(methods))];
for i=1:length(data_labels)
    parts=strsplit(data_labels{i}, ' ');
    data_labels{i}=parts{1};
end
keep_cols=find(all(~isnan(fvals),1));
fvals=fvals(:,keep_cols);
data_labels=data_labels(keep_cols);
oneway_family('method', {'loc','normal'}, surf_colors, fvals, data_labels);
