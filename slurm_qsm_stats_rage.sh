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

	echo "ASPIRE QSM"
	echo "Generating QSM with hybrid Cornell-Berkeley tools"
	echo "Fractional intensity threshold set to 0.1 (see scripts/matlab/ndi_qsm_fp1.sh)"
	cd ${projDir}/bids/derivatives/swi/${subject}/${sesname}
        mkdir ndi_out/old
        mv ./*nii ./ndi_out/old/
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}:/datain,${IMAGEDIR}/ndi:/ndi,${scripts}/matlab:/scripts ${IMAGEDIR}/matlab-r2019a.sif /scripts/ndi_qsm_fp1.sh
	echo "Pseudo-BIDSifying QSM outputs"
	cd ${projDir}/bids/derivatives/swi/${subject}/${sesname}
	mv ./ndi_out/mag.nii ./ndi_out/${subject}_${sesname}_ndi_mag_fp1.nii
	mv ./ndi_out/phs.nii ./ndi_out/${subject}_${sesname}_ndi_phs_fp1.nii
	mv ./ndi_out/qsm.nii ./ndi_out/${subject}_${sesname}_ndi_qsm_fp1.nii
	
	echo "Generating QSM with hybrid Cornell-Berkeley tools"
	echo "Fractional intensity threshold set to 0.2 (see scripts/matlab/ndi_qsm_fp2.sh)"
	cd ${projDir}/bids/derivatives/swi/${subject}/${sesname}
        mkdir ndi_out/old
        mv ./*nii ./ndi_out/old/
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}:/datain,${IMAGEDIR}/ndi:/ndi,${scripts}/matlab:/scripts ${IMAGEDIR}/matlab-r2019a.sif /scripts/ndi_qsm_fp2.sh
	echo "Pseudo-BIDSifying QSM outputs"
	cd ${projDir}/bids/derivatives/swi/${subject}/${sesname}
	mv ./ndi_out/mag.nii ./ndi_out/${subject}_${sesname}_ndi_mag_fp2.nii
	mv ./ndi_out/phs.nii ./ndi_out/${subject}_${sesname}_ndi_phs_fp2.nii
	mv ./ndi_out/qsm.nii ./ndi_out/${subject}_${sesname}_ndi_qsm_fp2.nii
	
	echo "Generating QSM with hybrid Cornell-Berkeley tools"
	echo "Fractional intensity threshold set to 0.3 (see scripts/matlab/ndi_qsm_fp3.sh)"
	cd ${projDir}/bids/derivatives/swi/${subject}/${sesname}
        mkdir ndi_out/old
        mv ./*nii ./ndi_out/old/
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}:/datain,${IMAGEDIR}/ndi:/ndi,${scripts}/matlab:/scripts ${IMAGEDIR}/matlab-r2019a.sif /scripts/ndi_qsm_fp3.sh
	echo "Pseudo-BIDSifying QSM outputs"
	cd ${projDir}/bids/derivatives/swi/${subject}/${sesname}
	mv ./ndi_out/mag.nii ./ndi_out/${subject}_${sesname}_ndi_mag_fp3.nii
	mv ./ndi_out/phs.nii ./ndi_out/${subject}_${sesname}_ndi_phs_fp3.nii
	mv ./ndi_out/qsm.nii ./ndi_out/${subject}_${sesname}_ndi_qsm_fp3.nii
	
	echo "OLD SWI SEQUENCE QSM"
	echo "Generating QSM with hybrid Cornell-Berkeley tools"
	echo "Fractional intensity threshold set to 0.1 (see scripts/matlab/ndi_qsm_fp1.sh)"
	cd ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}
        mkdir ndi_out/old
        mv ./*nii ./ndi_out/old/
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}:/datain,${IMAGEDIR}/ndi:/ndi,${scripts}/matlab:/scripts ${IMAGEDIR}/matlab-r2019a.sif /scripts/ndi_qsm_fp1.sh
	echo "Pseudo-BIDSifying QSM outputs"
	cd ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}
	mv ./ndi_out/mag.nii ./ndi_out/${subject}_${sesname}_ndi_mag_fp1.nii
	mv ./ndi_out/phs.nii ./ndi_out/${subject}_${sesname}_ndi_phs_fp1.nii
	mv ./ndi_out/qsm.nii ./ndi_out/${subject}_${sesname}_ndi_qsm_fp1.nii
	
	echo "Generating QSM with hybrid Cornell-Berkeley tools"
	echo "Fractional intensity threshold set to 0.2 (see scripts/matlab/ndi_qsm_fp2.sh)"
	cd ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}
        mkdir ndi_out/old
        mv ./*nii ./ndi_out/old/
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}:/datain,${IMAGEDIR}/ndi:/ndi,${scripts}/matlab:/scripts ${IMAGEDIR}/matlab-r2019a.sif /scripts/ndi_qsm_fp2.sh
	echo "Pseudo-BIDSifying QSM outputs"
	cd ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}
	mv ./ndi_out/mag.nii ./ndi_out/${subject}_${sesname}_ndi_mag_fp2.nii
	mv ./ndi_out/phs.nii ./ndi_out/${subject}_${sesname}_ndi_phs_fp2.nii
	mv ./ndi_out/qsm.nii ./ndi_out/${subject}_${sesname}_ndi_qsm_fp2.nii
	
	echo "Generating QSM with hybrid Cornell-Berkeley tools"
	echo "Fractional intensity threshold set to 0.3 (see scripts/matlab/ndi_qsm_fp3.sh)"
	cd ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}
        mkdir ndi_out/old
        mv ./*nii ./ndi_out/old/
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}:/datain,${IMAGEDIR}/ndi:/ndi,${scripts}/matlab:/scripts ${IMAGEDIR}/matlab-r2019a.sif /scripts/ndi_qsm_fp3.sh
	echo "Pseudo-BIDSifying QSM outputs"
	cd ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}
	mv ./ndi_out/mag.nii ./ndi_out/${subject}_${sesname}_ndi_mag_fp3.nii
	mv ./ndi_out/phs.nii ./ndi_out/${subject}_${sesname}_ndi_phs_fp3.nii
	mv ./ndi_out/qsm.nii ./ndi_out/${subject}_${sesname}_ndi_qsm_fp3.nii
	echo "ASPIRE QSM PROCESSING"
	
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
	
	echo "f threshold 0.1"
	echo "Intensity Non-Uniformity Correction with FSL FAST"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif fast -B -b -t 2 /dataqsm/${subject}_${sesname}_ndi_mag_fp1.nii
	#flirt transform routine
       #extract brain from fmriprep
        echo "Extracting brain from T1w based on fMRIPrep ANTs output"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif fslmaths /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz -mas /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz
	echo "Registering swi magnitude image to resampled deobliqued preprocessed T1w (see fmriprep anat outputs for more details)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif flirt -cost normmi -dof 12 -in /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz -ref /dataqsm/${subject}_${sesname}_ndi_mag_fp1_restore.nii.gz -omat /dataqsm/rage2swi.mat -out /dataqsm/rage_in_mag.nii.gz	
	echo "Inverting transform matrix"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif convert_xfm -omat /dataqsm/swi2rage.mat -inverse /dataqsm/rage2swi.mat
	echo "Registering resampled deobliqued freesurfer parcellation to swi magnitude image (see fmriprep anat outputs for more details)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif flirt -interp sinc -in /dataqsm/"$subject"_"$sesname"_ndi_qsm_fp1 -ref /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz -applyxfm -init /dataqsm/swi2rage.mat -out /dataqsm/QSM_to_RAGE.nii.gz
	echo "Calculation ROI-wise stats on QSM image using fslstats"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm,${scripts}:/scripts $IMAGEDIR/neurodoc.sif /scripts/qsm_stats_rage.sh ${subject} ${sesname} 1 ASPIRE
	mv ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out/QSM_to_RAGE.nii.gz ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out/QSM_to_RAGE_fp1.nii.gz
	rm -rf ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out/masks
	
	echo "f threshold 0.2"
	echo "Intensity Non-Uniformity Correction with FSL FAST"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif fast -B -b -t 2 /dataqsm/${subject}_${sesname}_ndi_mag_fp2.nii
	#flirt transform routine
	echo "Registering swi magnitude image to resampled deobliqued preprocessed T1w (see fmriprep anat outputs for more details)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif flirt -cost normmi -dof 12 -in /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz -ref /dataqsm/${subject}_${sesname}_ndi_mag_fp2_restore.nii.gz -omat /dataqsm/rage2swi.mat -out /dataqsm/rage_in_mag.nii.gz	
	echo "Inverting transform matrix"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif convert_xfm -omat /dataqsm/swi2rage.mat -inverse /dataqsm/rage2swi.mat
	echo "Registering resampled deobliqued freesurfer parcellation to swi magnitude image (see fmriprep anat outputs for more details)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif flirt -interp sinc -in /dataqsm/"$subject"_"$sesname"_ndi_qsm_fp2 -ref /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz -applyxfm -init /dataqsm/swi2rage.mat -out /dataqsm/QSM_to_RAGE.nii.gz
	echo "Calculation ROI-wise stats on QSM image using fslstats"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm,${scripts}:/scripts $IMAGEDIR/neurodoc.sif /scripts/qsm_stats_rage.sh ${subject} ${sesname} 2 ASPIRE
	mv ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out/QSM_to_RAGE.nii.gz ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out/QSM_to_RAGE_fp2.nii.gz
	rm -rf ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out/masks
	
	echo "f threshold 0.3"
	echo "Intensity Non-Uniformity Correction with FSL FAST"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif fast -B -b -t 2 /dataqsm/${subject}_${sesname}_ndi_mag_fp3.nii
	#flirt transform routine

	echo "Registering swi magnitude image to resampled deobliqued preprocessed T1w (see fmriprep anat outputs for more details)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif flirt -cost normmi -dof 12 -in /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz -ref /dataqsm/${subject}_${sesname}_ndi_mag_fp3_restore.nii.gz -omat /dataqsm/rage2swi.mat -out /dataqsm/rage_in_mag.nii.gz	
	echo "Inverting transform matrix"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif convert_xfm -omat /dataqsm/swi2rage.mat -inverse /dataqsm/rage2swi.mat
	echo "Registering resampled deobliqued freesurfer parcellation to swi magnitude image (see fmriprep anat outputs for more details)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif flirt -interp sinc -in /dataqsm/"$subject"_"$sesname"_ndi_qsm_fp3 -ref /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz -applyxfm -init /dataqsm/swi2rage.mat -out /dataqsm/QSM_to_RAGE.nii.gz
	echo "Calculation ROI-wise stats on QSM image using fslstats"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm,${scripts}:/scripts $IMAGEDIR/neurodoc.sif /scripts/qsm_stats_rage.sh ${subject} ${sesname} 3 ASPIRE
	mv ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out/QSM_to_RAGE.nii.gz ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out/QSM_to_RAGE_fp3.nii.gz
	rm -rf ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out/masks
	
	echo "OLD METHOD QSM PROCESSING"
	cd ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out
	roi_names=$scripts/aparc_cort_subcort_labels.txt
	acqtag="_acq-mp2rageunidenoised_"
	
	echo "afni deoblique and resample fmriprep anat outputs"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dWarp -oblique2card -prefix /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz /datafs/"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dresample -dxyz 1 1 1 -prefix /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz -input /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dWarp -oblique2card -prefix /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz /datafs/"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dresample -dxyz 1 1 1 -prefix /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz -input /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dWarp -oblique2card -prefix /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz /datafs/"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dresample -dxyz 1 1 1 -prefix /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz -input /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz
	
	echo "f threshold 0.1"
	echo "Intensity Non-Uniformity Correction with FSL FAST"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif fast -B -b -t 2 /dataqsm/${subject}_${sesname}_ndi_mag_fp1.nii
	#flirt transform routine
       #extract brain from fmriprep
        echo "Extracting brain from T1w based on fMRIPrep ANTs output"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif fslmaths /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz -mas /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz
	echo "Registering swi magnitude image to resampled deobliqued preprocessed T1w (see fmriprep anat outputs for more details)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif flirt -cost normmi -dof 12 -in /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz -ref /dataqsm/${subject}_${sesname}_ndi_mag_fp1_restore.nii.gz -omat /dataqsm/rage2swi.mat -out /dataqsm/rage_in_mag.nii.gz	
	echo "Inverting transform matrix"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif convert_xfm -omat /dataqsm/swi2rage.mat -inverse /dataqsm/rage2swi.mat
	echo "Registering resampled deobliqued freesurfer parcellation to swi magnitude image (see fmriprep anat outputs for more details)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif flirt -interp sinc -in /dataqsm/"$subject"_"$sesname"_ndi_qsm_fp1 -ref /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz -applyxfm -init /dataqsm/swi2rage.mat -out /dataqsm/QSM_to_RAGE.nii.gz
	echo "Calculation ROI-wise stats on QSM image using fslstats"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm,${scripts}:/scripts $IMAGEDIR/neurodoc.sif /scripts/qsm_stats_rage.sh ${subject} ${sesname} 1 OLD
	mv ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out/QSM_to_RAGE.nii.gz ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out/QSM_to_RAGE_fp1.nii.gz
	rm -rf ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out/masks
	
	echo "f threshold 0.2"
	echo "Intensity Non-Uniformity Correction with FSL FAST"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif fast -B -b -t 2 /dataqsm/${subject}_${sesname}_ndi_mag_fp2.nii
	#flirt transform routine
	echo "Registering swi magnitude image to resampled deobliqued preprocessed T1w (see fmriprep anat outputs for more details)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif flirt -cost normmi -dof 12 -in /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz -ref /dataqsm/${subject}_${sesname}_ndi_mag_fp2_restore.nii.gz -omat /dataqsm/rage2swi.mat -out /dataqsm/rage_in_mag.nii.gz	
	echo "Inverting transform matrix"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif convert_xfm -omat /dataqsm/swi2rage.mat -inverse /dataqsm/rage2swi.mat
	echo "Registering resampled deobliqued freesurfer parcellation to swi magnitude image (see fmriprep anat outputs for more details)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif flirt -interp sinc -in /dataqsm/"$subject"_"$sesname"_ndi_qsm_fp2 -ref /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz -applyxfm -init /dataqsm/swi2rage.mat -out /dataqsm/QSM_to_RAGE.nii.gz
	echo "Calculation ROI-wise stats on QSM image using fslstats"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm,${scripts}:/scripts $IMAGEDIR/neurodoc.sif /scripts/qsm_stats_rage.sh ${subject} ${sesname} 2 OLD
	mv ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out/QSM_to_RAGE.nii.gz ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out/QSM_to_RAGE_fp2.nii.gz
	rm -rf ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out/masks
	
	echo "f threshold 0.3"
	echo "Intensity Non-Uniformity Correction with FSL FAST"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif fast -B -b -t 2 /dataqsm/${subject}_${sesname}_ndi_mag_fp3.nii
	#flirt transform routine

	echo "Registering swi magnitude image to resampled deobliqued preprocessed T1w (see fmriprep anat outputs for more details)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif flirt -cost normmi -dof 12 -in /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz -ref /dataqsm/${subject}_${sesname}_ndi_mag_fp3_restore.nii.gz -omat /dataqsm/rage2swi.mat -out /dataqsm/rage_in_mag.nii.gz	
	echo "Inverting transform matrix"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif convert_xfm -omat /dataqsm/swi2rage.mat -inverse /dataqsm/rage2swi.mat
	echo "Registering resampled deobliqued freesurfer parcellation to swi magnitude image (see fmriprep anat outputs for more details)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif flirt -interp sinc -in /dataqsm/"$subject"_"$sesname"_ndi_qsm_fp3 -ref /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz -applyxfm -init /dataqsm/swi2rage.mat -out /dataqsm/QSM_to_RAGE.nii.gz
	echo "Calculation ROI-wise stats on QSM image using fslstats"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm,${scripts}:/scripts $IMAGEDIR/neurodoc.sif /scripts/qsm_stats_rage.sh ${subject} ${sesname} 3 OLD
	mv ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out/QSM_to_RAGE.nii.gz ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out/QSM_to_RAGE_fp3.nii.gz
	rm -rf ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out/masks
	
	
for fthresh in 1 2 3; do

fignameprefix="sub-${CLEANSUBJECT}_ses-${CLEANSESSION}_desc-QSM_fp${fthresh}"
QSM_REPORT_HTML="${projDir}/bids/derivatives/sub-${CLEANSUBJECT}_ses-${CLEANSESSION}_QSM_fp${fthresh}_REPORT.html"

qsm_resampled="/dataqsm/QSM_to_RAGE_fp${fthresh}.nii.gz"
# perhaps iterate through f values
qsm_orig="/dataqsm/${subject}_${sesname}_ndi_qsm_fp${fthresh}"


### old method
echo "Generating QC slices for original SWI sequence results" 

temp_slc="/dataqsm/QSM_slc_fp${fthresh}"
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif slicer ${qsm_orig} -L -s 1 -i -0.1 0.1 -x 0.3 ${temp_slc}x30.png -x 0.35 ${temp_slc}x35.png -x 0.4 ${temp_slc}x40.png -x 0.45 ${temp_slc}x45.png -x 0.5 ${temp_slc}x50.png -x 0.55 ${temp_slc}x55.png -x 0.6 ${temp_slc}x60.png -x 0.65 ${temp_slc}x65.png -x 0.7 ${temp_slc}x70.png -y 0.3 ${temp_slc}y30.png -y 0.35 ${temp_slc}y35.png -y 0.4 ${temp_slc}y40.png -y 0.45 ${temp_slc}y45.png -y 0.5 ${temp_slc}y50.png -y 0.55 ${temp_slc}y55.png -y 0.6 ${temp_slc}y60.png -y 0.65 ${temp_slc}y65.png -y 0.7 ${temp_slc}y70.png -z 0.3 ${temp_slc}z30.png -z 0.35 ${temp_slc}z35.png -z 0.4 ${temp_slc}z40.png -z 0.45 ${temp_slc}z45.png -z 0.5 ${temp_slc}z50.png -z 0.55 ${temp_slc}z55.png -z 0.6 ${temp_slc}z60.png -z 0.65 ${temp_slc}z65.png -z 0.7 ${temp_slc}z70.png
		
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif pngappend ${temp_slc}x30.png + ${temp_slc}x35.png + ${temp_slc}x40.png + ${temp_slc}x45.png + ${temp_slc}x50.png + ${temp_slc}x55.png + ${temp_slc}x60.png + ${temp_slc}x65.png + ${temp_slc}x70.png - ${temp_slc}y30.png + ${temp_slc}y35.png + ${temp_slc}y40.png + ${temp_slc}y45.png + ${temp_slc}y50.png + ${temp_slc}y55.png + ${temp_slc}y60.png + ${temp_slc}y65.png + ${temp_slc}y70.png - ${temp_slc}z30.png + ${temp_slc}z35.png + ${temp_slc}z40.png + ${temp_slc}z45.png + ${temp_slc}z50.png + ${temp_slc}z55.png + ${temp_slc}z60.png + ${temp_slc}z65.png + ${temp_slc}z70.png /dataqsm/${fignameprefix}OLD_native_figure27.png

SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif pngappend ${temp_slc}x40.png + ${temp_slc}x50.png + ${temp_slc}x60.png + ${temp_slc}y40.png + ${temp_slc}y50.png + ${temp_slc}y60.png + ${temp_slc}z40.png + ${temp_slc}z50.png + ${temp_slc}z60.png /dataqsm/${fignameprefix}OLD_native_figure9.png

echo "Generating QC slices for original SWI sequence results resampled fMRIPrep preproc-T1w space" 

temp_slc="/dataqsm/QSM_to_RAGE_slc_fp${fthresh}"
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif slicer ${qsm_resampled} -L -s 1 -i -0.1 0.1 -x 0.3 ${temp_slc}x30.png -x 0.35 ${temp_slc}x35.png -x 0.4 ${temp_slc}x40.png -x 0.45 ${temp_slc}x45.png -x 0.5 ${temp_slc}x50.png -x 0.55 ${temp_slc}x55.png -x 0.6 ${temp_slc}x60.png -x 0.65 ${temp_slc}x65.png -x 0.7 ${temp_slc}x70.png -y 0.3 ${temp_slc}y30.png -y 0.35 ${temp_slc}y35.png -y 0.4 ${temp_slc}y40.png -y 0.45 ${temp_slc}y45.png -y 0.5 ${temp_slc}y50.png -y 0.55 ${temp_slc}y55.png -y 0.6 ${temp_slc}y60.png -y 0.65 ${temp_slc}y65.png -y 0.7 ${temp_slc}y70.png -z 0.3 ${temp_slc}z30.png -z 0.35 ${temp_slc}z35.png -z 0.4 ${temp_slc}z40.png -z 0.45 ${temp_slc}z45.png -z 0.5 ${temp_slc}z50.png -z 0.55 ${temp_slc}z55.png -z 0.6 ${temp_slc}z60.png -z 0.65 ${temp_slc}z65.png -z 0.7 ${temp_slc}z70.png
		
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif pngappend ${temp_slc}x30.png + ${temp_slc}x35.png + ${temp_slc}x40.png + ${temp_slc}x45.png + ${temp_slc}x50.png + ${temp_slc}x55.png + ${temp_slc}x60.png + ${temp_slc}x65.png + ${temp_slc}x70.png - ${temp_slc}y30.png + ${temp_slc}y35.png + ${temp_slc}y40.png + ${temp_slc}y45.png + ${temp_slc}y50.png + ${temp_slc}y55.png + ${temp_slc}y60.png + ${temp_slc}y65.png + ${temp_slc}y70.png - ${temp_slc}z30.png + ${temp_slc}z35.png + ${temp_slc}z40.png + ${temp_slc}z45.png + ${temp_slc}z50.png + ${temp_slc}z55.png + ${temp_slc}z60.png + ${temp_slc}z65.png + ${temp_slc}z70.png /dataqsm/${fignameprefix}OLD_figure27.png

SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif pngappend ${temp_slc}x40.png + ${temp_slc}x50.png + ${temp_slc}x60.png + ${temp_slc}y40.png + ${temp_slc}y50.png + ${temp_slc}y60.png + ${temp_slc}z40.png + ${temp_slc}z50.png + ${temp_slc}z60.png /dataqsm/${fignameprefix}OLD_figure9.png

###Aspire 
temp_slc="/dataqsm/QSM_slc_native_fp${fthresh}"
echo "Generating QC slices for Aspire SWI sequence results"
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif slicer ${qsm_orig} -L -s 1 -i -0.1 0.1 -x 0.3 ${temp_slc}x30.png -x 0.35 ${temp_slc}x35.png -x 0.4 ${temp_slc}x40.png -x 0.45 ${temp_slc}x45.png -x 0.5 ${temp_slc}x50.png -x 0.55 ${temp_slc}x55.png -x 0.6 ${temp_slc}x60.png -x 0.65 ${temp_slc}x65.png -x 0.7 ${temp_slc}x70.png -y 0.3 ${temp_slc}y30.png -y 0.35 ${temp_slc}y35.png -y 0.4 ${temp_slc}y40.png -y 0.45 ${temp_slc}y45.png -y 0.5 ${temp_slc}y50.png -y 0.55 ${temp_slc}y55.png -y 0.6 ${temp_slc}y60.png -y 0.65 ${temp_slc}y65.png -y 0.7 ${temp_slc}y70.png -z 0.3 ${temp_slc}z30.png -z 0.35 ${temp_slc}z35.png -z 0.4 ${temp_slc}z40.png -z 0.45 ${temp_slc}z45.png -z 0.5 ${temp_slc}z50.png -z 0.55 ${temp_slc}z55.png -z 0.6 ${temp_slc}z60.png -z 0.65 ${temp_slc}z65.png -z 0.7 ${temp_slc}z70.png 
       
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif pngappend ${temp_slc}x30.png + ${temp_slc}x35.png + ${temp_slc}x40.png + ${temp_slc}x45.png + ${temp_slc}x50.png + ${temp_slc}x55.png + ${temp_slc}x60.png + ${temp_slc}x65.png + ${temp_slc}x70.png - ${temp_slc}y30.png + ${temp_slc}y35.png + ${temp_slc}y40.png + ${temp_slc}y45.png + ${temp_slc}y50.png + ${temp_slc}y55.png + ${temp_slc}y60.png + ${temp_slc}y65.png + ${temp_slc}y70.png - ${temp_slc}z30.png + ${temp_slc}z35.png + ${temp_slc}z40.png + ${temp_slc}z45.png + ${temp_slc}z50.png + ${temp_slc}z55.png + ${temp_slc}z60.png + ${temp_slc}z65.png + ${temp_slc}z70.png /dataqsm/${fignameprefix}ASPIRE_native_figure27.png

SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif pngappend ${temp_slc}x40.png + ${temp_slc}x50.png + ${temp_slc}x60.png + ${temp_slc}y40.png + ${temp_slc}y50.png + ${temp_slc}y60.png + ${temp_slc}z40.png + ${temp_slc}z50.png + ${temp_slc}z60.png /dataqsm/${fignameprefix}ASPIRE_native_figure9.png

temp_slc="/dataqsm/QSM_slc_prep_fp${fthresh}"        
echo "Generating QC slices for Aspire SWI sequence results in resampled fMRIPrep preproc-T1w space"
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif slicer ${qsm_resampled} -L -s 1 -i -0.1 0.1 -x 0.3 ${temp_slc}x30.png -x 0.35 ${temp_slc}x35.png -x 0.4 ${temp_slc}x40.png -x 0.45 ${temp_slc}x45.png -x 0.5 ${temp_slc}x50.png -x 0.55 ${temp_slc}x55.png -x 0.6 ${temp_slc}x60.png -x 0.65 ${temp_slc}x65.png -x 0.7 ${temp_slc}x70.png -y 0.3 ${temp_slc}y30.png -y 0.35 ${temp_slc}y35.png -y 0.4 ${temp_slc}y40.png -y 0.45 ${temp_slc}y45.png -y 0.5 ${temp_slc}y50.png -y 0.55 ${temp_slc}y55.png -y 0.6 ${temp_slc}y60.png -y 0.65 ${temp_slc}y65.png -y 0.7 ${temp_slc}y70.png -z 0.3 ${temp_slc}z30.png -z 0.35 ${temp_slc}z35.png -z 0.4 ${temp_slc}z40.png -z 0.45 ${temp_slc}z45.png -z 0.5 ${temp_slc}z50.png -z 0.55 ${temp_slc}z55.png -z 0.6 ${temp_slc}z60.png -z 0.65 ${temp_slc}z65.png -z 0.7 ${temp_slc}z70.png 
       
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif pngappend ${temp_slc}x30.png + ${temp_slc}x35.png + ${temp_slc}x40.png + ${temp_slc}x45.png + ${temp_slc}x50.png + ${temp_slc}x55.png + ${temp_slc}x60.png + ${temp_slc}x65.png + ${temp_slc}x70.png - ${temp_slc}y30.png + ${temp_slc}y35.png + ${temp_slc}y40.png + ${temp_slc}y45.png + ${temp_slc}y50.png + ${temp_slc}y55.png + ${temp_slc}y60.png + ${temp_slc}y65.png + ${temp_slc}y70.png - ${temp_slc}z30.png + ${temp_slc}z35.png + ${temp_slc}z40.png + ${temp_slc}z45.png + ${temp_slc}z50.png + ${temp_slc}z55.png + ${temp_slc}z60.png + ${temp_slc}z65.png + ${temp_slc}z70.png /dataqsm/${fignameprefix}ASPIRE_figure27.png

SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif pngappend ${temp_slc}x40.png + ${temp_slc}x50.png + ${temp_slc}x60.png + ${temp_slc}y40.png + ${temp_slc}y50.png + ${temp_slc}y60.png + ${temp_slc}z40.png + ${temp_slc}z50.png + ${temp_slc}z60.png /dataqsm/${fignameprefix}ASPIRE_figure9.png

#calculate image difference
echo "Calculating difference between Aspire and original QSM (Aspire - original) in native space"
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/aspire,${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/origswi -W /aspire $IMAGEDIR/neurodoc.sif fslmaths /aspire/"${subject}_${sesname}_ndi_qsm_fp${fthresh}" -sub /origswi/"${subject}_${sesname}_ndi_qsm_fp${fthresh}" /aspire/${subject}_${sesname}_ndi_qsm_fp${fthresh}_aspire-original

chmod 777 ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out/*_aspire-original*
echo "Generating QC slices for difference between Aspire and original QSM in native space" 

temp_slc="/dataqsm/QSM_native_diff_slc_fp${fthresh}"
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif slicer /dataqsm/${subject}_${sesname}_ndi_qsm_fp${fthresh}_aspire-original.nii.gz -L -s 1 -x 0.3 ${temp_slc}x30.png -x 0.35 ${temp_slc}x35.png -x 0.4 ${temp_slc}x40.png -x 0.45 ${temp_slc}x45.png -x 0.5 ${temp_slc}x50.png -x 0.55 ${temp_slc}x55.png -x 0.6 ${temp_slc}x60.png -x 0.65 ${temp_slc}x65.png -x 0.7 ${temp_slc}x70.png -y 0.3 ${temp_slc}y30.png -y 0.35 ${temp_slc}y35.png -y 0.4 ${temp_slc}y40.png -y 0.45 ${temp_slc}y45.png -y 0.5 ${temp_slc}y50.png -y 0.55 ${temp_slc}y55.png -y 0.6 ${temp_slc}y60.png -y 0.65 ${temp_slc}y65.png -y 0.7 ${temp_slc}y70.png -z 0.3 ${temp_slc}z30.png -z 0.35 ${temp_slc}z35.png -z 0.4 ${temp_slc}z40.png -z 0.45 ${temp_slc}z45.png -z 0.5 ${temp_slc}z50.png -z 0.55 ${temp_slc}z55.png -z 0.6 ${temp_slc}z60.png -z 0.65 ${temp_slc}z65.png -z 0.7 ${temp_slc}z70.png
		
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif pngappend ${temp_slc}x30.png + ${temp_slc}x35.png + ${temp_slc}x40.png + ${temp_slc}x45.png + ${temp_slc}x50.png + ${temp_slc}x55.png + ${temp_slc}x60.png + ${temp_slc}x65.png + ${temp_slc}x70.png - ${temp_slc}y30.png + ${temp_slc}y35.png + ${temp_slc}y40.png + ${temp_slc}y45.png + ${temp_slc}y50.png + ${temp_slc}y55.png + ${temp_slc}y60.png + ${temp_slc}y65.png + ${temp_slc}y70.png - ${temp_slc}z30.png + ${temp_slc}z35.png + ${temp_slc}z40.png + ${temp_slc}z45.png + ${temp_slc}z50.png + ${temp_slc}z55.png + ${temp_slc}z60.png + ${temp_slc}z65.png + ${temp_slc}z70.png /dataqsm/${fignameprefix}ASPIRE-OLD_native_figure27.png

SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif pngappend ${temp_slc}x40.png + ${temp_slc}x50.png + ${temp_slc}x60.png + ${temp_slc}y40.png + ${temp_slc}y50.png + ${temp_slc}y60.png + ${temp_slc}z40.png + ${temp_slc}z50.png + ${temp_slc}z60.png /dataqsm/${fignameprefix}ASPIRE-OLD_native_figure9.png

#calculate image difference in preproc space
echo "Calculating difference between Aspire and original QSM (Aspire - original) in resampled fMRIPrep preproc-T1w space"
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/aspire,${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/origswi -W /aspire $IMAGEDIR/neurodoc.sif fslmaths /aspire/QSM_to_RAGE.nii.gz -sub /origswi/QSM_to_RAGE.nii.gz /aspire/${subject}_${sesname}_qsm_in_rage_fp${fthresh}_aspire-original

chmod 777 ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out/*_aspire-original*
echo "Generating QC slices for difference between Aspire and original QSM in resampled fMRIPrep preproc-T1w space" 

temp_slc="/dataqsm/QSM_diff_slc_fp${fthresh}"
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif slicer /dataqsm/${subject}_${sesname}_qsm_in_rage_fp${fthresh}_aspire-original -L -s 1 -x 0.3 ${temp_slc}x30.png -x 0.35 ${temp_slc}x35.png -x 0.4 ${temp_slc}x40.png -x 0.45 ${temp_slc}x45.png -x 0.5 ${temp_slc}x50.png -x 0.55 ${temp_slc}x55.png -x 0.6 ${temp_slc}x60.png -x 0.65 ${temp_slc}x65.png -x 0.7 ${temp_slc}x70.png -y 0.3 ${temp_slc}y30.png -y 0.35 ${temp_slc}y35.png -y 0.4 ${temp_slc}y40.png -y 0.45 ${temp_slc}y45.png -y 0.5 ${temp_slc}y50.png -y 0.55 ${temp_slc}y55.png -y 0.6 ${temp_slc}y60.png -y 0.65 ${temp_slc}y65.png -y 0.7 ${temp_slc}y70.png -z 0.3 ${temp_slc}z30.png -z 0.35 ${temp_slc}z35.png -z 0.4 ${temp_slc}z40.png -z 0.45 ${temp_slc}z45.png -z 0.5 ${temp_slc}z50.png -z 0.55 ${temp_slc}z55.png -z 0.6 ${temp_slc}z60.png -z 0.65 ${temp_slc}z65.png -z 0.7 ${temp_slc}z70.png
		
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif pngappend ${temp_slc}x30.png + ${temp_slc}x35.png + ${temp_slc}x40.png + ${temp_slc}x45.png + ${temp_slc}x50.png + ${temp_slc}x55.png + ${temp_slc}x60.png + ${temp_slc}x65.png + ${temp_slc}x70.png - ${temp_slc}y30.png + ${temp_slc}y35.png + ${temp_slc}y40.png + ${temp_slc}y45.png + ${temp_slc}y50.png + ${temp_slc}y55.png + ${temp_slc}y60.png + ${temp_slc}y65.png + ${temp_slc}y70.png - ${temp_slc}z30.png + ${temp_slc}z35.png + ${temp_slc}z40.png + ${temp_slc}z45.png + ${temp_slc}z50.png + ${temp_slc}z55.png + ${temp_slc}z60.png + ${temp_slc}z65.png + ${temp_slc}z70.png /dataqsm/${fignameprefix}ASPIRE-OLD_figure27.png

SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif pngappend ${temp_slc}x40.png + ${temp_slc}x50.png + ${temp_slc}x60.png + ${temp_slc}y40.png + ${temp_slc}y50.png + ${temp_slc}y60.png + ${temp_slc}z40.png + ${temp_slc}z50.png + ${temp_slc}z60.png /dataqsm/${fignameprefix}ASPIRE-OLD_figure9.png

echo "Creating overlay images of Freesurfer parcellation over QSM in resampled fMRIPrep preproc-T1w space"
echo "Original Sequence Overlay"
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif overlay 1 0 ${qsm_resampled} -0.1 0.1 /dataqsm/resample_card_"$subject"_"$sesname"_acq-mp2rageunidenoised_desc-aparcaseg_dseg.nii.gz 0 2035 /dataqsm/"$subject"_"$sesname"_resample_card_aparcaseg_dseg_over_qsm_OLD_fp${fthresh}

echo "Aspire Sequence Overlay"
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif overlay 1 0 ${qsm_resampled} -0.1 0.1 /dataqsm/resample_card_"$subject"_"$sesname"_acq-mp2rageunidenoised_desc-aparcaseg_dseg.nii.gz 0 2035 /dataqsm/"$subject"_"$sesname"_resample_card_aparcaseg_dseg_over_qsm_ASPIRE_fp${fthresh}

temp_slc="/dataqsm/QSM_overlay_slc_orig_fp${fthresh}"
echo "Generating QC slices for Freesurfer parcellation overlaid on Original SWI sequence results in resampled fMRIPrep preproc-T1w space"
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif slicer /dataqsm/"$subject"_"$sesname"_resample_card_aparcaseg_dseg_over_qsm_OLD_fp${fthresh} -L -s 1 -x 0.3 ${temp_slc}x30.png -x 0.35 ${temp_slc}x35.png -x 0.4 ${temp_slc}x40.png -x 0.45 ${temp_slc}x45.png -x 0.5 ${temp_slc}x50.png -x 0.55 ${temp_slc}x55.png -x 0.6 ${temp_slc}x60.png -x 0.65 ${temp_slc}x65.png -x 0.7 ${temp_slc}x70.png -y 0.3 ${temp_slc}y30.png -y 0.35 ${temp_slc}y35.png -y 0.4 ${temp_slc}y40.png -y 0.45 ${temp_slc}y45.png -y 0.5 ${temp_slc}y50.png -y 0.55 ${temp_slc}y55.png -y 0.6 ${temp_slc}y60.png -y 0.65 ${temp_slc}y65.png -y 0.7 ${temp_slc}y70.png -z 0.3 ${temp_slc}z30.png -z 0.35 ${temp_slc}z35.png -z 0.4 ${temp_slc}z40.png -z 0.45 ${temp_slc}z45.png -z 0.5 ${temp_slc}z50.png -z 0.55 ${temp_slc}z55.png -z 0.6 ${temp_slc}z60.png -z 0.65 ${temp_slc}z65.png -z 0.7 ${temp_slc}z70.png 
       
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif pngappend ${temp_slc}x30.png + ${temp_slc}x35.png + ${temp_slc}x40.png + ${temp_slc}x45.png + ${temp_slc}x50.png + ${temp_slc}x55.png + ${temp_slc}x60.png + ${temp_slc}x65.png + ${temp_slc}x70.png - ${temp_slc}y30.png + ${temp_slc}y35.png + ${temp_slc}y40.png + ${temp_slc}y45.png + ${temp_slc}y50.png + ${temp_slc}y55.png + ${temp_slc}y60.png + ${temp_slc}y65.png + ${temp_slc}y70.png - ${temp_slc}z30.png + ${temp_slc}z35.png + ${temp_slc}z40.png + ${temp_slc}z45.png + ${temp_slc}z50.png + ${temp_slc}z55.png + ${temp_slc}z60.png + ${temp_slc}z65.png + ${temp_slc}z70.png /dataqsm/${fignameprefix}OLD_aparcaseg_dseg_overlay_figure27.png

SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif pngappend ${temp_slc}x40.png + ${temp_slc}x50.png + ${temp_slc}x60.png + ${temp_slc}y40.png + ${temp_slc}y50.png + ${temp_slc}y60.png + ${temp_slc}z40.png + ${temp_slc}z50.png + ${temp_slc}z60.png /dataqsm/${fignameprefix}OLD_aparcaseg_dseg_overlay_figure9.png


temp_slc="/dataqsm/QSM_overlay_slc_fp${fthresh}"
echo "Generating QC slices for Freesurfer parcellation overlaid on Aspire SWI sequence results in resampled fMRIPrep preproc-T1w space"
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif slicer /dataqsm/"$subject"_"$sesname"_resample_card_aparcaseg_dseg_over_qsm_ASPIRE_fp${fthresh} -L -s 1 -x 0.3 ${temp_slc}x30.png -x 0.35 ${temp_slc}x35.png -x 0.4 ${temp_slc}x40.png -x 0.45 ${temp_slc}x45.png -x 0.5 ${temp_slc}x50.png -x 0.55 ${temp_slc}x55.png -x 0.6 ${temp_slc}x60.png -x 0.65 ${temp_slc}x65.png -x 0.7 ${temp_slc}x70.png -y 0.3 ${temp_slc}y30.png -y 0.35 ${temp_slc}y35.png -y 0.4 ${temp_slc}y40.png -y 0.45 ${temp_slc}y45.png -y 0.5 ${temp_slc}y50.png -y 0.55 ${temp_slc}y55.png -y 0.6 ${temp_slc}y60.png -y 0.65 ${temp_slc}y65.png -y 0.7 ${temp_slc}y70.png -z 0.3 ${temp_slc}z30.png -z 0.35 ${temp_slc}z35.png -z 0.4 ${temp_slc}z40.png -z 0.45 ${temp_slc}z45.png -z 0.5 ${temp_slc}z50.png -z 0.55 ${temp_slc}z55.png -z 0.6 ${temp_slc}z60.png -z 0.65 ${temp_slc}z65.png -z 0.7 ${temp_slc}z70.png 
       
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif pngappend ${temp_slc}x30.png + ${temp_slc}x35.png + ${temp_slc}x40.png + ${temp_slc}x45.png + ${temp_slc}x50.png + ${temp_slc}x55.png + ${temp_slc}x60.png + ${temp_slc}x65.png + ${temp_slc}x70.png - ${temp_slc}y30.png + ${temp_slc}y35.png + ${temp_slc}y40.png + ${temp_slc}y45.png + ${temp_slc}y50.png + ${temp_slc}y55.png + ${temp_slc}y60.png + ${temp_slc}y65.png + ${temp_slc}y70.png - ${temp_slc}z30.png + ${temp_slc}z35.png + ${temp_slc}z40.png + ${temp_slc}z45.png + ${temp_slc}z50.png + ${temp_slc}z55.png + ${temp_slc}z60.png + ${temp_slc}z65.png + ${temp_slc}z70.png /dataqsm/${fignameprefix}ASPIRE_aparcaseg_dseg_overlay_figure27.png

SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm -W /dataqsm $IMAGEDIR/neurodoc.sif pngappend ${temp_slc}x40.png + ${temp_slc}x50.png + ${temp_slc}x60.png + ${temp_slc}y40.png + ${temp_slc}y50.png + ${temp_slc}y60.png + ${temp_slc}z40.png + ${temp_slc}z50.png + ${temp_slc}z60.png /dataqsm/${fignameprefix}ASPIRE_aparcaseg_dseg_overlay_figure9.png


html="<h1>QSM Report: ${CLEANSUBJECT} ${CLEANSESSION} fractional intensity threshold: 0.${fthresh}</h1>"
html+="<p>T1w preprocessing outputs from fMRIPrep used for ROI-based analyses after undergoing afni deoblique and resample to 1mm isotropic space. Processed SWI Magnitude images Intensity Non-Uniformity Corrected with FSL FAST and used for registration of resampled preprocessed brain T1w to SWI space using FLIRT (12 DOF, cost function: normmi). This matrix was then inverted and used to register QSM images to resampled preprocessed brain T1w using FLIRT (sinc interpolation). </p>"
html+="<h2>Native space QSM from Original SWI Sequence</h2>"
html+="<img src=${fignameprefix}OLD_native_figure27.png><br />"
html+="<h2>Native space QSM from Aspire Sequence</h2>"
html+="<img src=${fignameprefix}ASPIRE_native_figure27.png><br />"
html+="<h2>Difference between Native space QSM from Aspire Sequence and Original Sequence</h2>"
html+="<img src=${fignameprefix}ASPIRE-OLD_native_figure27.png><br />"
html+="<h2>fMRIPrep preproc-T1w space QSM from Original SWI Sequence</h2>"
html+="<img src=${fignameprefix}OLD_figure27.png><br />"
html+="<h2>fMRIPrep preproc-T1w space QSM from Aspire Sequence</h2>"
html+="<img src=${fignameprefix}ASPIRE_figure27.png><br />"
html+="<h2>Difference between fMRIPrep preproc-T1w space QSM from Aspire Sequence and Original Sequence</h2>"
html+="<img src=${fignameprefix}ASPIRE-OLD_figure27.png><br />"
html+="<h2>Freesurfer parcellation overlaid on Original SWI sequence results in resampled fMRIPrep preproc-T1w space</h2>"
html+="<img src=${fignameprefix}OLD_aparcaseg_dseg_overlay_figure27.png><br />"
html+="<h2>Freesurfer parcellation overlaid on Aspire SWI sequence results in resampled fMRIPrep preproc-T1w space</h2>"
html+="<img src=${fignameprefix}ASPIRE_aparcaseg_dseg_overlay_figure27.png><br />"

echo $html > ${QSM_REPORT_HTML}

echo "removing images of individual slices used to generate html"
rm ${projDir}/bids/derivatives/sw*/${subject}/${sesname}/ndi_out/*slc* 

done
