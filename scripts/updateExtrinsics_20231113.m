baseDir = '/groups/branson/bransonlab/kwaki/ForceData/examples/20231113_stm3day3day4';
calibOutDir = fullfile(baseDir, "new");
if ~exist(calibOutDir, 'dir')
    mkdir(calibOutDir);
end

calibFilename = fullfile(baseDir, "multicam.mat");
mouseLabelTableName = fullfile(baseDir, "stm4day3_day4_labels.mat");
sampledCheckerCornerFilenames = {};

updateExtrinsics(calibOutDir, calibFilename, mouseLabelTableName, sampledCheckerCornerFilenames)
