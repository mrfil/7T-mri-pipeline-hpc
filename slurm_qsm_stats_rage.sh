#!/bin/bash
# slurm_qsm_stats_rage.sh

while getopts :p:s:z:b:t: option; do
	case ${option} in
		p) export CLEANPROJECT=$OPTARG ;;
		s) export CLEANSESSION=$OPTARG ;;
		z) export CLEANSUBJECT=$OPTARG ;;
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

# translating naming conventions
echo "${CLEANSESSION: -1}"
session="${CLEANSESSION: -1}"
echo ${session}
project=${CLEANPROJECT}

subject="sub-"${CLEANSUBJECT}
sesname="ses-"${session}

projDir=${base_dir}/${version}/testing/${project}
scripts=${base_dir}/${version}/scripts

cd $projDir

IMAGEDIR=${base_dir}/apptainer_images
CACHESING=${scachedir}/${project}_${subject}_${sesname}_qsmstats
TMPSING=${stmpdir}/${project}_${subject}_${sesname}_qsmstats
mkdir -p $CACHESING
mkdir -p $TMPSING

ses=${sesname:4}
sub=${subject:4}

process_qsm() {
	local fthresh=$1
	local swi_dir=$2
	local script_suffix=$3
	local output_suffix=$4

	echo "Generating QSM with hybrid Cornell-Berkeley tools"
	echo "Fractional intensity threshold set to 0.${fthresh} (see scripts/matlab/ndi_qsm_fp${fthresh}.sh)"
	cd ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}
	mkdir -p ndi_out/old
	mv ./*nii ./ndi_out/old/

	APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING \
	apptainer exec --cleanenv --no-home --contain \
	--bind ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}:/datain \
	--bind ${IMAGEDIR}/ndi:/ndi,${scripts}/matlab:/scripts \
	${IMAGEDIR}/matlab-r2019a.sif /scripts/ndi_qsm_fp${fthresh}.sh
	echo "Pseudo-BIDSifying QSM outputs"
	cd ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}
	mv ./ndi_out/mag.nii ./ndi_out/${subject}_${sesname}_ndi_mag_fp${fthresh}_${output_suffix}.nii
	mv ./ndi_out/phs.nii ./ndi_out/${subject}_${sesname}_ndi_phs_fp${fthresh}_${output_suffix}.nii
	mv ./ndi_out/qsm.nii ./ndi_out/${subject}_${sesname}_ndi_qsm_fp${fthresh}_${output_suffix}.nii
}

export -f process_qsm
parallel process_qsm ::: 1 2 3 ::: swi swi_old ::: ASPIRE OLD

roi_names=$scripts/aparc_cort_subcort_labels.txt
acqtag="_acq-mp2rageunidenoised_"

echo "afni deoblique and resample fmriprep anat outputs"
APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING \
apptainer exec --containall --no-home --cleanenv \
--bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs \
--bind ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}/ndi_out:/dataqsm \
$IMAGEDIR/neurodoc.sif 3dWarp -oblique2card \
-prefix /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz \
/datafs/"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz

APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING \
apptainer exec --containall --no-home --cleanenv \
--bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs \
--bind ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}/ndi_out:/dataqsm \
$IMAGEDIR/neurodoc.sif 3dresample -dxyz 1 1 1 \
-prefix /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz \
-input /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz

APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING \
apptainer exec --containall --no-home --cleanenv \
--bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs \
--bind ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}/ndi_out:/dataqsm \
$IMAGEDIR/neurodoc.sif 3dWarp -oblique2card \
-prefix /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz \
/datafs/"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz

APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING \
apptainer exec --containall --no-home --cleanenv \
--bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs \
--bind ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}/ndi_out:/dataqsm \
$IMAGEDIR/neurodoc.sif 3dresample -dxyz 1 1 1 \
-prefix /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz \
-input /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz

APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING \
apptainer exec --containall --no-home --cleanenv \
--bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs \
--bind ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}/ndi_out:/dataqsm \
$IMAGEDIR/neurodoc.sif 3dWarp -oblique2card \
-prefix /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz \
/datafs/"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz

APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING \
apptainer exec --containall --no-home --cleanenv \
--bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs \
--bind ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}/ndi_out:/dataqsm \
$IMAGEDIR/neurodoc.sif 3dresample -dxyz 1 1 1 \
-prefix /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz \
-input /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz

process_qsm_stats() {
	local fthresh=$1
	local swi_dir=$2
	local output_suffix=$3

	cd ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}/ndi_out
	roi_names=$scripts/aparc_cort_subcort_labels.txt
	acqtag="_acq-mp2rageunidenoised_"

	echo "f threshold 0.${fthresh}"
	echo "Intensity Non-Uniformity Correction with FSL FAST"
	APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING \
	apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}/ndi_out:/dataqsm \
	$IMAGEDIR/neurodoc.sif fast -B -b -t 2 \
	/dataqsm/${subject}_${sesname}_ndi_mag_fp${fthresh}_${output_suffix}.nii
	
	# flirt transform routine
	echo "Registering swi magnitude image to resampled deobliqued preprocessed T1w"
	echo "(see fmriprep anat outputs for more details)"
	APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING \
	apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}/ndi_out:/dataqsm \
	$IMAGEDIR/neurodoc.sif flirt -cost normmi -dof 12 \
	-in /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz \
	-ref /dataqsm/${subject}_${sesname}_ndi_mag_fp${fthresh}_${output_suffix}_restore.nii.gz \
	-omat /dataqsm/rage2swi_${output_suffix}.mat \
	-out /dataqsm/rage_in_mag_${output_suffix}.nii.gz	
	
	echo "Inverting transform matrix"
	APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING \
	apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}/ndi_out:/dataqsm \
	$IMAGEDIR/neurodoc.sif convert_xfm -omat /dataqsm/swi2rage_${output_suffix}.mat \
	-inverse /dataqsm/rage2swi_${output_suffix}.mat
	
	echo "Registering resampled deobliqued freesurfer parcellation to swi magnitude image"
	echo "(see fmriprep anat outputs for more details)"
	APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING \
	apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}/ndi_out:/dataqsm \
	$IMAGEDIR/neurodoc.sif flirt -interp sinc \
	-in /dataqsm/"$subject"_"$sesname"_ndi_qsm_fp${fthresh}_${output_suffix} \
	-ref /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz \
	-applyxfm -init /dataqsm/swi2rage_${output_suffix}.mat \
	-out /dataqsm/QSM_to_RAGE_${output_suffix}.nii.gz
	
	echo "Calculation ROI-wise stats on QSM image using fslstats"
	APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING \
	apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}/ndi_out:/dataqsm,${scripts}:/scripts \
	$IMAGEDIR/neurodoc.sif /scripts/qsm_stats_rage.sh ${subject} ${sesname} ${fthresh} ${output_suffix}
	mv ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}/ndi_out/QSM_to_RAGE_${output_suffix}.nii.gz \
	${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}/ndi_out/QSM_to_RAGE_fp${fthresh}_${output_suffix}.nii.gz
	rm -rf ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}/ndi_out/masks
}

export -f process_qsm_stats
parallel process_qsm_stats ::: 1 2 3 ::: swi swi_old ::: ASPIRE OLD

generate_qc_slices() {
	local fthresh=$1
	local swi_dir=$2
	local output_suffix=$3

	fignameprefix="sub-${CLEANSUBJECT}_ses-${CLEANSESSION}_desc-QSM_fp${fthresh}"
	QSM_REPORT_HTML="${projDir}/bids/derivatives/sub-${CLEANSUBJECT}_ses-${CLEANSESSION}_QSM_fp${fthresh}_${output_suffix}_REPORT.html"

	qsm_resampled="/dataqsm/QSM_to_RAGE_fp${fthresh}_${output_suffix}.nii.gz"
	qsm_orig="/dataqsm/${subject}_${sesname}_ndi_qsm_fp${fthresh}_${output_suffix}"

	temp_slc="/dataqsm/QSM_slc_fp${fthresh}_${output_suffix}"
	echo "Generating QC slices for ${output_suffix} SWI sequence results" 
	
	APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING \
	apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}/ndi_out:/dataqsm \
	-W /dataqsm $IMAGEDIR/neurodoc.sif slicer ${qsm_orig} -L -s 1 -i -0.1 0.1 \
	-x 0.3 ${temp_slc}x30.png -x 0.35 ${temp_slc}x35.png -x 0.4 ${temp_slc}x40.png \
	-x 0.45 ${temp_slc}x45.png -x 0.5 ${temp_slc}x50.png -x 0.55 ${temp_slc}x55.png \
	-x 0.6 ${temp_slc}x60.png -x 0.65 ${temp_slc}x65.png -x 0.7 ${temp_slc}x70.png \
	-y 0.3 ${temp_slc}y30.png -y 0.35 ${temp_slc}y35.png -y 0.4 ${temp_slc}y40.png \
	-y 0.45 ${temp_slc}y45.png -y 0.5 ${temp_slc}y50.png -y 0.55 ${temp_slc}y55.png \
	-y 0.6 ${temp_slc}y60.png -y 0.65 ${temp_slc}y65.png -y 0.7 ${temp_slc}y70.png \
	-z 0.3 ${temp_slc}z30.png -z 0.35 ${temp_slc}z35.png -z 0.4 ${temp_slc}z40.png \
	-z 0.45 ${temp_slc}z45.png -z 0.5 ${temp_slc}z50.png -z 0.55 ${temp_slc}z55.png \
	-z 0.6 ${temp_slc}z60.png -z 0.65 ${temp_slc}z65.png -z 0.7 ${temp_slc}z70.png
	
	APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING \
	apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}/ndi_out:/dataqsm \
	-W /dataqsm $IMAGEDIR/neurodoc.sif pngappend ${temp_slc}x30.png + ${temp_slc}x35.png \
	+ ${temp_slc}x40.png + ${temp_slc}x45.png + ${temp_slc}x50.png + ${temp_slc}x55.png \
	+ ${temp_slc}x60.png + ${temp_slc}x65.png + ${temp_slc}x70.png - ${temp_slc}y30.png \
	+ ${temp_slc}y35.png + ${temp_slc}y40.png + ${temp_slc}y45.png + ${temp_slc}y50.png \
	+ ${temp_slc}y55.png + ${temp_slc}y60.png + ${temp_slc}y65.png + ${temp_slc}y70.png \
	- ${temp_slc}z30.png + ${temp_slc}z35.png + ${temp_slc}z40.png + ${temp_slc}z45.png \
	+ ${temp_slc}z50.png + ${temp_slc}z55.png + ${temp_slc}z60.png + ${temp_slc}z65.png \
	+ ${temp_slc}z70.png /dataqsm/${fignameprefix}${output_suffix}_native_figure27.png
	
	APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING \
	apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}/bids/derivatives/${swi_dir}/${subject}/${sesname}/ndi_out:/dataqsm \
	-W /dataqsm $IMAGEDIR/neurodoc.sif pngappend ${temp_slc}x40.png + ${temp_slc}x50.png \
	+ ${temp_slc}x60.png + ${temp_slc}y40.png + ${temp_slc}y50.png + ${temp_slc}y60.png \
	+ ${temp_slc}z40.png + ${temp_slc}z50.png + ${temp_slc}z60.png \
	/dataqsm/${fignameprefix}${output_suffix}_native_figure9.png
}

export -f generate_qc_slices
parallel generate_qc_slices ::: 1 2 3 ::: swi swi_old ::: ASPIRE OLD
