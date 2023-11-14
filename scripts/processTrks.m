% first process day 4
trkFilenames = {
    '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231023_avgc50day4avgc52day3_eval/avgc50day4/day4_avgc50_2023_08_18_12_32_32-002_0_20231019allmice_imported_mdn_joint_fpn.trk', ...
    '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231023_avgc50day4avgc52day3_eval/avgc50day4/day4_avgc50_2023_08_18_12_32_32-002_1_20231019allmice_imported_mdn_joint_fpn.trk', ...
    '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231023_avgc50day4avgc52day3_eval/avgc50day4/day4_avgc50_2023_08_18_12_32_32-002_2_20231019allmice_imported_mdn_joint_fpn.trk' ...
};

calibrationMatFilename = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231023_avgc50day4avgc52day3_eval/avgc50day4/multi_calib.mat';
outDir = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231023_avgc50day4avgc52day3_eval/avgc50day4/';
tic
[allPoints, occludedMasked, heuristic, bestReprojError, trks] = triangulateTrks(trkFilenames, calibrationMatFilename, outDir);
toc

save('avgc50day4/triangulated.mat', 'allPoints', 'occludedMasked', 'heuristic');




% trkFilenames = {
%     '', ...
%     '', ...
%     '' ...
% };
% calibrationMatFilename = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231023_avgc50day4avgc52day3_eval/avgc50day4/multi_calib.mat';
% outDir = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231023_avgc50day4avgc52day3_eval/avgc50day4/';
% tic
% [allPoints, occludedMasked, heuristic, bestReprojError, trks] = triangulateTrks(trkFilenames, calibrationMatFilename, outDir);
% toc

% save('avgc50day4/triangulated.mat', 'allPoints', 'occludedMasked', 'heuristic');