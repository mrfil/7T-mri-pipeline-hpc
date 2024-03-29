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

export SINGULARITYENV_ASHS_ROOT=/opt/ashs/ashs-1.0.0
SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}:/datain,${IMAGEDIR}/ashs_config.sh:/opt/ashs/ashs-1.0.0/bin/ashs_config.sh $IMAGEDIR/ashs-1.0.0.sif $SINGULARITYENV_ASHS_ROOT/bin/ashs_main.sh -a /opt/ashs/ashs_atlas_umcutrecht_7t_20170810 -g /datain/bids/sourcedata/${subject}/${sesname}/anat/${subject}_${sesname}_acq-mp2rageunidenoised_T1w.nii.gz -f /datain/bids/sourcedata/${subject}/${sesname}/anat/${subject}_${sesname}_acq-highreshippocampus_run-1_T2w.nii.gz -w /datain/bids/derivatives/ashs/${subject}/${sesname} 

