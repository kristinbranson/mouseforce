function X = triangulateHeuristic(ptrks, all_projections, fc_s, cc_s, kc_s, alpha_cs, occlusionTags)

    % keypoint notes
    % 1: use camera 1 and 2
    % 2, 3: use whatever is availale
    % 4, 5, 6, 7: always use camera 1 and 3, and only 2 if not predicted occluded
    % 8, 9, 10, 11: always use camera 2 and 3, and only 1 if not predicted occluded
    % use everything for 12.

    % triangulate the groups
    X = zeros([3, size(ptrks, [2,3])]);

    for i = 1:12
        tempPtrks = ptrks;
        if i == 1
            tempPtrks(:, :, i, 3) = nan;
        end
        if i == 4 || i == 5 || i == 6 || i == 7
            mask = find(occlusionTags(1, :, i, 2));
            tempPtrks(:, mask, i, 2) = nan;
        end
        if i == 8 || i == 9 || i == 10 || i == 11
            mask = find(occlusionTags(1, :, i, 1));
            tempPtrks(:, mask, i, 1) = nan;
        end

        X(:, :, i) = multiDLT(squeeze(tempPtrks(:, :, i, :)), all_projections, fc_s, cc_s, kc_s, alpha_cs);
    end
end