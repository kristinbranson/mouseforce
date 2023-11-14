function points = reshapeTableLabels(tableLbl)
% table points from APT are in a linear format, and a bit awkward to use. in a
% multiview project, p is number of frames x number of keypoints x number of views x number of dimensions(2)
% assumes the number of dimensions for a label keypoint is 2 (x,y image space coordinates.) 
    numFrames = size(tableLbl.frm, 1);
    numViews = size(tableLbl.mov, 2);
    numKeypoints = size(tableLbl.p, 2) / 2 / numViews;

    % rebuild the points into num view chunks...
    % order of points is frames x (num keypoints, num_views, 2)
    % ie: frame1: x1 v1, x2 v1, x3 v1, x4 v1, ..., x1v2, x2v2, x3v2, ..., y1 v1, y2v1, ...
    points = reshape(tableLbl.p, numFrames, numKeypoints, numViews, 2);
end