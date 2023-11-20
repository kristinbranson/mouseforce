setup_mouseforce_path;
rootdatadir = '/groups/branson/bransonlab/DataforAPT/JumpingMice';
calibrationoutdir = '/groups/branson/bransonlab/kwaki/ForceData/calibration/collected_20231027_analyzed_20231117';
calibrationvideofile = '/groups/branson/bransonlab/kwaki/ForceData/calibration/20231103_calibration/cal_2023_10_27_15_34_58.avi';
splitvideodir = fullfile(rootdatadir,'2023_08_VgatCtx_avgc50Plus_backToFibers_split');

%% split the videos on the cluster


[rawfiles,splitfiles] = split_video_list('defaultdir',rootdatadir,'usecluster',true);

% also split the calibration file for comparison, also put in 

%% 