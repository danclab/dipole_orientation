function plot_surface_comparison(varargin)

defaults = struct('mpm_surfs', true);  %define default values
params = struct(varargin{:});
for f = fieldnames(defaults)',  
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

surfaces={'pial','white','white-pial'};
methods={'ds surf norm','cps','orig surf norm','link vector','variational'};
method_order=[1 5 2 3 4];

dots_fvals=[];
instr_fvals=[];
resp_fvals=[];

for surf_idx=1:length(surfaces)
    surface=surfaces{surf_idx};
    
    result_path=fullfile('../output',surface,'visual_erf');
    if params.mpm_surfs
        result_path=fullfile(result_path, 'mpm_surfs');
    else
        result_path=fullfile(result_path, 't1_surfs');
    end
    load(fullfile(result_path, 'dots_results.mat'));
    dots_fvals(:,surf_idx,:)=results.fvals(:,method_order);
    
    load(fullfile(result_path, 'instr_results.mat'));
    instr_fvals(:,surf_idx,:)=results.fvals(:,method_order);

    result_path=fullfile('../output',surface,'motor_erf');
    if params.mpm_surfs
        result_path=fullfile(result_path, 'mpm_surfs');
    else
        result_path=fullfile(result_path, 't1_surfs');
    end
    load(fullfile(result_path, 'resp_results.mat'));
    resp_fvals(:,surf_idx,:)=results.fvals(:,method_order);
end

labels={};
for subj_idx=1:length(results.subjects)
    labels{subj_idx}=sprintf('%d',subj_idx);
end

for method_idx=1:length(methods)
    % Make F vals relative to worst surface
    for subj_idx=1:length(results.subjects)
        dots_fvals(subj_idx,:,method_idx)=dots_fvals(subj_idx,:,method_idx)-min(dots_fvals(subj_idx,:,method_idx));
    end
    for subj_idx=1:length(results.subjects)
        instr_fvals(subj_idx,:,method_idx)=instr_fvals(subj_idx,:,method_idx)-min(instr_fvals(subj_idx,:,method_idx));
    end
    for subj_idx=1:length(results.subjects)
        resp_fvals(subj_idx,:,method_idx)=resp_fvals(subj_idx,:,method_idx)-min(resp_fvals(subj_idx,:,method_idx));
    end
end

figure();
for method_idx=1:length(methods)
    subplot(3,length(methods),method_idx);
    bar(squeeze(dots_fvals(:,:,method_idx)));
    set(gca,'xticklabels',labels);
    hold on;
    xlim([0 9]);
    plot(xlim(),[3 3],'k--');
    %ylim([0 20]);
    ylim([0 30]);
    legend(surfaces);
    ylabel('\Delta F');
    title(methods{method_idx});

    subplot(3,length(methods),length(methods)+method_idx);
    bar(squeeze(instr_fvals(:,:,method_idx)));
    set(gca,'xticklabels',labels);
    hold on;
    xlim([0 9]);
    plot(xlim(),[3 3],'k--');
    %ylim([0 20]);
    ylim([0 15]);
    ylabel('\Delta F');

    subplot(3,length(methods),2*length(methods)+method_idx);
    bar(squeeze(resp_fvals(:,:,method_idx)));
    set(gca,'xticklabels',labels);
    hold on;
    xlim([0 9]);
    plot(xlim(),[3 3],'k--');
    ylim([0 30]);
    ylabel('\Delta F');
    xlabel('Participant');
end

