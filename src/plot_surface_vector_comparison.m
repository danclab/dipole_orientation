function plot_surface_vector_comparison(subjects, varargin)

defaults = struct('surf_dir', '../../beta_burst_layers/data/surf','mpm_surfs',true);  %define default values
params = struct(varargin{:});
for f = fieldnames(defaults)',  
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

methods={'ds_surf_norm','orig_surf_norm','variational'};

pial_vectors={};
white_vectors={};

for subj_idx=1:length(subjects)
    subj_info=subjects(subj_idx);
    if params.mpm_surfs
        subj_surf_dir=fullfile(params.surf_dir, sprintf('%s-synth', subj_info.subj_id), 'surf');
    else
        subj_surf_dir=fullfile(params.surf_dir, subj_info.subj_id, 'surf');
    end
    
    subj_method_pial_vectors=[];
    subj_method_white_vectors=[];
    
    for method_idx=1:length(methods)
        method_pial_fname=sprintf('pial.ds.%s.gii',methods{method_idx});
        method_white_fname=sprintf('white.ds.%s.gii',methods{method_idx});

        pial=gifti(fullfile(subj_surf_dir, method_pial_fname));
        white=gifti(fullfile(subj_surf_dir, method_white_fname));
        
        subj_pial_vectors=pial.normals;
        subj_method_pial_vectors(method_idx,:,:)=subj_pial_vectors;        
        subj_white_vectors=white.normals;
        subj_method_white_vectors(method_idx,:,:)=subj_white_vectors;
    end
    pial_vectors{subj_idx}=subj_method_pial_vectors;
    white_vectors{subj_idx}=subj_method_white_vectors;
end

c=cbrewer('qual','Accent',8);

figure();
for method_idx=1:length(methods)
    subplot(1,length(methods),method_idx);
    hold all
    subj_mean_diffs=[];
    for subj_idx=1:length(subjects)
        subj_method_pial_vectors=pial_vectors{subj_idx};
        subj_method_white_vectors=white_vectors{subj_idx};
        method_pial_vectors=squeeze(subj_method_pial_vectors(method_idx,:,:));
        method_white_vectors=squeeze(subj_method_white_vectors(method_idx,:,:));
        angle_diff=zeros(1,size(method_pial_vectors,1));
        for i=1:size(method_pial_vectors,1)
            x=method_pial_vectors(i,:);
            y=method_white_vectors(i,:);
            %angle_diff(i)=radtodeg(2 * atan(norm(x*norm(y) - norm(x)*y) / norm(x * norm(y) + norm(x) * y)));
            angle_diff(i)=atan2d(norm(cross(x,y)),dot(x,y));
            if angle_diff(i)>90
                angle_diff(i)=180-angle_diff(i);
            end
        end
        [f,xi] = ksdensity(angle_diff,linspace(0,180));
        plot(xi,f,'Color',c(subj_idx,:),'LineWidth',2);
        plot(ones(1,2).*nanmean(angle_diff), ylim(), '--', 'Color', c(subj_idx,:),'HandleVisibility','off');
        disp(sprintf('Method %s, subject %d, M=%.3f, SD=%.3f', methods{method_idx}, subj_idx, nanmean(angle_diff), nanstd(angle_diff)))
        xlim([0 90]);
        title(methods{method_idx});
        subj_mean_diffs(end+1)=nanmean(angle_diff);
    end
    disp(sprintf('Method %s,M=%.3f, SD=%.3f', methods{method_idx}, nanmean(subj_mean_diffs), nanstd(subj_mean_diffs)))
    legend('s1','s2','s3','s4','s5','s6','s7','s8');
end