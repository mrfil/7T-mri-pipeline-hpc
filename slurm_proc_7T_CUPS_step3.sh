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
	
	if [ -d "${projDir}/bids/${subject}/${sesname}/dwi" ];
        then

		IMAGEDIR=${based}/singularity_images
		scripts=${based}/${version}/scripts
		projDir=${based}/${version}/testing/${project}
		scachedir=${based}/${version}/scratch/scache/${project}/${sesname}
		stmpdir=${based}/${version}/scratch/stmp/${project}/${sesname}

		mkdir ${based}/${version}/scratch/scache/${project}
		mkdir ${based}/${version}/scratch/stmp/${project}
		mkdir ${based}/${version}/scratch/scache/${project}/${sesname}
		mkdir ${based}/${version}/scratch/stmp/${project}/${sesname}
		chmod 777 -R ${stmpdir}
		chmod 777 -R ${scachedir}
		NOW=$(date +"%m-%d-%Y-%T")
		echo "QSIprep started $NOW" >> ${scripts}/fulltimer.txt

		SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.16.1.sif --fs-license-file /imgdir/license.txt /data/bids/sourcedata /data/bids/derivatives  --freesurfer_input /data/bids/derivatives/sourcedata/freesurfer --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}

		chmod 777 -R ${projDir}/bids/derivatives/qsiprep
		${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} QSIprep ${based}
		NOW=$(date +"%m-%d-%Y-%T")
		echo "QSIprep finished $NOW" >> ${scripts}/fulltimer.txt
		NOW=$(date +"%m-%d-%Y-%T")
		echo "QSIprep Recon started $NOW" >> ${scripts}/fulltimer.txt
		SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.16.1.sif --fs-license-file /imgdir/license.txt /data/bids/sourcedata /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec mrtrix_multishell_msmt_ACT-hsvs --freesurfer_input /data/bids/derivatives/sourcedata/freesurfer --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}
		SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.16.1.sif --fs-license-file /imgdir/license.txt /data/bids/sourcedata /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec dsi_studio_gqi --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}
        SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.16.1.sif --fs-license-file /imgdir/license.txt /data/bids/sourcedata /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec amico_noddi --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}
        NOW=$(date +"%m-%d-%Y-%T")
		echo "QSIprep Recon finished $NOW" >> ${scripts}/fulltimer.txt
		chmod 777 -R ${projDir}/bids/derivatives/qsirecon

		SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${scripts}/matlab:/work,${scripts}/2019_03_03_BCT:/bctoolbox,${projDir}/bids/derivatives/qsirecon:/data ${IMAGEDIR}/matlab-R2019a.sif /work/qsinbs.sh "$subject" "$sesname"

		SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${scripts}:/scripts,${projDir}/bids/derivatives/qsirecon/${subject}/${sesname}/dwi:/datain -W /datain ${IMAGEDIR}/pylearn.sif /scripts/gqimetrics.py
		
		SINGULARITY_CACHEDIR=${scachedir} SINGULARITY_TMPDIR=${stmpdir} singularity run --cleanenv --bind ${scripts}:/scripts,${projDir}/bids/derivatives/qsirecon/${subject}/${sesname}/dwi:/datanoddi ${IMAGEDIR}/neurodoc.sif /scripts/noddi_stats.sh "$subject" "$sesname"
		
		cd {projDir}/bids/derivatives/qsirecon/${subject}/${sesname}/dwi
		paste -d, *ISOVF*csv > ${subject}_${sesname}_ISOVF.csv
		paste -d, *ICVF*csv > ${subject}_${sesname}_ICVF.csv
		paste -d, *OD*csv > ${subject}_${sesname}_OD.csv
		paste -d ${subject}_${sesname}_ICVF.csv ${subject}_${sesname}_ISOVF.csv ${subject}_${sesname}_OD.csv > ${subject}_${sesname}_NODDI_STATS.csv
		
		${scripts}/pdf_printer.sh ${projID} ${subject} ${sesname} QSIprepRecon ${based}
	fi

