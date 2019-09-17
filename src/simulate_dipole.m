function sim_signal=simulate_dipole(subj_info, surf_name, sim_vertex, ori, SNRdB, varargin)
%%
% Simulates a dipole at the given location, orientation, and SNR level
%%

defaults = struct('base_dir','../data',...
    'surf_dir', '../../beta_burst_layers/data/surf',...
    'mri_dir', '../../beta_burst_layers/data/mri');  %define default values
params = struct(varargin{:});
for f = fieldnames(defaults)',  
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

spm('defaults', 'EEG');
spm_jobman('initcfg'); 

% Where to put output data
data_dir=fullfile('../output/data',subj_info.subj_id,'sim');
mkdir(data_dir);

% Data file to load
data_file=fullfile(params.base_dir, subj_info.subj_id(1:2), 'prcresp_Tafdf.mat');
if strcmp(subj_info.subj_id(1:3),'bvw')
    data_file=fullfile(params.base_dir, subj_info.subj_id(1:3), 'prcresp_Tafdf.mat');
end

% Subject surfaces
subj_surf_dir=fullfile(params.surf_dir, sprintf('%s-synth',...
    subj_info.subj_id),'surf');
pial_fname=fullfile(subj_surf_dir,surf_name);

% Copy data file
reg_file=fullfile(data_dir, 'pial_prcresp_TafdfC.mat');

clear jobs
matlabbatch=[];
matlabbatch{1}.spm.meeg.other.copy.D = {data_file};
matlabbatch{1}.spm.meeg.other.copy.outfile = reg_file;
spm_jobman('run', matlabbatch);

% Coregister to pial mesh
matlabbatch=[];
matlabbatch{1}.spm.meeg.source.headmodel.D = {reg_file};
matlabbatch{1}.spm.meeg.source.headmodel.val = 1;
matlabbatch{1}.spm.meeg.source.headmodel.comment = '';
matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshes.custom.mri = {fullfile(params.mri_dir, subj_info.subj_id, [subj_info.headcast_t1 ',1'])};
matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshes.custom.cortex = {pial_fname};
matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshes.custom.iskull = {''};
matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshes.custom.oskull = {''};
matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshes.custom.scalp = {''};
matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshres = 2;
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).fidname = 'nas';
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).specification.type = subj_info.nas;
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).fidname = 'lpa';
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).specification.type = subj_info.lpa;
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).fidname = 'rpa';
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).specification.type = subj_info.rpa;
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.useheadshape = 0;
matlabbatch{1}.spm.meeg.source.headmodel.forward.eeg = 'EEG BEM';
matlabbatch{1}.spm.meeg.source.headmodel.forward.meg = 'Single Shell';
spm_jobman('run', matlabbatch);

% Setup spatial modes for cross validation
spatialmodesname=fullfile(data_dir, 'testmodes.mat');    
[spatialmodesname,Nmodes,pctest]=spm_eeg_inv_prep_modes_xval(reg_file, [], spatialmodesname, 1, 0);

clear jobs
matlabbatch={};
batch_idx=1;

matlabbatch{batch_idx}.spm.meeg.source.invertiter.D = {reg_file};
matlabbatch{batch_idx}.spm.meeg.source.invertiter.val = 1;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.whatconditions.all = 1;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.invfunc = 'Classic';
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.invtype = 'EBB'; %;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.woi = [-Inf Inf];
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.foi = [0 256];
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.hanning = 0;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.isfixedpatch.randpatch.npatches = 512;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.isfixedpatch.randpatch.niter = 1;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.patchfwhm = -5; %% NB A fiddle here- need to properly quantify
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.mselect = 0;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.nsmodes = Nmodes;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.umodes = {spatialmodesname};
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.ntmodes = 4;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.priors.priorsmask = {''};
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.priors.space = 1;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.restrict.locs = zeros(0, 3);
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.restrict.radius = 32;
matlabbatch{batch_idx}.spm.meeg.source.invertiter.isstandard.custom.outinv = '';
matlabbatch{batch_idx}.spm.meeg.source.invertiter.modality = {'All'};
matlabbatch{batch_idx}.spm.meeg.source.invertiter.crossval = [pctest 1];      
spm_jobman('run', matlabbatch);

D=spm_eeg_load(reg_file);   

% Create simulated signal
woi=[D.time(1)-(D.time(2)-D.time(1)) D.time(end)];
% Time zero is midpoint of WOI
zero_time=D.time((length(D.time)-1)/2+1);
% Simulate Gaussian
width=.025; % in s
sim_signal=exp(-((D.time-zero_time).^2)/(2*width^2));

% Simulate source
simpos=D.inv{1}.mesh.tess_mni.vert(sim_vertex,:);
nAmdipmom=10;
dipfwhm=5;

% Set sim signal to have unit variance
sim_signal=sim_signal./std(sim_signal')';
[D,meshsourceind]=spm_eeg_simulate({D}, 'sim_', simpos,...
    sim_signal, ori, woi, [], SNRdB, [], [], dipfwhm,...
    nAmdipmom, []);
save(D);

clear jobs
matlabbatch={};
batch_idx=1;    

% Average
matlabbatch{batch_idx}.spm.meeg.averaging.average.D = {fullfile(data_dir, 'sim_pial_prcresp_TafdfC.mat')};
matlabbatch{batch_idx}.spm.meeg.averaging.average.userobust.standard = false;
matlabbatch{batch_idx}.spm.meeg.averaging.average.plv = false;
matlabbatch{batch_idx}.spm.meeg.averaging.average.prefix = fullfile(data_dir, 'm');
batch_idx=batch_idx+1;

spm_jobman('run', matlabbatch); 