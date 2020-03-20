function compute_cov_matrix(fois)

spm('defaults', 'eeg')
%% arguments  
input = '../data/mg05125_SofieSpatialMemory_20170921_01.ds/spmeeg_mg05125_SofieSpatialMemory_20170921_01.mat';

D=spm_eeg_load(input);
megchans=D.indchantype('meg');
%% covariance

nAverages = 320; 
co=zeros(length(megchans),length(megchans));
for i = 1:nAverages
    start = (i-1)*600+1;
    en =i*600;
    Y =  squeeze(D(megchans,start:en,:))';
    co= co+corr(Y);
end
figure()
mean_co=co./nAverages;
% new_mean_co=zeros(size(mean_co,1)+1,size(mean_co,1)+1);
% new_mean_co(1:70,1:70)=mean_co(1:70,1:70);
% new_mean_co(1:70,72:end)=mean_co(1:70,71:end);
% new_mean_co(72:end,1:70)=mean_co(71:end,1:70);
% new_mean_co(72:end,72:end)=mean_co(71:end,71:end);
% new_mean_co(71,71)=1.0;
imagesc(mean_co);
set(gca,'clim',[-1 1]);
colorbar();
xlabel('Sensor');
ylabel('Sensor');
title('WB');
C=mean_co;
chan_labels=D.chanlabels(megchans);
save('../output/data/cov.mat','C','chan_labels');

for j=1:size(fois,1)
    foi=fois(j,:);
    clear jobs
    matlabbatch={};
    batch_idx=1;

    % Highpass filter
    matlabbatch{batch_idx}.spm.meeg.preproc.filter.D = {fullfile(dir,'SPM.mat')};
    matlabbatch{batch_idx}.spm.meeg.preproc.filter.type = 'butterworth';
    matlabbatch{batch_idx}.spm.meeg.preproc.filter.band = 'bandpass';
    matlabbatch{batch_idx}.spm.meeg.preproc.filter.freq = foi;
    matlabbatch{batch_idx}.spm.meeg.preproc.filter.dir = 'twopass';
    matlabbatch{batch_idx}.spm.meeg.preproc.filter.order = 5;
    matlabbatch{batch_idx}.spm.meeg.preproc.filter.prefix = fullfile(dir,'f');
    spm_jobman('run',matlabbatch);

    D=spm_eeg_load(fullfile(dir,'fSPM.mat'));
    
    co=zeros(size(D,1),size(D,1));
    for i = 1:nAverages
        start = (i-1)*600+1;
        en =i*600;
        Y =  squeeze(D(:,start:en,:))';
        co= co+corr(Y);
    end
    figure()
    mean_co=co./320;
    new_mean_co=zeros(size(mean_co,1)+1,size(mean_co,1)+1);
    new_mean_co(1:70,1:70)=mean_co(1:70,1:70);
    new_mean_co(1:70,72:end)=mean_co(1:70,71:end);
    new_mean_co(72:end,1:70)=mean_co(71:end,1:70);
    new_mean_co(72:end,72:end)=mean_co(71:end,71:end);
    new_mean_co(71,71)=1.0;
    C=new_mean_co;
    save(fullfile(dir,sprintf('cov_%d-%dHz.mat', foi(1),foi(2))),'C');
    
    coFinal(j+1,:,:) = new_mean_co;
    imagesc(squeeze(coFinal(j+1,:,:)));
    set(gca,'clim',[-1 1]);
    colorbar();
    xlabel('Sensor');
    ylabel('Sensor');
    title(sprintf('%d-%dHz',foi(1),foi(2)));
end