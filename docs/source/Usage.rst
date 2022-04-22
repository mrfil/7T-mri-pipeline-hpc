.. _Usage :

-----
Usage
-----

We designed this pipeline to use a `Slurm <https://slurm.schedmd.com/>`_-managed high-performance computing cluster.
The main pipeline takes MRI data in DICOM format and utilizes BIDS-Apps to output common preprocessing 
derivatives, processed derivatives, connectivity analyses, and other quantified microstructure measures and images. 


Setup for this pipeline is not currently automated due to the nature of building Singularity images varying for different systems and users of those systems.
We assume here that you have followed the `installation guide<Install>` to make your Singularity images and transferred them to the cluster you are using.


Once you have your DICOMs in a consistent directory structure (i.e. project/participant/session/series/DICOM/*dcm),
you can start modifying your :ref:`heuristic.py <Heuristics>`_ file (here named ${project}_heuristic.py). With your final heuristic,
you are ready to run the first part of the pipeline:


Since our use case for this pipeline is primarily for ongoing data collection, we split the pipeline into separate steps.
With the exception of `Step 1 <https://github.com/mrfil/7T-mri-pipeline-hpc/slurm_proc_7T_CUPS_step1.sh>`_, these steps do are intended to be run in parallel.
This allows for a faster turnaround time for processing if your cluster is able to process all sessions from one day before the next sessions begin processing.
*It is unlikely that this is the case for the functional stream due to processes stalling in Freesurfer recon-all*


You should have an array of participant ID numbers (maximum is three digits for sbatch) for your study.
*If you have more than 3 digits in your participant ID numbers, please see `dyno_PROJs.sh<make this link>`*
This array is passed to sbatch with the -a argument. We recommend creating a copy of dyno.sh that is study-specific in case you handle multiple studies and need to control the versions of scripts/apps.
You should do the same for the steps of the pipeline by changing the study label "CUPS" to your study ID.
If your sessions do not following the A B C ... naming convention, you will need to change the dyno.sh file to reflect the session naming convention.
These commands are written to run from your scripts directory: 

Step 1 - conversion to BIDS, MP2RAGE denoising, and MRIQC
---------------------------------------------------------

.. code-block:: bash

    sbatch -a 001,002,003 ./dyno_PROJ_A.sh slurm_proc_7T_CUPS_step1.sh <PROJECTID> <base directory> <version>

After this has completed - technically after the MRIQC processing begins - you can queue the rest of the steps for processing as appropriate for your dataset.

.. note::
    Using FreeSurfer for QSIprep will require that portion of Step 2 to finish first!

Step 2 - functional MRI stream
------------------------------

.. code-block:: bash

    sbatch -a 001,002,003 ./dyno_PROJ_A.sh slurm_proc_7T_CUPS_step2.sh <PROJECTID> <base directory> <version>


Automated segmentation of hippocampal subfields + Quantitative susceptibility mapping
-------------------------------------------------------------------------------------

.. code-block:: bash

    sbatch -a 001,002,003 ./dyno_PROJ_A.sh slurm_proc_7T_CUPS_ashs.sh <PROJECTID> <base directory> <version>
    sbatch -a 001,002,003 ./dyno_PROJ_A.sh slurm_qsm_stats_rage.sh <PROJECTID> <base directory> <version>


Step 3 - diffusion MRI stream
-----------------------------

.. code-block:: bash

    sbatch -a 001,002,003 ./dyno_PROJ_A.sh slurm_proc_7T_CUPS_step3.sh <PROJECTID> <base directory> <version>


(Optional) Running FreeSurfer-informed FSL DTI tractography on GPU
-------------------------------------------------------

.. note::
    Requires pre-existing FreeSurfer parcellation and FreeSurfer license.txt.
    As of 03/15/2022, the main pipeline will can produce the QSIPrep preprocessing outputs in fsl space for this workflow. 
    *These QSIPrep preprocessing outputs are required for the current script!*
    This workflow is intended to run on machines with CUDA 9.1 or CUDA 10.2 compatible GPUs.

*Docker*

.. code-block:: bash

    # Running SCFSL GPU tractography
    docker exec --gpus all -e LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-10.2/lib64 \
    -v /path/to/freesurfer/license.txt:/opt/freesurfer/license.txt \
    -v /path/project/bids:/data mrfilbi/scfsl_gpu:0.3.2 /bin/bash /scripts/proc_fsl_connectome_fsonly.sh ${subject} ${session}

*Singularity*

.. code-block:: bash

    # Running SCFSL GPU tractography
    SINGULARITY_ENVLD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-10.2/lib64 \
    singularity exec --nv -B /path/to/freesurfer/license.txt:/opt/freesurfer/license.txt,/path/project/bids:/data \
    /path/to/scfsl_gpu-v0.3.2.sif /bin/bash /scripts/proc_fsl_connectome_fsonly.sh ${subject} ${session}


Metrics Collation
-----------------

As your dataset reaches a desired size for data quality monitoring or statistical analyses,
you can combine the many metrics from the above BIDS-Apps to a one-line csv for each session for each participant:

.. code-block:: bash

    sbatch -a 001,002,003 ./dyno_PROJ_A.sh pipeline_collate.sh <PROJECTID> <base directory> <version>
    ./collect.sh <version> <PROJECTID> <base directory>

The collect.sh script takes these csvs for each participant and creates a group-level csv (output/PROJECTID/collect/).


Running on one node
-------------------

To run the main pipeline and log processing times, run with Slurm *sbatch* as follows:


.. code-block:: bash

    sbatch -a 001,002,003 ./dyno_PROJ_A.sh slurm_proc_7T_CUPS.sh <PROJECTID> <base directory> <version>

(Optional) HTML Quality Control Report Generator
------------------------------------------------

After running enough participant datasets through the pipeline, you can visualize quality control and network-based metrics using the  HTML QC Reports python tool developed by Nishant Bhamidipati and Paul Camacho https://github.com/mrfil/html-qc-reports

Use the pylearn.sif Singularity image to run QC_Reporter.py 

.. code-block:: bash
    
    cd ./singularity_images
    git clone https://github.com/mrfil/html-qc-reports.git
    cd html-qc-reports
    singularity exec -B /path/to/output/collect:/datain,./:/scripts pylearn.sif python3 /scripts/QC_Reporter.py

    
