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

#check for heuristic
if [ -f "${tmpdir}/${project}/${project}_heuristic.py" ];
then
	echo "trusting project heuristic"
else
	cp ${scripts}/main_heuristic.py ${tmpdir}/${project}/${project}_heuristic.py
fi

if [ "${MINQC}" == "yes" ];
then

	projDir=${tmpdir}/${project}
	scripts=${based}/${version}/scripts

	cd $projDir

	IMAGEDIR=${based}/singularity_images
	CACHESING=${scachedir}/${project}_${subject}_${sesname}_minqc
	TMPSING=${stmpdir}/${project}_${subject}_${sesname}_minqc

	mkdir $CACHESING
	mkdir $TMPSING
	chmod 777 -R $CACHESING
	chmod 777 -R $TMPSING

	NOW=$(date +"%m-%d-%Y-%T")
	#heudiconv
	echo "Running heudiconv"
	echo "$NOW" >> ${scripts}/timer.txt

	ses=${sesname:4}
	sub=${subject:4}
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}:/datain $IMAGEDIR/heudiconv0.6.simg heudiconv -d /datain/{subject}/{session}/*/scans/*/DICOM/*dcm -f /datain/${project}_heuristic.py -o /datain/bids -s ${sub} -ss ${ses} -c dcm2niix -b
	chmod 777 -R ${projDir}/bids
	rm -rf __pycache__

	mkdir ${based}/dataqc/${project}

	mkdir ${projDir}/bids/derivatives

	cd ${projDir}

	rm ${projDir}/bids/derivatives/mriqc
	mkdir ${projDir}/bids/derivatives/mriqc
	chmod 2777 -R ${projDir}/bids/derivatives/mriqc

	cd $projDir
	echo "Running mriqc"

	NOW=$(date +"%m-%d-%Y-%T")
	echo "$NOW" >> ${scripts}/timer.txt

	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv --bind ${projDir}/bids:/data --bind ${projDir}/bids/derivatives/mriqc:/out $IMAGEDIR/mriqc-0.16.0.sif /data /out participant --participant-label ${sub} --session-id ${ses} --fft-spikes-detector --despike --no-sub
	chmod 2777 -R ${projDir}/bids/derivatives/mriqc

	NOW=$(date +"%m-%d-%Y-%T")
	echo "$NOW" >> ${scripts}/timer.txt

	${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} mriqc ${based}

	rm -rf $CACHESING
	rm -rf $TMPSING
	mv ${projDir}/bids/derivatives/mriqc ${based}/dataqc/${project}/mriqc
	chmod 777 -R ${based}/dataqc/${project}

else
	projDir=${tmpdir}/${project}
	scripts=${based}/${version}/scripts

	cd $projDir

	IMAGEDIR=${based}/singularity_images
	CACHESING=${scachedir}/${project}_${subject}_${sesname}_dcm2rsfc
	TMPSING=${stmpdir}/${project}_${subject}_${sesname}_dcm2rsfc
	mkdir $CACHESING
	mkdir $TMPSING

	NOW=$(date +"%m-%d-%Y-%T")
	echo "HeuDiConv started $NOW" >> ${scripts}/fulltimer.txt

	#heudiconv
	echo "Running heudiconv"
	${scripts}/project_doc.sh ${project} ${subject} ${sesname} "heudiconv" "yes"
	ses=${sesname:4}
	sub=${subject:4}
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}:/datain ${IMAGEDIR}/heudiconv-0.9.0.sif heudiconv -d /datain/{subject}/{session}/scans/*/DICOM/*dcm -f /datain/${project}_heuristic_HCP.py -o /datain/bids --minmeta -s ${sub} -ss ${ses} -c dcm2niix -b --overwrite 
	chmod 2777 -R ${projDir}/bids

	NOW=$(date +"%m-%d-%Y-%T")
	echo "HeuDiConv finished $NOW" >> ${scripts}/fulltimer.txt

	if [ "${fieldmaps}" == "yes" ];
	then
	    SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}:/data,${scripts}:/scripts ${IMAGEDIR}/ubuntu-jq-0.1.sif /scripts/jsoncrawler.sh /data/bids ${sesname} ${subject}
	fi
	
	cd ${projDir}/bids/${subject}/${sesname}/anat/
	echo "`ls *DREAM*`" >> ${projDir}/bids/.bidsignore
	rm ${projDir}/bids/derivatives/${subject}/${sesname}/tmp
	rm ${projDir}/bids/derivatives/${subject}/${sesname}/test.txt	

	mkdir ${based}/${version}/output/${project}

	mkdir ${projDir}/bids/derivatives

	cd ${projDir}

	echo "Denoising MP2RAGE with LAYNII"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/sub-${sub}/ses-${ses}/anat:/datain $IMAGEDIR/laynii-2.0.0.sif /opt/laynii2/laynii/LN_MP2RAGE_DNOISE -INV1 /datain/sub-${sub}_ses-${ses}_acq-mp2rageinv_run-1_T1w.nii.gz -INV2 /datain/sub-${sub}_ses-${ses}_acq-mp2rageinv_run-2_T1w.nii.gz -UNI /datain/sub-${sub}_ses-${ses}_acq-mp2rageuni_run-3_T1w.nii.gz -beta 0.2
	mv ${projDir}/bids/sub-${sub}/ses-${ses}/anat/*inv* ${projDir}/bids/derivatives/
	mv ${projDir}/bids/sub-${sub}/ses-${ses}/anat/*uni_run-*_T1w.nii.gz ${projDir}/bids/derivatives/
	mv ${projDir}/bids/sub-${sub}/ses-${ses}/anat/*uni_run-*_T1w.json ${projDir}/bids/derivatives/
	mv ${projDir}/bids/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageuni_run-3_T1w*border*.nii.gz ${projDir}/bids/derivatives/
        mv ${projDir}/bids/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageuni_run-3_T1w_denoised.nii.gz ${projDir}/bids/sub-${sub}/ses-${ses}/anat/sub-${sub}_ses-${ses}_acq-mp2rageunidenoised_T1w.nii.gz 
	mkdir ${projDir}/bids/derivatives/mriqc
	chmod 777 -R ${projDir}/bids/derivatives/mriqc

	mkdir -p ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out
	mkdir -p ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/ndi_out

        cp ${projDir}/${sub}/${ses}/scans/swi/*dcm ${projDir}/bids/derivatives/swi/${subject}/${sesname}/
        cp ${projDir}/${sub}/${ses}/scans/swi_old/*dcm ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}/
	echo "Generating QSM with hybrid Cornell-Berkeley tools"
	echo "Fractional intensity threshold set to 0.3 (see scripts/matlab/ndi_qsm_fp3.sh)"
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}:/datain,${IMAGEDIR}/ndi:/ndi,${scripts}/matlab:/scripts ${IMAGEDIR}/matlab-r2019a.sif /scripts/ndi_qsm_fp3.sh
	echo "Pseudo-BIDSifying QSM outputs"
	cd ${projDir}/bids/derivatives/swi/${subject}/${sesname}
	mv ./ndi_out/mag.nii ./ndi_out/${subject}_${sesname}_ndi_mag_fp3.nii
	mv ./ndi_out/phs.nii ./ndi_out/${subject}_${sesname}_ndi_phs_fp3.nii
	mv ./ndi_out/qsm.nii ./ndi_out/${subject}_${sesname}_ndi_qsm_fp3.nii

        echo "Fractional intensity threshold set to 0.2 (see scripts/matlab/ndi_qsm_fp2.sh)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}:/datain,${IMAGEDIR}/ndi:/ndi,${scripts}/matlab:/scripts ${IMAGEDIR}/matlab-r2019a.sif /scripts/ndi_qsm_fp2.sh
        echo "Pseudo-BIDSifying QSM outputs"
        cd ${projDir}/bids/derivatives/swi/${subject}/${sesname}
        mv ./ndi_out/mag.nii ./ndi_out/${subject}_${sesname}_ndi_mag_fp2.nii
        mv ./ndi_out/phs.nii ./ndi_out/${subject}_${sesname}_ndi_phs_fp2.nii
        mv ./ndi_out/qsm.nii ./ndi_out/${subject}_${sesname}_ndi_qsm_fp2.nii

        echo "Fractional intensity threshold set to 0.4 (see scripts/matlab/ndi_qsm_fp4.sh)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}:/datain,${IMAGEDIR}/ndi:/ndi,${scripts}/matlab:/scripts ${IMAGEDIR}/matlab-r2019a.sif /scripts/ndi_qsm_fp4.sh
        echo "Pseudo-BIDSifying QSM outputs"
        cd ${projDir}/bids/derivatives/swi/${subject}/${sesname}
        mv ./ndi_out/mag.nii ./ndi_out/${subject}_${sesname}_ndi_mag_fp4.nii
        mv ./ndi_out/phs.nii ./ndi_out/${subject}_${sesname}_ndi_phs_fp4.nii
        mv ./ndi_out/qsm.nii ./ndi_out/${subject}_${sesname}_ndi_qsm_fp4.nii

        echo "Fractional intensity threshold set to 0.2 (see scripts/matlab/ndi_qsm_fp2.sh)"
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --bind ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}:/datain,${IMAGEDIR}/ndi:/ndi,${scripts}/matlab:/scripts ${IMAGEDIR}/matlab-r2019a.sif /scripts/ndi_qsm_fp2.sh
        echo "Pseudo-BIDSifying QSM outputs"
        cd ${projDir}/bids/derivatives/swi_old/${subject}/${sesname}
        mv ./ndi_out/mag.nii ./ndi_out/${subject}_${sesname}_ndi_mag_fp2.nii
        mv ./ndi_out/phs.nii ./ndi_out/${subject}_${sesname}_ndi_phs_fp2.nii
        mv ./ndi_out/qsm.nii ./ndi_out/${subject}_${sesname}_ndi_qsm_fp2.nii

	
	echo "Running mriqc"
	TEMPLATEFLOW_HOST_HOME=$IMAGEDIR/templateflow
        export SINGULARITYENV_TEMPLATEFLOW_HOME="/templateflow"
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --bind ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME},${projDir}/bids:/data,${projDir}/bids/derivatives/mriqc:/out $IMAGEDIR/mriqc-0.16.1.sif /data /out participant --participant-label ${sub} --session-id ${ses} -v --fft-spikes-detector --despike --no-sub
	chmod 2777 -R ${projDir}/bids/derivatives/mriqc

	NOW=$(date +"%m-%d-%Y-%T")
	echo "MRIQC finished $NOW" >> ${scripts}/fulltimer.txt

	${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} mriqc ${based}

	mkdir ${dataqc}/${project}
	cp -R ${projDir}/bids/derivatives/mriqc ${dataqc}/${project}/

fi
