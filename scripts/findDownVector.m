% first attempt at defining a down vector. this also kind of defines the
% coordinate frame of reference for the system.

% baseDir = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231011_finddownwardvector';

% %% load calibration file
% % going to use avgc 50 day 4 for analysis. i hand labeled the head plate on
% % a day 4 video (and exported the labels). So will need the calibration for
% % day 4.
% multicam = load(fullfile(baseDir, 'multicam.mat'));
% multicam = multicam.multicam;

% tblLbls = load(fullfile(baseDir, 'temp/gravity_labels.mat'));
% tblLbls = tblLbls.tblLbls;
baseDir = '/groups/branson/bransonlab/kwaki/ForceData/outputs/20231023_avgc50day4avgc52day3_eval/avgc52day3';

%% load calibration file
% going to use avgc 50 day 4 for analysis. i hand labeled the head plate on
% a day 4 video (and exported the labels). So will need the calibration for
% day 4.
multicam = load(fullfile(baseDir, 'multi_calib.mat'));
multicam = multicam.multicam;

tblLbls = load(fullfile(baseDir, 'gravity_labels.mat'));
tblLbls = tblLbls.tblLbls;



%% build the plane vector
points = reshapeTableLabels(tblLbls);
[numFrames, numKpts, numViews] = size(points, 1:3);

% permute the points to be easier to use with DLT
% change to be dims x kpts x frames x views
points = permute(points, [4, 1, 2, 3]);
% use one frame of the keypoints, use only 4 keypoints (and 5th being the nose)
points = squeeze(points(:, 1, 1:5, :));

% triangulate points
[projMats, fcs, ccs, kcs, alpha_cs] = constructCaltechCalibInfo(multicam);
[oms, Ts] = convertProjMat2RodT(projMats);
triangulated = multiDLT(points, projMats, fcs, ccs, kcs, alpha_cs);

% mid point of the head plate
midPoint=mean(triangulated,2);

% compute vector perpendicular to the plane (plot to make sure it points down
% and not up)
v1=triangulated(:,4)-triangulated(:,1);
v1=v1/norm(v1);
v2=triangulated(:,2)-triangulated(:,1);
v2=v2/norm(v2);

pVecDir=cross(v1,v2);
pVecDir=pVecDir/norm(pVecDir)*10;
pVec=pVecDir+triangulated(:,1);

% construct another perpendicular vector
v2perpDir=cross(pVecDir,v1);
v2perpDir=v2perpDir/norm(v2perpDir)*4;
v2perpVec=v2perpDir+triangulated(:,1);


% rotate the plane vector 35 degrees
rotatedDir=cosd(35)*pVecDir + sind(35)*(cross(v1,pVecDir));
rotatedDir=rotatedDir/norm(rotatedDir)*10;
rotatedVec=rotatedDir+midPoint(:,1);
downDir=rotatedDir/norm(rotatedDir);

nose3D = triangulated(:, 5);

save('downDir.mat', 'downDir', 'nose3D');
% construct the new plane vector
pNewDir=cross(rotatedDir,v1);
pNewDir=pNewDir/norm(pNewDir)*10;
pNewVec=pNewDir+triangulated(:,1);


%% check the labels.
movieFilenames = cell(numViews, 1);
movieReaders = cell(numViews, 1);
for i=1:numViews
   movieFilenames{i} = tblLbls.mov{1,i};
   movieReaders{i} = VideoReader(movieFilenames{i});
end


downVec = downDir*30+nose3D;

figure(1000);
clf
set(gcf,'position',[421,662,2030,748]);
for i=1:numFrames

    if ~strcmp(movieFilenames{1},  tblLbls.mov{i,1})
        for j=1:numViews
            movieFilenames{j}=tblLbls.mov{i,j};
            movieReaders{j} = VideoReader(movieFilenames{i});
        end
    end

    currFrameNum=double(tblLbls.frm(i)-1);
    for j=1:numViews
        movieReaders{j}.CurrentTime = currFrameNum / movieReaders{j}.FrameRate;
        frame = readFrame(movieReaders{j});

        subplot(1,numViews,j)
        imshow(frame)
        hold on
        % plot(points(1,:,j),points(2,:,j),'o');

        % projected = project_points2(triangulated, oms(j,:), Ts(j,:)', ...
        %     fcs{j}, ccs{j}, kcs{j}, alpha_cs{j});

        % if j == 1
        %     plot(projected(1,1:2),projected(2,1:2),'b-o', 'markersize',5,'linewidth',2);
        % elseif j == 2
        %     plot(projected(1,3:4),projected(2,3:4),'bo', 'markersize',5,'linewidth',2);
        % else
        %     plot(projected(1,:),projected(2,:),'bo', 'markersize',5,'linewidth',2);
        % end

        % % % midPointProj = project_points2(midPoint, oms(j,:), Ts(j,:)', ...
        % % %     fcs{j}, ccs{j}, kcs{j}, alpha_cs{j});

        % % % plot(midPointProj(1,1),midPointProj(2,1),'cx');

        % pVecProj = project_points2(pVec, oms(j,:), Ts(j,:)', ...
        %     fcs{j}, ccs{j}, kcs{j}, alpha_cs{j});

        % plot(pVecProj(1,:),pVecProj(2,:),'ro','markersize',5,'linewidth',2);
        % plot([projected(1,1),pVecProj(1,:)],[projected(2,1),pVecProj(2,:)],'r','markersize',5,'linewidth',2);

        % % % % v2=project_points2(v2perpVec, oms(j,:), Ts(j,:)', ...
        % % % %     fcs{j}, ccs{j}, kcs{j}, alpha_cs{j});

        % % % % plot(v2(1,:),v2(2,:),'rx');


        % rot=project_points2(rotatedVec, oms(j,:), Ts(j,:)', ...
        %     fcs{j}, ccs{j}, kcs{j}, alpha_cs{j});
        % plot(rot(1,:),rot(2,:),'gx','markersize',5,'linewidth',2);


        % planeVec=project_points2(pNewVec, oms(j,:), Ts(j,:)', ...
        %     fcs{j}, ccs{j}, kcs{j}, alpha_cs{j});

        % plot([rot(1,:),projected(1,1),planeVec(1)],[rot(2,:),projected(2,1),planeVec(2)],'g','markersize',5,'linewidth',2);
        % %plot(planeVec(1),planeVec(2),'cx');

        noseReproj = project_points2(nose3D, oms(j,:), Ts(j,:)', ...
            fcs{j}, ccs{j}, kcs{j}, alpha_cs{j});
        downReproj = project_points2(downVec, oms(j,:), Ts(j,:)', ...
            fcs{j}, ccs{j}, kcs{j}, alpha_cs{j});

        plot([noseReproj(1),downReproj(1)],[noseReproj(2),downReproj(2)],'g','markersize',5,'linewidth',2);
        % % %plot(planeVec(1),planeVec(2),'cx');

    end
    break
end