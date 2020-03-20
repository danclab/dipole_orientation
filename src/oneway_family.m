function oneway_family(factor_name, factor_labels, factor_colors, f_vals,...
    data_labels, varargin)

defaults = struct('ax', 0);  %define default values
params = struct(varargin{:});
for f = fieldnames(defaults)',  
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

factor_family=[];
factor_family.names=factor_labels;
factor_family.infer='RFX';
factor_family.partition=[];%1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2];
for c=1:length(data_labels)
    label=data_labels{c};
    factor_family.partition(end+1)=find(strcmp(factor_family.names,label));
end
[factor_results,~]=spm_compare_families(f_vals,factor_family)

% Plot family-level inference results
if params.ax==0;
    figure;
end
results=NaN(1,length(factor_family.names));
for i=1:length(factor_results.names)
    name=factor_results.names{i};
    idx=find(strcmp(factor_labels,name));
    results(idx)=factor_results.xp(i);
end
N=numel(results);
for i=1:N
    h=bar(i,results(i), 'FaceColor', factor_colors(i,:));
    if i==1, hold on, end
end
ylabel('p(r|y)');
set(gca,'XTick',[1:numel(factor_labels)]);
set(gca,'XTickLabel',factor_labels);
ylim([0 1]);
xlabel(factor_name);
