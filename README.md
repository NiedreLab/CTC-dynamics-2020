# CTC-dynamics-2020
Processing and plotting DiFC data of Short-term CTC Dynamics 
Williams et.al. (2020) "Short-Term Circulating Tumor Cell Dynamics in Mouse Xenograft Models and Implications for Liquid Biopsy," **Frontiers in Oncology** 10, 601085.

## Table of Contents
* [General Info](#general-info)
* [Technologies](#technologies)
* [Processing raw data](#processing-raw-data)
* [Creating simulated data](#creating-simulated-data)
* [Data analysis and plotting](#data-analysis-and-plotting)

## General Info
This files in this github repository were used to process, analyze and plot data used in the 2020 Frontiers in Oncology article "Short-term circulating tumor cell dynamics and implications for liquid biopsy". The raw data, processed data and functions used for creating the figures in the article are included in this repository. The processed data can also be found in the Blackfynn repository DOI: 10.26275/x9xq-e4wu. 

## Technologies
Matlab 2019a

## Processing raw data
To process the raw data files, download the following folders:
* LLC_raw_data
* MM_35min_raw_data
* MM_24hr_raw_data
* Phantom_raw_data
* One_Op_with_Repos_raw_data
* Two_Op_with_Repos_raw_data

These folders should be located in your working directory and/or paths to the folders should be manually changed at the top of each script or function (where noted). If you are not using a windows computer, you must also manually change these paths. 

The following scripts can then be used to process this raw data to output the times of cell detections within each DiFC scan. (Other files required are listed below each script, except Count_CTCs_per_interval which is used by all of the "Process_*_data" scripts.)
* Process_LLC_data.m
  * DiFC_LLC_process_Amber_2020_05_15.m
  * LLC_file_names.mat
* Process_MM_35min_data .m
  * DiFC_process.m
  * MM_35min_file_names.mat
* Process_MM_24hr_data..m
  * DiFC_process.m
  * MM_24hour_file_names.mat
* Process_Phantom_Microsphere_data.m
  * DiFC_process.m
  * Phantom_file_names.mat
* Process_Reposition_data.m
  * DiFC_process.m
  * One_Op_with_Repos_file_names.mat
  * Two_Ops_with_Repos_file_names.mat

The files "DiFC_LLC_process_Amber_2020_05_15" and "DiFC_process" each processes one DiFC scan at a time. The "Process_*_data" scripts process all scans in each respective group of data.

The resulting processed data can be found in the following folders in this GitHub repository or the Blackfynn repository DOI: 10.26275/x9xq-e4wu:
* LLC_processed_data
* MM_35min_processed_data
* MM_24hr_processed_data
* Phantom_processed_data
* One_Op_with_Repos_processed_data
* Two_Op_with_Repos_processed_data

These folders should be located in your working directory and/or paths to the folders should be manually changed at the top of each script or function (where noted). If you are not using a windows computer, you must also manually change these paths. 

Summaries of the processed data are produced by the processing scripts can be found in the following files:
* LLC_data.mat
* MM_35min_data.mat
* MM_24hr_data.mat
*Phantom_data.mat
* Max_min_ratios_Repos.mat

## Creating simulated data
The following scripts are used for generating simulated DiFC data.
* CreateSimulations_Poisson.m
  * Creates simulations from Poisson statistics
  * MM_35min_data.mat
  * Count_CTCs_per_interval.m
  * may need Simulations_Poisson_detections.mat
* CreateSimulations_MergedPoissons.m
  * Creates simulations of two simultaneous (merged) Poisson processes
  * Count_CTCs_per_interval.m
  * may need Simulations_MergedPoissons_detections.mat
* CreateSimulations_ChangingMean.m
  * Creates simulations from Poisson statistics where the mean event/CTC detection rate is doubled halfway through the simulated scan
  * Count_CTCs_per_interval.m
  * may need Simulations_ChangingMeanPoissons_detections.mat

## Data analysis and plotting
The following scripts are used for creating part or all of a respective figure from Williams et.al. 2020.
* figure1_MM_LLC_DiFC_tumorvol_BLI.m
  * folder LLC_processed_data
  * folder MM_35min_processed_data
  * rasterplot.m 
  * may need folder LLC_raw_data
  * may need folder MM_35min_raw_data
  * may need DiFC_process.m
* figure2_LLC_rasters_histograms.m
  * folder LLC_processed_data
  * LLC_data.mat
  * LLC_file_names.mat
  * Count_CTCs_per_interval.m
* figure2_LLC_scatter_plots.m
  * LLC_data.mat 
* figure3_movAvgs.m
  * folder MM_35min_processed_data
  * MM_35min_file_names.mat
  * Count_CTCs_per_interval.m
* figure4_stepGraphs_DFSM.m
  * folder MM_35min_processed_data
  * MM_35min_data.mat
  * MM_35min_file_names.mat
  * step_graph.m
  * Scatter_boxplot.m
    * distribScatter.m
* figure5_TOD_max_min.m
  * folder MM_24hour_processed_data
  * MM_24hour_file_names.mat
  * MM_24hour_data.mat
  * MM_24hour_extra_info.mat
  * Count_CTCs_per_interval.m
  * Scatter_boxplot.m
    * distribScatter.m
* figure6_mean_variance.m
  * MM_35min_data.mat
  * MM_24hour_data.mat
  * Simulations_Poisson_data.mat
  * Phantom_data.mat
  * Simulations_ChangingMeanPoissons_data.mat
  * Simulations_MergedPoissons_data.mat
* figure7_sampling_24hour.m
  * MM_24hour_data.mat
  * Scatter_boxplot_variedMarkers.m
    * distribScatter.m
  * Scatter_boxplot.m
    * distribScatter.m
