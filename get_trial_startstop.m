function trial_idx = get_trial_startstop(trial_data)

    diffs = diff(trial_data);
    % start of a bout should be where diffs == 1. and the end of a bout should
    % be where diffs == -1. There are some edge cases to look for.
    start_idx = find(diffs == 1) + 1; % add one because the diffs gives us the frame before the first 1 of a bout.
    end_idx = find(diffs == -1);
    
    % if the first start_idx is after the first end_idx, then the first frame is
    % the start of the bout
    if start_idx(1) > end_idx(1)
        start_idx = [1, start_idx];
    end
    % if the last start_idx is after than the end_idx, then the last frame is the
    % last end of the last bout.
    if start_idx(end) > end_idx(end)
        end_idx = [end_idx, 1];
    end

    trial_idx = [start_idx; end_idx];

end