%% script for trying to update the stereo extrinsic estimates, using clicked points on the mouse
baseDir = '/groups/branson/bransonlab/kwaki/ForceData/outputs/improvingcalibration/20231114_avgc54day4';

% load calibration data
multicam = load(fullfile(baseDir, 'new/multi_calib.mat'));
multicam = multicam.multicam;


% labeled point data
tbl = load(fullfile(baseDir, 'avgc5455label_labels.mat'));
tbl = tbl.tblLbls;

frameNums = tbl.frm;
frameCount = numel(frameNums);

% load the clicked points, then reshape into a more useful structure
points = reshapeTableLabels(tbl);
[numFrames, numKeypoints, numViews] = size(points, [1, 2, 3]);
occluded = reshape(tbl.tfocc, [numFrames, numKeypoints, numViews]);
% first mask the occluded points. for this processing, dont need to ever look
% at occluded points.
points(cat(4, occluded, occluded)) = nan;
% for now use nans as occluded...

% construct instrinsic parameter structures, to help with some of the future processing.
[projMats, fcs, ccs, kcs, alpha_cs] = constructCaltechCalibInfo(multicam);

% construct starting extrinsic structure
[omsOrg, TsOrg] = convertProjMat2RodT(projMats);
startingExtrinsics = convertRodT2OptimExtrinsicsVec(omsOrg, TsOrg);

% get keypoints to optimize
[optimizationKeypoints, testFiltered] = selectOptimizationKeypoints(points);
% note, these keypoints will be of the shape, (2x(numKeypoints * numFrames) x numViews)

allPoints = optimizationKeypoints;

% save the examples used for the optimization
sampledPointsFilename = fullfile(baseDir, 'sampled.mat');
save(sampledPointsFilename, 'optimizationKeypoints');


%% construct the projection matrices and extrinsic data.
numViews = numViews;
oms_org = cell(numViews, numViews);
Ts_org = cell(numViews, numViews);
for i = 1:numViews
    for j = i+1:numViews
        oms_org{i,j} = multicam.crigStros{i,j}.omLR;
        Ts_org{i,j} = multicam.crigStros{i,j}.T.LR;
    end
end

%% check errors
new_errors = 0;
old_errors = 0;

fprintf("all points, pairwise stereo reprojection errors\n");
for i = 1:numViews
    for j = (i+1):numViews
        [mean_rpe, rpe] = stereo_reprojection_error(allPoints(:, :, [i, j]), oms_org{i,j}, Ts_org{i,j}, fcs([i,j]), ccs([i,j]), kcs([i,j]), alpha_cs([i,j]));
        fprintf("cam %d, cam %d, %f\n", i, j, mean_rpe);
        old_errors = old_errors + mean_rpe;
    end
end

fprintf("keypoints, pairwise stereo reprojection errors\n");
for i = 1:numViews
    for j = (i+1):numViews
        [mean_rpe, rpe] = stereo_reprojection_error(optimizationKeypoints(:, :, [i, j]), oms_org{i,j}, Ts_org{i,j}, fcs([i,j]), ccs([i,j]), kcs([i,j]), alpha_cs([i,j]));
        fprintf("cam %d, cam %d, %f\n", i, j, mean_rpe);
        old_errors = old_errors + mean_rpe;
    end
end


% create the projection matrix for the dlt
proj_mats = cell(numViews, 1);
proj_mats{1} = [eye(3), zeros(3, 1)];

start_idx = 1;
for i_view = 2:numViews
    proj_mats{i_view} = [rodrigues(oms_org{1,i_view}), Ts_org{1,i_view}];
end
[mean_rpe, rpe, mean_allcam_rpe] = multidlt_reprojection_error(allPoints, proj_mats, fcs, ccs, kcs, alpha_cs);
fprintf("all cam available dlt reproj, %f\n", mean_allcam_rpe);
fprintf("any cam dlt reproj, %f\n", mean_rpe);
old_errors = old_errors + mean_allcam_rpe;

fprintf("total errors: %f\n", old_errors);


%% create reprojection images.
% plot reprojections
movieNames = { ...
    '/groups/branson/bransonlab/DataforAPT/JumpingMice/2023_08_VgatCtx_avgc50Plus_backToFibers/day4_avgc54_2023_11_02_10_06_00-001_0.avi', ...
    '/groups/branson/bransonlab/DataforAPT/JumpingMice/2023_08_VgatCtx_avgc50Plus_backToFibers/day4_avgc54_2023_11_02_10_06_00-001_1.avi', ...
    '/groups/branson/bransonlab/DataforAPT/JumpingMice/2023_08_VgatCtx_avgc50Plus_backToFibers/day4_avgc54_2023_11_02_10_06_00-001_2.avi' ...
};



movieReaders = cell(3,1);
for i = 1:length(movieNames)
    movieReaders{i} = VideoReader(movieNames{i});
end

