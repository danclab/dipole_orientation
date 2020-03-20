function f_val=invert_visual_erf_subject_extended(subj_info, method, ori_surface, loc_surface, surf_fname, stim, woi, varargin)

defaults = struct('base_dir','../data',...
    'surf_dir', '../../../inProgress/beta_burst_layers/data/surf',... 
    'mri_dir', '../../../inProgress/beta_burst_layers/data/mri',...
    'mpm_surfs', true, 'patch_size', 5, 'n_temp_modes', 4, 'export', true,...
    'recompute_lgain',false);  %define default values
params = struct(varargin{:});
for f = fieldnames(defaults)',  
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

% Where to put output data
data_dir=fullfile('../output/data',subj_info.subj_id);
mkdir(data_dir);

% Data file to load
data_file=fullfile(params.base_dir, subj_info.subj_id(1:2), sprintf('mp%s_rcinstr_Tafdf.mat',stim));
if strcmp(subj_info.subj_id(1:3),'bvw')
    data_file=fullfile(params.base_dir, subj_info.subj_id(1:3), sprintf('mp%s_rcinstr_Tafdf.mat',stim));
end

% Subject surfaces
if params.mpm_surfs
    subj_surf_dir=fullfile(params.surf_dir, sprintf('%s-synth',...
        subj_info.subj_id),'surf');
else
    subj_surf_dir=fullfile(params.surf_dir, subj_info.subj_id,'surf');
end

spm('defaults','eeg');
spm_jobman('initcfg');

[smoothkern]=spm_eeg_smoothmesh_mm(fullfile(subj_surf_dir,surf_fname), params.patch_size);

% Coregistered filename
coreg_fname=fullfile(data_dir, sprintf('ori_%s.loc_%s_mp%s_rcinstr_Tafdf_%s.mat',ori_surface,loc_surface,stim, method));

% Coregister to mesh if not done already
clear jobs
matlabbatch={};
batch_idx=1;

% Copy datafile
matlabbatch{batch_idx}.spm.meeg.other.copy.D = {data_file};
matlabbatch{batch_idx}.spm.meeg.other.copy.outfile = coreg_fname;
batch_idx=batch_idx+1;

% Coregister simulated dataset to reconstruction mesh
matlabbatch{batch_idx}.spm.meeg.source.headmodel.D = {coreg_fname};
matlabbatch{batch_idx}.spm.meeg.source.headmodel.val = 1;
matlabbatch{batch_idx}.spm.meeg.source.headmodel.comment = '';
matlabbatch{batch_idx}.spm.meeg.source.headmodel.meshing.meshes.custom.mri = {fullfile(params.mri_dir, subj_info.subj_id, [subj_info.headcast_t1 ',1'])};
matlabbatch{batch_idx}.spm.meeg.source.headmodel.meshing.meshes.custom.cortex = {fullfile(subj_surf_dir,surf_fname)};
matlabbatch{batch_idx}.spm.meeg.source.headmodel.meshing.meshes.custom.iskull = {''};
matlabbatch{batch_idx}.spm.meeg.source.headmodel.meshing.meshes.custom.oskull = {''};
matlabbatch{batch_idx}.spm.meeg.source.headmodel.meshing.meshes.custom.scalp = {''};
matlabbatch{batch_idx}.spm.meeg.source.headmodel.meshing.meshres = 2;
matlabbatch{batch_idx}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).fidname = 'nas';
matlabbatch{batch_idx}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).specification.type = subj_info.nas;
matlabbatch{batch_idx}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).fidname = 'lpa';
matlabbatch{batch_idx}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).specification.type = subj_info.lpa;
matlabbatch{batch_idx}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).fidname = 'rpa';
matlabbatch{batch_idx}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).specification.type = subj_info.rpa;
matlabbatch{batch_idx}.spm.meeg.source.headmodel.coregistration.coregspecify.useheadshape = 0;
matlabbatch{batch_idx}.spm.meeg.source.headmodel.forward.eeg = 'EEG BEM';
matlabbatch{batch_idx}.spm.meeg.source.headmodel.forward.meg = 'Single Shell';            
spm_jobman('run', matlabbatch);    

% if ~params.recompute_lgain
%     D=spm_eeg_load(coreg_fname);
%     [path,fname,ext]=fileparts(coreg_fname);
%     D.inv{1}.gainmat = ['SPMgainmatrix_' fname '_1.mat'];
%     save(D);
% end

% Setup spatial modes for cross validation
spatialmodesname=fullfile(data_dir, 'testmodes.mat');   
[spatialmodesname,Nmodes,pctest]=spm_eeg_inv_prep_modes_xval(coreg_fname, [], spatialmodesname, 1, 0);

clear jobs
matlabbatch={};
batch_idx=1;

% Source reconstruction
matlabbatch{batch_idx}.spm.meeg.source.invertiter.D = {coreg_fname};
matlabbatch{batch_idx}.spm.meeg.source.invertiter.val = 1;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.whatconditions.all = 1;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.invfunc = 'Classic';
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.invtype = 'EBB'; %;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.woi = woi;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.foi = [0 256];
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.hanning = 0;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.isfixedpatch.randpatch.npatches = 512;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.isfixedpatch.randpatch.niter = 1;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.patchfwhm = -params.patch_size; %% NB A fiddle here- need to properly quantify
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.mselect = 0;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.nsmodes = Nmodes;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.umodes = {spatialmodesname};
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.ntmodes = params.n_temp_modes;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.priors.priorsmask = {''};
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.priors.space = 1;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.restrict.locs = zeros(0, 3);
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.restrict.radius = 32;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.outinv = '';
matlabbatch{batch_idx}.spm.meeg.source.invertiter.modality = {'All'};
matlabbatch{batch_idx}.spm.meeg.source.invertiter.crossval = [pctest 1];                                
[a,b]=spm_jobman('run', matlabbatch);

% Get F-value for inversion
Drecon=spm_eeg_load(coreg_fname);                
f_val=Drecon.inv{1}.inverse.crossF;

if params.export
    % Extract source
    spm_jobman('initcfg'); 
    clear jobs
    matlabbatch={};
    batch_idx=1;

    matlabbatch{batch_idx}.spm.meeg.source.results.D = {coreg_fname};
    matlabbatch{batch_idx}.spm.meeg.source.results.val = 1;
    matlabbatch{batch_idx}.spm.meeg.source.results.woi = woi;
    matlabbatch{batch_idx}.spm.meeg.source.results.foi = [0 256];
    matlabbatch{batch_idx}.spm.meeg.source.results.ctype = 'evoked';
    matlabbatch{batch_idx}.spm.meeg.source.results.space = 0;
    matlabbatch{batch_idx}.spm.meeg.source.results.format = 'mesh';
    matlabbatch{batch_idx}.spm.meeg.source.results.smoothing = 8;
    batch_idx=batch_idx+1;
    spm_jobman('run',matlabbatch);
       
end


