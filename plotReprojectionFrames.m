function plotReprojectionFrames(movieFilenames, frames, keypoints, reprojected)

    for i=1:length(movieFilenames)
        movieReaders{i} = VideoReader(movieFilenames{i});
    end

    if length(reprojected) == 2
        markers = {'+', 'x'};
    else
        markers = cell(length(reprojected),1);
        markers(:) = {'x'};
    end

    figure(100);
    set(gcf, 'Position',[19 1400 2150 560]);
    for i=1:length(frames)
        clf
        for j=1:length(movieReaders)
            movieReaders{j}.CurrentTime = double(frames(i) - 1) / movieReaders{j}.FrameRate;
            frame = readFrame(movieReaders{j});
            subplot(1, 3, j);
            imshow(frame);
            hold on
            plot(squeeze(keypoints(1, i, :, j)), squeeze(keypoints(2, i, :, j)), 'o', 'markersize', 5, 'linewidth', 2);

            for k=1:length(reprojected)
                plot(squeeze(reprojected{k}(1, i, :, j)), squeeze(reprojected{k}(2, i, :, j)), markers{k}, 'markersize', 5, 'linewidth', 2);
            end
        end
    end

end