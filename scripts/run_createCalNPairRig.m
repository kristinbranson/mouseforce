calibDir = '/groups/branson/bransonlab/kwaki/ForceData/calibration/20231103_calibration';
numViews = 3;
calibFilenamesCellArray = cell(numViews, numViews);


for i = 1:numViews
    for j = i+1:numViews
        view1 = i - 1;
        view2 = j - 1;
        calibFilenamesCellArray{i,j} = fullfile(calibDir, "cam_" + num2str(view1) + num2str(view2) +"_opencv.mat");
    end
end
multicam = createCalRigNPairwiseCalibrated(calibFilenamesCellArray)
save(fullfile(calibDir + "/multi_calib.mat"), 'multicam');