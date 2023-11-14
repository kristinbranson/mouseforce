function [oms, Ts] = convertOptimExtrinsicsVec2OMT(numViews, extrinsicVecs)

    oms = cell(numViews, numViews);
    Ts = cell(numViews, numViews);

    % extrinsicsVec contains the extrinsic parameters between camera 1 and the
    % rest of the cameras
    for i = 2:numViews
        startIdx = (i-2) * 6 + 1;

        oms{1,i} = extrinsicVecs(startIdx:startIdx+2);
        Ts{1,i} = extrinsicVecs(startIdx+3:startIdx+5);
    end


    % build the extrinsic information between cameras ij where i is not camera 1
    for i = 2:numViews
        for j = i+1:numViews
            % construct the extrinsc from camera i to camera 1, compose with
            % camera 1 to camera j
            R_i1 = rodrigues(-oms{1,i});
            R_1j = rodrigues(oms{1,j});
            R_ij = R_1j * R_i1;

            T_i1 = -R_i1 * Ts{1, i};
            T_ij = R_1j * T_i1 + Ts{1,j};
            
            oms{i,j} = rodrigues(R_ij);
            Ts{i,j} = T_ij;
        end
    end
end