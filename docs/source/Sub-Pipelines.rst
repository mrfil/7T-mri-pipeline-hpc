.. _Sub-Pipelines :

-------------
Sub-Pipelines
-------------

The main pipeline consists of five sub-pipelines:

* Conversion to BIDS with HeuDiConv + basic quality control with MRIQC
* Functional preprocessing with fMRIPrep + resting-state analyses with XCP-D
* Diffusion-weighted image preprocessing with QSIPrep + reconstruction with QSIRecon
* Automated segmentation of hippocampal subfields with ASHS
* Quantitative susceptibility mapping


BIDS-App containers
###################

Examples of how to run each containerized BIDS-App used in our pipeline

The following variables must be set to those for your file structure on your machine:

IMAGEDIR : The location of apptainer_images built for the pipeline
TEMPLATEFLOW_HOST_HOME : The location of a local copy of the TemplateFlow data to prevent errors fetching a copy 
stmpdir & TMPSING : (Interchangeable) locations of a tmp directory for Apptainer to use
scachedir & CACHESING : (Interchangeable) locations of a cache directory for Apptainer to use
projDir : The location of your project's data. This includes bids as a subdirectory.
CLEANSUBJECT : Participant label without "sub-" prefix
CLEANSESSION : Session label without "ses-" prefix
subject : BIDS style participant label with "sub-" prefix
sesname & session : BIDS style session label with "ses-" prefix
scripts : The location of the pipeline scripts

.. note::
    The above are all set via the pipeline script based on argument inputs from the shell command. 


MRIQC - Anatomical & Functional Quality Control
***********************************************

.. code-block:: bash
    docker run -v ${IMAGEDIR}:/imgdir -v ${TEMPLATEFLOW_HOST_HOME}:${APPTAINERENV_TEMPLATEFLOW_HOME} -v ${stmpdir}:/paulscratch -v ${projDir}/bids:/data -v ${projDir}/bids/derivatives/mriqc:/out nipreps/mriqc:24.0.2 /data /out participant --participant-label ${CLEANSUBJECT} --session-id ${CLEANSESSION} -v --no-sub -w /paulscratch

.. code-block:: bash

    apptainer run --contain --no-home --cleanenv --bind ${IMAGEDIR}:/imgdir,${TEMPLATEFLOW_HOST_HOME}:${APPTAINERENV_TEMPLATEFLOW_HOME},${stmpdir}:/paulscratch,${projDir}/bids:/data,${projDir}/bids/derivatives/mriqc:/out ${IMAGEDIR}/mriqc-v24.0.2.sif /data /out participant --participant-label ${CLEANSUBJECT} --session-id ${CLEANSESSION} -v --no-sub

fMRIPrep - Anatomical & Functional Preprocessing
************************************************

.. code-block:: bash

    docker exec -v ${TEMPLATEFLOW_HOST_HOME}:${APPTAINERENV_TEMPLATEFLOW_HOME} -v $IMAGEDIR/license.txt:/opt/freesurfer/license.txt -v $TMPSING:/paulscratch -v ${projDir}:/datain nipreps/fmriprep:23.2.2 fmriprep /datain/bids /datain/bids/derivatives/fmriprep participant --participant-label ${subject} --output-spaces {MNI152NLin2009cAsym,T1w,fsnative} -w /paulscratch --fs-license-file /opt/freesurfer/license.txt

.. code-block:: bash

    apptainer exec --contain --no-home --cleanenv --bind ${TEMPLATEFLOW_HOST_HOME}:${APPTAINERENV_TEMPLATEFLOW_HOME},$IMAGEDIR/license.txt:/opt/freesurfer/license.txt,$TMPSING:/paulscratch,${projDir}:/datain $IMAGEDIR/fmriprep-v23.2.2.sif fmriprep /datain/bids /datain/bids/derivatives/fmriprep participant --participant-label ${subject} --output-spaces {MNI152NLin2009cAsym,T1w,fsnative} -w /paulscratch --fs-license-file /opt/freesurfer/license.txt

