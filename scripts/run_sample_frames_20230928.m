% helper script to sample frames during trials.
% try to sample one or 2 frames per trial for now. fill in later with extra
% labels.
matFileDir = '/groups/branson/bransonlab/DataforAPT/JumpingMice/2023_08_VgatCtx_avgc50Plus_backToFibers_mats';

% load all the data, then sample frames based on platform distance, as a
% surrogate for variety of appearances.
platDistsMatNames = dir(fullfile(matFileDir, '*Distance.mat'));
trialsMatNames = dir(fullfile(matFileDir, '*trials.mat'));

totalDays = 4;
totalMice = 2;

platDistsMatNames = sort({platDistsMatNames.name});
platDistsMatNames = reshape(platDistsMatNames, totalMice, totalDays);
trialsMatNames = sort({trialsMatNames.name});
trialsMatNames = reshape(trialsMatNames, totalMice, totalDays);

% load the desired subset of data.
mice = [2];
days = [1, 2, 3, 4];

platDistsMats = cell(length(mice), length(days));
trialsMats = cell(length(mice), length(days));
numberTrials = zeros(length(mice), length(days));
trialStartStops = cell(length(mice), length(days));

jump_trials = cell(length(mice), length(days)); 
plat_dists = cell(length(mice), length(days));

for i = 1:length(mice)
    for j = 1:length(days)
        jump_trials{i, j} = load(fullfile(matFileDir, trialsMatNames{mice(i), days(j)})); 
        jump_trials{i, j}.x = jump_trials{i, j}.x(:)';
        plat_dists{i, j} = load(fullfile(matFileDir, platDistsMatNames{mice(i), days(j)})); 
        platDistsMats{i, j} = load(fullfile(matFileDir, platDistsMatNames{mice(i), days(j)})).x;
        trialsMats{i, j} = load(fullfile(matFileDir, trialsMatNames{mice(i), days(j)})).x;
        trialStartStops{i,j} = get_trial_startstop(trialsMats{i,j});
        numberTrials(i,j) = size(trialStartStops{i,j}, 2);
    end
end

numSamples = 200;
%[movieIndices, sampledFrameIndices] = sampleMouseForceTrials(trialsMats, trialStartStops, platDistsMats, numSamples, 1);
num_samples = 200;
[movie_indices, sampled_frame_indices] = sample_mouse_force_trials(jump_trials, plat_dists, num_samples, 1)

% get the names out in a more human friendly format.
%sorted_movie_ids = cell(1, num_movies);
sorted_frame_nums = cell(1, 4);

for i = 1:length(movie_indices)
    num_sampled_in_bin = length(movie_indices{i});
    for j = 1:num_sampled_in_bin
        sorted_frame_nums{movie_indices{i}(j)}(end+1) = sampled_frame_indices{i}(j);
    end
end

% finished organizing by movie, next sort by frame order.
out_dir = '/groups/branson/bransonlab/kwaki/ForceData/examples/20230928_avgc52sample';
if ~exist(out_dir, 'dir')
    mkdir(out_dir)
end
fid = fopen(fullfile(out_dir, 'sampled_frames.txt'), 'w');
for i=1:length(sorted_frame_nums)
    sorted_frame_nums{i} = sort(sorted_frame_nums{i});
    for j = 1:length(sorted_frame_nums{i})
        fprintf(fid, 'day%d_avgc%d\t%d\n', days(i), 52, sorted_frame_nums{i}(j));
    end
end
fclose(fid);
