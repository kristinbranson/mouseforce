%% script for evaluating checkerboard post calibration
baseDir = '/groups/branson/home/bransonk/tracking/code/calibrate_jumping_arena/sampledata';

multicam = load(fullfile(baseDir, 'new/multi_calib.mat'));
multicam = multicam.multicam;

sampledPointsFilename = fullfile(baseDir, 'new/sampled.mat');
sampledPoints = load(sampledPointsFilename);
optimizationCornersFrames = sampledPoints.optimizationCornersFrames;

%% assemble extrinsic data
[projMats, fcs, ccs, kcs, alpha_cs] = constructCaltechCalibInfo(multicam);

%% evaluate the checkerboard corners
numCorners = 12;
optimizationCornersReshaped = reshape(sampledPoints.optimizationCorners, 2, [], numCorners, 3);
%optimizationCornersPermuted = permute(optimizationCornersReshaped, [1, 2, 4, 3]);
optimizationCornersPermuted = permute(optimizationCornersReshaped, [1, 3, 4, 2]);

numCheckerboards = size(optimizationCornersPermuted, 4);

% horizontal norms
horizontalNorms = zeros(numCheckerboards * (numCorners - 3), 1);
idx = 1;
for i = 1:numCheckerboards
    triangulated = multiDLT(optimizationCornersPermuted(:, :, :, i), projMats, fcs, ccs, kcs, alpha_cs);
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
    triangulated = multiDLT(optimizationCornersPermuted(:, :, :, i), projMats, fcs, ccs, kcs, alpha_cs);
    for j = 1:8
        verticalNorms(idx) = norm(triangulated(:, j) - triangulated(:, j+4));
        idx = idx + 1;
    end
end

%% plot distributoin of corner distances
figure(100);
clf;
histogram(horizontalNorms);
xlabel('Horizontal distance (mm) -- should be 5');
figure(101);
clf;
histogram(verticalNorms)
xlabel('Vertical distance (mm) -- should be 5');
