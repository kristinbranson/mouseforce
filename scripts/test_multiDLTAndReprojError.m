% script to test some dlt code

baseDir = "/groups/branson/bransonlab/kwaki/ForceData/outputs/20231024_test_multiDLTReproj";

calibrationMatFilename = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231023_avgc50day4avgc52day3_eval/avgc50day4/multi_calib.mat';
outDir = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231023_avgc50day4avgc52day3_eval/avgc50day4/';


trkFilenames = {
    'day4_avgc50_2023_08_18_12_32_32-002_0_20231019allmice_imported_mdn_joint_fpn.trk', ...
    'day4_avgc50_2023_08_18_12_32_32-002_1_20231019allmice_imported_mdn_joint_fpn.trk', ...
    'day4_avgc50_2023_08_18_12_32_32-002_2_20231019allmice_imported_mdn_joint_fpn.trk' ...
};
trkFilenames = cellfun(@(x) fullfile(baseDir, x), trkFilenames, 'uniformoutput', false);
% check reprojections
movieFilenames = { ...
    'day4_avgc50_2023_08_18_12_32_32-002_0.avi', ...
    'day4_avgc50_2023_08_18_12_32_32-002_1.avi', ...
    'day4_avgc50_2023_08_18_12_32_32-002_2.avi' ...
};
movieFilenames = cellfun(@(x) fullfile(baseDir, x), movieFilenames, 'uniformoutput', false);


[trks, keypoints, occlusionTags] = loadTrks(trkFilenames);

multicam = load(calibrationMatFilename).multicam;
[projMats, fc_s, cc_s, kc_s, alpha_cs] = constructCaltechCalibInfo(multicam);


% get a subset of keypoints to test with.
frames = 433658:433660;
keypoints = keypoints(:, frames, 7:8, :);
occlusionTags = occlusionTags(:, frames, 7:8, :);

[numFrames, numKeypoints, numViews] = size(keypoints, [2, 3, 4]);


keypointsFlattened = reshape(keypoints, [2, numFrames*numKeypoints, numViews]);
[triangulatedFlat, xReprojFlat, meanReprojError, reprojErrors] = multiDLTAndReprojError(keypointsFlattened, projMats, fc_s, cc_s, kc_s, alpha_cs);
triangulated = reshape(triangulatedFlat, [3, numFrames, numKeypoints]);
xReproj = reshape(xReprojFlat, [2, numFrames, numKeypoints, numViews]);


keypointsMasked = keypoints;
keypointsMasked(occlusionTags) = nan;
keypointsMasked = reshape(keypointsMasked, [2, numFrames*numKeypoints, numViews]);
[~, maskedReproj, ~, ~] = multiDLTAndReprojError(keypointsMasked, projMats, fc_s, cc_s, kc_s, alpha_cs);

reprojMasked = reshape(maskedReproj, [2, numFrames, numKeypoints, numViews]);


[Xbest, reprojBestFlat] = bestRPETriangulate(keypointsFlattened, projMats, fc_s, cc_s, kc_s, alpha_cs);
reprojBest = reshape(reprojBestFlat, [2, numFrames, numKeypoints, numViews]);


% Xheuristic = triangulateHeuristic(keypoints, projMats, fc_s, cc_s, kc_s, alpha_cs, occlusionTags);
% XheuristicFlat = reshape(Xheuristic, [3, numFrames*numKeypoints]);
% %XheuristicReproj = zeros(size(keypoints));
% XheuristicReproj = zeros(2, numFrames*numKeypoints, numViews);
% for i = 1:numViews
%     om = rodrigues(projMats{i}(:, 1:3));
%     T = projMats{i}(:, 4);

%     XheuristicReproj(:, :, i) = project_points2(XheuristicFlat, om, T, ...
%         fc_s{i}, cc_s{i}, kc_s{i}, alpha_cs{i});
% end
% heuristicReproj = reshape(XheuristicReproj, [2, numFrames, numKeypoints, numViews]);


%plotReprojectionFrames(movieFilenames, frames, keypoints, {xReproj, reprojBest});
plotReprojectionFrames(movieFilenames, frames, keypoints, {reprojMasked, reprojBest});
%plotReprojectionFrames(movieFilenames, frames, keypoints, {heuristicReproj, reprojBest});