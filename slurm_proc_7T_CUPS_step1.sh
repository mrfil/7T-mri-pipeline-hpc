#!/bin/bash
#
# slurm_proc_7T_CUPS_step1.sh
#
# This script is the first step in the 7T CUPS pipeline. It runs HeuDiConv, LAYNII MP2RAGE Denoising, and MRIQC on the input subject and session.

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

#check for heuristic
if [ -f "${tmpdir}/${project}/${project}_heuristic.py" ];
then
	echo "trusting project heuristic"
else
	cp ${scripts}/main_heuristic.py ${tmpdir}/${project}/${project}_heuristic.py
fi

if [ "${MINQC}" == "yes" ];
then

	projDir=${base_dir}/${version}/testing/${project}

	cd $projDir

	IMAGEDIR=${base_dir}/apptainer_images
	CACHESING=${scachedir}/${project}_${subject}_${sesname}_minqc
	TMPSING=${stmpdir}/${project}_${subject}_${sesname}_minqc

	mkdir $CACHESING
	mkdir $TMPSING
	chmod 730 -R $CACHESING
	chmod 730 -R $TMPSING

	NOW=$(date +"%m-%d-%Y-%T")
	#heudiconv
	echo "Running heudiconv"
	echo "$NOW" >> ${scripts}/timer.txt

	ses=${sesname:4}
	sub=${subject:4}
	APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --cleanenv --no-home --contain \
	--bind ${projDir}:/datain $IMAGEDIR/heudiconv-1.3.0.sif heudiconv -d /datain/{subject}/{session}/*/scans/*/DICOM/*dcm \
	-f /datain/${project}_heuristic.py -o /datain/bids -s ${sub} -ss ${ses} -c dcm2niix -b
	chmod 730 -R ${projDir}/bids
	rm -rf __pycache__

	mkdir ${projDir}/bids/derivatives/mriqc -p

	cd ${projDir}

	echo "Running mriqc"

	NOW=$(date +"%m-%d-%Y-%T")
	echo "$NOW" >> ${scripts}/timer.txt

	APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer run --containall --no-home --cleanenv \
	--bind ${projDir}/bids:/data --bind ${projDir}/bids/derivatives/mriqc:/out \
	$IMAGEDIR/mriqc-v24.0.2.sif /data /out participant --participant-label ${sub} \
	--session-id ${ses} --fft-spikes-detector --despike --no-sub
	chmod 730 -R ${projDir}/bids/derivatives/mriqc

	NOW=$(date +"%m-%d-%Y-%T")
	echo "$NOW" >> ${scripts}/timer.txt

	rm -rf $CACHESING
	rm -rf $TMPSING

else
	projDir=${base_dir}/${version}/testing/${project}

	cd $projDir

	IMAGEDIR=${base_dir}/apptainer_images
	CACHESING=${scachedir}/${project}_${subject}_${sesname}_dcm2rsfc
	TMPSING=${stmpdir}/${project}_${subject}_${sesname}_dcm2rsfc
	mkdir $CACHESING
	mkdir $TMPSING

	NOW=$(date +"%m-%d-%Y-%T")
	echo "HeuDiConv started $NOW" >> ${scripts}/fulltimer.txt

	#heudiconv
	echo "Running heudiconv"
	ses=${sesname:4}
	sub=${subject:4}
	APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --containall --no-home --cleanenv \
	--bind ${projDir}:/datain ${IMAGEDIR}/heudiconv-v1.3.0.sif heudiconv \
	-d /datain/{subject}/{session}/scans/*/DICOM/*dcm -f /datain/${project}_heuristic.py \
	-o /datain/bids/sourcedata --minmeta -s ${sub} -ss ${ses} -c dcm2niix -b --overwrite 
	chmod 730 -R ${projDir}/bids

	NOW=$(date +"%m-%d-%Y-%T")
	echo "HeuDiConv finished $NOW" >> ${scripts}/fulltimer.txt

	if [ "${fieldmaps}" == "yes" ];
	then
	    APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --cleanenv --no-home --contain \
		--bind ${projDir}:/data,${scripts}:/scripts ${IMAGEDIR}/ubuntu-jqjo.sif /scripts/jsoncrawler_jq.sh \
		/data/bids/sourcedata ${sesname} ${subject}
	fi
	
	cd ${projDir}/bids/sourcedata/${subject}/${sesname}/anat/
	echo "`ls *DREAM*`" >> ${projDir}/bids/.bidsignore
	rm ${projDir}/bids/derivatives/${subject}/${sesname}/tmp
	rm ${projDir}/bids/derivatives/${subject}/${sesname}/test.txt
	cd -

	mkdir ${projDir}/bids/derivatives

	cd ${projDir}

	echo "Denoising MP2RAGE with LAYNII"
	APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer exec --containall --no-home --cleanenv --bind ${projDir}/bids/sourcedata/sub-${sub}/ses-${ses}/anat:/datain $IMAGEDIR/laynii-v2.1.1.sif /opt/laynii2/laynii/LN_MP2RAGE_DNOISE -INV1 /datain/sub-${sub}_ses-${ses}_acq-mp2rageinv_run-1_T1w.nii.gz -INV2 /datain/sub-${sub}_ses-${ses}_acq-mp2rageinv_run-2_T1w.nii.gz -UNI /datain/sub-${sub}_ses-${ses}_acq-mp2rageuni_run-3_T1w.nii.gz -beta 0.4
	mv ${projDir}/bids/sourcedata/sub-${sub}/ses-${ses}/anat/*inv* ${projDir}/bids/derivatives/
	mv ${projDir}/bids/sourcedata/sub-${sub}/ses-${ses}/anat/*uni_run-*_T1w.nii.gz ${projDir}/bids/derivatives/
	mv ${projDir}/bids/sourcedata/sub-${sub}/ses-${ses}/anat/*uni_run-*_T1w.json ${projDir}/bids/derivatives/
	mv ${projDir}/bids/sourcedata/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageuni_run-3_T1w*border*.nii.gz ${projDir}/bids/derivatives/
    mv ${projDir}/bids/sourcedata/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageuni_run-3_T1w_denoised.nii.gz ${projDir}/bids/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageunidenoised_T1w.nii.gz 


	mkdir ${projDir}/bids/derivatives/mriqc
	chmod 730 -R ${projDir}/bids/derivatives/mriqc
	
	echo "Running mriqc"
	TEMPLATEFLOW_HOST_HOME=$IMAGEDIR/templateflow
    export APPTAINERENV_TEMPLATEFLOW_HOME="/templateflow"
    APPTAINER_CACHEDIR=$CACHESING APPTAINER_TMPDIR=$TMPSING apptainer run --bind ${TEMPLATEFLOW_HOST_HOME}:${APPTAINERENV_TEMPLATEFLOW_HOME},${projDir}/bids/sourcedata:/data,${projDir}/bids/derivatives/mriqc:/out $IMAGEDIR/mriqc-v24.0.2.sif /data /out participant --participant-label ${sub} --session-id ${ses} -v --no-sub
	chmod 730 -R ${projDir}/bids/derivatives/mriqc

	NOW=$(date +"%m-%d-%Y-%T")
	echo "MRIQC finished $NOW" >> ${scripts}/fulltimer.txt

fi
