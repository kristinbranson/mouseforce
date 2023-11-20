% compare videos

% rootdatadir = '/groups/branson/bransonlab/DataforAPT/JumpingMice/2023_08_VgatCtx_avgc50Plus_backToFibers_recorded';
% nc = 512;
% vidfiles = dir(fullfile(rootdatadir,'*mp4'));
% vidfiles = cellfun(@(x) fullfile(rootdatadir,x),{vidfiles.name},'Uni',0);

% vidfiles = {
%   '/groups/branson/bransonlab/DataforAPT/JumpingMice/2023_08_VgatCtx_avgc50Plus_backToFibers_split/day1_avgc56_2023_10_30_12_51_26-015_0.avi'
%   '/groups/branson/bransonlab/DataforAPT/JumpingMice/2023_08_VgatCtx_avgc50Plus_backToFibers_split/day3_avgc56_2023_11_06_11_34_02-001_0.avi'
%   '/groups/branson/bransonlab/DataforAPT/JumpingMice/2023_08_VgatCtx_avgc50Plus_backToFibers_split/cal_2023_10_27_15_34_58_0.avi'
%   };
vidfiles = {
  };
brighten = [1.5;1.5;1];
n = numel(vidfiles);

readframes = cell(size(vidfiles));
ims = cell(size(vidfiles));
for i = 1:n,
  readframe = get_readframe_fcn(vidfiles{i});
  ims{i} = min(1,brighten(i)*im2double(rgb2gray(readframe(1))));
end

clf;
if n <= 3,
  naxc = n;
  naxr = 1;
else
  naxc = ceil(sqrt(n));
  naxr = ceil(n/naxc);
end
hax = createsubplots(naxr,naxc,.025);
hax = hax(:);
for i = 1:n,
  imagesc(im{i},'parent',hax(i),[0,1]);
  axis(hax(i),'image');
  [~,fn] = fileparts(vidfile1);
  title(hax(i),fn,'Interpreter','none');
  hold(hax(i),'on');
end
colormap gray;
linkaxes(hax);

%% add a circle

hcirc = drawcircle;
htmp = {};
for k = 1:3,
  htmp{k} = drawellipse(hcirc.Center(1),hcirc.Center(2),0,hcirc.Radius,hcirc.Radius,'c','parent',hax(k));
end
delete(hcirc);

%% add a polygon

hpoly = drawpolyline;
htmp = {};
for k = 1:3,
  htmp{k} = plot(hax(k),hpoly.Position(:,1),hpoly.Position(:,2),'g.-');
end
delete(hpoly)

%% find all lines

hlines = findobj(hax(2),'type','line');
xy = cell(numel(hlines),1);
color = cell(numel(hlines),1);
for k = 1:numel(hlines),
  xy{k} = cat(1,get(hlines(k),'XData'),get(hlines(k),'YData'));
  color{k} = get(hlines(k),'Color');
end

%% plot all lines

for l = 1:3,
  hold(hax(l),'on');
  for k = 1:numel(xy),
    plot(hax(l),xy{k}(1,:),xy{k}(2,:),'color',color{k});
  end
end