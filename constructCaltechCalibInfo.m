function [projMats, fc_s, cc_s, kc_s, alpha_cs] = constructCaltechCalibInfo(multicam)
    % put CalRighNPairwise intrinstic/extrinsic data into a more user friendly format.
    % CalRigNPairwise objects store data as pairwise relative information. Convert
    % to be as list of data, where each index is the camera number.

    numViews = multicam.nviews;

    projMats = cell(numViews, 1);
    fc_s = cell(numViews, 1);
    cc_s = cell(numViews, 1);
    kc_s = cell(numViews, 1);
    alpha_cs = cell(numViews, 1);

    for i = 1:numViews
        % the camera data is stored in something like an upper triangular style matrix.
        % all cameras will be the right camera with respect to camera 1 in the first
        % row of the crigStros matrix. camera 1 is never the right camera in this
        % structure.
        if i == 1
            projMats{i} = [eye(3), zeros(3, 1)];
            fc_s{i} = multicam.crigStros{1, 2}.int.L.fc;
            cc_s{i} = multicam.crigStros{1, 2}.int.L.cc;
            kc_s{i} = multicam.crigStros{1, 2}.int.L.kc;
            alpha_cs{i} = multicam.crigStros{1, 2}.int.L.alpha_c;
        else
            projMats{i} = [multicam.crigStros{1, i}.R.LR, multicam.crigStros{1, i}.T.LR];
            fc_s{i} = multicam.crigStros{1, i}.int.R.fc;
            cc_s{i} = multicam.crigStros{1, i}.int.R.cc;
            kc_s{i} = multicam.crigStros{1, i}.int.R.kc;
            alpha_cs{i} = multicam.crigStros{1, i}.int.R.alpha_c;
        end
    end

end