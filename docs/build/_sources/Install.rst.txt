.. _Install :

-------
Install
-------

To get started with the pipeline, please install the following requirements: 

    * Apptainer BIDS apps (HeuDiConv, MRIQC, fMRIPrep, XCP-D, QSIprep, QSIRecon) 
    * Apptainer image of Matlab R2019a (how to: https://github.com/mathworks-ref-arch/matlab-dockerfile) 
    * Apptainer image of Ubuntu with JQ installed Apptainer image of Python3 (Based on Docker python/3.10.0) 
    * Apptainer image of Docker HTML to PDF (https://github.com/pinkeen/docker-html-to-pdf) 
    * Brain Connectivity Toolbox for Matlab (https://sites.google.com/site/bctnet/Home/functions/BCT.zip?attredirects=0) 
    * ASHS (https://sites.google.com/site/hipposubfields/) 
    * LAYNII (https://github.com/layerfMRI/LAYNII) 
    * bidsphysio (https://github.com/cbinyu/bidsphysio)

You will need to install git, to clone the build recipe files from this repository.
Please cite the images used and retrieve all relevant licenses (you will need your own Freesurfer license for some containers).

This following commands can be used to build these required images for the pipeline.
*Run on a machine which has sufficient permissions for Apptainer and Docker building!*

.. code-block:: bash

    # Generates Apptainer images used in pipeline
    mkdir ./apptainer_images
    chmod 730 -R ./apptainer_images
    cd ./apptainer_images

    apptainer build mriqc-v24.0.2.sif docker://poldracklab/mriqc:24.0.2
    apptainer build heudiconv-v1.3.0.sif docker://nipy/heudiconv:1.3.0
    apptainer build fmriprep-v24.1.1.sif docker://nipreps/fmriprep:23.2.0
    apptainer build xcp-d-v0.10.0.sif docker://pennlinc/xcp_d:0.10.0
    #for reorient_fslstd to prepare for SCFSL_GPU
    apptainer build qsiprep-v0.24.0.sif docker://pennbbl/qsiprep:0.24.0
    apptainer build qsirecon-v0.23.2.sif docker://pennbbl/qsirecon:0.23.2


    # See README.md for more information on 
    #provide def files for ubuntu-jq, python3
    apptainer build ubuntu-jqjo.sif jqjo.def
    apptainer build python3.sif defpy3
    apptainer laynii-2.1.1.sif layniidef
    apptainer build ashs-1.0.0.sif ashsdef
    apptainer build pylearn.sif pylearndef

    # Follow directions to build Docker images for the following:
    git clone https://github.com/cbinyu/bidsphysio.git

    cd ./bidsphysio
    docker build -t bidsphysio:latest -t localhost:5000/bidsphysio:latest .
    docker push localhost:5000/bidsphysio:latest
    cd ../
    apptainer build bidsphysio.sif docker://localhost:5000/bidsphysio:latest

    ## Prerequisites
    #The following examples use the CUDA 10.2 toolkit and runtime (loaded via module or native install)
    git clone https://github.com/mrfil/scfsl.git
    cd ./scfsl
    docker build -t scfsl_gpu:0.3.2 -t localhost:5000/scfsl_gpu:0.3.2 .
    cd ../
    docker push localhost:5000/scfsl_gpu:0.3.2
    apptainer build scfsl_gpu-v0.3.2.sif docker://localhost:5000/scfsl_gpu:0.3.2

    apptainer build matlab-R2019a.sif docker://mathworks/matlab:r2021a

    chmod 730 -R ./apptainer_images

.. note:: 
    The process for creating the MATLAB container has changed! You can build more recent MATLAB containers using the 
    official Docker Hub images from MathWorks. You will still need to provide license information as denoted in the 
    repository listed above.
