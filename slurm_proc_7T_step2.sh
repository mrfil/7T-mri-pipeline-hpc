#!/bin/bash
#slurm_process_pipeline.sh

while getopts :p:s:z:l:b:t: option; do
	case ${option} in
    	p) export CLEANPROJECT=$OPTARG ;;
    	s) export CLEANSESSION=$OPTARG ;;
    	z) export CLEANSUBJECT=$OPTARG ;;
	l) export longitudinal=$OPTARG ;;
	b) export based=$OPTARG ;;
	t) export version=$OPTARG ;;
	esac
done
## takes project, subject, and session as inputs

IMAGEDIR=${based}/singularity_images
tmpdir=${based}/${version}/testing
scripts=${based}/${version}/scripts
bids_out=${based}/${version}/bids_only
conn_out=${based}/${version}/conn_out
dataqc=${based}/${version}/data_qc
stmpdir=${based}/${version}/scratch/stmp
scachedir=${based}/${version}/scratch/scache

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

	NOW=$(date +"%m-%d-%Y-%T")
	echo "fMRIPrep started $NOW" >> ${scripts}/fulltimer.txt

	#fmriprep
	echo "Running fmriprep on $subject $sesname"

	${scripts}/project_doc.sh ${project} ${subject} ${sesname} "fmriprep" "no"
	if [ "${longitudinal}" == "yes" ];
	then 
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME},$IMAGEDIR/license.txt:/opt/freesurfer/license.txt,$TMPSING:/paulscratch,${projDir}:/datain $IMAGEDIR/fmriprep-v21.0.1.sif fmriprep /datain/bids /datain/bids/derivatives participant --participant-label ${subject} --longitudinal --use-aroma --output-spaces {MNI152NLin2009cAsym:res-1,MNI152NLin2009cAsym:res-native,T1w:res-1,fsnative:res-1} -w /paulscratch --fs-license-file /opt/freesurfer/license.txt
	elif [ "${longitudinal}" == "no" ];
	then
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME},$IMAGEDIR/license.txt:/opt/freesurfer/license.txt,$TMPSING:/paulscratch,${projDir}:/datain $IMAGEDIR/fmriprep-v21.0.1.sif fmriprep /datain/bids /datain/bids/derivatives participant --participant-label ${subject} --output-spaces {MNI152NLin2009cAsym:res-1,T1w:res-1,fsnative:res-1} -w /paulscratch --use-aroma --mem 190000 --omp-nthreads 20 --nthreads 24 --fs-license-file /opt/freesurfer/license.txt
	fi


	NOW=$(date +"%m-%d-%Y-%T")
	echo "fMRIPrep finished $NOW" >> ${scripts}/fulltimer.txt

	chmod 2777 -R ${projDir}/bids/derivatives/fmriprep
	
	${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} fmriprep ${based}

	cd ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out
	roi_names=$scripts/aparc_cort_subcort_labels.txt
	acqtag="_acq-mp2rageunidenoised_"
	
