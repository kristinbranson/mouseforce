%% script for evaluating checkerboard post calibration
% load data, setup paths
baseDir = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20230920_updatecalibration';
%calibFile = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20230622_checkerboardtest/new/multi_calib.mat';
calibFile = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20230920_updatecalibration/new/multi_calib.mat';
%calibFile = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20230920_updatecalibration/multicam.mat';
multicam = load(calibFile);
multicam = multicam.multicam;

sampledPointsFilename = fullfile(baseDir, 'sampled.mat');
sampledPoints = load(sampledPointsFilename);
optimizationCornersFrames = sampledPoints.optimizationCornersFrames;

%% assemble extrinsic data
[projMats, fcs, ccs, kcs, alpha_cs] = constructCalibInfo(multicam);

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
        % if vertical_norms(idx) > 3.7
        %     keyboard
        % end
        idx = idx + 1;
    end
end

%% plot distributoin of corner distances
figure(100);
histogram(horizontalNorms);
figure(101);
histogram(verticalNorms)


%% create some outputs
% load the video
figure(10)
%calib_video = '/groups/branson/bransonlab/kwaki/ForceData/calibration/calibration_videos/merged/calibration.avi';
calib_video = '/groups/branson/bransonlab/kwaki/ForceData/calibration/20230830_calibrationvideos/raw/cal_2023_08_30_10_49_34.avi';
video_reader = VideoReader(calib_video);


out_dir = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20230920_updatecalibration/reproj/';


for kpidx = 1:10
    video_reader.CurrentTime = (double(optimizationCornersFrames(kpidx))) / video_reader.FrameRate;
    currentFrame = readFrame(video_reader);

    figure(10)
    clf
    imshow(currentFrame);
    hold on
    rpe = zeros(42, 3);

    triangulated = multiDLT(optimizationCornersPermuted(:, :, :, kpidx), projMats, fcs, ccs, kcs, alpha_cs);
    for i = 1:3
        plot(optimizationCornersPermuted(1, :, i, kpidx) + (i - 1)*512 + 1, optimizationCornersPermuted(2, :, i, kpidx) + 1, 'o');


        om = rodrigues(projMats{i}(:, 1:3));
        T = projMats{i}(:, 4);
        projected = project_points2(triangulated, om, T, ...
            fcs{i}, ccs{i}, kcs{i}, alpha_cs{i});
            
        %rpe(:, i) = sqrt(sum((projected-optimizationCornersPermuted(:, :, i, kpidx)).*(projected-optimizationCornersPermuted(:, :, i, kpidx))));

        plot(projected(1, :) + (i - 1)*512+1, projected(2, :), 'x');

    end
    savefig(gcf, fullfile(out_dir, sprintf('%06d.fig', optimizationCornersFrames(kpidx))));
    saveas(gcf, fullfile(out_dir, sprintf('%06d.png', optimizationCornersFrames(kpidx))));
end



figure(10)
clf
%calib_video = '/groups/branson/bransonlab/kwaki/ForceData/calibration/calibration_videos/merged/calibration.avi';
calib_video = '/groups/branson/bransonlab/kwaki/ForceData/calibration/20230830_calibrationvideos/raw/cal_2023_08_30_10_53_40.avi';
video_reader = VideoReader(calib_video);


out_dir = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20230920_updatecalibration/reproj/';


for kpidx = 11:20
    video_reader.CurrentTime = (double(optimizationCornersFrames(kpidx))) / video_reader.FrameRate;
    currentFrame = readFrame(video_reader);

    figure(10)
    clf
    imshow(currentFrame);
    hold on
    rpe = zeros(42, 3);

    triangulated = multiDLT(optimizationCornersPermuted(:, :, :, kpidx), projMats, fcs, ccs, kcs, alpha_cs);
    for i = 1:3
        plot(optimizationCornersPermuted(1, :, i, kpidx) + (i - 1)*512 + 1, optimizationCornersPermuted(2, :, i, kpidx) + 1, 'o');


        om = rodrigues(projMats{i}(:, 1:3));
        T = projMats{i}(:, 4);
        projected = project_points2(triangulated, om, T, ...
            fcs{i}, ccs{i}, kcs{i}, alpha_cs{i});
            
        %rpe(:, i) = sqrt(sum((projected-optimizationCornersPermuted(:, :, i, kpidx)).*(projected-optimizationCornersPermuted(:, :, i, kpidx))));

        plot(projected(1, :) + (i - 1)*512+1, projected(2, :), 'x');

    end
    savefig(gcf, fullfile(out_dir, sprintf('%06d.fig', optimizationCornersFrames(kpidx))));
    saveas(gcf, fullfile(out_dir, sprintf('%06d.png', optimizationCornersFrames(kpidx))));
end