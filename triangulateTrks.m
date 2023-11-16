function [keypoints, allPoints, occludedMasked, heuristic, bestReprojError, trks] = triangulateTrks(trkFilenames, calibrationMatFileName, outDir)
    numViews = length(trkFilenames);
    % load calibration and trk data
    multicam = load(calibrationMatFileName).multicam;
    [trks, keypoints, occlusionTags] = loadTrks(trkFilenames);

    [numFrames, numKpts] = size(keypoints, [2, 3]);

    % construct extrinsic and instrinsic parameter structures
    [projMats, fc_s, cc_s, kc_s, alpha_cs] = constructCaltechCalibInfo(multicam);


    keypointsFlattened = reshape(keypoints, [2, numFrames*numKpts, numViews]);
    [X, xReproj, ~, ~] = multiDLTAndReprojError(keypointsFlattened, projMats, fc_s, cc_s, kc_s, alpha_cs);
    X = reshape(X, [3, numFrames, numKpts]); % npt x 3 x nfrm
    allPoints.X = X;
    allPoints.reproj = reshape(xReproj, [2, numFrames, numKpts, numViews]);


    keypointsMasked = keypoints;
    keypointsMasked(occlusionTags) = nan;
    keypointsMasked = reshape(keypointsMasked, [2, numFrames*numKpts, numViews]);
    [Xmasked, maskedReproj, ~, ~] = multiDLTAndReprojError(keypointsMasked, projMats, fc_s, cc_s, kc_s, alpha_cs);
    Xmasked = reshape(Xmasked, [3, numFrames, numKpts]); % npt x 3 x nfrm
    occludedMasked.X = Xmasked;
    occludedMasked.reproj = reshape(maskedReproj, [2, numFrames, numKpts, numViews]);


    Xheuristic = triangulateHeuristic(keypoints, projMats, fc_s, cc_s, kc_s, alpha_cs, occlusionTags);
    XheuristicFlat = reshape(Xheuristic, [3, numFrames*numKpts]);
    %XheuristicReproj = zeros(size(keypoints));
    XheuristicReproj = zeros(2, numFrames*numKpts, numViews);
    for i = 1:numViews
        om = rodrigues(projMats{i}(:, 1:3));
        T = projMats{i}(:, 4);

        XheuristicReproj(:, :, i) = project_points2(XheuristicFlat, om, T, ...
            fc_s{i}, cc_s{i}, kc_s{i}, alpha_cs{i});
    end
    heuristic.X = Xheuristic;
    heuristic.reproj = reshape(XheuristicReproj, [2, numFrames, numKpts, numViews]);
    %XheuristicReproj = reshape(XheuristicReproj, [2, numFrames, numKpts, numViews]);

    % temp = zeros(size(XheuristicReproj));
    % for i = 1:numViews
    %     om = rodrigues(projMats{i}(:, 1:3));
    %     T = projMats{i}(:, 4);
    %     for j = 1:numKpts
    %         temp(:, :, j, i) = project_points2(Xheuristic(:, :, j), om, T, ...
    %             fc_s{i}, cc_s{i}, kc_s{i}, alpha_cs{i});
    %     end
    % end

    bestReprojError = [];
    % tic
    % [Xbest, reprojBestFlat] = bestRPETriangulate(keypointsFlattened, projMats, fc_s, cc_s, kc_s, alpha_cs);
    % reprojBest = reshape(reprojBestFlat, [2, numFrames, numKpts, numViews]);
    % toc

end

