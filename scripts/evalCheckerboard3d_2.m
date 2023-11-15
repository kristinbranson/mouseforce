%% script for evaluating checkerboard post calibration
baseDir = '/groups/branson/bransonlab/kwaki/ForceData/outputs/improvingcalibration/20231114_avgc54day4';

calibFile = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20230920_updatecalibration/new/multi_calib.mat';
multicam = load(fullfile(baseDir, 'new/multi_calib.mat'));
multicam = multicam.multicam;

sampledPointsFilename = fullfile(baseDir, 'sampled_12.mat');
sampledPoints = load(sampledPointsFilename);
corners = sampledPoints.sampledCorners;

%% assemble extrinsic data
[projMats, fcs, ccs, kcs, alpha_cs] = constructCaltechCalibInfo(multicam);

%% evaluate the checkerboard corners
numCorners = 12;
cornersPermuted = permute(corners, [5, 3, 1, 2, 4]);
numCheckerboards = size(cornersPermuted, 4);

% horizontal norms
horizontalNorms = zeros(numCheckerboards * (numCorners - 3), 1);
idx = 1;
for i = 1:numCheckerboards
    triangulated = multiDLT(cornersPermuted(:, :, :, i), projMats, fcs, ccs, kcs, alpha_cs);
    for j = 1:11
        if mod(j, 4) ~= 0
            horizontalNorms(idx) = norm(triangulated(:, j) - triangulated(:, j+1));
            idx = idx + 1;
        end
    end
end


verticalNorms = zeros(numCheckerboards * (numCorners - 4), 1);
idx = 1;
for i = 1:numCheckerboards
    triangulated = multiDLT(cornersPermuted(:, :, :, i), projMats, fcs, ccs, kcs, alpha_cs);
    for j = 1:8
        verticalNorms(idx) = norm(triangulated(:, j) - triangulated(:, j+4));
        idx = idx + 1;
    end
end

%% plot distributoin of corner distances
figure(100);
histogram(horizontalNorms);
figure(101);
histogram(verticalNorms)