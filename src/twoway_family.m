function twoway_family(factor1_name, factor1_labels, factor1_colors,....
    factor2_name, factor2_labels, factor2_colors, f_vals, data_labels)

all_family=[];
all_family.names={};
for f1_idx=1:length(factor1_labels)
    for f2_idx=1:length(factor2_labels)
        name=sprintf('%s %s', factor1_labels{f1_idx}, factor2_labels{f2_idx});
        if find(strcmp(data_labels,name))
            all_family.names{end+1}=name;
        end
    end
end
all_family.infer='RFX';
all_family.partition=[];%1 2 3 4 5 6 1 2 3 4 5 6 1 2 3 4 5 6 1 2 3 4 5 6 1 2 3 4 5 6 1 2 3 4 5 6 1 2 3 4 5 6 1 2 3 4 5 6 1 2 3 4 5 6 1 2 3 4 5 6 1 2 3 4 5 6 1 2 3 4 5 6];
for c=1:length(data_labels)
    label=data_labels{c};
    parts=strsplit(label,' ');
    fam_name=sprintf('%s %s', parts{1}, parts{2});
    all_family.partition(end+1)=find(strcmp(all_family.names,fam_name));
end
[all_family_results,~]=spm_compare_families(f_vals,all_family);

factor1_family=[];
factor1_family.names=factor1_labels;
factor1_family.infer='RFX';
factor1_family.partition=[];%1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2];
for c=1:length(data_labels)
    label=data_labels{c};
    parts=strsplit(label,' ');
    fam_name=parts{1};
    factor1_family.partition(end+1)=find(strcmp(factor1_family.names,fam_name));
end
[factor1_results,~]=spm_compare_families(f_vals,factor1_family);

factor2_family=[];
factor2_family.names=factor2_labels;
factor2_family.infer='RFX';
factor2_family.partition=[];%1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3];
for c=1:length(data_labels)
    label=data_labels{c};
    parts=strsplit(label,' ');
    fam_name=parts{2};
    factor2_family.partition(end+1)=find(strcmp(factor2_family.names,fam_name));
end
[factor2_results,~]=spm_compare_families(f_vals,factor2_family);

figure();
bar(all_family_results.xp);
set(gca,'Xtick',[1:numel(all_family_results.xp)]);
set(gca,'XtickLabel',all_family_results.names);

% Plot family-level inference results
figure;
subplot(4,4,[5 6 7 9 10 11 13 14 15]);
colormap(cbrewer('seq','Reds',100));
results=NaN(length(factor1_family.names),length(factor2_family.names));
for i=1:length(all_family_results.names)
    name=all_family_results.names{i};
    parts=strsplit(name,' ');
    idx1=find(strcmp(factor1_family.names,parts{1}));
    idx2=find(strcmp(factor2_family.names,parts{2}));
    results(idx1,idx2)=all_family_results.xp(i);
end
imagesc(results);
set(gca,'clim',[0 1]);
set(gca,'ydir','reverse')
originalSize = get(gca, 'Position');
cb=colorbar();
cb_position=get(cb,'Position');
set(gca,'Position',originalSize);
set(gca,'XTick',1:numel(factor2_family.names))
set(gca,'XTickLabel',factor2_family.names);
set(gca,'YTick',1:numel(factor1_family.names))
set(gca,'YTickLabel',factor1_family.names);
xlabel(factor2_name);
ylabel(factor1_name);

ax2=subplot(4,4,[8 12 16]);
results=NaN(1,length(factor1_family.names));
for i=1:length(factor1_results.names)
    name=factor1_results.names{i};
    idx=find(strcmp(factor1_labels,name));
    if i<=length(factor1_results.xp)
        results(idx)=factor1_results.xp(i);
    end
end
N=numel(results);
for i=1:N
    h=barh(i,results(i),'FaceColor',factor1_colors(i,:));
    if i==1, hold on, end
end
set(gca,'ydir','reverse')
xlabel('p(r|y)');
set(ax2,'YTick',[]);
orig_pos=get(ax2,'Position');
set(ax2,'Position',orig_pos+[cb_position(3)+.03 0 0 0]);
xlim([0 1]);

ax3=subplot(4,4,[1 2 3]);
results=NaN(1,length(factor2_family.names));
for i=1:length(factor2_results.names)
    name=factor2_results.names{i};
    idx=find(strcmp(factor2_labels,name));
    if i<=length(factor2_results.xp)
        results(idx)=factor2_results.xp(i);
    end
end
N=numel(results);
for i=1:N
    h=bar(i,results(i),'FaceColor',factor2_colors(i,:));
    if i==1, hold on, end
end
ylabel('p(r|y)');
set(ax3,'XTick',[]);
ylim([0 1]);