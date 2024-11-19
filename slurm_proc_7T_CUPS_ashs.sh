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
## takes project, subject, and session as inputs

pilotdir=${base_dir}/original_location_of_images_from_XNAT
IMAGEDIR=${base_dir}/apptainer_images
tmpdir=${base_dir}/${version}/testing
scripts=${base_dir}/${version}/scripts
bids_out=${base_dir}/${version}/bids_only
conn_out=${base_dir}/${version}/conn_out
dataqc=${base_dir}/${version}/data_qc
stmpdir=${base_dir}/${version}/scratch/stmp
scachedir=${base_dir}/${version}/scratch/scache

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
scripts=${base_dir}/${version}/scripts

cd $projDir

IMAGEDIR=${base_dir}/apptainer_images
CACHESING=${scachedir}/${project}_${subject}_${sesname}_dcm2rsfc
TMPSING=${stmpdir}/${project}_${subject}_${sesname}_dcm2rsfc
mkdir $CACHESING
mkdir $TMPSING

ses=${sesname:4}
sub=${subject:4}

export APPTAINERENV_ASHS_ROOT=/opt/ashs/ashs-1.0.0
APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --containall --no-home --cleanenv \
--bind ${projDir}:/datain,${IMAGEDIR}/ashs_config.sh:/opt/ashs/ashs-1.0.0/bin/ashs_config.sh \
$IMAGEDIR/ashs-1.0.0.sif $APPTAINERENV_ASHS_ROOT/bin/ashs_main.sh -a /opt/ashs/ashs_atlas_umcutrecht_7t_20170810 \
-g /datain/bids/sourcedata/${subject}/${sesname}/anat/${subject}_${sesname}_acq-mp2rageunidenoised_T1w.nii.gz \
-f /datain/bids/sourcedata/${subject}/${sesname}/anat/${subject}_${sesname}_acq-highreshippocampus_run-1_T2w.nii.gz \
-w /datain/bids/derivatives/ashs/${subject}/${sesname} 

