function plot_cov_comparison(varargin)

defaults = struct('mpm_surfs', true);  %define default values
params = struct(varargin{:});
for f = fieldnames(defaults)',  
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

surfaces={'pial','white','white-pial'};
methods={'ds_surf_norm','cps','orig_surf_norm','link_vector','variational'};
method_order=[1 5 2 3 4];
figure();
colors=get(gca,'ColorOrder');
cov_colors=colors;
for i=1:size(cov_colors,1)
    for j=3
        cov_colors(i,j)=min([1 cov_colors(i,j)+.1]);
    end
end

for surf_idx=1:length(surfaces)
    surface=surfaces{surf_idx};
    
    result_path=fullfile('../output',surface,'visual_erf');
    if params.mpm_surfs
        result_path=fullfile(result_path, 'mpm_surfs');
    else
        result_path=fullfile(result_path, 't1_surfs');
    end
    load(fullfile(result_path, 'dots_results.mat'));
    dots_results=results;
    load(fullfile(result_path, 'cov_dots_results.mat'));
    cov_dots_results=results;
    
    load(fullfile(result_path, 'instr_results.mat'));
    instr_results=results;
    load(fullfile(result_path, 'cov_instr_results.mat'));
    cov_instr_results=results;
    
    result_path=fullfile('../output',surface,'motor_erf');
    if params.mpm_surfs
        result_path=fullfile(result_path, 'mpm_surfs');
    else
        result_path=fullfile(result_path, 't1_surfs');
    end
    load(fullfile(result_path, 'resp_results.mat'));
    resp_results=results;
    load(fullfile(result_path, 'cov_resp_results.mat'));
    cov_resp_results=results;
    
    labels={};
    for subj_idx=1:length(resp_results.subjects)
        labels{subj_idx}=sprintf('%d',subj_idx);
    end

    % Make F vals relatiive to ds surf norm
    for subj_idx=1:length(dots_results.subjects)
        dots_results.fvals(subj_idx,:)=dots_results.fvals(subj_idx,:)-dots_results.fvals(subj_idx,1);
        cov_dots_results.fvals(subj_idx,:)=cov_dots_results.fvals(subj_idx,:)-cov_dots_results.fvals(subj_idx,1);
    end
    for subj_idx=1:length(instr_results.subjects)
        instr_results.fvals(subj_idx,:)=instr_results.fvals(subj_idx,:)-instr_results.fvals(subj_idx,1);
        cov_instr_results.fvals(subj_idx,:)=cov_instr_results.fvals(subj_idx,:)-cov_instr_results.fvals(subj_idx,1);
    end
    for subj_idx=1:length(resp_results.subjects)
        resp_results.fvals(subj_idx,:)=resp_results.fvals(subj_idx,:)-resp_results.fvals(subj_idx,1);
        cov_resp_results.fvals(subj_idx,:)=cov_resp_results.fvals(subj_idx,:)-cov_resp_results.fvals(subj_idx,1);
    end

    subplot(3,length(surfaces),surf_idx);
    hold all;
    handles=[];
    for m_idx=2:length(methods)
        method=methods{m_idx};
        mo_idx=find(strcmp(dots_results.methods,method));
        for subj_idx=1:length(dots_results.subjects)
            h=bar(subj_idx+((m_idx-1)-2)*.2-.1,dots_results.fvals(subj_idx,mo_idx),.1,'FaceColor',cov_colors(m_idx,:));
            if subj_idx==1
                handles(end+1)=h;
            end
        end
    end        
    for m_idx=2:length(methods)
        method=methods{m_idx};
        mo_idx=find(strcmp(dots_results.methods,method));
        for subj_idx=1:length(dots_results.subjects)
            h=bar(subj_idx+((m_idx-1)-2)*.2-.1+.1,cov_dots_results.fvals(subj_idx,mo_idx),.1,'FaceColor',colors(m_idx,:));
        end
    end        
    set(gca,'xtick',[1:length(dots_results.subjects)]);
    set(gca,'xticklabels',labels);
    hold on;
    plot(xlim(),[3 3],'k--');
    plot(xlim(),[-3 -3],'k--');
    legend(handles,dots_results.methods(method_order(2:end)));
    xlim([.5 length(dots_results.subjects)+.5]);
    ylim([-10 35]);
    %ylim([-20 35]);
    ylabel('\Delta F');

    subplot(3,length(surfaces),length(surfaces)+surf_idx);
    hold all;
    for m_idx=2:length(methods)
        method=methods{m_idx};
        mo_idx=find(strcmp(instr_results.methods,method));
        for subj_idx=1:length(instr_results.subjects)
            bar(subj_idx+((m_idx-1)-2)*.2-.1,instr_results.fvals(subj_idx,mo_idx),.1,'FaceColor',colors(m_idx,:));
        end
    end       
    for m_idx=2:length(methods)
        method=methods{m_idx};
        mo_idx=find(strcmp(instr_results.methods,method));
        for subj_idx=1:length(instr_results.subjects)
            bar(subj_idx+((m_idx-1)-2)*.2-.1+.1,cov_instr_results.fvals(subj_idx,mo_idx),.1,'FaceColor',colors(m_idx,:));
        end
    end       
    set(gca,'xtick',[1:length(instr_results.subjects)]);
    set(gca,'xticklabels',labels);
    hold on;
    plot(xlim(),[3 3],'k--');
    plot(xlim(),[-3 -3],'k--');
    xlim([.5 length(instr_results.subjects)+.5]);
    ylim([-10 25]);
    %ylim([-10 30]);
    ylabel('\Delta F');

    subplot(3,length(surfaces),2*length(surfaces)+surf_idx);
    hold all;
    for m_idx=2:length(methods)
        method=methods{m_idx};
        mo_idx=find(strcmp(resp_results.methods,method));
        for subj_idx=1:length(resp_results.subjects)
            bar(subj_idx+((m_idx-1)-2)*.2-.1,resp_results.fvals(subj_idx,mo_idx),.1,'FaceColor',colors(m_idx,:));
        end
    end   
    for m_idx=2:length(methods)
        method=methods{m_idx};
        mo_idx=find(strcmp(resp_results.methods,method));
        for subj_idx=1:length(resp_results.subjects)
            bar(subj_idx+((m_idx-1)-2)*.2-.1+.1,cov_resp_results.fvals(subj_idx,mo_idx),.1,'FaceColor',colors(m_idx,:));
        end
    end   
    set(gca,'xtick',[1:length(resp_results.subjects)]);
    set(gca,'xticklabels',labels);
    hold on;
    plot(xlim(),[3 3],'k--');
    plot(xlim(),[-3 -3],'k--');
    xlim([.5 length(resp_results.subjects)+.5]);
    %ylim([-45 20]);
    ylim([-20 20]);
    ylabel('\Delta F');
end
