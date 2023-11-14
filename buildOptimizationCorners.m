function [optimizationCorners, frameNums] = buildOptimizationCorners(cornerData)
    % convert the corner data (collected from python opencv) into corners useful
    % for the optimization. The structure of the corners for the optimziation is
    % 2 x all corners x num views. IE, the checkerboard is flattened. Before
    % flattening, merge any checkerboard that is visible in more than one
    % view. Also sample before flattening.

    % code should on work for more than 3 views...
    numViewPairs = numel(cornerData.views1);
    numCheckerCorners = size(cornerData.corners1{1}, 2);

    % get the camera indexes. add 1 because this data is from python.
    numCameras = sum(unique([cornerData.views1, cornerData.views2]));

    % figure out the intersection of corners between each of the pairwise
    % calibration checkerboards.
    numFramesPerPair = cellfun(@(x) size(x, 1), cornerData.corners1);
    allCorners = nan(sum(numFramesPerPair), numCheckerCorners, 2, numCameras);
    frameNums = zeros(sum(numFramesPerPair), 1);
    startIdx = 1;
    for i = 1:numViewPairs
        for j = (i+1):numViewPairs
            [overlapping, idx1, idx2] = intersect(cornerData.frames{i}, cornerData.frames{j});
            % add these frames to the corner data
            if ~isempty(overlapping)
                stopIdx = startIdx + size(overlapping, 2) - 1;
                frameNums(startIdx:stopIdx) = cornerData.frames{i}(idx1);

                % first cam pair
                camera1 = cornerData.views1(i) + 1;
                camera2 = cornerData.views2(i) + 1;
                allCorners(startIdx:stopIdx, :, :, camera1) = ...
                    cornerData.corners1{i}(idx1, :, :, :);
                allCorners(startIdx:stopIdx, :, :, camera2) = ...
                    cornerData.corners2{i}(idx1, :, :, :);

                % second cam pair
                camera1 = cornerData.views1(j) + 1;
                camera2 = cornerData.views2(j) + 1;
                allCorners(startIdx:stopIdx, :, :, camera1) = ...
                    cornerData.corners1{j}(idx2, :, :, :);
                allCorners(startIdx:stopIdx, :, :, camera2) = ...
                    cornerData.corners2{j}(idx2, :, :, :);
                startIdx = stopIdx + 1;
                cornerData.frames{i}(idx1) = [];
                cornerData.frames{j}(idx2) = [];

                cornerData.corners1{i}(idx1, :, :) = [];
                cornerData.corners2{i}(idx1, :, :) = []; 
                cornerData.corners1{j}(idx2, :, :) = [];
                cornerData.corners2{j}(idx2, :, :) = []; 

            end 
        end
    end

    % get the rest of the corner data.
    %numFramesPerPair = cellfun(@(x) size(x, 1), cornerData.corners1);
    %allCorners = nan(sum(numFramesPerPair), numCheckerCorners, 2, numCameras);
    % update the number of frames per pair
    numFramesPerPair = cellfun(@(x) size(x, 1), cornerData.corners1);
    cornerFrameIdx = horzcat(cornerData.frames{:});
    missingCamera = zeros(size(cornerFrameIdx));
    %startIdx = 1;
    rng('default');
    for i = 1:numViewPairs
        if i == 1
            % do things get better if we skip the opposing views?
            continue
        end
        camera1 = cornerData.views1(i) + 1;
        camera2 = cornerData.views2(i) + 1;

        % randomly sample corners
        numSamples = 15;
        %numSamples = 20;
        randIdx = randperm(size(cornerData.corners1{i}, 1), numSamples);

        %stopIdx = numFramesPerPair(i) + startIdx - 1;
        stopIdx = startIdx + numSamples - 1;
        allCorners(startIdx:stopIdx, :, :, camera1) = cornerData.corners1{i}(randIdx, :, :);
        allCorners(startIdx:stopIdx, :, :, camera2) = cornerData.corners2{i}(randIdx, :, :);
        missingCamera(startIdx:stopIdx) = setdiff(1:numCameras, [camera1, camera2]);

        frameNums(startIdx:stopIdx) = cornerData.frames{i}(randIdx);
        startIdx = stopIdx + 1;
    end
    allCorners = allCorners(1:startIdx - 1, :, :, :);
    mergedCorners = allCorners;

    optimizationCorners = permute(mergedCorners, [3, 2, 1, 4]);
    optimizationCorners = reshape(optimizationCorners, 2, [], numCameras);
    frameNums = frameNums(1:startIdx - 1);

end