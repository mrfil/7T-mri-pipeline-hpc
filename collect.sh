#!/bin/bash

version=$1
project=$2
base_dir=$3
scripts=`pwd`
NOW=$(date +"%m-%d-%Y")
cd ${base_dir}/${version}/output/${project}
mkdir ./collect
cp ./sub-*/ses*/*pipeline_results.csv ./collect/
apptainer exec  --contain --no-home --cleanen -B ./collect:/datain,${scripts}/pyscripts:/scripts ${base_dir}/apptainer_images/python3-dev.sif python3 /scripts/df_maker.py
cd ./collect
mv outputs.csv pipeline_outputs_${project}_${NOW}.csv
