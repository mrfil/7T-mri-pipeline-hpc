#!/bin/bash

subject=$1
sesname=$2
fthresh=$3
sequence=$4
roi_names=/scripts/aparc_cort_subcort_labels.txt
cd /dataqsm

echo "Creating masks for each ROI based on freesurfer parcellation and calculating ROI stats in QSM image"
touch roi_csv_tmp.csv
mkdir ./masks
acqtag="_acq-mp2rageunidenoised_"

while read roi_name_tmp; do

    roi_num_tmp=`echo $roi_name_tmp | sed 's@^[^0-9]*\([0-9]\+\).*@\1@'`
    roi_name=`cut -d ' ' -f 2 <<< $roi_name_tmp`
    roi_lowthresh=$( echo "scale=2; $roi_num_tmp - 0.5" | bc )
    roi_highthresh=$( echo "scale=2; $roi_num_tmp + 0.5" | bc )
    echo "$roi_name_tmp"
    echo "$roi_num_tmp"
    echo "$roi_lowthresh"
    echo "$roi_name"
    fslmaths resample_card_"$subject"_"$sesname""$acqtag"desc-aparcaseg_dseg.nii.gz -thr $roi_lowthresh -uthr $roi_highthresh roitmp
    fslstats QSM_to_RAGE.nii.gz -k roitmp.nii.gz -V -M -S -R -r > roistats.txt
    roi_stats_tmp=`cat roistats.txt`
    echo $roi_stats_tmp
    
    echo "${sequence}_fp${fthresh}_${roi_name}_vol_voxels ${sequence}_fp${fthresh}_${roi_name}_vol_mm3 ${sequence}_fp${fthresh}_${roi_name}_mean_nonzero ${sequence}_fp${fthresh}_${roi_name}_standard_deviation ${sequence}_fp${fthresh}_${roi_name}_min ${sequence}_fp${fthresh}_${roi_name}_max ${sequence}_fp${fthresh}_${roi_name}_min_robust ${sequence}_fp${fthresh}_${roi_name}_max_robust" > roistats.csv
    echo $roi_stats_tmp >> roistats.csv
    sed -i 's/ *$//' roistats.csv
    sed -i 's/\ /,/g' roistats.csv
    paste -d, roi_csv_tmp.csv roistats.csv > ROI_STATS.csv
    cp ROI_STATS.csv roi_csv_tmp.csv
    mv roitmp.nii.gz ./masks/${roi_name}.nii.gz
done <$roi_names
sed -i 's/\([^,]*\),\(.*\)/\2/' ROI_STATS.csv
mv ROI_STATS.csv ${sequence}_ROI_STATS_rage_fp${fthresh}.csv
echo "Cleaning tmp files"
rm roi_csv_tmp.csv
rm roistats.csv
rm roistats.txt
echo "Statistics available in ${sequence}_ROI_STATS_rage_f${fthresh}.csv within QSM directory"
