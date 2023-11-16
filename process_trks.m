baseDir = "/groups/branson/bransonlab/DataforAPT/JumpingMice/2023_08_VgatCtx_avgc50Plus_backToFibers";
%trkNames = dir(fullfile(baseDir, "day4_avgc50_*_label_file_trained_back_mdn_joint_fpn.trk"));
trkNames = dir(fullfile(baseDir, "day4_avgc50_*20230929_merged*.trk"));
trkNames = cellfun(@(x) fullfile(baseDir, x), {trkNames.name});

%calibrationMatFileName = '/groups/branson/bransonlab/kwaki/ForceData/calibration/current/multicam.mat';
calibrationMatFileName = '/groups/branson/bransonlab/kwaki/ForceData/outputs/improvingcalibration/20230920_updatecalibration/new/multi_calib.mat';
multicam = load(calibrationMatFileName).multicam;

outDir = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231010_jasonoutputs';

trks = cell(3, 1);
ptrks = cell(3, 1);
occlusionTags = cell(3, 1);
for i = 1:3
    trks{i} = load(trkNames{i}, '-mat');
    ptrks{i} = trks{i}.pTrk{1};
    occlusionTags{i} = trks{i}.pTrkTag{1};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEBUG
DEBUG = false;
nkpt = size(ptrks{1}, 1);
nvw = 3;
ptrk_reshaped = cell(nvw, 1);
temp_permuted = cell(nvw, 1);
temp_occlusion = cell(nvw, 1);
for i = 1:nvw
    nfrm = size(ptrks{i}, 3);
    temp_permuted{i} = permute(ptrks{i},[2 3 1]);
    ptrk_reshaped{i} = reshape(permute(ptrks{i},[2 3 1]),2,nfrm*nkpt); % coord, frm*pt

    temp_occlusion{i} = occlusionTags{i}';
    occlusionTag_reshaped{i} = reshape(occlusionTags{i}',1,nfrm*nkpt); % coord, frm*pt

    if DEBUG == true
        nfrm = 50000;
        temp_permuted{i} = temp_permuted{i}(:, 1:nfrm, :);
        ptrk_reshaped{i} = reshape(permute(temp_permuted{i},[2 3 1]),2,nfrm*nkpt); % coord, frm*pt

        temp_occlusion{i} = occlusionTags{i}';
        temp_occlusion{i} = temp_occlusion{i}(1:nfrm, :);
        occlusionTag_reshaped{i} = reshape(temp_occlusion{i},1,nfrm*nkpt); % coord, frm*pt
    end
end
allPermuted = cat(4,temp_permuted{:});
allPtrks = cat(3,ptrk_reshaped{:});
allOcclusionTags = cat(3,occlusionTag_reshaped{:});
occPermuted = cat(3, temp_occlusion{:});

% construct projection matricies between the cameras.
% use the first camera as source/world frame of reference.
all_projections = cell(nvw,1);
all_projections{1} = [eye(3), zeros(3, 1)];

fc_s = cell(nvw,1);
cc_s = cell(nvw,1);
kc_s = cell(nvw,1);
alpha_cs = cell(nvw,1);

fc_s{1} = multicam.crigStros{1,2}.int.L.fc;
cc_s{1} = multicam.crigStros{1,2}.int.L.cc;
kc_s{1} = multicam.crigStros{1,2}.int.L.kc;
alpha_cs{1} = multicam.crigStros{1,2}.int.L.alpha_c;

for i=2:nvw
    all_projections{i} = [multicam.crigStros{1,i}.R.LR,multicam.crigStros{1,i}.TLR];
    fc_s{i} = multicam.crigStros{1,i}.int.R.fc;
    cc_s{i} = multicam.crigStros{1,i}.int.R.cc;
    kc_s{i} = multicam.crigStros{1,i}.int.R.kc;
    alpha_cs{i} = multicam.crigStros{1,i}.int.R.alpha_c;
end

% use all points
tic
X = multiDLT(allPtrks, all_projections, fc_s, cc_s, kc_s, alpha_cs);
X = reshape(X,[3 nfrm nkpt]); % npt x 3 x nfrm
toc
% use only visible.
masked = allPtrks([allOcclusionTags; allOcclusionTags]);
tic
Xmasked = multiDLT(allPtrks, all_projections, fc_s, cc_s, kc_s, alpha_cs);
%Xmasked = permute(reshape(Xmasked,[3 nfrm nkpt]),[3 1 2]); % npt x 3 x nfrm
Xmasked = reshape(Xmasked,[3 nfrm nkpt]); % npt x 3 x nfrm
toc


% always use 2 views for certain points.
% mask heuristic
% compute the points using only visible points.
tic
Xheurstic = triangulateHeuristic(allPermuted, all_projections, fc_s, cc_s, kc_s, alpha_cs, occPermuted);
toc


kptNames = { ...
    'tail', 'nose', 'mouth', ...
    'r_paw', 'r_toe', 'r_ankle', 'r_knee', ...
    'l_paw', 'l_toe', 'l_ankle', 'l_knee', ...
    'chest' ...
};
kpt2Idx = @(x) (find(strcmp(kptNames, x)));


save(fullfile(outDir, 'triangulated.mat'), 'X', 'Xheurstic', 'Xmasked', 'kptNames', 'kpt2Idx');

% % heurstic based on best reprojection error.
% disp('best rpe triangulate');
% tic
% X = bestRPETriangulate(allPtrks, all_projections, fc_s, cc_s, kc_s, alpha_cs, allOcclusionTags);
% toc


% plot reprojections
movieNames = { ...
    '/groups/branson/bransonlab/DataforAPT/JumpingMice/2023_08_VgatCtx_avgc50Plus_backToFibers/day4_avgc50_2023_08_18_12_32_32-002_0.avi', ...
    '/groups/branson/bransonlab/DataforAPT/JumpingMice/2023_08_VgatCtx_avgc50Plus_backToFibers/day4_avgc50_2023_08_18_12_32_32-002_1.avi', ...
    '/groups/branson/bransonlab/DataforAPT/JumpingMice/2023_08_VgatCtx_avgc50Plus_backToFibers/day4_avgc50_2023_08_18_12_32_32-002_2.avi' ...
};


movieReaders = cell(3,1);
for i = 1:length(movieNames)
    movieReaders{i} = VideoReader(movieNames{i});
end

% figure(100)
% clf
% set(gcf, 'Position', [200, 1000, 1300, 500]);

% numFrames = size(X, 2);
% for i=1:numFrames
%     frames = cell(3,1);
%     current_x = allPermuted(:, i, :, :);

%     if mod(i, 10000) == 0
%         figure(100)
%         clf
%     else
%         continue
%     end
%     for j=1:length(movieNames)
%         movieReaders{j}.CurrentTime = double(i - 1) / movieReaders{j}.FrameRate;
%         frames{j} = readFrame(movieReaders{j});
%         x_reproj = project_points2(squeeze(Xheurstic(:, i, :)), rodrigues(all_projections{j}(:, 1:3)), ...
%             all_projections{j}(:, 4), fc_s{j}, cc_s{j}, kc_s{j}, alpha_cs{j});

%         if mod(i, 10000) == 0
%             subplot(1,3,j);
%             imshow(frames{j})
%             hold on
            
%             plot(squeeze(current_x(1, :, :, j)), squeeze(current_x(2, :, :, j)), 'o')
%             plot(x_reproj(1,:), x_reproj(2,:), 'x')
%         end
%     end
%     if mod(i, 10000) == 0
%         waitforbuttonpress
%     end
% end

frame = readFrame(movieReaders{1});
temp = double(frame)/255;
tempEdge = edge(temp(:, :, 1));
