#!/bin/bash
# slurm_proc_7T_CUPS_step2.sh
#
# This script is the second step in the 7T CUPS pipeline. It runs fMRIPrep and XCP-D on the input subject and session.

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
CACHESING=${scachedir}/${project}_${subject}_${sesname}_rsfc
TMPSING=${stmpdir}/${project}_${subject}_${sesname}_rsfc
mkdir $CACHESING
mkdir $TMPSING
chmod 730 -R $CACHESING
chmod 730 -R $TMPSING

ses=${sesname:4}
sub=${subject:4}


# Get number of cpus from slurm, if not available, use 16
if [ -z "$SLURM_CPUS_PER_TASK" ]; then
	num_cpus=16
else
	num_cpus=$SLURM_CPUS_PER_TASK
fi

TEMPLATEFLOW_HOST_HOME=$IMAGEDIR/templateflow
export APPTAINERENV_TEMPLATEFLOW_HOME="/templateflow"
# Set MPLCONFIGDIR to the scratch directory
MPLCONFIGDIR=$TMPSING/matplotlib
mkdir -p $MPLCONFIGDIR
export APPTAINERENV_MPLCONFIGDIR="/sing_scratch/matplotlib"


NOW=$(date +"%m-%d-%Y-%T")
echo "fMRIPrep started $NOW" >> ${scripts}/fulltimer.txt

#fmriprep
echo "Running fmriprep on $subject $sesname"

${scripts}/project_doc.sh ${project} ${subject} ${sesname} "fmriprep" "no"
if [ "${longitudinal}" == "yes" ];
then 
APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --containall \
--no-home --cleanenv --bind ${TEMPLATEFLOW_HOST_HOME}:${APPTAINERENV_TEMPLATEFLOW_HOME} \
--bind $IMAGEDIR/license.txt:/opt/freesurfer/license.txt,$TMPSING:/paulscratch,${projDir}:/datain \
$IMAGEDIR/fmriprep-v23.2.2.sif fmriprep /datain/bids /datain/bids/derivatives/fmriprep participant \
--participant-label ${subject} --longitudinal --use-aroma \
--output-spaces {MNI152NLin2009cAsym:res-1,MNI152NLin2009cAsym:res-native,T1w:res-1,fsnative:res-1} \
-w /paulscratch --fs-license-file /opt/freesurfer/license.txt
elif [ "${longitudinal}" == "no" ];
then
APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --containall \
--no-home --cleanenv --bind ${TEMPLATEFLOW_HOST_HOME}:${APPTAINERENV_TEMPLATEFLOW_HOME} \
--bind $IMAGEDIR/license.txt:/opt/freesurfer/license.txt,$TMPSING:/paulscratch,${projDir}:/datain \
$IMAGEDIR/fmriprep-v23.2.2.sif fmriprep /datain/bids /datain/bids/derivatives/fmriprep participant \
--participant-label ${subject} --use-aroma \
--output-spaces {MNI152NLin2009cAsym:res-1,MNI152NLin2009cAsym:res-native,T1w:res-1,fsnative:res-1} \
-w /paulscratch --fs-license-file /opt/freesurfer/license.txt
fi


NOW=$(date +"%m-%d-%Y-%T")
echo "fMRIPrep finished $NOW" >> ${scripts}/fulltimer.txt

chmod 730 -R ${projDir}/bids/derivatives/fmriprep

echo "Running FSQC on $subject $sesname"
mkdir -p ${projDir}/bids/derivatives/qatools/${subject}
APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer run --containall --no-home --cleanenv \
--bind ${projDir}/bids/derivatives:/datain,${IMAGEDIR}/license.txt:/opt/freesurfer/license.txt $IMAGEDIR/fsqc-v2.1.1.sif \
--subjects_dir /datain/freesurfer --output_dir /datain/fsqc/${subject} --subjects ${subject} \
--screenshots --screenshots-html --shape



# Run XCP-D
echo "Running XCP-D on $subject $sesname"
APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --containall --no-home --cleanenv \
--bind ${projDir}/bids/derivatives:/datain,${IMAGEDIR}/license.txt:/opt/freesurfer/license.txt \
$IMAGEDIR/xcp-d-v0.10.0.sif --participant_label ${subject} --nthreads $num_cpus \
--omp-nthreads $((num_cpus / 2)) --input-type fmriprep --smoothing $SMOOTHING -p ${CONFOUND_REGRESSION} \
-f 0 -w "/sing_scratch" --notrack --fs-license-file /imgdir/license.txt \
/datain/fmriprep /datain/ participant