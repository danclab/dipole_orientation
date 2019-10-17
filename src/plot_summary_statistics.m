function plot_summary_statistics()

surfaces={'pial','white','white-pial'};
methods={'ds surf norm','orig surf norm','link vector','variational'};

mpm_dots_fvals=[];
t1_dots_fvals=[];
mpm_instr_fvals=[];
t1_instr_fvals=[];
mpm_resp_fvals=[];
t1_resp_fvals=[];

for surf_idx=1:length(surfaces)
    surface=surfaces{surf_idx};
    
    result_path=fullfile('../output',surface,'visual_erf');
    result_path=fullfile(result_path, 'mpm_surfs');
    load(fullfile(result_path, 'dots_results.mat'));
    mpm_dots_fvals(:,surf_idx,:)=results.fvals;
    load(fullfile(result_path, 'instr_results.mat'));
    mpm_instr_fvals(:,surf_idx,:)=results.fvals;

    result_path=fullfile('../output',surface,'visual_erf');
    result_path=fullfile(result_path, 't1_surfs');
    load(fullfile(result_path, 'dots_results.mat'));
    t1_dots_fvals(:,surf_idx,:)=results.fvals;
    load(fullfile(result_path, 'instr_results.mat'));
    t1_instr_fvals(:,surf_idx,:)=results.fvals;
    
    result_path=fullfile('../output',surface,'motor_erf');
    result_path=fullfile(result_path, 'mpm_surfs');
    load(fullfile(result_path, 'resp_results.mat'));
    mpm_resp_fvals(:,surf_idx,:)=results.fvals;
    
    result_path=fullfile('../output',surface,'motor_erf');
    result_path=fullfile(result_path, 't1_surfs');
    load(fullfile(result_path, 'resp_results.mat'));
    t1_resp_fvals(:,surf_idx,:)=results.fvals;
end

all_mpm_fvals=[reshape(mpm_dots_fvals,8,12) reshape(mpm_instr_fvals,8,12) reshape(mpm_resp_fvals,8,12)];
all_t1_fvals=[reshape(t1_dots_fvals,8,12) reshape(t1_instr_fvals,8,12) reshape(t1_resp_fvals,8,12)];

all_family=[];
all_family.names={'ds-pial','ds-white','ds-combined','orig-pial','orig-white','orig-combined','link-pial','link-white','link-combined','var-pial','var-white','var-combined'};
all_family.infer='RFX';
all_family.partition=[1 2 3 4 5 6 7 8 9 10 11 12 1 2 3 4 5 6 7 8 9 10 11 12 1 2 3 4 5 6 7 8 9 10 11 12];
[family_all_mpm,~]=spm_compare_families(all_mpm_fvals,all_family);
[family_all_t1,~]=spm_compare_families(all_t1_fvals,all_family);

method_family=[];
method_family.names={'ds','orig','link','var'};
method_family.infer='RFX';
method_family.partition=[1 1 1 2 2 2 3 3 3 4 4 4 1 1 1 2 2 2 3 3 3 4 4 4 1 1 1 2 2 2 3 3 3 4 4 4];
[family_methods_mpm,~]=spm_compare_families(all_mpm_fvals,method_family);
[family_methods_t1,~]=spm_compare_families(all_t1_fvals,method_family);

surf_family=[];
surf_family.names={'pial','white','grey'};
surf_family.infer='RFX';
surf_family.partition=[1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3 1 2 3];
[family_surfs_mpm,~]=spm_compare_families(all_mpm_fvals,surf_family);
[family_surfs_t1,~]=spm_compare_families(all_t1_fvals,surf_family);

% Plot family-level inference results
figure;
subplot(4,4,[5 6 7 9 10 11 13 14 15]);
colormap(cbrewer('seq','Reds',100));
imagesc(reshape(family_all_mpm.xp,3,4));
originalSize = get(gca, 'Position');
cb=colorbar();
cb_position=get(cb,'Position');
set(gca,'Position',originalSize);
set(gca,'ydir','normal')
set(gca,'XTick',1:numel(method_family.names))
set(gca,'XTickLabel',method_family.names);
set(gca,'YTick',1:numel(surf_family.names))
set(gca,'YTickLabel',surf_family.names);

ax2=subplot(4,4,[8 12 16]);
H=family_surfs_mpm.xp;
N=numel(H);
colors=parula(numel(H));
for i=1:N
    h=barh(i,H(i));
    if i==1, hold on, end
    set(h,'FaceColor',colors(i,:))
end
xlabel('p(r|y)');
set(ax2,'YTick',[]);
orig_pos=get(ax2,'Position');
set(ax2,'Position',orig_pos+[cb_position(3)+.03 0 0 0]);
xlim([0 1]);

ax3=subplot(4,4,[1 2 3]);
H=family_methods_mpm.xp;
N=numel(H);
colors=parula(numel(H));
for i=1:N
    h=bar(i,H(i));
    if i==1, hold on, end
    set(h,'FaceColor',colors(i,:))
end
ylabel('p(r|y)');
set(ax3,'XTick',[]);
ylim([0 1]);


figure;
subplot(4,4,[5 6 7 9 10 11 13 14 15]);
colormap(cbrewer('seq','Reds',100));
imagesc(reshape(family_all_t1.xp,3,4));
originalSize = get(gca, 'Position');
cb=colorbar();
cb_position=get(cb,'Position');
set(gca,'Position',originalSize);
set(gca,'ydir','normal')
set(gca,'XTick',1:numel(method_family.names))
set(gca,'XTickLabel',method_family.names);
set(gca,'YTick',1:numel(surf_family.names))
set(gca,'YTickLabel',surf_family.names);

ax2=subplot(4,4,[8 12 16]);
H=family_surfs_t1.xp;
N=numel(H);
colors=parula(numel(H));
for i=1:N
    h=barh(i,H(i));
    if i==1, hold on, end
    set(h,'FaceColor',colors(i,:))
end
xlabel('p(r|y)');
xlim([0 1]);
set(ax2,'YTick',[]);
orig_pos=get(ax2,'Position');
set(ax2,'Position',orig_pos+[cb_position(3)+.03 0 0 0]);

ax3=subplot(4,4,[1 2 3]);
H=family_methods_t1.xp;
N=numel(H);
colors=parula(numel(H));
for i=1:N
    h=bar(i,H(i));
    if i==1, hold on, end
    set(h,'FaceColor',colors(i,:))
end
ylabel('p(r|y)');
ylim([0 1]);
set(ax3,'XTick',[]);