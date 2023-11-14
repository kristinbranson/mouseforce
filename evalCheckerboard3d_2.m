%% script for evaluating checkerboard post calibration
% load data, setup paths
baseDir = '/groups/branson/bransonlab/kwaki/ForceData/calibration/20230814_redocalib_noflip/test/';
%calibFile = '/groups/branson/bransonlab/kwaki/ForceData/calibration/20230814_redocalib_noflip/new/multi_calib.mat';
calibFile = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20230622_checkerboardtest/multi_good.mat';
%calibFile = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20230622_checkerboardtest/multi_calib.mat';
multicam = load(calibFile);
multicam = multicam.multicam;

sampledPointsFilename = fullfile(baseDir, 'sampled.mat');
sampledPoints = load(sampledPointsFilename);
optimizationCornersFrames = sampledPoints.optimizationCornersFrames;

%% assemble extrinsic data
[projMats, fcs, ccs, kcs, alpha_cs] = constructCalibInfo(multicam);

%% evaluate the checkerboard corners
numCorners = 42;
optimizationCornersReshaped = reshape(sampledPoints.optimizationCorners, 2, numCorners, [], 3);
optimizationCornersPermuted = permute(optimizationCornersReshaped, [1, 2, 4, 3]);

numCheckerboards = size(optimizationCornersPermuted, 4);

% horizontal norms
%horizontalNorms = zeros(numCheckerboards * (numCorners - 6), 1);
horizontalNorms = zeros(numCheckerboards * 6, 1);
idx = 1;
for i = 1:numCheckerboards
    triangulated = multiDLT(optimizationCornersPermuted(:, :, :, i), projMats, fcs, ccs, kcs, alpha_cs);
    % eval each row
    for j = 1:6
        startIdx = (j - 1) * 7 + 1;
        stopIdx = j * 7;
        %disp(startIdx)
        %disp(stopIdx)
        horizontalNorms(idx) = norm(triangulated(:, startIdx) - triangulated(:, stopIdx));
        idx = idx + 1;
    end
end
mean(horizontalNorms)

verticalNorms = zeros(numCheckerboards * 7, 1);
idx = 1;
for i = 1:numCheckerboards
    triangulated = multiDLT(optimizationCornersPermuted(:, :, :, i), projMats, fcs, ccs, kcs, alpha_cs);
    %for j = 1:35
    for j = 1:7
        startIdx = j;
        stopIdx = 36 + (j - 1);
        verticalNorms(idx) = norm(triangulated(:, startIdx) - triangulated(:, stopIdx));
        %verticalNorms(idx) = norm(triangulated(:, j) - triangulated(:, j+7));
        % if vertical_norms(idx) > 3.7
        %     keyboard
        % end
        idx = idx + 1;
    end
end
mean(verticalNorms)
%% plot distributoin of corner distances
figure(100);
clf
histogram(horizontalNorms);
title('Histogram Horizontal Checkerboard Total Edge Distance')
xlabel('millimeters')
saveas(gcf, fullfile(out_dir, 'all_horz.png'));

figure(101);
clf
histogram(verticalNorms)
title('Histogram Vertical Checkerboard Total Edge Distance')
xlabel('millimeters')
saveas(gcf, fullfile(out_dir, 'all_vert.png'));

% horizontal norms
horizontalNorms = zeros(numCheckerboards * (numCorners - 6), 1);
idx = 1;
for i = 1:numCheckerboards
    triangulated = multiDLT(optimizationCornersPermuted(:, :, :, i), projMats, fcs, ccs, kcs, alpha_cs);
    for j = 1:41
        if mod(j, 7) ~= 0
            horizontalNorms(idx) = norm(triangulated(:, j) - triangulated(:, j+1));
            idx = idx + 1;
        end
    end
end


verticalNorms = zeros(numCheckerboards * (42 - 7), 1);
idx = 1;
for i = 1:numCheckerboards
    triangulated = multiDLT(optimizationCornersPermuted(:, :, :, i), projMats, fcs, ccs, kcs, alpha_cs);
    for j = 1:35
        verticalNorms(idx) = norm(triangulated(:, j) - triangulated(:, j+7));
        % if vertical_norms(idx) > 3.7
        %     keyboard
        % end
        idx = idx + 1;
    end
end


figure(200);
clf
histogram(horizontalNorms);
title('Histogram Horizontal Checkerboard Single Edge Distance')
xlabel('millimeters')
saveas(gcf, fullfile(out_dir, 'single_horz.png'));

figure(201);
clf
histogram(verticalNorms)
title('Histogram Vertical Checkerboard Single Edge Distance')
xlabel('millimeters')
saveas(gcf, fullfile(out_dir, 'single_vert.png'));


%% create some outputs
% load the video
figure(10)
calib_video = '/groups/branson/bransonlab/kwaki/ForceData/calibration/calibration_videos/merged/calibration.avi';
video_reader = VideoReader(calib_video);


out_dir = '/groups/branson/bransonlab/kwaki/ForceData/calibration/20230814_redocalib_noflip/test/recal_examples/';


% for kpidx = 1:size(optimizationCornersPermuted,4)
%     video_reader.CurrentTime = (optimizationCornersFrames(kpidx)) / video_reader.FrameRate;
%     currentFrame = readFrame(video_reader);

%     figure(10)
%     clf
%     imshow(currentFrame);
%     hold on
%     rpe = zeros(42, 3);

%     triangulated = multiDLT(optimizationCornersPermuted(:, :, :, kpidx), projMats, fcs, ccs, kcs, alpha_cs);
%     for i = 1:3
%         plot(optimizationCornersPermuted(1, :, i, kpidx) + (i - 1)*512 + 1, optimizationCornersPermuted(2, :, i, kpidx) + 1, 'o');


%         om = rodrigues(projMats{i}(:, 1:3));
%         T = projMats{i}(:, 4);
%         projected = project_points2(triangulated, om, T, ...
%             fcs{i}, ccs{i}, kcs{i}, alpha_cs{i});
            
%         rpe(:, i) = sqrt(sum((projected-optimizationCornersPermuted(:, :, i, kpidx)).*(projected-optimizationCornersPermuted(:, :, i, kpidx))));

%         plot(projected(1, :) + (i - 1)*512+1, projected(2, :), 'x');

%     end
%     savefig(gcf, fullfile(out_dir, sprintf('%06d.fig', optimizationCornersFrames(kpidx))));
%     saveas(gcf, fullfile(out_dir, sprintf('%06d.png', optimizationCornersFrames(kpidx))));
% end