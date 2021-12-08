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
	b) export based=$OPTARG ;;
	t) export version=$OPTARG ;;
	esac
done
## takes project, subject, and session as inputs

pilotdir=${based}/original_location_of_images_from_XNAT
IMAGEDIR=${based}/singularity_images
tmpdir=${based}/${version}/testing
scripts=${based}/${version}/scripts
bids_out=${based}/${version}/bids_only
conn_out=${based}/${version}/conn_out
dataqc=${based}/${version}/data_qc
stmpdir=${based}/${version}/scratch/stmp
scachedir=${based}/${version}/scratch/scache

cd $pilotdir

DIR=${CLEANPROJECT}/${CLEANSUBJECT}/${CLEANSESSION}


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
mkdir -p ${tmpdir}/${project}/${CLEANSUBJECT}/${session}
cp -R ${pilotdir}/${DIR} ${tmpdir}/${project}/${CLEANSUBJECT}/${session}

subject="sub-"${CLEANSUBJECT}
sesname="ses-"${session}

	projDir=${tmpdir}/${project}
	scripts=${based}/${version}/scripts

	cd $projDir

	IMAGEDIR=${based}/singularity_images
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
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dWarp -oblique2card -prefix /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz /datafs/"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dresample -dxyz 1 1 1 -prefix /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz -input /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dWarp -oblique2card -prefix /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz /datafs/"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dresample -dxyz 1 1 1 -prefix /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz -input /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dWarp -oblique2card -prefix /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz /datafs/"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dresample -dxyz 1 1 1 -prefix /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz -input /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz
	
	echo "Intensity Non-Uniformity Correction with FSL FAST"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif fast -B -b -t 2 /dataqsm/${subject}_${sesname}_ndi_mag_fp2.nii
	#flirt transform routine
       	#extract brain from fmriprep
        echo "Extracting brain from T1w based on fMRIPrep ANTs output"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif fslmaths /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz -mas /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz
	echo "Registering resampled deobliqued preprocessed T1w image to swi magnitude (see fmriprep anat outputs for more details)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif flirt -cost normmi -dof 12 -in /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz -ref /dataqsm/${subject}_${sesname}_ndi_mag_fp2_restore.nii.gz -omat /dataqsm/rage2swi.mat -out /dataqsm/rage_in_mag.nii.gz	
	echo "Inverting transform matrix"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif convert_xfm -omat /dataqsm/swi2rage.mat -inverse /dataqsm/rage2swi.mat
	echo "Registering qsm magnitude image to resampled deobliqued preprocessed T1w image space (see fmriprep anat outputs for more details)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif flirt -interp sinc -in /dataqsm/"$subject"_"$sesname"_ndi_qsm_fp2 -ref /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz -applyxfm -init /dataqsm/swi2rage.mat -out /dataqsm/QSM_to_RAGE.nii.gz
	echo "Calculation ROI-wise stats on T1w space QSM image using fslstats"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm,${scripts}:/scripts $IMAGEDIR/neurodoc.sif /scripts/qsm_stats_rage.sh ${subject} ${sesname}
