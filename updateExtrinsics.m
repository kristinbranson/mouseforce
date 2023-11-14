function updateExtrinsics(outDir, calibFilename, mouseLabelTableName, sampledCheckerCornerFilenames)

    multicam = load(calibFilename);    
    multicam = multicam.multicam;

    if ~isempty(sampledCheckerCornerFilenames)
        cornerData = cellfun(@(x) load(x), sampledCheckerCornerFilenames, 'uniformoutput', false);
    else
        cornerData = {};
    end

    tbl = load(mouseLabelTableName);
    tbl = tbl.tblLbls;

    frameNums = tbl.frm;
    frameCount = numel(frameNums);

    % load the clicked points, then reshape into a more useful structure
    points = reshapeTableLabels(tbl);
    [numFrames, numKeypoints, numViews] = size(points, [1, 2, 3]);
    occluded = reshape(tbl.tfocc, [numFrames, numKeypoints, numViews]);
    % first mask the occluded points. for this processing, dont need to ever look
    % at occluded points.
    points(cat(4, occluded, occluded)) = nan;
    % for now use nans as occluded...

    % construct instrinsic parameter structures, to help with some of the future processing.
    [projMats, fc_s, cc_s, kc_s, alpha_cs] = constructCaltechCalibInfo(multicam);

    % construct starting extrinsic structure
    [omsOrg, TsOrg] = convertProjMat2RodT(projMats);
    startingExtrinsics = convertRodT2OptimExtrinsicsVec(omsOrg, TsOrg);

    % get keypoints to optimize
    [optimizationKeypoints, testFiltered] = selectOptimizationKeypoints(points);
    % note, these keypoints will be of the shape, (2x(numKeypoints * numFrames) x numViews)

    % merge with corner data
    if ~isempty(cornerData)
        % need to convert the corner data from 2 view paired info, to 3 view. For the third view,
        % the corner data will be nans, and there isn't any filtering that the keypoints had.
        [optimizationCorners, optimizationCornersFrames] = buildOptimizationCorners2(cornerData,10);
    else
        optimizationCorners = [];
        optimizationCornersFrames = [];
    end

    % both the optimizationCorners and optimizationKeypoints should be in
    % 2 x number of points x numViews. So concatenate along the second dimension
    allPoints = cat(2, optimizationKeypoints, optimizationCorners);
    %allPoints = optimizationKeypoints;

    % save the examples used for the optimization
    sampledPointsFilename = fullfile(outDir, 'sampled.mat');
    save(sampledPointsFilename, 'optimizationKeypoints', 'optimizationCorners', 'optimizationCornersFrames');
    %save(sampledPointsFilename, 'optimizationKeypoints');


    %% bundle adjustment
    fprintf("optimizing extrinsic parameters...");
    options = optimset('MaxFunEvals', 50000, 'MaxIter', 50000, 'display', 'off');
    tic
    currentExtrinsics = startingExtrinsics;
    numIters = 20;
    %numIters = 5;
    exits = cell(numIters, 1);
    losses = cell(numIters, 1);
    for i = 1:numIters
        [currentExtrinsics, fval, exits{i}, outputs{i}] = fminsearch( ...
            @(extrinsicVecs) fmin_multidlt(extrinsicVecs, allPoints, fc_s, cc_s, kc_s, alpha_cs), ...
            currentExtrinsics, options ...
        );
        fprintf("\n\t%f, %d\n", fval, outputs{i}.iterations);
    end
    extrinsicVecs = currentExtrinsics;
    fprintf(" done! %f\n");
    toc

    %% construct the new projection matrices and extrinsic data.
    num_views = numViews;
    oms_org = cell(num_views, num_views);
    Ts_org = cell(num_views, num_views);
    for i = 1:num_views
        for j = i+1:num_views
            oms_org{i,j} = multicam.crigStros{i,j}.omLR;
            Ts_org{i,j} = multicam.crigStros{i,j}.T.LR;
        end
    end

    % get updated extrinsics 
    [oms, Ts] = convertOptimExtrinsicsVec2OMT(numViews, extrinsicVecs);

    %% check errors
    new_errors = 0;
    old_errors = 0;

    fprintf("all points, pairwise stereo reprojection errors\n");
    for i = 1:num_views
        for j = (i+1):num_views
            [mean_rpe_old, rpe_old] = stereo_reprojection_error(allPoints(:, :, [i, j]), oms_org{i,j}, Ts_org{i,j}, fc_s([i,j]), cc_s([i,j]), kc_s([i,j]), alpha_cs([i,j]));
            [mean_rpe_new, rpe_new] = stereo_reprojection_error(allPoints(:, :, [i, j]), oms{i,j}, Ts{i,j}, fc_s([i,j]), cc_s([i,j]), kc_s([i,j]), alpha_cs([i,j]));
            fprintf("cam %d, cam %d, %f, %f\n", i, j, mean_rpe_old, mean_rpe_new);
            new_errors = new_errors + mean_rpe_new;
            old_errors = old_errors + mean_rpe_old;
        end
    end

    fprintf("keypoints, pairwise stereo reprojection errors\n");
    for i = 1:num_views
        for j = (i+1):num_views
            [mean_rpe_old, rpe_old] = stereo_reprojection_error(optimizationKeypoints(:, :, [i, j]), oms_org{i,j}, Ts_org{i,j}, fc_s([i,j]), cc_s([i,j]), kc_s([i,j]), alpha_cs([i,j]));
            [mean_rpe_new, rpe_new] = stereo_reprojection_error(optimizationKeypoints(:, :, [i, j]), oms{i,j}, Ts{i,j}, fc_s([i,j]), cc_s([i,j]), kc_s([i,j]), alpha_cs([i,j]));
            fprintf("cam %d, cam %d, %f, %f\n", i, j, mean_rpe_old, mean_rpe_new);
            new_errors = new_errors + mean_rpe_new;
            old_errors = old_errors + mean_rpe_old;
        end
    end

    if ~isempty(cornerData)
        fprintf("checkerboard, pairwise stereo reprojection errors\n");
        for i = 1:num_views
            for j = (i+1):num_views
                [mean_rpe_old, rpe_old] = stereo_reprojection_error(optimizationCorners(:, :, [i, j]), oms_org{i,j}, Ts_org{i,j}, fc_s([i,j]), cc_s([i,j]), kc_s([i,j]), alpha_cs([i,j]));
                [mean_rpe_new, rpe_new] = stereo_reprojection_error(optimizationCorners(:, :, [i, j]), oms{i,j}, Ts{i,j}, fc_s([i,j]), cc_s([i,j]), kc_s([i,j]), alpha_cs([i,j]));
                fprintf("cam %d, cam %d, %f, %f\n", i, j, mean_rpe_old, mean_rpe_new);
                new_errors = new_errors + mean_rpe_new;
                old_errors = old_errors + mean_rpe_old;
            end
        end
    end

    % create the projection matrix for the dlt
    proj_mats_old = cell(numViews, 1);
    proj_mats_old{1} = [eye(3), zeros(3, 1)];
    proj_mats_new = cell(numViews, 1);
    proj_mats_new{1} = [eye(3), zeros(3, 1)];

    start_idx = 1;
    for i_view = 2:num_views
        proj_mats_old{i_view} = [rodrigues(oms_org{1,i_view}), Ts_org{1,i_view}];
        proj_mats_new{i_view} = [rodrigues(oms{1,i_view}), Ts{1,i_view}];
    end
    [mean_rpe_old, rpe_old, mean_allcam_rpe_old] = multidlt_reprojection_error(allPoints, proj_mats_old, fc_s, cc_s, kc_s, alpha_cs);
    [mean_rpe_new, rpe_new, mean_allcam_rpe_new] = multidlt_reprojection_error(allPoints, proj_mats_new, fc_s, cc_s, kc_s, alpha_cs);
    fprintf("all cam available dlt reproj, %f, %f\n", mean_allcam_rpe_old, mean_allcam_rpe_new);
    fprintf("any cam dlt reproj, %f, %f\n", mean_rpe_old, mean_rpe_new);
    new_errors = new_errors + mean_allcam_rpe_new;
    old_errors = old_errors + mean_allcam_rpe_old;

    fprintf("total errors: %f %f\n", old_errors, new_errors);

    %% build the calrig friendly data
    calibFilenamesCellArray = cell(num_views, num_views);
    for i = 1:numViews
        for j = i+1:numViews
            view1 = i;
            view2 = j;

            calib_struct = struct( ...
                "calib_name_left", "cam_" + num2str(view1), ...
                "calib_name_right", "cam_" + num2str(view2), ...
                "cam0_id", view1, ...
                "cam1_id", view2, ...
                "dX", 5, ...
                "nx", 512, ...
                "ny", 512, ...
                "fc_left", fc_s{i}, ...
                "cc_left", cc_s{i}, ...
                "alpha_c_left", alpha_cs{i}, ...
                "kc_left", kc_s{i}, ...
                "fc_right", fc_s{j}, ...
                "cc_right", cc_s{j}, ...
                "alpha_c_right", alpha_cs{j}, ...
                "kc_right", kc_s{j}, ...
                "om", oms{i,j}, ...
                "R", rodrigues(oms{i,j}), ...
                "T", Ts{i,j}, ...
                "F", [], ...
                "active_images_left", [], ...
                "cc_left_error", 0, ...
                "cc_right_error", 0, ...
                "recompute_intrinsic_right", 1, ...
                "recompute_intrinsic_left", 1);
            save(fullfile(outDir, "/" + num2str(view1) + num2str(view2) +".mat"), "-struct", "calib_struct");
            calibFilenamesCellArray{view1,view2} = outDir + "/" + num2str(view1) + num2str(view2) +".mat";
        end
    end
    multicam = createCalRigNPairwiseCalibrated(calibFilenamesCellArray)
    save(fullfile(outDir + "/multi_calib.mat"), 'multicam');
end