#!/bin/bash
# slurm_proc_7T_CUPS_ashs.sh
#
# This script runs after step 1 in the 7T CUPS pipeline. It runs ASHS on the input subject and session.

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
CACHESING=${scachedir}/${project}_${subject}_${sesname}_ashs
TMPSING=${stmpdir}/${project}_${subject}_${sesname}_ashs
mkdir $CACHESING
mkdir $TMPSING

ses=${sesname:4}
sub=${subject:4}

echo "Running ASHS on ${subject} ${sesname}"

export APPTAINERENV_ASHS_ROOT=/opt/ashs/ashs-1.0.0
APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --containall --no-home --cleanenv \
--bind ${projDir}:/datain \
$IMAGEDIR/ashs-1.0.0.sif $APPTAINERENV_ASHS_ROOT/bin/ashs_main.sh -a /opt/ashs/ashs_atlas_umcutrecht_7t_20170810 \
-g /datain/bids/sourcedata/${subject}/${sesname}/anat/${subject}_${sesname}_acq-mp2rageunidenoised_T1w.nii.gz \
-f /datain/bids/sourcedata/${subject}/${sesname}/anat/${subject}_${sesname}_acq-highreshippocampus_run-1_T2w.nii.gz \
-w /datain/bids/derivatives/ashs/${subject}/${sesname} 

rm -rf $CACHESING
rm -rf $TMPSING
