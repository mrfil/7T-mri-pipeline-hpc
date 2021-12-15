#!/bin/bash
# mount qsirecon/subject/session/dwi to /datanoddi

subject=$1
sesname=$2

cd /datanoddi
for atlas in aal116 aicha384 brainnetome246 gordon333 power264 schaefer100x17 schaefer100x7 schaefer200x17 schaefer200x7 schaefer400x17 schaefer400x7; do
    roi_names="./*${atlas}_mrtrixLUT.txt"
    parc_file="./*${atlas}_atlas.nii.gz"
    echo $roi_names
    echo "Creating temporary masks for each ROI based on $atlas parcellation"
    #mkdir ./masks
    while read roi_name_tmp; do
        roi_num_tmp=`echo $roi_name_tmp | sed 's@^[^0-9]*\([0-9]\+\).*@\1@'`
        roi_name=`cut -d ' ' -f 2 <<< $roi_name_tmp`
        roi_lowthresh=$( echo "scale=2; $roi_num_tmp - 0.5" | bc )
        roi_highthresh=$( echo "scale=2; $roi_num_tmp + 0.5" | bc )
        echo "$roi_name_tmp"
        echo "$roi_num_tmp"
        echo "$roi_lowthresh"
        echo "$roi_name"
        touch roi_csv_tmp.csv
        fslmaths ${parc_file} -thr $roi_lowthresh -uthr $roi_highthresh roitmp.nii.gz
        for metric in ICVF ISOVF OD; do
            echo "Calculating ROI stats in $metric image"
            metricImage="./*${metric}_NODDI.nii.gz"
            fslstats ${metricImage} -k roitmp.nii.gz -M -S -r > roistats.txt
            roi_stats_tmp=`cat roistats.txt`
            echo $roi_stats_tmp
            echo "${metric}_${atlas}_${roi_name}_mean_nonzero ${metric}_${atlas}_${roi_name}_standard_deviation ${metric}_${atlas}_${roi_name}_min_robust ${metric}_${atlas}_${roi_name}_max_robust" > roistats.csv
            echo $roi_stats_tmp >> roistats.csv
            sed -i 's/ *$//' roistats.csv
            sed -i 's/\ /,/g' roistats.csv
            # mv -d, roi_csv_tmp.csv roistats.csv > ROI_STATS.csv
            # cp ROI_STATS.csv roi_csv_tmp.csv
            # sed -i 's/\([^,]*\),\(.*\)/\2/' roistats.csv
            mv roistats.csv "${subject}_${sesname}_${metric}_${atlas}_${roi_name}_roistats.csv"
            echo "Cleaning tmp files"
            rm roistats.txt
        done
        rm roitmp.nii.gz
	#mv roitmp.nii.gz ./masks/${roi_name}.nii.gz
        rm roi_csv_tmp.csv
    done <$roi_names
    #rm -rf ./masks
    paste -d, ${subject}_${sesname}_ICVF_${atlas}_*_roistats.csv > ${subject}_${sesname}_ICVF_${atlas}.csv
    paste -d, ${subject}_${sesname}_ISOVF_${atlas}_*_roistats.csv > ${subject}_${sesname}_ISOVF_${atlas}.csv
    paste -d, ${subject}_${sesname}_OD_${atlas}_*_roistats.csv > ${subject}_${sesname}_OD_${atlas}.csv
    echo "Statistics available in QSIPrep directory"
done
echo "NODDI stats finished"
rm *_roistats.csv

