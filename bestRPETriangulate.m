function [Xbest, reprojBest] = bestRPETriangulate(ptrks, projMats, fc_s, cc_s, kc_s, alpha_cs)
    numViews = size(projMats, 1);
    [viewMasks, numMasks] = buildMasks(numViews);
    numPoints = size(ptrks, 2);

    X = zeros(3, numPoints, numMasks);
    xReproj = zeros(2, numPoints, numViews, numMasks);
    allReprojErrors = zeros(numPoints, numMasks);
    for i = 1:numMasks
        % triangulate points
        maskedPtrks = ptrks;
        maskedPtrks(:, :, ~viewMasks(i,:)) = nan;

        [X(:, :, i), xReproj(:, :, :, i), ~, ~] = multiDLTAndReprojError(maskedPtrks, projMats, fc_s, cc_s, kc_s, alpha_cs);
        %allReprojErrors(:, i) = meanReprojErrorViews(ptrks, xReproj);
        allReprojErrors(:, i) = mean(sqrt(sum((ptrks - xReproj(:, :, :, i)) .* (ptrks - xReproj(:, :, :, i)), 1)), 3);
    end

    % for each point, just the triangulation and reprojection that has the smallest error
    Xbest = zeros(3, numPoints);
    reprojBest = zeros(2, numPoints, numViews);
    for i = 1:numPoints
        [~, minIdx] = min(allReprojErrors(i, :));
        reprojBest(:, i, :) = xReproj(:, i, :, minIdx);
        Xbest(:, i) = X(:, i, minIdx);
    end
end


function [viewMasks, numMasks] = buildMasks(numViews)
    % need to do some hard coding here. not sure it makes sense to assume what
    % kind of masks make sense to create as the number of views increases. May
    % make sense to contruct all combinations (2, 3, 4, 5...) and then compute
    % reprojection errors. Has a ransac feel to it.
    % for now, do all pairwise view triangulations, and all views.

    % there are nchoosek pairs of views + 1 for all views
    k = 2; % for now only pairwise views
    numMasks = nchoosek(numViews, 2) + 1;
    viewMasks = zeros(numMasks, numViews);
    % from https://www.mathworks.com/matlabcentral/answers/510687-produce-all-combinations-of-n-choose-k-in-binary#answer_419982
    viewMasks(1:numMasks - 1, :) = dec2bin(sum(nchoosek(2.^(0:numViews-1),k),2)) - '0';
    viewMasks(end, :) = ones(1, numViews);
end


% function meanReprojErrors = meanReprojErrorViews(keypoints, reprojected)
%     % compute the mean reprojection error over the non nan elements of the views.
%     numPoints = size(reprojErrors, 1);
%     meanReprojErrors = zeros(numPoints, 1);



%     for i = 1:numPoints
%         % if all entries are nans, then the mean function will return nan.
%         meanReprojErrors(i) = mean(reprojErrors(i, ~isnan(reprojErrors(i, :))));
%     end
% end