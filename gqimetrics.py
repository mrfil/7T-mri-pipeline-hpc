#!/usr/env/python
import pandas as pd
import sys, getopt
import numpy as np
import scipy.io as sio
import os
import glob

atlases = ['aal116','power264','gordon333','aicha384','brainnetome246','schaefer100x17','schaefer100x7','schaefer200x17','schaefer200x7','schaefer400x17','schaefer400x7']
metrics = ['_count_end_clustering_coeff_average_weighted','_count_end_mean_strength_weighted','_count_end_network_characteristic_path_length_weighted','_count_end_global_efficiency_weighted','_count_end_density','_ncount_end_clustering_coeff_average_weighted','_ncount_end_mean_strength_weighted','_ncount_end_network_characteristic_path_length_weighted','_ncount_end_global_efficiency_weighted','_ncount_end_density','_gfa_end_clustering_coeff_average_weighted','_gfa_end_mean_strength_weighted','_gfa_end_network_characteristic_path_length_weighted','_gfa_end_global_efficiency_weighted','_gfa_end_density','_count_pass_clustering_coeff_average_weighted','_count_pass_mean_strength_weighted','_count_pass_network_characteristic_path_length_weighted','_count_pass_global_efficiency_weighted','_count_pass_density','_ncount_pass_clustering_coeff_average_weighted','_ncount_pass_mean_strength_weighted','_ncount_pass_network_characteristic_path_length_weighted','_ncount_pass_global_efficiency_weighted','_ncount_pass_density','_gfa_pass_clustering_coeff_average_weighted','_gfa_pass_mean_strength_weighted','_gfa_pass_network_characteristic_path_length_weighted','_gfa_pass_global_efficiency_weighted','_gfa_pass_density']
    
    
gqi_nbs = pd.DataFrame(columns=['place_holder'])
#mount bids/derivatives/qsirecon/subject/session/dwi as /datain
for filename in glob.glob('/datain/*gqinetwork.mat'):
    print(filename)
    mat=sio.loadmat(filename)# load mat-file
    for atlas in atlases:
        print(atlas)
        mean_strength_ncount_pass = np.mean(mat[atlas+'_ncount_pass_strength_weighted'])  # variable in mat file 
        mean_strength_ncount_end = np.mean(mat[atlas+'_ncount_end_strength_weighted'])
        mean_strength_gfa_pass = np.mean(mat[atlas+'_gfa_pass_strength_weighted'])
        mean_strength_gfa_end = np.mean(mat[atlas+'_gfa_end_strength_weighted'])
        mean_strength_count_pass = np.mean(mat[atlas+'_count_pass_strength_weighted'])
        mean_strength_count_end = np.mean(mat[atlas+'_count_end_strength_weighted'])
        for metric in metrics:
            print(metric)
            if 'mean_strength' in str(metric):
                if 'end' in metric:
                    if 'ncount' in metric:
                        gqi_nbs.append({str(atlas+metric): mean_strength_ncount_end},ignore_index=True)
                    elif 'gfa' in metric:
                        gqi_nbs.append({str(atlas+metric): mean_strength_gfa_end},ignore_index=True)
                    elif '_count' in metric:
                        gqi_nbs.append({str(atlas+metric): mean_strength_count_end},ignore_index=True)
                elif 'pass' in metric:
                    if 'ncount' in metric:
                        gqi_nbs.append({str(atlas+metric): mean_strength_ncount_pass},ignore_index=True)
                    elif 'gfa' in metric:
                        gqi_nbs.append({str(atlas+metric): mean_strength_gfa_pass},ignore_index=True)
                    elif '_count' in metric:
                        gqi_nbs.append({str(atlas+metric): mean_strength_count_pass},ignore_index=True)
            elif '_mean_strength_' not in str(metric):
                met = mat[atlas+metric]
                col_name = str(atlas+metric)
                print(met)
                print(col_name)
                gqi_nbs.append({col_name: met},ignore_index=True)
gqi_nbs.to_csv('/datain/gqi_nbs.csv')
