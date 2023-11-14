function [maskedPoints1, maskedPoints2] = selectOptimizationKeypoints(points)
    % points, occlusionFlags should be (num frames x num keypoints x num views x 2);
    % odd, but maskedPoints will be (2 x (num keypoints * num frames) x num views
    [numFrames, numKeypoints, numViews] = size(points, 1:3);

    % trying to different versions of the masked points
    ignoreMask = false(12, 1);
    ignoreMask([6, 7, 10, 11, 12]) = true;

    maskedPoints1 = points;
    maskedPoints1(:, ignoreMask, :, :) = nan;
    maskedPoints1(:, 1, 3, :) = nan;

    selectedPointIdx = false(12, 1);
    selectedPointIdx([1, 2, 3, 4, 5, 8, 9]) = true;
    maskedPoints2 = points(:, selectedPointIdx, :, :);
    maskedPoints2(:, 1, :, :) = nan;

    % reshape/permute to be more friendly to downstream tasks.
    %maskedPoints1 = reshape(maskedPoints1, numFrames*numKeypoints, numViews, 2);
    %maskedPoints1 = permute(maskedPoints1, [3, 1, 2]);
    maskedPoints1 = permute(maskedPoints1, [4, 2, 1, 3]);
    maskedPoints1 = reshape(maskedPoints1, 2, numKeypoints*numFrames, numViews) - 1;

    maskedPoints2 = reshape(maskedPoints2, numFrames*7, numViews, 2);
    maskedPoints2 = permute(maskedPoints2, [3, 1, 2]);

end