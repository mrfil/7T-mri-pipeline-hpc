



    In participant native space for individuals:
    LiBra/bids/derivatives/fmriprep/sub-LiBra113/ses-A/anat/sub-LiBra113_ses-A_desc-preproc_T1w.nii.gz
    LiBra/bids/derivatives/fmriprep/sub-LiBra113/ses-A/func/sub-LiBra113_ses-A_task-rest_dir-PA_run-1_space-T1w_desc-preproc_bold.nii.gz

    In MNI152 standard space for group-level analyses:
    LiBra/bids/derivatives/fmriprep/sub-LiBra113/ses-A/anat/sub-LiBra113_ses-A_space-MNI152NLin2009cAsym_desc-preproc_T1w.nii.gz
    LiBra/bids/derivatives/fmriprep/sub-LiBra113/ses-A/func/sub-LiBra113_ses-A_task-rest_dir-PA_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz

    *We also run an independent component analysis-based denoising via ICA-AROMA, which yields a BOLD image that has been smoothed and non-aggressively denoised (minimal removal to conserve what might not actually be noise components) :

    LiBra/bids/derivatives/fmriprep/sub-LiBra113/ses-A/func/sub-LiBra113_ses-A_task-rest_dir-PA_run-1_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz

    *If you use this image as the func input, convention is to then skip the Denoising step of CONN.

    If you are interested in confound regression/denoising using methods other than ICA-AROMA, you can select which confounds to remove by editing the following file to contain only the columns that describe the confounds you want to remove:
    LiBra/bids/derivatives/fmriprep/sub-LiBra113/ses-A/func/sub-LiBra113_ses-A_task-rest_dir-PA_run-1_desc-confounds_timeseries.tsv

    !We never remove all the possible confounds as this would cause artifacts in the BOLD data. See this discussion for more details on using the confounds for denoising with CONN: https://www.nitrc.org/forum/message.php?msg_id=32790

    For a basic resting-state functional connectivity analysis, we run XCPengine with a few different confound regression methods (36P, 36P + Power scrub volume censoring, 36P + despiking via regression, and an ICA-AROMA based method).
    These are quantified for parcellations from common atlases (AAL116 - anatomically derived, Power264 - functionally derived, schaefer series - network neuroscience derived, etc.), yielding connectomes in a number of formats (.net - the Pajek format, .txt - a single column of all edges in the connectome, and .1D - a matrix with the timeseries for each node).
        e.g. for the AAL116 atlas : LiBra/bids/derivatives/xcp/ses-A/xcp_despike/sub-LiBra113/fcon/aal116/

    sub-LiBra113_aal116.net  sub-LiBra113_aal116_network.txt  sub-LiBra113_aal116_ts.1D

    Our MATLAB script then takes the connectome matrices for a few of these atlases and outputs them in labeled .txt files for:
        the whole matrix: sub-LiBra113_aal116net_mat_labeled.txt (this is the one most widely used)
        only positive correlations: sub-LiBra113_aal116net_mat_pos_labeled.txt
        only negative correlations: sub-LiBra113_aal116net_mat_neg_labeled.txt

    These can be found in: LiBra/bids/derivatives/xcp/ses-A/xcp_despike/sub-LiBra113/fcon

    We also use the Brain Connectivity Toolbox to calculate some network-based statistics for the AAL116, Power264, and Desikan-Killiany (this is the atlas used for Freesurfer aparc_aseg) atlases. For convenience, these are collated into the pipeline outputs csv.
