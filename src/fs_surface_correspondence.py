import os
import subprocess
import nibabel as nb
import numpy as np

subject_ids=["gb070167","rh110484","ag170592","rk131286","sp260284","nc120894","bvw270685","ad080391"]
subjects_dir='/home/bonaiuto/Dropbox/Projects/inProgress/dipole_moment_priors/data/t1_surf'

os.environ['SUBJECTS_DIR'] = subjects_dir
hemis=['lh','rh']
surfs=['pial','white']

for surf in surfs:
    output_vectors_suffix='%s.variational_normals.txt' % surf
    
    for subject_id in subject_ids:
        for h, hemi in enumerate(hemis):
            output_vectors_name = os.path.join(subjects_dir, subject_id, 'surf', hemi + '.' + output_vectors_suffix)

            gray_surf_name = os.path.join(subjects_dir, subject_id, 'surf', hemi + '.pial')
            white_surf_name = os.path.join(subjects_dir, subject_id, 'surf', hemi + '.white')

            # For computing vectors on pial surface, reverse order of surfaces
            if surf=='pial'
                subprocess.call('mris_thickness -variational -w 0 -pial white -white pial ' + subject_id + ' ' + hemi + ' ' + hemi + '.thickness', shell=True)
            else:
                subprocess.call('mris_thickness -variational -w 0 -pial pial -white white ' + subject_id + ' ' + hemi + ' ' + hemi + '.thickness', shell=True)
            
            os.rename(hemi + '.normals.mgz', os.path.join(subjects_dir, subject_id, 'surf', hemi + '.normals.mgz'))
            os.rename(hemi + '.normals.init.mgz', os.path.join(subjects_dir, subject_id, 'surf', hemi + '.normals.init.mgz'))
            os.rename(hemi + '.thickness.out', os.path.join(subjects_dir, subject_id, 'surf', hemi + '.thickness.out'))

            links = nb.load(os.path.join(subjects_dir, subject_id, 'surf', hemi + '.normals.mgz'))
            links_new = links.get_data()[:, 0, 0, :]

            np.savetxt(output_vectors_name, links_new)
