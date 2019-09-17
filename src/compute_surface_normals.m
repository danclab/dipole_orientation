function norm=compute_surface_normals(subjects_dir, subj_id, surface, method)

surf_dir=fullfile(subjects_dir, subj_id, 'surf');

if strcmp(surface,'white-pial')
    ds_surface=gifti(fullfile(surf_dir, 'white.ds-pial.ds.gii'));
else
    ds_surface=gifti(fullfile(surf_dir, sprintf('%s.ds.gii', surface)));
end
norm = spm_mesh_normals(struct('faces',ds_surface.faces,...
    'vertices',ds_surface.vertices),true);

switch method
    %% Orig surface normals
    case 'orig_surf_norm'
        if strcmp(surface,'white-pial')
            ds_white=gifti(fullfile(surf_dir, 'white.ds.gii'));
            orig_white=gifti(fullfile(surf_dir, 'white.gii'));
            orig_white_idx=knnsearch(orig_white.vertices,ds_white.vertices);
            white_norm=spm_mesh_normals(struct('faces',orig_white.faces,...
                'vertices',orig_white.vertices),true);
            white_norm=white_norm(orig_white_idx,:);
            
            ds_pial=gifti(fullfile(surf_dir, 'pial.ds.gii'));
            orig_pial=gifti(fullfile(surf_dir, 'pial.gii'));
            orig_pial_idx=knnsearch(orig_pial.vertices,ds_pial.vertices);
            pial_norm=spm_mesh_normals(struct('faces',orig_pial.faces,...
                'vertices',orig_pial.vertices),true);
            pial_norm=pial_norm(orig_pial_idx,:);
            norm=[white_norm; pial_norm];
        else
            orig_surface=gifti(fullfile(surf_dir, sprintf('%s.gii', surface)));
            orig_idx=knnsearch(orig_surface.vertices,ds_surface.vertices);
            norm=spm_mesh_normals(struct('faces',orig_surface.faces,...
                'vertices',orig_surface.vertices),true);
            norm=norm(orig_idx,:);
        end
    case 'link_vector'
        switch surface
            case 'pial'
                ds_white=gifti(fullfile(surf_dir, 'white.ds.gii'));
                norm=ds_white.vertices-ds_surface.vertices;
            case 'white'
                ds_pial=gifti(fullfile(surf_dir, 'pial.ds.gii'));
                % Multiply by -1 so vectors point inward (toward inside of
                % brain)
                norm=(ds_pial.vertices-ds_surface.vertices).*-1;
            case 'white-pial'
                ds_pial=gifti(fullfile(surf_dir, 'pial.ds.gii'));
                ds_white=gifti(fullfile(surf_dir, 'white.ds.gii'));
                % Multiply white norms by -1 so vectors point inward
                % (toward inside of brain)
                norm=[(ds_pial.vertices-ds_white.vertices).*-1; ds_white.vertices-ds_pial.vertices];
        end
        normN = sqrt(sum(norm.^2,2));
        bad_idx=find(normN < eps);
        normN(bad_idx)=1;
        norm = bsxfun(@rdivide,norm,normN);
        norm=double(norm);        
                
        % Replace where 0 with face normal
        norm2 = spm_mesh_normals(struct('faces',ds_surface.faces,...
            'vertices',ds_surface.vertices),true);
        z=find(sum(norm,2)==0);
        norm(z,:)=norm2(z,:);
