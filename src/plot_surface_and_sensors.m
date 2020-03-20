function plot_surface_and_sensors()

spm('defaults','eeg');
methods={'ds_surf_norm','orig_surf_norm','link_vector','fs_anat_link'};

for m_idx=1:length(methods)
    fname=fullfile('C:/Users/jbonaiuto/Dropbox/Projects/inProgress/dipole_moment_priors/output/data/gb070167/',...
        sprintf('pial_mpdots_rcinstr_Tafdf_%s.mat', methods{m_idx}));
    D=spm_eeg_load(fname);

    forward = D.inv{1}.forward;
    vol      = forward(1).vol;
    modality = forward(1).modality;
    sens     = forward(1).sensors;
    Mcortex  = forward(1).mesh;

    chanind = strmatch(modality, D.chantype);
    chanind = setdiff(chanind, D.badchannels);

    face    = Mcortex.face;
    vert    = Mcortex.vert;
    g=gifti();
    g.faces=face;
    g.vertices=vert;
    
    figs(m_idx)=figure();%'PaperPosition',[-5.411458333333332,2.213541666666667,19.322916666666664,6.572916666666665],...
        %'PaperUnits','inches','Position',[1,1,1855,631]);
    ax=plot_surface(g, 'ax', gca);

    hold on

    ctx=gifti(fullfile('C:/Users/jbonaiuto/Dropbox/Projects/inProgress/beta_burst_layers/data/surf/gb070167-synth/surf',...
        sprintf('pial.ds.%s.gii', methods{m_idx})));
    % Transform normal vectors into right space
    M=D.inv{1}.forward(1).fromMNI*D.inv{1}.mesh.Affine;
    norm=[ctx.normals ones(size(ctx.normals,1),1)]*inv(M')';
    norm=norm(:,1:3);
    normN = sqrt(sum(norm.^2,2));
    bad_idx=find(normN < eps);
    normN(bad_idx)=1;
    norm = bsxfun(@rdivide,norm,normN);
    norm=double(norm)*-1;
    quiver3(vert(:,1),vert(:,2),vert(:,3),norm(:,1),norm(:,2),norm(:,3),'ShowArrowHead',false,'AutoScaleFactor',5,'Color',[126 2 47]./255.0);


    [vol, sens] = ft_prepare_vol_sens(vol, sens, 'channel', D.chanlabels(chanind));


    ft_plot_sens(sens, 'style', '*', 'edgecolor', 'k', 'elecsize', 20, 'coil', ft_senstype(sens, 'eeg'));
    
    set(ax,'CameraViewAngle',4.766793353982266);
    set(ax,'CameraUpVector',[0.999480072899086,-0.000498917938299411,-0.032238718313994]);
    set(ax,'CameraPosition',[0.069588472016092,-0.003172317653279,2.645534827999546]);
end

for m_idx=1:length(methods)
    saveas(figs(m_idx), fullfile('../output', sprintf('surface_and_sensors_%s.png',methods{m_idx})), 'png');
    saveas(figs(m_idx), fullfile('../output', sprintf('surface_and_sensors_%s.eps',methods{m_idx})), 'epsc');
end
