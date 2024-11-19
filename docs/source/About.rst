.. _About :

-----
About
-----

The BIDS format and BIDS-App pipelines
--------------------------------------
This pipeline and its sub-pipelines are designed to convert DICOM data to the Brain Imaging Data Structure (BIDS)
and leverage BIDS-Apps to perform quality control, preprocessing, and automated analyses on high-performance computing clusters.
The main Pipeline takes 7T brain MRI DICOMs and outputs BIDS sourcedata, preprocessed derivatives, resting-state functional connectivity and structural connectivity matrices, basic network-based statistics, and hippocampal subfield segmentation via BIDS App Apptainer containers. 
While developed for Slurm control systems, the shell scripts here should be compatible with CentOS-derived Linux clusters.

Our :ref:`Installation Guide<Install>` provides details on installing the following requirements:

.. hlist::
    * Apptainer BIDS apps (HeuDiConv, MRIQC, fMRIPrep, xcpEngine, QSIprep) 
    * Apptainer image of Matlab R2021a (how to: https://github.com/mathworks-ref-arch/matlab-dockerfile) 
    * Apptainer image of Ubuntu with JQ installed Apptainer image of Python3 (Based on Docker python/3.10.0) 
    * Apptainer image of Docker HTML to PDF (https://github.com/pinkeen/docker-html-to-pdf) 
    * Brain Connectivity Toolbox for Matlab (https://sites.google.com/site/bctnet/Home/functions/BCT.zip?attredirects=0) 
    * ASHS (https://sites.google.com/site/hipposubfields/) 
    * LAYNII (https://github.com/layerfMRI/LAYNII) 
    * bidsphysio (https://github.com/cbinyu/bidsphysio)
