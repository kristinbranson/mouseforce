function [jointAngles, limbLengths] = calculateJointAngles(kpts, kptsIdxs)
    % kpts: 3xNxK, where K is the number of keypoints, and N is the number of frames.
    % kptsIdxs: 3 x L. L is the number of keypoint triplets to compute angles between.
    % 3 keypoints are needed to compute an angle, assume the middle keypoint is the joint
    % to measure the angle over.

    numLimbs = size(kptsIdxs, 2);
    numFrames = size(kpts, 2);
    limbs = zeros(3, numFrames, numLimbs, 2);

    for i_limbs = 1:numLimbs
        part1 = kpts(:, :, kptsIdxs(1, i_limbs)) - kpts(:, :, kptsIdxs(2, i_limbs));
        part2 = kpts(:, :, kptsIdxs(3, i_limbs)) - kpts(:, :, kptsIdxs(2, i_limbs));

        % cat on the 4th dim which shouldn't exist, which will create a new dimension
        limbs(:, :, i_limbs, :) = cat(4, part1, part2);
    end


    limbCross = zeros(3, numFrames, numLimbs);
    limbDot = zeros(numFrames, numLimbs);
    jointAngles = zeros(numFrames, numLimbs);
    limbLengths = zeros(2, numFrames, numLimbs);


    for i_limbs = 1:numLimbs
        limbCross(:, :, i_limbs) = cross(limbs(:, :, i_limbs, 1), limbs(:, :, i_limbs, 2), 1);
        limbDot(:, i_limbs) = dot(limbs(:, :, i_limbs, 1), limbs(:, :, i_limbs, 2), 1);

        limbs(:, :, i_limbs, :) = cat(4, part1, part2);
        for i_frames = 1:numFrames
            jointAngles(i_frames, i_limbs) = rad2deg(atan2( ...
                norm(limbCross(:, i_frames, i_limbs)), ...
                limbDot(i_frames, i_limbs)));

            limbLengths(1, i_frames, i_limbs) = norm(limbs(:, i_frames, i_limbs, 1));
            limbLengths(2, i_frames, i_limbs) = norm(limbs(:, i_frames, i_limbs, 2));
        end
    end

end