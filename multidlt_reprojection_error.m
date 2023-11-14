function [mean_rpe, rpe, mean_all_cam_rpe] = multidlt_reprojection_error(keypoints, proj_mats, fc_s, cc_s, kc_s, alpha_cs)
    % reproj_error = multidlt_reprojection_error(keypoints, om, T, fc_s, cc_s, kc_s, alpha_cs)
    %
    % Calculate the reprojection error for keypoints using the given intrinsic and extrinsic
    % parameters. keypoints is assumed to be 2 x num points x num cameras (in this case
    % three cameras). Each intrinsic parameter dimensions corresponds to each of the
    % cameras. om and T represent the extrinsic parameters from camera 1 to 2 and
    % camera 1 to 3, and so on.
    %
    % keypoints: 2 x N x C, where N is the number of keypoints to evaluate.
    % proj_mats: projection matrices from cam1 to others
    % fc_s: focal camera parameters
    % cc_s: camera center
    % kc_s: distortion
    % alpha_cs: skew
    %
    % mean_rpe: mean reprojection error over the keypoints. any nan's will be skipped and
    % masked out of the reprojection error
    % rpe: all the reprojection erorrs. nans will be left in so that indicies match
    % provide keypoint indicies.
    % mean_allcam_rpe: mean reprojection error for points where all cameras are 
    num_views = size(keypoints, 3);
    triangulated = multiDLT(keypoints, proj_mats, fc_s, cc_s, kc_s, alpha_cs);

    % for each view, compute the reprojection error
    rpe = zeros(size(keypoints, [2,3]));
    err_idx = true(size(keypoints, 2), 1);
    mean_rpes = zeros(num_views, 1);
    for i = 1:num_views
        om = rodrigues(proj_mats{i}(:, 1:3));
        T = proj_mats{i}(:, 4);
        projected = project_points2(triangulated, om, T, ...
            fc_s{i}, cc_s{i}, kc_s{i}, alpha_cs{i});
 
        rpe(:, i) = sqrt(sum((projected-keypoints(:, :, i)).*(projected-keypoints(:, :, i))));

        % create an indexing of the non nan points. goal is to find the points
        % that are not nan in all views. this will let us calculate the 
        % mean rpe for points that used 3 views to triangulate.
        err_idx = err_idx & ~isnan(rpe(:, i));

        mean_rpes(i) = mean(rpe(~isnan(rpe(:, i)), i));
    end

    mean_rpe = mean(mean_rpes);
    mean_all_cam_rpe = mean(mean(rpe(err_idx, :), 1));
end