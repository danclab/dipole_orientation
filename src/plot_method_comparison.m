function plot_method_comparison(surface, varargin)

defaults = struct('mpm_surfs', true);  %define default values
params = struct(varargin{:});
for f = fieldnames(defaults)',  
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

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

figure();
subplot(3,1,1);
bar(dots_results.fvals);
set(gca,'xticklabels',labels);
hold on;
plot(xlim(),[3 3],'k--');
plot(xlim(),[-3 -3],'k--');
legend(dots_results.methods);
ylabel('\Delta F');

subplot(3,1,2);
bar(instr_results.fvals);
set(gca,'xticklabels',labels);
hold on;
plot(xlim(),[3 3],'k--');
plot(xlim(),[-3 -3],'k--');
ylabel('\Delta F');

subplot(3,1,3);
bar(resp_results.fvals);
set(gca,'xticklabels',labels);
hold on;
plot(xlim(),[3 3],'k--');
plot(xlim(),[-3 -3],'k--');
ylabel('\Delta F');
