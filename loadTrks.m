function [trks, allkeypoints, allOcclusionTags] = loadTrks(trkFilenames)
    for i = 1:length(trkFilenames)
        trks{i} = load(trkFilenames{i}, '-mat');
    end

    % reshape trk data
    [numKpts, numFrames] = size(trks{1}.pTrk{1}, [1,3]);
    numViews = length(trkFilenames);

    % build the combined trk data.
    allkeypoints = zeros(2, numFrames, numKpts, numViews);
    allOcclusionTags = zeros(2, numFrames, numKpts, numViews);
    for i=1:numViews
        % keypoints are normally in (keypoints x dims x frames). the caltech calibration code prefers things in
        % (dims x points), so moving the xy dimension to the front.
        allkeypoints(:, :, :, i) = permute(trks{i}.pTrk{1}, [2, 3, 1]);
        allOcclusionTags(1, :, :, i) = permute(trks{i}.pTrkTag{1}, [2, 1]);
        allOcclusionTags(2, :, :, i) = permute(trks{i}.pTrkTag{1}, [2, 1]);
    end
    allOcclusionTags = logical(allOcclusionTags);
end
