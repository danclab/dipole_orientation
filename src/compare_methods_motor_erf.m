function compare_methods_motor_erf(subjects, woi, surface, varargin)
% woi= -50 - 50
defaults = struct('surf_dir', '../../beta_burst_layers/data/surf',...
    'mpm_surfs',true);  %define default values
params = struct(varargin{:});
for f = fieldnames(defaults)',  
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

methods={'ds_surf_norm','orig_surf_norm','link_vector','variational'};
fvals=[];
f_idx=1;

labels={};

for subj_idx=1:length(subjects)
    subj_info=subjects(subj_idx);
    if params.mpm_surfs
        subj_surf_dir=fullfile(params.surf_dir, sprintf('%s-synth', subj_info.subj_id), 'surf');
    else
        subj_surf_dir=fullfile(params.surf_dir, subj_info.subj_id, 'surf');
    end
    if strcmp(surface,'white-pial')
        ds_surface=gifti(fullfile(subj_surf_dir, 'white.ds-pial.ds.gii'));
    else
        ds_surface=gifti(fullfile(subj_surf_dir, sprintf('%s.ds.gii', surface)));
    end
     
    for i=1:length(methods)
        if params.mpm_surfs
            ds_surface.normals=compute_surface_normals(params.surf_dir, sprintf('%s-synth', subj_info.subj_id), surface, methods{i});
        else
            ds_surface.normals=compute_surface_normals(params.surf_dir, subj_info.subj_id, surface, methods{i});
        end
        if strcmp(surface,'white-pial')
            method_fname=sprintf('white.ds-pial.ds.%s.gii',methods{i});
        else
            method_fname=sprintf('%s.ds.%s.gii',surface, methods{i});
        end
        save(ds_surface,fullfile(subj_surf_dir, method_fname));
        
        fwhm_orig_fname=sprintf('FWHM5.00_%s.ds',surface);
        if strcmp(surface,'white-pial')
            fwhm_orig_fname='FWHM5.00_white.ds-pial.ds';
        end
        if exist(fullfile(subj_surf_dir,sprintf('%s.mat', fwhm_orig_fname)),'file')==2
            copyfile(fullfile(subj_surf_dir,sprintf('%s.mat', fwhm_orig_fname)),...
                fullfile(subj_surf_dir,sprintf('%s.%s.mat',fwhm_orig_fname, methods{i})));
        end
        fvals(f_idx,i)=invert_motor_erf_subject(subj_info, methods{i}, surface, method_fname, woi,...
            'surf_dir', params.surf_dir, 'mpm_surfs', params.mpm_surfs);
    end
    fvals(f_idx,:)=fvals(f_idx,:)-fvals(f_idx,1);
    labels{f_idx}=sprintf('%d',subj_idx);
    f_idx=f_idx+1;
    
end
figure();bar(fvals);
set(gca,'xticklabels',labels);
hold on;
legend(methods);
ylabel('\Delta F');
plot(xlim(),[3 3],'k--');
ylabel('\Delta F');

results=[];
results.fvals=fvals;
results.methods=methods;
results.subjects=subjects;
results.woi=woi;
results.params=params;

out_dir=fullfile('../output',surface,'motor_erf');
if params.mpm_surfs
    out_dir=fullfile(out_dir, 'mpm_surfs');
else
    out_dir=fullfile(out_dir, 't1_surfs');
end
save(fullfile(out_dir, 'resp_results.mat'), 'results');