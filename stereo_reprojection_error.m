function [mean_rpe, rpe] = stereo_reprojection_error(keypoints, om, T, fc_s, cc_s, kc_s, alpha_cs)
    % reproj_error = stereo_reprojection_error(keypoints, om, T, fc_s, cc_s, kc_s, alpha_cs)
    %
    % Calculate the reprojection error for keypoints using the given intrinsic and extrinsic
    % parameters. keypoints is assumed to be 2 x num points x num cameras (in this case
    % two cameras). Each intrinsic parameter dimensions corresponds to the first
    % and second camera dimensions of keypoints. om and T represent the extrinsic parameters
    % for camera 1 to camera 2.
    %
    % keypoints: 2 x N x C, where N is the number of keypoints to evaluate. C is always
    % 2 and represents the keypoints in each camera dimension.
    % om: Rodrigues rotation from camera 1 to camera 2 (keypoints(:, :, 1) -> keypoints(:, :, 2)
    % T: Translation from camera 1 to camera 2
    % fc_s: focal camera parameters
    % cc_s: camera center
    % kc_s: distortion
    % alpha_cs: skew
    %
    % mean_rpe: mean reprojection error over the keypoints. any nan's will be skipped and
    % masked out of the reprojection error
    % rpe: all the reprojection erorrs. nans will be left in so that indicies match
    % provide keypoint indicies.

    num_keypoints = size(keypoints, 2);

    rpe = zeros(size(keypoints, [2, 3]));
 
    [XL, XR] = stereo_triangulation( ...
        keypoints(:, :, 1), keypoints(:, :, 2), ...
        om, T, ... % extrinsics
        fc_s{1}, cc_s{1}, kc_s{1}, alpha_cs{1}, ... % camera 1 intrinsics (left)
        fc_s{2}, cc_s{2}, kc_s{2}, alpha_cs{2}); % camera 2 intrinsics (right)

    [xL_re_org] = project_points2(XL,zeros(size(om)),zeros(size(T)),...
        fc_s{1}, cc_s{1}, kc_s{1}, alpha_cs{1});
    [xR_re_org] = project_points2(XR,zeros(size(om)),zeros(size(T)),...
        fc_s{2}, cc_s{2}, kc_s{2}, alpha_cs{2});


    % [xL_re_org_scale] = project_points2(XL*(3/3.3),zeros(size(om)),zeros(size(T)),...
    %     fc_s{1}, cc_s{1}, kc_s{1}, alpha_cs{1});
    % [xR_re_org_scale] = project_points2(XR*(3/3.3),zeros(size(om)),zeros(size(T)),...
    %     fc_s{2}, cc_s{2}, kc_s{2}, alpha_cs{2});

    rpe(:, 1) = sqrt(sum((keypoints(:, :, 1) - xL_re_org).*(keypoints(:, :, 1) - xL_re_org), 1));
    rpe(:, 2) = sqrt(sum((keypoints(:, :, 2) - xR_re_org).*(keypoints(:, :, 2) - xR_re_org), 1));

    % assume if one dim is nan, then both are
    mask = ~isnan(xL_re_org(1, :));
    mean_rpe = mean(mean(rpe(mask, :)));

end