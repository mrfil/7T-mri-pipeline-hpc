#!/bin/bash
#
# slurm_proc_7T_CUPS_step3.sh
#
# This script is the third step in the 7T CUPS pipeline. It runs QSIprep and QSIRecon on the input subject and session.

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

IMAGEDIR=${base_dir}/apptainer_images
scripts=${base_dir}/${version}/scripts
stmpdir=${base_dir}/${version}/scratch/stmp
scachedir=${base_dir}/${version}/scratch/scache

cd $pilotdir

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
CACHESING=${scachedir}/${project}_${subject}_${sesname}_sc
TMPSING=${stmpdir}/${project}_${subject}_${sesname}_sc
mkdir $CACHESING
mkdir $TMPSING

ses=${sesname:4}
sub=${subject:4}

TEMPLATEFLOW_HOST_HOME=$IMAGEDIR/templateflow
export APPTAINERENV_TEMPLATEFLOW_HOME="/templateflow"
# Set MPLCONFIGDIR to the scratch directory
MPLCONFIGDIR=$TMPSING/matplotlib
mkdir -p $MPLCONFIGDIR
export APPTAINERENV_MPLCONFIGDIR="/sing_scratch/matplotlib"

if [ -d "${projDir}/bids/${subject}/${sesname}/dwi" ];
	then

	NOW=$(date +"%m-%d-%Y-%T")
	echo "QSIprep started $NOW" >> ${scripts}/fulltimer.txt

	APPTAINER_CACHEDIR=${CACHESING} APPTAINER_TMPDIR=${TMPSING} apptainer run --containall --no-home --cleanenv \
	--bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v1.0.0.sif \
	--fs-license-file /imgdir/license.txt /data/bids/sourcedata /data/bids/derivatives \
	--freesurfer_input /data/bids/derivatives/sourcedata/freesurfer --output-resolution 1.6 \
	-w /paulscratch participant --participant-label ${subject}

	chmod 730 -R ${projDir}/bids/derivatives/qsiprep
	NOW=$(date +"%m-%d-%Y-%T")
	echo "QSIprep finished $NOW" >> ${scripts}/fulltimer.txt
	NOW=$(date +"%m-%d-%Y-%T")
	echo "QSIprep Recon started $NOW" >> ${scripts}/fulltimer.txt
	
	APPTAINER_CACHEDIR=${CACHESING} APPTAINER_TMPDIR=${TMPSING} apptainer run --containall --no-home --cleanenv \
	--bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsirecon-v1.0.0.sif \
	--fs-license-file /imgdir/license.txt /data/bids/sourcedata /data/bids/derivatives \
	--recon_input /data/bids/derivatives/qsiprep -- --recon_spec mrtrix_multishell_msmt_ACT-hsvs \
	--freesurfer_input /data/bids/derivatives/sourcedata/freesurfer --output-resolution 1.6 \
	-w /paulscratch participant --participant-label ${subject}
	
	APPTAINER_CACHEDIR=${CACHESING} APPTAINER_TMPDIR=${TMPSING} apptainer run --containall --no-home --cleanenv \
	--bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsirecon-v1.0.0.sif \
	--fs-license-file /imgdir/license.txt /data/bids/sourcedata /data/bids/derivatives \
	--recon_input /data/bids/derivatives/qsiprep --recon_spec dsi_studio_gqi --output-resolution 1.6 \
	-w /paulscratch participant --participant-label ${subject}
	
	APPTAINER_CACHEDIR=${CACHESING} APPTAINER_TMPDIR=${TMPSING} apptainer run --containall --no-home --cleanenv \
	--bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsirecon-v1.0.0.sif \
	--fs-license-file /imgdir/license.txt /data/bids/sourcedata /data/bids/derivatives \
	--recon_input /data/bids/derivatives/qsiprep --recon_spec amico_noddi --output-resolution 1.6 \
	-w /paulscratch participant --participant-label ${subject}
	NOW=$(date +"%m-%d-%Y-%T")
	echo "QSIprep Recon finished $NOW" >> ${scripts}/fulltimer.txt

	# APPTAINER_CACHEDIR=${CACHESING} APPTAINER_TMPDIR=${TMPSING} apptainer run --containall --no-home --cleanenv \
	# --bind ${scripts}/matlab:/work,${scripts}/2019_03_03_BCT:/bctoolbox \
	# --bind ${projDir}/bids/derivatives/qsirecon-MRtrix3_act-HSVS:/data \
	# ${IMAGEDIR}/matlab-R2019a.sif /work/qsinbs.sh "$subject" "$sesname"

	# APPTAINER_CACHEDIR=${CACHESING} APPTAINER_TMPDIR=${TMPSING} apptainer run --containall --no-home --cleanenv \
	# --bind ${scripts}:/scripts,${projDir}/bids/derivatives/qsirecon-DSIStudio/${subject}/${sesname}/dwi:/datain \
	# -W /datain ${IMAGEDIR}/pylearn.sif /scripts/gqimetrics.py
	
	# APPTAINER_CACHEDIR=${CACHESING} APPTAINER_TMPDIR=${TMPSING} apptainer run --containall --no-home --cleanenv \
	# --bind ${scripts}:/scripts,${projDir}/bids/derivatives/qsirecon-NODDI/${subject}/${sesname}/dwi:/datanoddi \
	# ${IMAGEDIR}/neurodoc.sif /scripts/noddi_stats.sh "$subject" "$sesname"
	
	# cd {projDir}/bids/derivatives/qsirecon/${subject}/${sesname}/dwi
	# paste -d, *ISOVF*csv > ${subject}_${sesname}_ISOVF.csv
	# paste -d, *ICVF*csv > ${subject}_${sesname}_ICVF.csv
	# paste -d, *OD*csv > ${subject}_${sesname}_OD.csv
	# paste -d ${subject}_${sesname}_ICVF.csv ${subject}_${sesname}_ISOVF.csv ${subject}_${sesname}_OD.csv > ${subject}_${sesname}_NODDI_STATS.csv
	
fi

