function extrinsics = convertRodT2OptimExtrinsicsVec(oms, Ts)
    % assume oms is numViews x 3 dimensional array
    numViews = size(oms, 1);

    % extrinsic vector is (numViews - 1) * 6 dimensional vector. The first view
    % is missing because for the optimization, the extrinsic transformation from
    % camera 1 to camera 1 isn't needed. It can be useful to have the extrinsic
    % transformation from camera 1 to camera 1 for reprojecting points.
    extrinsics = zeros((numViews -1) * 6, 1);
    for i = 2:numViews
        startRod = (i-2)*(3+3) +1;
        stopRod = startRod+2; % 
        extrinsics(startRod:stopRod) = oms(i, :);

        startT = stopRod+1;
        stopT = startT+2;
        extrinsics(startT:stopT) = Ts(i, :);
    end

end