*If you do not have fMRI data, use the --anat-only argument*

.. code-block:: bash

    docker exec -v ${TEMPLATEFLOW_HOST_HOME}:${APPTAINERENV_TEMPLATEFLOW_HOME} -v $IMAGEDIR/license.txt:/opt/freesurfer/license.txt -v $TMPSING:/paulscratch -v ${projDir}:/datain nipreps/fmriprep:23.2.2 fmriprep /datain/bids /datain/bids/derivatives/fmriprep participant --participant-label ${subject} --output-spaces {MNI152NLin2009cAsym,T1w,fsnative} --anat-only -w /paulscratch --fs-license-file /opt/freesurfer/license.txt

.. code-block:: bash

    apptainer exec --contain --no-home --cleanenv --bind ${TEMPLATEFLOW_HOST_HOME}:${APPTAINERENV_TEMPLATEFLOW_HOME},$IMAGEDIR/license.txt:/opt/freesurfer/license.txt,$TMPSING:/paulscratch,${projDir}:/datain $IMAGEDIR/fmriprep-v23.2.2.sif fmriprep /datain/bids /datain/bids/derivatives/fmriprep participant --participant-label ${subject} --output-spaces {MNI152NLin2009cAsym,T1w,fsnative} --anat-only -w /paulscratch --fs-license-file /opt/freesurfer/license.txt


XCPEngine - Correlation-based resting-state functional connectivity analysis
****************************************************************************


Correlation-based resting-state functional connectivity analysis in multiple atlases.
Amplitude of Low Frequency Fluctuations (ALFF) and regional homogeneity (REHO) also quantified for each parcellation


Running XCP-D Workflow
==========================

.. code-block:: bash
   
   #running processing
   apptainer run --contain --no-home --cleanenv -B ${projDir}:/data,$TMPSING:/tmpdir $IMAGEDIR/xcp_d-v0.10.0.sif \ 
   --participant_label ${subject} --nthreads $num_cpus \
   --omp-nthreads $((num_cpus / 2)) --input-type fmriprep --smoothing $SMOOTHING -p ${CONFOUND_REGRESSION} \
   -f 0 -w "/sing_scratch" --notrack --fs-license-file /imgdir/license.txt \
   /data/${DERIVATIVES_DIR}/fmriprep /data/${DERIVATIVES_DIR} participant
   
A `more detailed tutorial <https://xcp_d.readthedocs.io/config/tutorial.html>`_ is available in the `XCP-D documentation <https://xcp_d.readthedocs.io/index.html>`_
QSIPrep - DWI preprocessing and reconstruction
**********************************************

Using the structural images and fieldmaps, we perform diffusion-weighted-image preprocessing and structural connectivity analysis in multiple atlases

*Preprocessing*

.. code-block:: bash

    docker run -v ${IMAGEDIR}:/imgdir -v ${stmpdir}:/paulscratch -v ${projDir}:/data pennbbl/qsiprep:0.24.0 --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}

.. code-block:: bash

    apptainer run --contain --no-home --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.24.0.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --freesurfer-input /data/bids/derivatives/fmriprep/freesurfer --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}

*Reconstruction*

Constrained Spherical Deconvolution-based multi-shell multi-tissue w/ SIFT2 via MRtrix3 reconstruction workflow

.. code-block:: bash

    #run reconstruction workflow in QSIPrep
    docker run -v ${IMAGEDIR}:/imgdir -v ${stmpdir}:/paulscratch -v ${projDir}:/data pennbbl/qsirecon:0.23.2 --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec mrtrix_multishell_msmt_ACT-hsvs --freesurfer-input /data/bids/derivatives/fmriprep/freesurfer --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}
    
    #calculate network-based statistics and save NxN matrices from .net
    docker run -v ${scripts}/matlab:/work -v ${scripts}/2019_03_03_BCT:/bctoolbox -v ${projDir}/bids/derivatives/qsirecon:/data ${IMAGEDIR}/matlab-R2019a.sif /work/qsinbs.sh "$subject" "$sesname"

