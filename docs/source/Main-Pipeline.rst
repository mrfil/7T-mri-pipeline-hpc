.. _Main-Pipeline :

-------------
Main Pipeline
-------------

To facilitate reproducible analyses at 7T, we developed a Singularity container-based processing pipeline for MRI modalities commonly collected at our site (BIC + CI-AIC).
These are compatible with the Brain Imaging Data Structure (BIDS) specification and are designed for deployment to high-performance computing clusters.
This pipeline uses internally and externally developed BIDS-Apps converted from Docker images to Singularity images or built directly as Singularity images (see :ref:`the installation guide<Install>`). 
The pipeline consists of an initial conversion and quality control metric generation step, followed by four steps run in parallel with the Slurm Workload Manager (SchedMD LLC, Lehi, Utah, USA).
*Note that these scripts can also be run on Linux systems not managed by Slurm.*