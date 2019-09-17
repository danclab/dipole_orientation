function plot_methods_vectors(subj_info, varargin)

defaults = struct('surf_dir', '../../beta_burst_layers/data/surf','mpm_surfs',true);  %define default values
params = struct(varargin{:});
for f = fieldnames(defaults)',  
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

methods={'ds_surf_norm','orig_surf_norm','link_vector','fs_anat_link'};

pial=gifti(fullfile(params.surf_dir, sprintf('%s-synth',subj_info.subj_id), 'surf/pial.ds.gii'));
wm=gifti(fullfile(params.surf_dir, sprintf('%s-synth',subj_info.subj_id), 'surf/white.ds.gii'));

ax=plot_surfaces([pial wm],[0.25,1.0],[0,0],[.75,.75],[1,1],...
    {'phong','phong'},[0.5 0.5 0.5;0.5 0.5 0.5]);
hold all

method_colors=[53 42 134; 6 156 207; 165 190 106; 248 250 13];
for method_idx=1:length(methods)
    method=methods{method_idx};
    pial_norms=gifti(fullfile(params.surf_dir, sprintf('%s-synth',subj_info.subj_id), 'surf', sprintf('pial.ds.%s.gii',method)));
    % Times -1 so that the vectors are outward facing
    norms=pial_norms.normals(:,:).*5;
    quiver3(pial.vertices(:,1),pial.vertices(:,2),pial.vertices(:,3),norms(:,1),norms(:,2),norms(:,3),2,'ShowArrowHead','off','LineWidth',1,'Color',method_colors(method_idx,:)./255.0);
end
set(ax,'CameraViewAngle',3.9097);
set(ax,'CameraUpVector',[0.1924 -0.2541 0.9478]);
set(ax,'CameraPosition',1.0e+03.*[-1.6792 0.0925 0.3779]);
%print(gcf,'../output/method_vectors.png','-dpng','-r900');
%print(gcf,'../output/method_vectors.eps','-depsc','-r900');