figure(100)
set(gcf, 'position', [200, 500, 2100, 875]);

% triangulatedKeypoints = multiDLT(optimizationKeypoints, proj_mats, fcs, ccs, kcs, alpha_cs);
% triangulatedKeypoints = reshape(triangulatedKeypoints, 3, numKeypoints, numFrames);
optimizationKeypointsPerFrame = reshape(optimizationKeypoints, 2, numKeypoints, numFrames, 3);

% construct the stereo triangulation for the non current views
k = 2; % for now only pairwise views
numMasks = nchoosek(numViews, 2) + 1;
viewMasks = zeros(numMasks, numViews);
% from https://www.mathworks.com/matlabcentral/answers/510687-produce-all-combinations-of-n-choose-k-in-binary#answer_419982
viewMasks(1:numMasks - 1, :) = dec2bin(sum(nchoosek(2.^(0:numViews-1),k),2)) - '0';
viewMasks(end, :) = ones(1, numViews);
X = zeros(3, size(optimizationKeypoints, 2), numMasks);
for i = 1:numMasks
    maskedKeypoints = optimizationKeypoints;
    maskedKeypoints(:, :, ~viewMasks(i,:)) = nan;

    X(:, :, i) = multiDLT(maskedKeypoints, proj_mats, fcs, ccs, kcs, alpha_cs);
end
triangulatedKeypoints = reshape(X, 3, numKeypoints, numFrames, numMasks);
% X = multiDLT(optimizationKeypoints, proj_mats, fcs, ccs, kcs, alpha_cs);
% triangulatedKeypoints = reshape(X, 3, numKeypoints, numFrames);

reprojectionDir = fullfile(baseDir, 'reprojections');
if ~exist(reprojectionDir, 'dir')
    mkdir(reprojectionDir)
end
for i = 1:numFrames
    frames = cell(3,1);
    current_x = optimizationKeypointsPerFrame(:, :, i, :);

    currFrameNum = double(tbl.frm(i)  - 1);
    figure(100)
    clf
    for j=1:length(movieNames)
        movieReaders{j}.CurrentTime = currFrameNum / movieReaders{j}.FrameRate;
        frames{j} = readFrame(movieReaders{j});
        %x_reproj = project_points2(squeeze(triangulatedKeypoints(:, :, i)), rodrigues(proj_mats{j}(:, 1:3)), ...
        x_reproj = project_points2(squeeze(triangulatedKeypoints(:, :, i, 4)), rodrigues(proj_mats{j}(:, 1:3)), ...
            proj_mats{j}(:, 4), fcs{j}, ccs{j}, kcs{j}, alpha_cs{j});

        subplot(1,3,j);
        imshow(frames{j})
        hold on
        
        plot(squeeze(current_x(1, :, :, j)), squeeze(current_x(2, :, :, j)), 'co', 'markersize', 5, 'linewidth', 2)
        plot(x_reproj(1,:), x_reproj(2,:), 'rx', 'markersize', 5, 'linewidth', 2)

    end
    sgtitle(sprintf("Frame Number: %d", currFrameNum + 1));
    saveas(gcf, fullfile(reprojectionDir, num2str(currFrameNum) + ".png"));
end

colors = {'r', 'g', 'm'};
epipolarDir = fullfile(baseDir, 'epipolar');
if ~exist(epipolarDir, 'dir')
    mkdir(epipolarDir)
end
for i = 1:numFrames
    frames = cell(3,1);
    current_x = squeeze(optimizationKeypointsPerFrame(:, :, i, :));

    currFrameNum = double(tbl.frm(i)  - 1);
    for i_kpt=1:numKeypoints
        if any(i_kpt == [1, 2, 3, 4, 5, 8, 9]) == false
            continue
        end
        figure(100)
        clf
        for j=1:length(movieNames)
            movieReaders{j}.CurrentTime = currFrameNum / movieReaders{j}.FrameRate;
            frames{j} = readFrame(movieReaders{j});
            
            subplot(1,3,j);
            imshow(frames{j})
            hold on

            for k = 1:numViews
                if j == k
                    continue
                end
                kptXY = squeeze(current_x(:, i_kpt, k));
                if ~isnan(kptXY(1))
                    [xEPL, yEPL] = multicam.computeEpiPolarLine(k, kptXY, j, [1, 512, 1, 512]);
                    plot(xEPL, yEPL, colors{k}, 'linewidth', 2);
                end
            end
            plot(squeeze(current_x(1, i_kpt, j)), squeeze(current_x(2, i_kpt, j)), 'co', 'linewidth', 3, 'markersize', 5)
        end
        sgtitle(sprintf('red generated from view 1, green generated from view 2, magenta generated from view 3, frame: %d, kpt: %d', currFrameNum+1, i_kpt));
        saveas(gcf, fullfile(epipolarDir, num2str(i_kpt) + "_" + num2str(currFrameNum) + ".png"));
    end
end