#!/bin/bash
#
# Generates Apptainer images used in pipeline
# Run on a machine which has sufficient permissions for Apptainer and Docker building!
# Install git prior to running
# Please cite the images used and retrieve all relevant licenses
# You will need your own Freesurfer license for some containers
#

mkdir ./apptainer_images
chmod 730 -R ./apptainer_images
cd ./apptainer_images

apptainer build mriqc-v24.0.2.sif docker://poldracklab/mriqc:24.0.2
apptainer build heudiconv-v1.3.0.sif docker://nipy/heudiconv:1.3.0
apptainer build fmriprep-v23.0.2.sif docker://nipreps/fmriprep:23.0.2
apptainer build xcp-d-v0.9.1.sif docker://pennlinc/xcp_d:0.9.1
apptainer build qsiprep-v1.0.0.sif docker://pennbbl/qsiprep:1.0.0
#for reorient_fslstd to prepare for SCFSL_GPU
apptainer build qsirecon-v1.0.0.sif docker://pennbbl/qsirecon:1.0.0


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
