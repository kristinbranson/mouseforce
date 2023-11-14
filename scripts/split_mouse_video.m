% script to help convert videos from the dudman lab into a friednly codec
% and split views.
% splitting and saving on local drive (hoping this is faster than moving video frames between network drives).
movie_dir = '/home/kwaki@hhmi.org/scratch';
out_dir = '/home/kwaki@hhmi.org/scratch/split';

% for each video convert and split the videos.
% the videos in this set of folders are 500x500 glued together.
files = dir(fullfile(movie_dir, '*mp4'));
% remove first two files
base_width = 512;
num_views = 3;

for i = 1:length(files)
    if strcmp(files(i).name(end-2:end), 'mp4') ~= 1
        continue
    end

    disp(files(i).name);
    % create the out folder names
    vid_name = fullfile(movie_dir, files(i).name);
    vid_in = VideoReader(vid_name);
    total_frames = vid_in.Duration * vid_in.FrameRate;

    basename = files(i).name(1:end-4);
    writers = cell(num_views, 1);
    for j = 1:num_views
        out_name = fullfile(out_dir, [basename, '_', num2str(j-1), '.avi']);
        writers{j} = VideoWriter(out_name, 'Motion JPEG AVI');
        open(writers{j});
    end

    frame_num = 1;
    while(hasFrame(vid_in))
        if mod(frame_num, 500) == 1
            fprintf('%d of %d frames\n', frame_num, total_frames);
        end
        frame = readFrame(vid_in);
        for j = 1:num_views
            frame_crop = frame(:, (j-1)*512+1:j*512, :);
            writeVideo(writers{j}, frame_crop);
        end

        frame_num = frame_num + 1;
    end

    for j = 1:num_views
        close(writers{j});
    end
end
