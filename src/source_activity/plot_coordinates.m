function plot_coordinates(subj_info, methods, coords, cam_dir, varargin)

defaults = struct('ax', 0);  %define default values
params = struct(varargin{:});
for f = fieldnames(defaults)',  
    if ~isfield(params, f{1}),
        params.(f{1}) = defaults.(f{1});
    end
end

if params.ax==0
    figure();
    params.ax=subplot(1,1,1);
end

subj_pial_fname=fullfile('../../../../inProgress/beta_burst_layers/data/surf',sprintf('%s-synth',subj_info.subj_id),'surf','pial.ds.inflated.gii');
subj_pial=gifti(subj_pial_fname);
ax=plot_surface(subj_pial, 'ax', params.ax, 'surface_alpha', 0.2);
% Plot coordinates
[x,y,z]=sphere();
colors=get(gca,'ColorOrder');
for m_idx=1:length(methods)
    c=colors(m_idx,:);
    coord=squeeze(coords(m_idx,:));
    hp=surface(x.*2+double(coord(1)),y.*2+double(coord(2)),z.*2+double(coord(3)),...
       'FaceColor',c,'EdgeColor','none','linestyle','none','FaceLighting','phong',...
       'SpecularStrength',0,'DiffuseStrength',1,'AmbientStrength',1);
end
set(gca,'CameraViewAngle',4.028);
set(ax,'CameraUpVector',subj_info.camera_up_vector(cam_dir));
set(ax,'CameraPosition',subj_info.camera_position(cam_dir));