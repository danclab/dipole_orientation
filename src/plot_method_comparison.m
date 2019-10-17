function plot_method_comparison(varargin)

defaults = struct('mpm_surfs', true);  %define default values
params = struct(varargin{:});
for f = fieldnames(defaults)',  
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

surfaces={'pial','white','white-pial'};

figure();

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

    load(fullfile(result_path, 'instr_results.mat'));
    instr_results=results;

    result_path=fullfile('../output',surface,'motor_erf');
    if params.mpm_surfs
        result_path=fullfile(result_path, 'mpm_surfs');
    else
        result_path=fullfile(result_path, 't1_surfs');
    end
    load(fullfile(result_path, 'resp_results.mat'));
    resp_results=results;

    labels={};
    for subj_idx=1:length(dots_results.subjects)
        labels{subj_idx}=sprintf('%d',subj_idx);
    end

    % Make F vals relatiive to ds surf norm
    for subj_idx=1:length(dots_results.subjects)
        dots_results.fvals(subj_idx,:)=dots_results.fvals(subj_idx,:)-dots_results.fvals(subj_idx,1);
    end
    for subj_idx=1:length(instr_results.subjects)
        instr_results.fvals(subj_idx,:)=instr_results.fvals(subj_idx,:)-instr_results.fvals(subj_idx,1);
    end
    for subj_idx=1:length(resp_results.subjects)
        resp_results.fvals(subj_idx,:)=resp_results.fvals(subj_idx,:)-resp_results.fvals(subj_idx,1);
    end

    subplot(3,length(surfaces),surf_idx);
    bar(dots_results.fvals);
    set(gca,'xticklabels',labels);
    hold on;
    plot(xlim(),[3 3],'k--');
    plot(xlim(),[-3 -3],'k--');
    legend(dots_results.methods);
    ylim([-10 35]);
    ylabel('\Delta F');

    subplot(3,length(surfaces),length(surfaces)+surf_idx);
    bar(instr_results.fvals);
    set(gca,'xticklabels',labels);
    hold on;
    plot(xlim(),[3 3],'k--');
    plot(xlim(),[-3 -3],'k--');
    ylim([-10 25]);
    ylabel('\Delta F');

    subplot(3,length(surfaces),2*length(surfaces)+surf_idx);
    bar(resp_results.fvals);
    set(gca,'xticklabels',labels);
    hold on;
    plot(xlim(),[3 3],'k--');
    plot(xlim(),[-3 -3],'k--');
    ylim([-20 15]);
    ylabel('\Delta F');
end
