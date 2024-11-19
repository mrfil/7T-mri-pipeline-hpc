#!/bin/bash
#
#
# file_structure_gen.sh {base directory} {version}

base_dir=$1
version=$2
mkdir ${base_dir}/${version}

#Create directories for the following: 
# 1. During processing data housing
mkdir ${base_dir}/${version}/testing

# 2. Whole dataset and outputs housing
mkdir ${base_dir}/${version}/output

# 3. BIDS outputs & derivatives housing
mkdir ${base_dir}/${version}/bids_only

# 4. Connectivity matrices and node-level network-base_dir statistics housing
mkdir ${base_dir}/${version}/conn_out

# 5. Visual quality control reports and one-liner csv reports
mkdir ${base_dir}/${version}/data_qc

# 6. Scripts directory for current version
mkdir ${base_dir}/${version}/scripts
cp -R ../* ${base_dir}/${version}/scripts

# 7. Scratch directory for tmp and cache
mkdir ${base_dir}/${version}/scratch
mkdir ${base_dir}/${version}/scratch/stmp
mkdir ${base_dir}/${version}/scratch/scache

# 8. Singularity image housing
mkdir ${base_dir}/singularity_images

# change file permissions
chmod 777 -R mkdir ${base_dir}/${version}