.. code-block:: bash

    #run reconstruction workflow in QSIPrep
    apptainer run --contain --no-home --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsirecon-v0.23.2.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec mrtrix_multishell_msmt_ACT-hsvs --freesurfer-input /data/bids/derivatives/fmriprep/freesurfer --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}
    
    #calculate network-based statistics and save NxN matrices from .net
    apptainer run --contain --no-home --cleanenv --bind ${scripts}/matlab:/work,${scripts}/2019_03_03_BCT:/bctoolbox,${projDir}/bids/derivatives/qsirecon:/data ${IMAGEDIR}/matlab-R2019a.sif /work/qsinbs.sh "$subject" "$sesname"

Generalized q-Sampling imaging via DSI Studio

.. code-block:: bash

    #run reconstruction workflow in QSIPrep
    docker run -v ${IMAGEDIR}:/imgdir -v ${stmpdir}:/paulscratch -v ${projDir}:/data pennbbl/qsiprep:0.23.2 --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep  --recon_spec dsi_studio_gqi --freesurfer-input /data/bids/derivatives/fmriprep/freesurfer --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}

    #get network-based statistics to a csv from .mat
    docker run -v ${scripts}:/scripts -v ${projDir}/bids/derivatives/qsirecon/${subject}/${sesname}/dwi:/datain -W /datain ${IMAGEDIR}/pylearn.sif /scripts/gqimetrics.py


.. code-block:: bash

    #run reconstruction workflow in QSIPrep
    apptainer run --contain --no-home --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.23.2.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec dsi_studio_gqi --freesurfer-input /data/bids/derivatives/fmriprep/freesurfer --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}

    #get network-based statistics to a csv from .mat
    apptainer run --contain --no-home --cleanenv --bind ${scripts}:/scripts,${projDir}/bids/derivatives/qsirecon/${subject}/${sesname}/dwi:/datain -W /datain ${IMAGEDIR}/pylearn.sif /scripts/gqimetrics.py

NODDI via AMICO python implementation

.. code-block:: bash

    #run reconstruction workflow in QSIPrep
    docker run -v ${IMAGEDIR}:/imgdir -v ${stmpdir}:/paulscratch -v ${projDir}:/data pennbbl/qsiprep:0.23.2 --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec amico_noddi --freesurfer-input /data/bids/derivatives/fmriprep/freesurfer --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}

    #ROI-wise stats       
    docker run -v ${scripts}:/scripts -v ${projDir}/bids/derivatives/qsirecon/${subject}/${sesname}/dwi:/datanoddi mrfilbi/neurodoc.sif /scripts/noddi_stats.sh "$subject" "$sesname"

.. code-block:: bash

    #run reconstruction workflow in QSIPrep
    apptainer run --contain --no-home --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsirecon-v0.23.2.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec amico_noddi --freesurfer-input /data/bids/derivatives/fmriprep/freesurfer --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}

    #ROI-wise stats       
    apptainer run --contain --no-home --cleanenv --bind ${scripts}:/scripts,${projDir}/bids/derivatives/qsirecon/${subject}/${sesname}/dwi:/datanoddi ${IMAGEDIR}/neurodoc.sif /scripts/noddi_stats.sh "$subject" "$sesname"


FSL DTI probabilistic tractography from QSIPrep Preprocessing 
*************************************************************

.. note::
    Requires pre-existing FreeSurfer parcellation and FreeSurfer license.txt


QSIPrep preprocessing reorient to FSL space:
============================================

.. code-block:: bash

    #run reconstruction workflow in QSIPrep
    docker run -v ${IMAGEDIR}:/imgdir -v ${stmpdir}:/paulscratch -v ${projDir}:/data ${IMAGEDIR}/qsirecon-v0.23.2.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec reorient_fslstd --freesurfer-input /data/bids/derivatives/fmriprep/freesurfer --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}