%     case 'anat_link'
%         orig_surface=gifti(fullfile(surf_dir, 'pial.gii'));
%         pial_idx=knnsearch(orig_surface.vertices,ds_surface.vertices);
%         lh_smoothed_normals_coords=dlmread(fullfile(surf_dir, 'lh.smoothed_normals_coords.txt'));
%         rh_smoothed_normals_coords=dlmread(fullfile(surf_dir, 'rh.smoothed_normals_coords.txt'));
%         all_smoothed_normals_coords=[lh_smoothed_normals_coords; rh_smoothed_normals_coords];
%          
%         lh_smoothed_origin_coords=dlmread(fullfile(surf_dir,'lh.smoothed_orig_coords.txt'));
%         rh_smoothed_origin_coords=dlmread(fullfile(surf_dir,'rh.smoothed_orig_coords.txt'));
%         all_smoothed_origin_coords=[lh_smoothed_origin_coords; rh_smoothed_origin_coords];
%          
%         origin_idx=knnsearch(all_smoothed_origin_coords,orig_surface.vertices);
%         all_smoothed_origin_coords=all_smoothed_origin_coords(origin_idx,:);
%         all_smoothed_normals_coords=all_smoothed_normals_coords(origin_idx,:);
%          
%         norm=all_smoothed_normals_coords-all_smoothed_origin_coords;
%         norm=norm(pial_idx,:);
%         normN = sqrt(sum(norm.^2,2));
%         bad_idx=find(normN < eps);
%         normN(bad_idx)=1;
%         norm = bsxfun(@rdivide,norm,normN);
%         norm=double(norm);
%          
%         % Replace where 0 with face normal
%         norm2 = spm_mesh_normals(struct('faces',ds_surface.faces,'vertices',ds_surface.vertices),true);
%         z=find(sum(norm,2)==0);
%         norm(z,:)=norm2(z,:); 
    case 'fs_anat_link'
        if strcmp(surface, 'white-pial')
            ds_white=gifti(fullfile(surf_dir, 'white.ds.gii'));
            orig_white=gifti(fullfile(surf_dir, 'white.gii'));
            orig_white_idx=knnsearch(orig_white.vertices,ds_white.vertices);
            lh_white_normals=dlmread(fullfile(surf_dir, 'lh.white.variational_normals.txt'));
            rh_white_normals=dlmread(fullfile(surf_dir, 'rh.white.variational_normals.txt'));
            white_normals=[lh_white_normals; rh_white_normals].*-1;        
            white_normals=white_normals(orig_white_idx,:);
            
            ds_pial=gifti(fullfile(surf_dir, 'pial.ds.gii'));
            orig_pial=gifti(fullfile(surf_dir, 'pial.gii'));
            orig_pial_idx=knnsearch(orig_pial.vertices,ds_pial.vertices);
            lh_pial_normals=dlmread(fullfile(surf_dir, 'lh.pial.variational_normals.txt'));
            rh_pial_normals=dlmread(fullfile(surf_dir, 'rh.pial.variational_normals.txt'));
            pial_normals=[lh_pial_normals; rh_pial_normals];        
            pial_normals=pial_normals(orig_pial_idx,:);
            
            norm=[white_normals; pial_normals];
        else 
            orig_surface=gifti(fullfile(surf_dir, sprintf('%s.gii',surface)));
            orig_idx=knnsearch(orig_surface.vertices,ds_surface.vertices);
            lh_normals=dlmread(fullfile(surf_dir, sprintf('lh.%s.variational_normals.txt', surface)));
            rh_normals=dlmread(fullfile(surf_dir, sprintf('rh.%s.variational_normals.txt', surface)));
            all_normals=[lh_normals; rh_normals];        
            % Multiply by -1 so vectors point inward (toward inside of
            % brain)
            if strcmp(surface,'white')
                all_normals=-1.*all_normals;
            end
            norm=all_normals(orig_idx,:);
        end         
        
        normN = sqrt(sum(norm.^2,2));
        bad_idx=find(normN < eps);
        normN(bad_idx)=1;
        norm = bsxfun(@rdivide,norm,normN);
        norm=double(norm);
         
        % Replace where 0 with face normal
        norm2 = spm_mesh_normals(struct('faces',ds_surface.faces,...
            'vertices',ds_surface.vertices),true);
        z=find(sum(norm,2)==0);
        norm(z,:)=norm2(z,:); 
end