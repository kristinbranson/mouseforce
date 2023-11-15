function [optimizationCorners, frameNums] = buildOptimizationCorners2(cornerData,numSamples)
    % convert the corner data (collected from python opencv) into corners useful
    % for the optimization. The structure of the corners for the optimziation is
    % 2 x all corners x num views. IE, the checkerboard is flattened. Before
    % flattening, merge any checkerboard that is visible in more than one
    % view. Also sample before flattening.

    rng('default');
    allCorners = cell(length(cornerData),1);
    allFrames = cell(length(cornerData),1);
    %cameraIdx = [1,3;2,3];
    for i = 1:length(cornerData)
        randIdx = randperm(length(cornerData{i}.frameNumbers), numSamples);
        temp = squeeze(cornerData{i}.sampledCorners);
        % hard code which thing to nan out.
        % if i == 1
        %     temp(2, :, :, :) = nan;
        % end
        % if i == 2
        %     temp(1, :, :, :) = nan;
        % end
        allCorners{i} = temp(:, randIdx, :, :);
        allFrames{i} = cornerData{i}.frameNumbers(randIdx);
    end
    allCorners = cat(2, allCorners{:});
    sampledFrames = horzcat([allFrames{:}]);

    %allCorners = allCorners(1:startIdx - 1, :, :, :);
    %mergedCorners = allCorners;

    optimizationCorners = permute(allCorners, [4,2,3,1]);
    %optimizationCorners = permute(mergedCorners, [3, 2, 1, 4]);
    optimizationCorners = reshape(optimizationCorners, 2, [], 3);
    frameNums = sampledFrames;
end