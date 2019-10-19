function merge_motor_data_subjects(subjects)

spm('defaults','eeg');

clear jobs
matlabbatch={};
batch_idx=1;

base_data_dir=fullfile('C:/Users/jbonaiuto/Dropbox/Projects/inProgress/dipole_moment_priors/data');
subject_files={};

for idx=1:length(subjects)
    subj_info=subjects(idx);
    subj_init=subj_info.subj_id(1:2);
    if strcmp(subj_init,'bv')
        subj_init=subj_info.subj_id(1:3);
    end
    subj_dir=fullfile(base_data_dir,subj_init);
    subj_file=fullfile(subj_dir, 'mprcresp_Tafdf.mat');
    
    subject_files{end+1,1}=subj_file;
end

matlabbatch{batch_idx}.spm.meeg.preproc.merge.D = subject_files;
matlabbatch{batch_idx}.spm.meeg.preproc.merge.recode.file = '.*';
matlabbatch{batch_idx}.spm.meeg.preproc.merge.recode.labelorg = '.*';
matlabbatch{batch_idx}.spm.meeg.preproc.merge.recode.labelnew = '#labelorg#';
matlabbatch{batch_idx}.spm.meeg.preproc.merge.prefix = 'c';
batch_idx=batch_idx+1;    

[path filename]=fileparts(subject_files{end,1});
matlabbatch{batch_idx}.spm.meeg.other.copy.D = {sprintf('c%s.mat', filename)};
matlabbatch{batch_idx}.spm.meeg.other.copy.outfile = fullfile(base_data_dir, 'mprcresp_Tafdf.mat');
batch_idx=batch_idx+1;

matlabbatch{batch_idx}.spm.meeg.other.delete.D = {sprintf('c%s.mat', filename)};
batch_idx=batch_idx+1;

spm_jobman('run', matlabbatch); 