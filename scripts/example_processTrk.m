% first process day 4
trkFilenames = {
    '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231023_avgc50day4avgc52day3_eval/avgc50day4/day4_avgc50_2023_08_18_12_32_32-002_0_20231019allmice_imported_mdn_joint_fpn.trk', ...
    '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231023_avgc50day4avgc52day3_eval/avgc50day4/day4_avgc50_2023_08_18_12_32_32-002_1_20231019allmice_imported_mdn_joint_fpn.trk', ...
    '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231023_avgc50day4avgc52day3_eval/avgc50day4/day4_avgc50_2023_08_18_12_32_32-002_2_20231019allmice_imported_mdn_joint_fpn.trk' ...
};

calibrationMatFilename = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231023_avgc50day4avgc52day3_eval/avgc50day4/multi_calib.mat';
outDir = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231023_avgc50day4avgc52day3_eval/avgc50day4/';
[keypoints, allPoints, occludedMasked, heuristic, bestReprojError, trks] = triangulateTrks(trkFilenames, calibrationMatFilename, outDir);


% check reprojections
movieFilenames = { ...
    '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231023_avgc50day4avgc52day3_eval/avgc50day4/day4_avgc50_2023_08_18_12_32_32-002_0.avi', ...
    '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231023_avgc50day4avgc52day3_eval/avgc50day4/day4_avgc50_2023_08_18_12_32_32-002_1.avi', ...
    '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231023_avgc50day4avgc52day3_eval/avgc50day4/day4_avgc50_2023_08_18_12_32_32-002_2.avi' ...
};

figure(100);
clf
set(gcf, 'Position',[19 1400 2150 560]);
frames = 430085:430095;
movieReaders = cell(length(movieFilenames),1);
for i=1:length(movieFilenames)
    movieReaders{i} = VideoReader(movieFilenames{i});
    movieReaders{i}.CurrentTime = double(frames(1) - 1) / movieReaders{i}.FrameRate;
end


for i=1:length(frames)
    for j=1:length(movieReaders)
        frame=readFrame(movieReaders{j});
        subplot(1, 3, j);
        imshow(frame);
        hold on
        plot(squeeze(keypoints(1, i, :, j)), squeeze(keypoints(2, i, :, j)), 'o', 'markersize', 5, 'linewidth', 2);
        plot(squeeze(allPoints.reproj(1, i, :, j)), squeeze(allPoints.reproj(2, i, :, j)), 'x', 'markersize', 5, 'linewidth', 2);
        plot(squeeze(occludedMasked.reproj(1, i, :, j)), squeeze(occludedMasked.reproj(2, i, :, j)), '+', 'markersize', 5, 'linewidth', 2);
    end
    break
end