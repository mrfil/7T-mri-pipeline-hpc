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
CACHESING=${scachedir}/${project}_${subject}_${sesname}_rsfc
TMPSING=${stmpdir}/${project}_${subject}_${sesname}_rsfc
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

cd ${projDir}

NOW=$(date +"%m-%d-%Y-%T")
echo "xcp-d started $NOW" >>	${scripts}/fulltimer.txt	

cd ${projDir}
   APPTAINER_CACHEDIR=${CACHESING} APPTAINER_TMPDIR=${TMPSING} apptainer run \
    --cleanenv --containall --no-home --bind ${IMAGEDIR}:/imgdir,${TMPSING}:/sing_scratch \
    --bind ${projDir}:/data ${IMAGEDIR}/xcp_d-v0.9.1.sif \
    --participant-label ${CLEANSUBJECT} --nthreads $num_cpus \
    --omp-nthreads 12 --mem-gb 192 \
    --input-type fmriprep --smoothing $SMOOTHING -p ${CONFOUND_REGRESSION} \
    --motion-filter-type none \
    --combine-runs n --despike n \
    --file-format nifti --linc-qc y --min-coverage 0.5 --output-type censored \
    --warp-surfaces-native2std n --abcc-qc y \
    --lower-bpf 0.01 --upper-bpf 0.08 --bpf-order 2 \
    --notrack --write-graph -vv --create-matrices all --low-mem \
    --mode none -f 0 -w /sing_scratch --notrack --fs-license-file /imgdir/license.txt \
    /data/bids/derivatives/fmriprep /data/bids/derivatives/xcp_d participant

NOW=$(date +"%m-%d-%Y-%T")
echo "xcp-d finished $NOW" >> ${scripts}/fulltimer.txt
