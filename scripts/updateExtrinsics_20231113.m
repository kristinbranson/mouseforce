baseDir = '/groups/branson/home/bransonk/tracking/code/calibrate_jumping_arena/sampledata';
calibOutDir = fullfile(baseDir, "new");
if ~exist(calibOutDir, 'dir')
    mkdir(calibOutDir);
end

calibFilename = fullfile(baseDir, "multi_calib.mat");
mouseLabelTableName = fullfile(baseDir, "SampleDataMouseForce_labels.mat");
sampledCheckerCornerFilenames = {fullfile(baseDir,'sampled_02.mat')};

updateExtrinsics(calibOutDir, calibFilename, mouseLabelTableName, sampledCheckerCornerFilenames)
