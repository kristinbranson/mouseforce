% add current matlab mouseforce path and subdirectories
%addpath(genpath('/groups/branson/home/kwaki/checkouts/mouseforce/3rd_party/'));
%addpath(genpath('/groups/branson/home/kwaki/checkouts/caltech_camera_calibration/'));

%addpath(genpath('/groups/branson/home/kwaki/checkouts/mouseforce/matlab/'));
%addpath(genpath('/groups/branson/home/kwaki/checkouts/APT'));

% TODO: make this script a function, take in a parameter to setup the matlab space for specific tasks
% if APT stuff
addpath('/groups/branson/home/kwaki/checkouts/APT');
APT.setpathsmart;
addpath(genpath(pwd));