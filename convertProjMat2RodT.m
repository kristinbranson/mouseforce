function [oms, Ts] = convertProjMat2Rodt(projMats)
    % assume projMats is cell array. will need to clean this up in the future.
    % no reason for projection matricies to be a cell array... kind of an
    % artifact of the CalRigNPairwise structure.
    numViews = numel(projMats);
    oms = zeros(numViews, 3);
    Ts = zeros(numViews, 3);

    for i = 1:numViews
        oms(i, :) = rodrigues(projMats{i}(:, 1:3));
        Ts(i, :) = projMats{i}(:, 4);
    end

end