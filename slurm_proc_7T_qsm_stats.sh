#!/bin/bash
#slurm_process_pipeline.sh

while getopts :p:s:z:m:f:l:b:t: option; do
	case ${option} in
    	p) export CLEANPROJECT=$OPTARG ;;
    	s) export CLEANSESSION=$OPTARG ;;
    	z) export CLEANSUBJECT=$OPTARG ;;
	m) export MINQC=$OPTARG ;;
	f) export fieldmaps=$OPTARG ;;
	l) export longitudinal=$OPTARG ;;
	b) export base_dir=$OPTARG ;;
	t) export version=$OPTARG ;;
	esac
done

IMAGEDIR=${base_dir}/apptainer_images
scripts=${base_dir}/${version}/scripts
stmpdir=${base_dir}/${version}/scratch/stmp
scachedir=${base_dir}/${version}/scratch/scache

## setup our variables and change to the session directory

echo ${CLEANPROJECT}
echo ${CLEANSUBJECT}
echo ${CLEANSESSION}
pwd

#translating naming conventions
echo "${CLEANSESSION: -1}"
session="${CLEANSESSION: -1}"
echo ${session}
project=${CLEANPROJECT}

subject="sub-"${CLEANSUBJECT}
sesname="ses-"${session}

projDir=${base_dir}/${version}/testing/${project}

cd $projDir

IMAGEDIR=${base_dir}/apptainer_images
CACHESING=${scachedir}/${project}_${subject}_${sesname}_dcm2rsfc
TMPSING=${stmpdir}/${project}_${subject}_${sesname}_dcm2rsfc
mkdir $CACHESING
mkdir $TMPSING

ses=${sesname:4}
sub=${subject:4}

cd ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out
roi_names=$scripts/aparc_cort_subcort_labels.txt
acqtag="_acq-mp2rageunidenoised_"
echo "afni deoblique and resample fmriprep anat outputs"
APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm \
	$IMAGEDIR/neurodoc.sif 3dWarp -oblique2card -prefix /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz \
	/datafs/"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz

APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm \
	$IMAGEDIR/neurodoc.sif 3dresample -dxyz 1 1 1 -prefix /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz \
	-input /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz

APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm \
	$IMAGEDIR/neurodoc.sif 3dWarp -oblique2card -prefix /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz \
	/datafs/"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz

APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm \
	$IMAGEDIR/neurodoc.sif 3dresample -dxyz 1 1 1 -prefix /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz \
	-input /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz

APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm \
	$IMAGEDIR/neurodoc.sif 3dWarp -oblique2card -prefix /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz \
	/datafs/"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz

APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm \
	$IMAGEDIR/neurodoc.sif 3dresample -dxyz 1 1 1 -prefix /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz \
	-input /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz

echo "Intensity Non-Uniformity Correction with FSL FAST"
APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm \
	$IMAGEDIR/neurodoc.sif fast -B -b -t 2 /dataqsm/${subject}_${sesname}_ndi_mag_fp2.nii

#flirt transform routine
#extract brain from fmriprep
echo "Extracting brain from T1w base_dir on fMRIPrep ANTs output"
APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm \
	$IMAGEDIR/neurodoc.sif fslmaths /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz \
	-mas /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz \
	/dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz

echo "Registering swi magnitude image to resampled deobliqued preprocessed T1w (see fmriprep anat outputs for more details)"
APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm \
	$IMAGEDIR/neurodoc.sif flirt -cost normmi -dof 12 -in /dataqsm/${subject}_${sesname}_ndi_mag_fp2_restore.nii.gz \
	-ref /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz \
	-omat /dataqsm/swi2rage.mat -out /dataqsm/mag_in_rage.nii.gz	

echo "Inverting transform matrix"
APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm \
	$IMAGEDIR/neurodoc.sif convert_xfm -omat /dataqsm/rage2swi.mat -inverse /dataqsm/swi2rage.mat

echo "Registering resampled deobliqued freesurfer parcellation to swi magnitude image (see fmriprep anat outputs for more details)"
APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm \
	$IMAGEDIR/neurodoc.sif flirt -interp sinc -in /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz \
	-ref /dataqsm/${subject}_${sesname}_ndi_mag_fp2_restore.nii.gz -applyxfm -init /dataqsm/rage2swi.mat \
	-out /dataqsm/FS_to_SWI.nii.gz

echo "Calculation ROI-wise stats on QSM image using fslstats"
APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm,${scripts}:/scripts \
	$IMAGEDIR/neurodoc.sif /scripts/qsm_stats.sh ${subject} ${sesname}
