function loss = fmin_multidlt(extrinsic_params, keypoints, fc_s, cc_s, kc_s, alpha_cs)

    num_views = length(fc_s);

    % create the projection matrix
    proj_mats = cell(num_views, 1);
    proj_mats{1} = [eye(3), zeros(3, 1)];
    start_idx = 1;
    oms = cell(3, 1);
    Ts = cell(3, 1);
    for i = 2:num_views;
        om = extrinsic_params(start_idx:start_idx+3-1);
        T = extrinsic_params(start_idx+3:start_idx+6-1);
        oms{i} = om;
        Ts{i} = T;

        proj_mats{i} = [rodrigues(om), T];
        start_idx = start_idx + 6;
    end

    % triangulated points are in view 1's frame of reference.
    triangulated = multiDLT(keypoints, proj_mats, fc_s, cc_s, kc_s, alpha_cs);

    % for each view, compute the reprojection error
    errs = zeros(num_views,1);
    for i = 1:num_views
        om = rodrigues(proj_mats{i}(:, 1:3));
        T = proj_mats{i}(:, 4);
        projected = project_points2(triangulated, om, T, ...
            fc_s{i}, cc_s{i}, kc_s{i}, alpha_cs{i});

        % assume if a nan in one dim, in both
        mask = ~isnan(keypoints(1, :, i)) & ~isnan(projected(1, :));
        assert(all(~isnan(projected(1, mask)) & ~isnan(keypoints(1, mask, i))));

        %errs(i) = mean(sqrt(sum((projected(:, mask) - keypoints(:, mask, i)).^2, 1)));
        errs(i) = sum(sqrt(sum((projected(:, mask) - keypoints(:, mask, i)).^2, 1)));
    end

    % for each pair of views, compute the stereo reprojection and its error.
    % pairwise_errors = zeros(num_views, num_views);
    for i = 1:num_views
        for j = (i+1):num_views
            % if i is 1, then this is the first view. the first view extrinsics
            % are available in the proj mat.
            if i==1
                om = oms{j};
                T = Ts{j};
            else
                % else, need to build the extrinsic information from existing info.
                Ri1 = rodrigues(-oms{i});
                Ti1 = -Ri1 * Ts{i};
                Rij = rodrigues(oms{j}) * Ri1;

                om = rodrigues(Rij);
                T = rodrigues(oms{j}) * Ti1 + Ts{j};
            end

            [XL, XR] = stereo_triangulation( ...
                keypoints(:, :, i), keypoints(:, :, j), ...
                om, T, ...
                fc_s{i}, cc_s{i}, kc_s{i}, alpha_cs{i}, ...
                fc_s{j}, cc_s{j}, kc_s{j}, alpha_cs{j});

            projected = project_points2(XL, zeros(size(om)), zeros(size(T)), ...
                fc_s{i}, cc_s{i}, kc_s{i}, alpha_cs{i});
    
            mask = ~isnan(keypoints(1, :, i)) & ~isnan(projected(1, :));
            assert(all(~isnan(projected(1, mask)) & ~isnan(keypoints(1, mask, i))));
            pairwise_errors(i,j) = sum(sqrt(sum((projected(:, mask) - keypoints(:, mask, i)).^2, 1)));

            projected = project_points2(XR, zeros(size(om)), zeros(size(T)), ...
                fc_s{j}, cc_s{j}, kc_s{j}, alpha_cs{j});


            mask = ~isnan(keypoints(1, :, j)) & ~isnan(projected(1, :));
            assert(all(~isnan(projected(1, mask)) & ~isnan(keypoints(1, mask, j))));
            pairwise_errors(i,j) = pairwise_errors(i,j) + sum(sqrt(sum((projected(:, mask) - keypoints(:, mask, j)).^2, 1)));
            % if i == 1 && j == 2
            %     pairwise_errors(i,j) = .4 * pairwise_errors(i,j);
            % end
        end
    end

    %loss = sum(pairwise_errors(:));
    loss = sum(errs) + sum(pairwise_errors(:));
    %loss = .95 * errs(1) + errs(2) + errs(3);
    %loss = .95 * errs(1) + errs(2) + errs(3) + sum(pairwise_errors(:));
    %loss = errs(1) + errs(2) + errs(3);
end