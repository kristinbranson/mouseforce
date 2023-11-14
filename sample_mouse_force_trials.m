function [movie_indices, sampled_frame_indices] = sample_mouse_force_trials(jump_trials, platform_distances, num_samples, DEBUG)
% sample_mouse_force_trials samples frames to label in the jumping mouse force experiments
% 
% Samples frames from a jumping trial using jump trial indices and platform
% distances. Optionally provide the number of frames to sample.
% 
% Inputs:
%   jump_trials: a list of structs single field 'x'. x is a 1xN array with ones
%       where a jump trial is occuring, and 0 otherwise. This struct is the
%       output of loading a jumptrail mat file (same matfile that can be
%       provided to APT custom data).
%   platform_distances: a list of structs with a sinngle field, 'x'. x is a 1xN
%       array of distances. This struct is the output of loading a platform
%       distance mat file.
%   num_samples: optional, defualt is 1000. Number of total frames to sample.
% Outputs:
%   movie_index: 1 x num_samples array of indices into the jump trails list.
%       Represents movie index.
%   sampled_frame_index: 1 x num_samples array of frame indices.
%
% Example usage:
%   jump_trials{1} = load('/nrs/branson/kwaki/jumping_data/202210_set1/2022_04_VglutStGtacr1_thal_stm3to5/day1_stm3_trials.mat');
%   jump_trials{2} = load('/nrs/branson/kwaki/jumping_data/202210_set1/2022_04_VglutStGtacr1_thal_stm3to5/day2_stm3_trials.mat');
%   jump_trials{3} = load('/nrs/branson/kwaki/jumping_data/202210_set1/2022_04_VglutStGtacr1_thal_stm3to5/day3_stm3_trials.mat');
%   platform_distances{1} = load('/nrs/branson/kwaki/jumping_data/202210_set1/2022_04_VglutStGtacr1_thal_stm3to5/day1_stm3_platformDistance.mat');
%   platform_distances{2} = load('/nrs/branson/kwaki/jumping_data/202210_set1/2022_04_VglutStGtacr1_thal_stm3to5/day2_stm3_platformDistance.mat');
%   platform_distances{3} = load('/nrs/branson/kwaki/jumping_data/202210_set1/2022_04_VglutStGtacr1_thal_stm3to5/day3_stm3_platformDistance.mat');
%   num_samples = 1000;
%   [movie_index, sampled_frame_index] = sample_mouse_force_trials(jump_trials, platform_distances, num_samples)

    if nargin < 3
        num_samples = 1000;
    end
    if nargin < 4
        DEBUG = false;
    end
    % hard coding number of bins to 10. for sampling this seems okay for now.
    num_bins = 10;
    num_movies = length(jump_trials);

    % create histograms of the platform distances.
    jump_trial_distances = cell(1, num_movies);
    rest_trial_distances = cell(1, num_movies);
    % in order to rebuild the data later, have a movie indexing variable
    movie_ids = cell(1, num_movies);
    jump_trial_frames = cell(1, num_movies);
    % save some indexing variables to help with the sampling.
    for i = 1:num_movies
        jump_trial_frames{i} = find(jump_trials{i}.x);
        jump_trial_distances{i} = platform_distances{i}.x(jump_trial_frames{i});
        rest_trial_distances{i} = platform_distances{i}.x(~logical(jump_trials{i}.x));
        movie_ids{i} = zeros(1, length(jump_trial_frames{i})) + i;
    end

    % optionally save the histograms to file
    cat_jump_trial_distances = [jump_trial_distances{:}];
    cat_jump_trial_frames = [jump_trial_frames{:}];
    cat_movie_ids = [movie_ids{:}];
    % histogram(cat_jump_trial_distances);
    % create a histogram to help sample. for now use automatically placed edges (may want to tweak this in the future.)
    [~, edges, bins] = histcounts(cat_jump_trial_distances, num_bins);

    % calculate number of samples per bin. may need to be weighted based on number of samples for each bin.
    % for now just take an even amount from each bin.
    % assume divisible for now...
    num_samples_per_bin = num_samples / num_bins;

    % not sure if this is the best structure to store things in. but might be useful for some downstream
    % processing to know what histogram bin each sample came from for some sanity checks.
    movie_indices = cell(num_bins, 1);
    sampled_frame_indices = cell(num_bins, 1);
    % loop over the bins, and sample frames from the bins.
    for i = 1:num_bins
        bin_idx = bins == i;
        %curr_jump_dists = jump_dists(bin_idx);
        curr_movie_ids = cat_movie_ids(bin_idx);
        curr_frame_nums = cat_jump_trial_frames(bin_idx);

        perm_idx = randperm(sum(bin_idx));

        if length(perm_idx) < num_samples_per_bin
            error('number frames to sample in a bin greater than number of frames in histogram bin');
        end

        movie_indices{i} = curr_movie_ids(perm_idx(1:num_samples_per_bin));
        sampled_frame_indices{i} = curr_frame_nums(perm_idx(1:num_samples_per_bin));
    end
end