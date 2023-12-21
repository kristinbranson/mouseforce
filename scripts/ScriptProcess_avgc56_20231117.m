setup_mouseforce_path;
rootdatadir = '/groups/branson/bransonlab/DataforAPT/JumpingMice';
calibrationdir = '/groups/branson/bransonlab/kwaki/ForceData/calibration/collected_20231027_analyzed_20231117';
calibrationvideofile = fullfile(calibrationdir,'cal_2023_10_27_15_34_58.avi');
splitvideodir = fullfile(rootdatadir,'2023_08_VgatCtx_avgc50Plus_backToFibers_split');

%% split the videos on the cluster

% all avg56 movies and cal_2023_10_27_15_34_58_1.avi
[rawfiles,splitfiles] = split_video_list('defaultdir',rootdatadir,'usecluster',true);

% ls -tr /groups/branson/bransonlab/DataforAPT/JumpingMice/2023_08_VgatCtx_avgc50Plus_backToFibers_split/
% cal_2023_10_27_15_34_58_1.avi
% day1_avgc56_2023_10_30_12_51_26-015_1.avi
% cal_2023_10_27_15_34_58_0.avi
% cal_2023_10_27_15_34_58_2.avi
% day4_avgc56_optoTest1_2023_11_10_09_36_23-010_0.avi
% day2_avgc56_2023_10_31_11_49_32-008_1.avi
% day1_avgc56_2023_10_30_12_51_26-015_0.avi
% day2_avgc56_2023_10_31_11_49_32-008_0.avi
% day3_avgc56_2023_11_06_11_34_02-001_1.avi
% day4_avgc56_optoTest1_2023_11_10_09_36_23-010_1.avi
% day1_avgc56_2023_10_30_12_51_26-015_2.avi
% day3_avgc56_2023_11_06_11_34_02-001_0.avi
% day3_avgc56_2023_11_06_11_34_02-001_2.avi
% day2_avgc56_2023_10_31_11_49_32-008_2.avi
% day4_avgc56_optoTest1_2023_11_10_09_36_23-010_2.avi

%% intrinsic parameter computation
% (done from terminal)

% cd ../calibrate_jumping_arena
% docker build -t iskwak/calibrate .