echo "afni deoblique and resample fmriprep anat outputs"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dWarp -oblique2card -prefix /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz /datafs/"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dresample -dxyz 1 1 1 -prefix /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz -input /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dWarp -oblique2card -prefix /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz /datafs/"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dresample -dxyz 1 1 1 -prefix /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz -input /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dWarp -oblique2card -prefix /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz /datafs/"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/fmriprep/${subject}/${sesname}/anat:/datafs,${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif 3dresample -dxyz 1 1 1 -prefix /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz -input /dataqsm/card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz
	
	echo "Intensity Non-Uniformity Correction with FSL FAST"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif fast -B -b -t 2 /dataqsm/${subject}_${sesname}_ndi_mag_fp2.nii
	#flirt transform routine
       	#extract brain from fmriprep
        echo "Extracting brain from T1w based on fMRIPrep ANTs output"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif fslmaths /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-preproc_T1w.nii.gz -mas /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain_mask.nii.gz /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz
	echo "Registering swi magnitude image to resampled deobliqued preprocessed T1w (see fmriprep anat outputs for more details)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif flirt -cost normmi -dof 12 -in /dataqsm/${subject}_${sesname}_ndi_mag_fp2_restore.nii.gz -ref /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-brain.nii.gz -omat /dataqsm/swi2rage.mat -out /dataqsm/mag_in_rage.nii.gz	
	echo "Inverting transform matrix"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif convert_xfm -omat /dataqsm/rage2swi.mat -inverse /dataqsm/swi2rage.mat
	echo "Registering resampled deobliqued freesurfer parcellation to swi magnitude image (see fmriprep anat outputs for more details)"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm $IMAGEDIR/neurodoc.sif flirt -interp sinc -in /dataqsm/resample_card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz -ref /dataqsm/${subject}_${sesname}_ndi_mag_fp2_restore.nii.gz -applyxfm -init /dataqsm/rage2swi.mat -out /dataqsm/FS_to_SWI.nii.gz
	echo "Calculation ROI-wise stats on QSM image using fslstats"
	SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity exec --cleanenv --bind ${projDir}/bids/derivatives/swi/${subject}/${sesname}/ndi_out:/dataqsm,${scripts}:/scripts $IMAGEDIR/neurodoc.sif /scripts/qsm_stats.sh ${subject} ${sesname}
		
		#copy freesurfer to fmriprep so xcpEngine can find it
		cd ${projDir}/bids/derivatives
		mkdir ./fmriprep/freesurfer
		cp -R ./freesurfer/fsaverage ./fmriprep/freesurfer/fsaverage
		cp -R ./freesurfer/${subject} ./fmriprep/freesurfer/${subject}	
	
		chmod 2777 -R ${projDir}/bids/derivatives/fmriprep
		cd ${projDir}

		NOW=$(date +"%m-%d-%Y-%T")
		echo "xcpEngine fc-36p started $NOW" >>	${scripts}/fulltimer.txt
		
		#generate xcpEngine cohorts for a new subject
		${scripts}/func_cohort_maker.sh ${subject} ${sesname} yes


		#xcpEngine 36p
		$scripts/project_doc.sh ${project} ${subject} ${sesname} "xcpengine" "no"
		cp ${scripts}/xcpEngineDesigns/*_gh.dsn ${projDir}/
		cd ${projDir}
		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv -B ${projDir}:/data,$TMPSING:/tmpdir $IMAGEDIR/xcpengine-1.2.4.sif -d /data/fc-36p_gh.dsn -c /data/cohort_func_${subject}_${sesname}.csv -o /data/bids/derivatives/xcp/${sesname}/xcp_minimal_func -r /data/bids -i /tmpdir
		chmod 2777 -R ${projDir}/bids/derivatives/xcp*
		mv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/*quality.csv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/${subject}_${sesname}_quality_fc36p.csv
		${scripts}/procd.sh ${project} xcp no ${subject} ${based}

		${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} xcp36p ${based}

		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --bind ${scripts}/spm12:/spmtoolbox,${scripts}/matlab:/work,${scripts}/2019_03_03_BCT:/bctoolbox,${projDir}/bids/derivatives/xcp/${sesname}:/datain ${IMAGEDIR}/matlab-R2019a.sif /work/rsfcnbs.sh "xcp_minimal_func" "${subject}"
		mkdir ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs
		mkdir ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/fc36p
		chmod 777 -R ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/fc36p
		cp ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/*txt ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/fc36p/
		

		NOW=$(date +"%m-%d-%Y-%T")
		echo "xcpEngine fc-36p finished $NOW" >> ${scripts}/fulltimer.txt
		

        NOW=$(date +"%m-%d-%Y-%T")
        echo "xcpEngine fc-36p despike started $NOW" >> ${scripts}/fulltimer.txt

        #xcpEngine 36p despike
        $scripts/project_doc.sh ${project} ${subject} ${sesname} "xcpengine" "no"
        cd ${projDir}
        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv -B ${projDir}:/data,$TMPSING:/tmpdir $IMAGEDIR/xcpengine-1.2.4.sif -d /data/fc-36p_despike_gh.dsn -c /data/cohort_func_${subject}_${sesname}.csv -o /data/bids/derivatives/xcp/${sesname}/xcp_despike -r /data/bids -i /tmpdir
        chmod 2777 -R ${projDir}/bids/derivatives/xcp*
        mv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_despike/${subject}/*quality.csv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/${subject}_${sesname}_quality_despike.csv


        SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --bind ${scripts}/spm12:/spmtoolbox,${scripts}/matlab:/work,${scripts}/2019_03_03_BCT:/bctoolbox,${projDir}/bids/derivatives/xcp/${sesname}:/datain ${IMAGEDIR}/matlab-R2019a.sif /work/rsfcnbs.sh "xcp_despike" "${subject}"
        mkdir ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/despike
        chmod 777 -R ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/despike
        cp ${projDir}/bids/derivatives/xcp/${sesname}/xcp_despike/${subject}/fcon/*txt ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/despike/
${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} xcp36pdespike ${based}

        NOW=$(date +"%m-%d-%Y-%T")
        echo "xcpEngine fc-36p despike finished $NOW" >> ${scripts}/fulltimer.txt


		NOW=$(date +"%m-%d-%Y-%T")
		echo "xcpEngine fc-36p_scrub started $NOW" >> ${scripts}/fulltimer.txt

		#xcpEngine 36p_scrub
		cd ${projDir}
		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv -B ${projDir}:/data,$TMPSING:/tmpdir $IMAGEDIR/xcpengine-1.2.4.sif -d /data/fc-36p_scrub_gh.dsn -c /data/cohort_func_${subject}_${sesname}.csv -o /data/bids/derivatives/xcp/${sesname}/xcp_scrub -r /data/bids -i /tmpdir
		chmod 2777 -R /projects/BICpipeline/Pipeline_Pilot/TestingFork/${project}/bids/derivatives/xcp*
		mv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_scrub/${subject}/*quality.csv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/${subject}_${sesname}_quality_scrub.csv

		${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} xcp36pscrub ${based}

		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv --bind ${scripts}/spm12:/spmtoolbox,${scripts}/matlab:/work,${scripts}/2019_03_03_BCT:/bctoolbox,${projDir}/bids/derivatives/xcp/${sesname}:/datain ${IMAGEDIR}/matlab-R2019a.sif /work/rsfcnbs.sh "xcp_scrub" "${subject}" 
		mkdir ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/scrub
		chmod 777 -R ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/scrub
		cp ${projDir}/bids/derivatives/xcp/${sesname}/xcp_scrub/${subject}/fcon/*txt ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_func/${subject}/fcon/nbs/scrub/

		NOW=$(date +"%m-%d-%Y-%T")
	
		echo "xcpEngine fc-36p_scrub finished $NOW" >> ${scripts}/fulltimer.txt

		NOW=$(date +"%m-%d-%Y-%T")
		echo "xcpEngine fc-aroma started $NOW" >> ${scripts}/fulltimer.txt

		#xcpEngine aroma
		$scripts/project_doc.sh ${project} ${subject} ${sesname} "xcpengine" "no"
		cd ${projDir}
		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv -B ${projDir}:/data,$TMPSING:/tmpdir $IMAGEDIR/xcpengine-1.2.4.sif -d /data/fc-aroma_gh.dsn -c /data/cohort_func_${subject}_${sesname}.csv -o /data/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma -r /data/bids -i /tmpdir
		chmod 2777 -R ${projDir}/bids/derivatives/xcp*
		mv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma/${subject}/*quality.csv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma/${subject}/${subject}_${sesname}_quality_aroma.csv 

		${scripts}/procd.sh $project xcp no ${subject} ${based}
		cp ${scripts}/projdoc.css ${based}/batchproc/${project}/${project}_sample.css
		${scripts}/pdf_printer.sh ${project} ${subject} ${sesname} xcpfcaroma ${based}

		NOW=$(date +"%m-%d-%Y-%T")
		echo "xcpEngine fc-aroma finished $NOW" >> ${scripts}/fulltimer.txt

		SINGULARITY_CACHEDIR=$CACHESING SINGULARITY_TMPDIR=$TMPSING singularity run --cleanenv --bind ${scripts}/spm12:/spmtoolbox,${scripts}/matlab:/work,${scripts}/2019_03_03_BCT:/bctoolbox,${projDir}/bids/derivatives/xcp/${sesname}:/datain ${IMAGEDIR}/matlab-R2019a.sif /work/rsfcnbs.sh "xcp_minimal_aroma" "${subject}" 
		mkdir ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma/${subject}/fcon/nbs
		chmod 777 -R ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma/${subject}/fcon/nbs
		mv ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma/${subject}/fcon/*txt ${projDir}/bids/derivatives/xcp/${sesname}/xcp_minimal_aroma/${subject}/fcon/nbs/


