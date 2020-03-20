function plot_vector_comparison(subjects, surface, varargin)

defaults = struct('surf_dir', '../../../inProgress/beta_burst_layers/data/surf','mpm_surfs',true);  %define default values
params = struct(varargin{:});
for f = fieldnames(defaults)',  
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

methods={'ds_surf_norm','cps','orig_surf_norm','link_vector','variational'};

vectors={};

for subj_idx=1:length(subjects)
    subj_info=subjects(subj_idx);
    if params.mpm_surfs
        subj_surf_dir=fullfile(params.surf_dir, sprintf('%s-synth', subj_info.subj_id), 'surf');
    else
        subj_surf_dir=fullfile(params.surf_dir, subj_info.subj_id, 'surf');
    end
    
    subj_method_vectors=[];
    
    for method_idx=1:length(methods)
        method_fname=sprintf('%s.ds.%s.gii',surface,methods{method_idx});

        surf=gifti(fullfile(subj_surf_dir, method_fname));
        subj_vectors=surf.normals;
        subj_method_vectors(method_idx,:,:)=subj_vectors;
    end
    vectors{subj_idx}=subj_method_vectors;
end

c=cbrewer('qual','Accent',8);

figure();
for method_idx1=1:length(methods)
    for method_idx2=1:length(methods)
        if method_idx1<method_idx2
            subplot(length(methods),length(methods),(method_idx1-1)*length(methods)+method_idx2);
            hold all
            subj_mean_diffs=[];
            for subj_idx=1:length(subjects)
                subj_method_vectors=vectors{subj_idx};
                method1_vectors=squeeze(subj_method_vectors(method_idx1,:,:));
                method2_vectors=squeeze(subj_method_vectors(method_idx2,:,:));
                angle_diff=zeros(1,size(method1_vectors,1));
                for i=1:size(method1_vectors,1)
                    x=method1_vectors(i,:);
                    y=method2_vectors(i,:);
                    %angle_diff(i)=radtodeg(2 * atan(norm(x*norm(y) - norm(x)*y) / norm(x * norm(y) + norm(x) * y)));
                    angle_diff(i)=atan2d(norm(cross(x,y)),dot(x,y));
                    if angle_diff(i)>90
                        angle_diff(i)=180-angle_diff(i);
                    end
                end
                [f,xi] = ksdensity(angle_diff,linspace(0,180));
                plot(xi,f,'Color',c(subj_idx,:),'LineWidth',2);
                plot(ones(1,2).*nanmean(angle_diff), ylim(), '--', 'Color', c(subj_idx,:),'HandleVisibility','off');
                disp(sprintf('Methods %s-%s, subject %d, M=%.3f, SD=%.3f', methods{method_idx1}, methods{method_idx2}, subj_idx, nanmean(angle_diff), nanstd(angle_diff)))
                xlim([0 90]);
                title(methods{method_idx1});
                ylabel(methods{method_idx2});
                subj_mean_diffs(end+1)=nanmean(angle_diff);
            end
            disp(sprintf('Methods %s-%s,M=%.3f, SD=%.3f', methods{method_idx1}, methods{method_idx2}, nanmean(subj_mean_diffs), nanstd(subj_mean_diffs)))
            legend('s1','s2','s3','s4','s5','s6','s7','s8');
        elseif method_idx1==method_idx2
            subplot(length(methods),length(methods),(method_idx1-1)*length(methods)+method_idx2);
            xlim([0 90]);
            if method_idx2==length(methods)
                xlabel('Angular vector difference');
                ylabel('Probability density');
            end
        end        
    end
end