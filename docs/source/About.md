# 7T-pipeline-hpc
# pipeline-hpc: Pipeline for processing 7T brain MRI DICOMs to resting-state functional connectivity and structural connectivity matrices, basic network-based statistics, hippocampal subfield segmentation via BIDS App Apptainer containers on HPCs. 

Requirements: 
 - Apptainer BIDS apps (HeuDiConv, MRIQC, fMRIPrep, XCP-D, QSIprep, QSIRecon) 
 - Apptainer image of Matlab R2021a (how to: https://github.com/mathworks-ref-arch/matlab-dockerfile)
 - Apptainer image of Ubuntu with JQ installed 
 - Apptainer image of Python3 (Based on Docker python/3.10.0) 
 - Brain Connectivity Toolbox for Matlab (https://sites.google.com/site/bctnet/Home/functions/BCT.zip?attredirects=0) 
 - ASHS (https://sites.google.com/site/hipposubfields/) 
 - LAYNII (https://github.com/layerfMRI/LAYNII) 
 - bidsphysio (https://github.com/cbinyu/bidsphysio)