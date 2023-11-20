% rawfiles,outfiles = split_video_list(...)
% optional arguments:
% defaultdir: starting location for choosing videos to process. default
% value: '.'
% nc: number of columns in each video piece. default: 512
% nr: number of rows in video. default: 512
% qual: quality of jpeg compression. see ffmpeg for details. default: 3
% overwrite: whether to overwrite existing files (true), or skip (false).
% default: false.
% ffmpegpath: path to ffmpeg. default: ffmpeg
% debug: whether to only output commands to command window (true) or run
% the commands (false). default: false
% usecluster: whether to use the cluster to parallelize. probably should
% only be done on Linux. default: false. 
function [rawfiles,outfiles] = split_video_list(varargin)

[defaultdir,nc,nr,qual,overwrite,ffmpegpath,DEBUG,usecluster,rawfiles] = myparse(varargin,...
  'defaultdir','.','nc',512,'nr',512,'qual',3,'overwrite',false,...
  'ffmpegpath','ffmpeg','debug',false,'usecluster',false,'rawfiles',{});

outfiles = {};

while true,

  rawfiles = uipickfiles('FilterSpec',fullfile(defaultdir,'*.mp4'),'append',rawfiles);
  if isempty(rawfiles),
    fprintf('No files selected.\n');
    return;
  end
  fprintf('Process the following files: \n');
  fprintf('%s\n',rawfiles{:});
  res = input('y/n? [y]: ','s');
  if isempty(res) || res == 'y' || res == 'Y',
    break;
  end
end

while true,
  fprintf('Select one of the following:\n');
  fprintf('1: Output in the same directory as the original video\n');
  fprintf('2: Choose an output directory\n');
  res = input('Choose option 1/2 [1]: ');
  if isempty(res)
    res = 1;
  end
  if res == 1,
    outdir = 0;
  elseif res == 2,
    outdir = uigetdir(defaultdir);
  else
    continue;
  end
  break;
end

if ischar(outdir) && ~exist(outdir,'dir'),
  mkdir(outdir);
end

outfiles = cell(numel(rawfiles),3);

for i = 1:numel(rawfiles),
  fprintf('Processing video %d / %d: %s\n',i,numel(rawfiles),rawfiles{i});
  [p,n] = fileparts(rawfiles{i});
  if ischar(outdir),
    p = outdir;
  end
  for j = 0:2,
    fprintf('View %d...\n',j);
    outfile = fullfile(p,sprintf('%s_%d.avi',n,j));
    outfiles{i,j+1} = outfile;
    if exist(outfile,'file'),
      if overwrite,
        fprintf('Overwriting\n');
      else
        fprintf('Exists, skipping\n');
        continue;
      end
    end
    cmd = sprintf('%s -i "%s" -vf "crop=%d:%d:%d:0" -c:v mjpeg -q:v %d "%s"',...
      ffmpegpath,rawfiles{i},nc,nr,j*nc,qual,outfile);
    if usecluster,
      basecmd = cmd;
      bsuboutfile = fullfile(p,sprintf('%s_%d.out',n,j));
      bsubcmd = sprintf('bsub -n 1 -o "%s" -R"affinity[core(1)]" "%s"',...
        bsuboutfile,String.escapeQuotes(basecmd));
      sshcmd = sprintf('ssh login1 "%s"',String.escapeQuotes(bsubcmd));
      cmd = sshcmd;
    end
    fprintf('%s\n',cmd);
    if ~DEBUG,
      system(cmd);
    end
  end
end