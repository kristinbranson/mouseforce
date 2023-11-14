function convertPTRAPTLin2Win(aptLblPath, winBasePath, linBasePath)
    if nargin < 2
        winBasePath = 'X:\DataForAPT\JumpingMice\2022_04_VglutStGtacr1_thal_stm3to5\';
        linBasePath = '/groups/branson/bransonlab/DataforAPT/JumpingMice/2022_04_VglutStGtacr1_thal_stm3to5';
    end

    % apt files are tarballs. first untar and then load it.
    [outDir, ~, ~] = fileparts(aptLblPath);
    files = untar(aptLblPath, outDir);

    % assume only one file comes out of the untar
    lbl = load(files{1}, '-mat')

    % replace the paths in movieFilesAll and movieFilesAllGT
    [num_exps, num_views] = size(lbl.movieFilesAll);
    for i = 1:num_exps
        for j = 1:num_views
            % get basefile name (no path) and replace entry with the moviedir+basefilename
            split_path = strsplit(lbl.movieFilesAll{i, j}, '/');

            new_name = strcat(winBasePath, split_path{end});
            lbl.movieFilesAll{i, j} = new_name;
        end
    end

    [num_exps, num_views] = size(lbl.movieFilesAllGT);
    for i = 1:num_exps
        for j = 1:num_views
            % get basefile name (no path) and replace entry with the moviedir+basefilename
            %[filepath,name,ext] = fileparts(lbl.movieFilesAll{i, j});
            split_path = strsplit(lbl.movieFilesAllGT{i, j}, '/');

            new_name = strcat(winBasePath, split_path{end});
            lbl.movieFilesAllGT{i, j} = new_name;
        end
    end

    save(fullfile(outDir, 'label_file_modified.lbl'), '-mat', '-struct', 'lbl');
end