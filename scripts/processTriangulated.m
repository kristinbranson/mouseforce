%% load triangulated points
triangulated = load('triangulated.mat');

% triangulated has 4 fields
% X          : Triangulated keypoints using all points
% Xmasked    : Triangulated keypoints using only non occluded points
% Xheurstic  : Triangulated keypoints using a heurstic where I guess the visible keypoints based on camera
% kptNames   : names of the keypoints
% kpt2Idx    : function to convert the names to index

% the keypoint names:
% 'tail'
% 'nose'
% 'mouth'
% 'r_paw'
% 'r_toe'
% 'r_ankle'
% 'r_knee'
% 'l_paw'
% 'l_toe'
% 'l_ankle'
% 'l_knee'
% 'chest'


% compute the angles between triangulated points
% angles for [right paw, right ankle, right knee] and [left paw, left ankle, left knee]
kptsIdxs = [[5,6,7]',[9,10,11]'];
[angles, lengths] = calculateJointAngles(triangulated.Xheurstic, kptsIdxs);


%% sanity debug plot
platDists = load('day4_avgc50_platformDistance.mat');
frameRange = 218471:222186;

figure(1)
clf
plot(frameRange, angles(frameRange, 1));
hold on
plot(frameRange, angles(frameRange, 2));
ylabel("Degrees")


yyaxis right
plot(frameRange, platDists.x(frameRange));
ylabel("Millimeters")
