function average_motor_data(subj_info)

spm('defaults','eeg');

clear jobs
matlabbatch={};
batch_idx=1;

subj_init=subj_info.subj_id(1:2);
if strcmp(subj_init,'bv')
    subj_init=subj_info.subj_id(1:3);
end
data_dir=fullfile('C:/Users/jbonaiuto/Dropbox/Projects/inProgress/dipole_moment_priors/data',subj_init);

session_files={};

for idx=1:length(subj_info.sessions)
    session_num=num2str(subj_info.sessions(idx));
    session_dir=fullfile(data_dir,session_num);
    session_file=fullfile(session_dir, sprintf('rcresp_Tafdf%s.mat', session_num));
    
    % Load files
    load(session_file);
    D.condlist={''};
    for meg_idx=1:length(D.trials)        
        cond_label='';
        D.trials(meg_idx).label=cond_label;        
    end
    save(session_file,'D');

    session_files{end+1,1}=session_file;
end

if length(subj_info.sessions)>1
    matlabbatch{batch_idx}.spm.meeg.preproc.merge.D = session_files;
    matlabbatch{batch_idx}.spm.meeg.preproc.merge.recode.file = '.*';
    matlabbatch{batch_idx}.spm.meeg.preproc.merge.recode.labelorg = '.*';
    matlabbatch{batch_idx}.spm.meeg.preproc.merge.recode.labelnew = '#labelorg#';
    matlabbatch{batch_idx}.spm.meeg.preproc.merge.prefix = 'c';
    batch_idx=batch_idx+1;    

    [path filename]=fileparts(session_files{end,1});
    matlabbatch{batch_idx}.spm.meeg.other.copy.D = {sprintf('c%s.mat', filename)};
    matlabbatch{batch_idx}.spm.meeg.other.copy.outfile = fullfile(data_dir, 'rcresp_Tafdf.mat');
    batch_idx=batch_idx+1;

    matlabbatch{batch_idx}.spm.meeg.other.delete.D = {sprintf('c%s.mat', filename)};
    batch_idx=batch_idx+1;
else
    matlabbatch{batch_idx}.spm.meeg.other.copy.D = {session_files{1,1}};
    matlabbatch{batch_idx}.spm.meeg.other.copy.outfile = fullfile(data_dir, 'rcresp_Tafdf.mat');
    batch_idx=batch_idx+1;
end

matlabbatch{batch_idx}.spm.meeg.preproc.crop.D = {fullfile(data_dir, 'rcresp_Tafdf.mat')};
matlabbatch{batch_idx}.spm.meeg.preproc.crop.timewin = [-500 500];
matlabbatch{batch_idx}.spm.meeg.preproc.crop.freqwin = [-Inf Inf];
matlabbatch{batch_idx}.spm.meeg.preproc.crop.channels{1}.all = 'all';
matlabbatch{batch_idx}.spm.meeg.preproc.crop.prefix = 'p';
batch_idx=batch_idx+1;

matlabbatch{batch_idx}.spm.meeg.averaging.average.D = {fullfile(data_dir, 'prcresp_Tafdf.mat')};
matlabbatch{batch_idx}.spm.meeg.averaging.average.userobust.robust.ks = 3;
matlabbatch{batch_idx}.spm.meeg.averaging.average.userobust.robust.bycondition = false;
matlabbatch{batch_idx}.spm.meeg.averaging.average.userobust.robust.savew = false;
matlabbatch{batch_idx}.spm.meeg.averaging.average.userobust.robust.removebad = false;
matlabbatch{batch_idx}.spm.meeg.averaging.average.plv = false;
matlabbatch{batch_idx}.spm.meeg.averaging.average.prefix = 'm';

spm_jobman('run', matlabbatch); 
