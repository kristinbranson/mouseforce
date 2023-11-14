function multiCamCalibration = createCalRigNPairwiseCalibrated(calibFilenamesCellArray)
% createCalRigNPairwiseCalibrated helper function to create a CalRigNPairwiseCalibrated object to use with APT.
%
% Given a NxN, where N is the number of camears, cell array of
% CalRig2CamCaltech pairwise calibration filenames, merge and create a
% CalRigNPairwiseCalibrated object. The cell array should be arranged by
% camera ids. Ie, the CalRig2CamCaltech calibration object between cameras 1 and
% 2 should be cell (1, 2).
% 
% Inputs:
%   calibCellArray: NxN cell array of CalRig2CamCaltech calibration objects.
% Outputs:
%   multiCamCalibration: A CalRigNPairwiseCalibrated object for APT.
%

    [m, n] = size(calibFilenamesCellArray);
    % m and n should be the same, and represent the number of cameras in the
    % system.
    assert(m == n);
    
    calibCellArray = cell(n,n);
    for i = 1:n
        for j = 1:n
            if ~isempty(calibFilenamesCellArray{i,j})
                calibCellArray{i,j} = CalRig2CamCaltech(calibFilenamesCellArray{i,j});
            end
        end
    end

    % construct the calibration struct, the input to the CalRigNPairwiseCalibrated
    % constructor.
    calib_struct.nviews = n;
    calib_struct.calibrations = calibCellArray;

    multiCamCalibration = CalRigNPairwiseCalibrated(calib_struct);

end