.. code-block:: bash

    #run reconstruction workflow in QSIPrep
    apptainer run --contain --no-home --cleanenv --bind ${IMAGEDIR}:/imgdir,${stmpdir}:/paulscratch,${projDir}:/data ${IMAGEDIR}/qsiprep-v0.23.2.sif --fs-license-file /imgdir/license.txt /data/bids /data/bids/derivatives --recon_input /data/bids/derivatives/qsiprep --recon_spec reorient_fslstd --freesurfer-input /data/bids/derivatives/fmriprep/freesurfer --output-resolution 1.6 -w /paulscratch participant --participant-label ${subject}


CUDA 10.2-accelerated FDT pipeline
==================================

Usage: 

.. code-block:: bash

    # Running SCFSL GPU tractography
    docker exec --gpus all -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-10.2/lib64 \
    -v /path/to/freesurfer/license.txt:/opt/freesurfer/license.txt \
    -v /path/project/bids:/data mrfilbi/scfsl_gpu:0.3.2 /bin/bash /scripts/proc_fsl_connectome_fsonly.sh ${subject} ${session}

.. code-block:: bash

    # Running SCFSL GPU tractography
    APPTAINER_ENVLD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-10.2/lib64 \
    apptainer exec --nv -B /path/to/freesurfer/license.txt:/opt/freesurfer/license.txt,/path/project/bids:/data \
    /path/to/scfsl_gpu-v0.3.2.sif /bin/bash /scripts/proc_fsl_connectome_fsonly.sh ${subject} ${session}

*Outputs*

In addition to the fdt_network_matrix produced by probtrackx2 for the masks 
derived from Freesurfer parcellation (generated in sMRIPrep/fMRIPrep),
this sub-pipeline also outputs node-labeled csv files of the NxN streamline-weighted 
and ROI volume-weighted structural connectome.

*Performance*

From initial testing (on 23 datasets from 7T 1.6mm isotropic CMRR DWI):

.. list-table:: Benchmark with 7T DWI data
   :widths: 20 20 30 50 20 20 
   :header-rows: 1

   * - Host OS
     - CUDA Version
     - GPU
     - CPU
     - RAM
     - Run time
   * - CentOS
     - 9.1
     - Nvidia Tesla V100 16GB
     - Intel Xeon Gold 6138 2.00GHz (80 threads)
     - 192GB
     - 30-35 minutes

Peak GPU memory usage: 14435MiB / 16160MiB


From testing 30 datasets from 3T 2.0mm isotropic CMRR DWI):

.. list-table:: Benchmark with 3T DWI data
   :widths: 20 20 30 50 20 20 
   :header-rows: 1

   * - Host OS
     - CUDA Version
     - GPU
     - CPU
     - RAM
     - Run time
   * - CentOS
     - 9.1
     - Nvidia Tesla V100 16GB
     - Intel Xeon Gold 6138 2.00GHz (80 threads)
     - 192GB
     - 25-30 minutes
   * - CentOS
     - 10.2
     - Nvidia Tesla V100 16GB
     - Intel Xeon Gold 6138 2.00GHz (80 threads)
     - 192GB
     - 25-30 minutes


Peak GPU memory usage: 13999MiB / 16160MiB


(Optional) HTML Quality Control Report Generator
================================================

After running enough participant datasets through the pipeline, you can visualize quality control and network-based metrics using the  HTML QC Reports python tool developed by Nishant Bhamidipati and Paul Camacho https://github.com/mrfil/html-qc-reports

Use the pylearn.sif Apptainer image to run QC_Reporter.py 

.. code-block:: bash
    
    cd ./apptainer_images
    git clone https://github.com/mrfil/html-qc-reports.git
    cd html-qc-reports
    apptainer exec -B /path/to/output/collect:/datain,./:/scripts pylearn.sif python3 /scripts/QC_Reporter.py
