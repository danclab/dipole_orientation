function plot_loc_relative_comparison(varargin)

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
    load(fullfile(result_path, 'loc_dots_results.mat'));
    loc_dots_results=results;
    
    load(fullfile(result_path, 'instr_results.mat'));
    instr_results=results;
    load(fullfile(result_path, 'loc_instr_results.mat'));
    loc_instr_results=results;
    
    result_path=fullfile('../output',surface,'motor_erf');
    if params.mpm_surfs
        result_path=fullfile(result_path, 'mpm_surfs');
    else
        result_path=fullfile(result_path, 't1_surfs');
    end
    load(fullfile(result_path, 'resp_results.mat'));
    resp_results=results;
    load(fullfile(result_path, 'loc_resp_results.mat'));
    loc_resp_results=results;
    
    labels={};
    for subj_idx=1:length(resp_results.subjects)
        labels{subj_idx}=sprintf('%d',subj_idx);
    end

    % Make F vals relatiive to without LOC
    for subj_idx=1:length(dots_results.subjects)
        loc_dots_results.fvals(subj_idx,:)=loc_dots_results.fvals(subj_idx,:)-dots_results.fvals(subj_idx,:);
    end
    for subj_idx=1:length(instr_results.subjects)
        loc_instr_results.fvals(subj_idx,:)=loc_instr_results.fvals(subj_idx,:)-instr_results.fvals(subj_idx,:);
    end
    for subj_idx=1:length(resp_results.subjects)
        loc_resp_results.fvals(subj_idx,:)=loc_resp_results.fvals(subj_idx,:)-resp_results.fvals(subj_idx,:);
    end

    subplot(3,length(surfaces),surf_idx);
    hold all;
    handles=[];
    for m_idx=2:length(methods)
        method=methods{m_idx};
        mo_idx=find(strcmp(dots_results.methods,method));
        for subj_idx=1:length(dots_results.subjects)
            h=bar(subj_idx+((m_idx-1)-2)*.2-.1,loc_dots_results.fvals(subj_idx,mo_idx),.2,'FaceColor',colors(m_idx,:));
            if subj_idx==1
                handles(end+1)=h;
            end
        end
    end        
    set(gca,'xtick',[1:length(loc_dots_results.subjects)]);
    set(gca,'xticklabels',labels);
    hold on;
    plot(xlim(),[3 3],'k--');
    plot(xlim(),[-3 -3],'k--');
    legend(handles,loc_dots_results.methods(method_order(2:end)));
    xlim([.5 length(loc_dots_results.subjects)+.5]);
    ylim([-30 50]);
    %ylim([-20 35]);
    ylabel('\Delta F');

    subplot(3,length(surfaces),length(surfaces)+surf_idx);
    hold all;
    for m_idx=2:length(methods)
        method=methods{m_idx};
        mo_idx=find(strcmp(instr_results.methods,method));
        for subj_idx=1:length(instr_results.subjects)
            bar(subj_idx+((m_idx-1)-2)*.2-.1,loc_instr_results.fvals(subj_idx,mo_idx),.2,'FaceColor',colors(m_idx,:));
        end
    end       
    set(gca,'xtick',[1:length(loc_instr_results.subjects)]);
    set(gca,'xticklabels',labels);
    hold on;
    plot(xlim(),[3 3],'k--');
    plot(xlim(),[-3 -3],'k--');
    xlim([.5 length(loc_instr_results.subjects)+.5]);
    ylim([-40 25]);
    %ylim([-10 30]);
    ylabel('\Delta F');

    subplot(3,length(surfaces),2*length(surfaces)+surf_idx);
    hold all;
    for m_idx=2:length(methods)
        method=methods{m_idx};
        mo_idx=find(strcmp(resp_results.methods,method));
        for subj_idx=1:length(resp_results.subjects)
            bar(subj_idx+((m_idx-1)-2)*.2-.1,loc_resp_results.fvals(subj_idx,mo_idx),.2,'FaceColor',colors(m_idx,:));
        end
    end   
    set(gca,'xtick',[1:length(loc_resp_results.subjects)]);
    set(gca,'xticklabels',labels);
    hold on;
    plot(xlim(),[3 3],'k--');
    plot(xlim(),[-3 -3],'k--');
    xlim([.5 length(loc_resp_results.subjects)+.5]);
    ylim([-60 20]);
    %ylim([-20 20]);
    ylabel('\Delta F');
end
