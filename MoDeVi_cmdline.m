function MoDeVi_cmdline( cfg )
% MODEVI_CMDLINE 
%
% Use as
%   MoDeVi_cmdline( cfg )
%
% The configuration options are
%   cfg.srcPath     = path to video, (default: [])
%   cfg.ROI1        = [x0 y0 width height], (default: [1 1 1920 1080])
%   cfg.ROI2        = [x0 y0 width height], (default: [1 1 1920 1080])
%   cfg.baseROI     = [x0 y0 width height], (default: [1720 1 200 200])
%   cfg.selROI1     = true or false, (default: true)
%   cfg.selROI2     = true or false, (default: true)
%   cfg.selbaseROI  = true or false, (default: true)
%
% NOTE: The regions of interest have to be within the image. Therefore it
% is recommended to check the validity of the regions with MoDeVi_gui 
% first. It is only necessary to specify the coordinates and dimensions for
% regions of interest which are selected. If no srcPath is specified, the
% function will display a selection window first.
%
% NOTE: Only wmv videos are supported

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------
MoDeVi_init;

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
srcPath       = MoDeVi_getopt(cfg, 'srcPath', []);
ROI1          = MoDeVi_getopt(cfg, 'ROI1', [1 1 1920 1080]);
ROI2          = MoDeVi_getopt(cfg, 'ROI2', [1 1 1920 1080]);
baseROI       = MoDeVi_getopt(cfg, 'baseROI', [1720 1 200 200]);
selROI1       = MoDeVi_getopt(cfg, 'selROI1', true);
selROI2       = MoDeVi_getopt(cfg, 'selROI2', true);
selbaseROI    = MoDeVi_getopt(cfg, 'selbaseROI', true);

roi.dimension = {ROI1, ROI2, baseROI};
roi.selected = [selROI1 selROI2 selbaseROI];
roi.description = {'first', 'second', 'base'};

% -------------------------------------------------------------------------
% Load video and check options
% -------------------------------------------------------------------------
% Check validity of source file specifications
if isempty(cfg.srcPath)
  [file, path] = uigetfile('*.wmv', 'Select video file...');                % select video
  srcPath = [path file];
end

if ~contains(srcPath, '.wmv')
   cprintf([1,0.5,0], 'Wrong format, only *.wmv files are supported.\n');
   return;
end

try
  VidObj = VideoReader( srcPath );                                          % try to get video handle
catch
  cprintf([1,0.5,0], 'The specified video file can not be loaded.\n');
  return;
end

if VidObj.Width == 0                                                        % if video has no valid frames
  cprintf([1,0.5,0], 'The specified video file can not be processed. Wrong libraries are used.\n');
  cprintf([1,0.5,0], 'Please start matlab as follows: MATLAB --patch stdc++\n');
  return;
end

% Check if at least one ROI is selected
if ~any(roi.selected)
  cprintf([1,0.5,0], 'No ROI was selected. Select at least one ROI');
  return;
end

% Check validity of ROI specifications
if selROI1                                                                  % first ROI
  if ~(length(ROI1) == 4)
    cprintf([1,0.5,0], 'Wrong ROI1 specification. Specify ROI1 = [x0 y0 width height]');
    return;
  end
  if ( ROI1(1) < 1 || (ROI1(1) + ROI1(3) - 1) > VidObj.Width || ...
        ROI1(2) < 1 || (ROI1(2) + ROI1(4) - 1) > VidObj.Height )
    cprintf([1,0.5,0], 'Wrong ROI1 dimension. ROI1 is not within the video image.');
    return;  
  end
end

if selROI2                                                                  % second ROI
  if ~(length(ROI2) == 4)
    cprintf([1,0.5,0], 'Wrong ROI2 specification. Specify ROI2 = [x0 y0 width height]');
  end
  if ( ROI2(1) < 1 || (ROI2(1) + ROI2(3) - 1) > VidObj.Width || ...
        ROI2(2) < 1 || (ROI2(2) + ROI2(4) - 1) > VidObj.Height )
    cprintf([1,0.5,0], 'Wrong ROI2 dimension. ROI2 is not within the video image.');
    return;
  end
end

if selbaseROI                                                               % baseline ROI
  if ~(length(baseROI) == 4)
    cprintf([1,0.5,0], 'Wrong baseROI specification. Specify baseROI = [x0 y0 width height]');
  end
  if ( baseROI(1) < 1 || (baseROI(1) + baseROI(3) - 1) > VidObj.Width || ...
        baseROI(2) < 1 || (baseROI(2) + baseROI(4) - 1) > VidObj.Height )
    cprintf([1,0.5,0], 'Wrong baseROI dimension. baseROI is not within the video image.');
    return;
  end
end

% Visual Check of settings
NewImg = readFrame(VidObj);
NewImg = GeneratePreview(roi, NewImg);                                      % Add regions of interest to first image of the video

warning off;
imshow(NewImg);
warning on;

selection = false;
while selection == false
  fprintf('\nDo you want to analyse the video by using the shown regions of interest?\n')
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    close(gcf);
  elseif strcmp('n', x)
    close(gcf);
    return;
  else
    selection = false;
  end
end

% -------------------------------------------------------------------------
% Main video processing
% -------------------------------------------------------------------------
VidObj.CurrentTime = 0;                                                     % reset Video Object
numOfFrames = ceil(VidObj.FrameRate * VidObj.Duration);                     % estimate approximate number of frames

motionSignal(1:3) = {zeros(1, numOfFrames)};                                % allocate memory for the motion signal 
time              = zeros(1, numOfFrames);                                  % allocate memory for the time vector

if hasFrame(VidObj)                                                   
  OldImg      = readFrame(VidObj);                                          % load first image
  frameNumber = 1;
end

f = waitbar(0, 'Data processing...',...                                     % display status bar with cancel button 
            'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
setappdata(f,'canceling',0);

while hasFrame(VidObj)                                                      % do as long as frames available
  NewImg      = readFrame(VidObj);                                          % get new frame
  frameNumber = frameNumber + 1;                                            % increase number of frames Counter
  sigPointer  = frameNumber - 1;                                            % determine pointer to current field of the motion signal vector
  timePointer = frameNumber - 1;                                            % determine pointer to current field of the time vector
  NewImage    = im2double(NewImg);                                          % convert pixel values into double format
  OldImage    = im2double(OldImg);
  NewImage    = rgb2gray(NewImage);                                         % convert images into a grayscale images
  OldImage    = rgb2gray(OldImage);

  for i=1:1:3                                                               % do it for all selected regions of interest
    if roi.selected(i) == true
      NewROI      = GetExcerpt(roi, NewImage, i);                           % extract the part of the image, wich is defined as region of interest
      OldROI      = GetExcerpt(roi, OldImage, i);    

      motionSignal{i}(sigPointer) = mean(mean((OldROI - NewROI).^2));       % estimate current value
    end
  end
  time(timePointer) = VidObj.CurrentTime;                                   % add current timestamp to time vector

  OldImg = NewImg;                                                          % copy current Image to variable containing the predecessor
  waitbar(frameNumber/numOfFrames, f, ...
            sprintf('Data processing (%d/%d)...', ...
                    frameNumber, numOfFrames));
  if getappdata(f,'canceling')
      break;                                                                % quit data processing, if cancel was pressed
  end
end

delete(f);                                                                  % delete status bar

% After the whole video processing was done
time = time(1:timePointer);                                                 %#ok<NASGU> % shrink time vector to its actual length                               
motionSignal{1} = motionSignal{1}(1:sigPointer);                            % shrink motion signal vector to its actual length
motionSignal{2} = motionSignal{2}(1:sigPointer);
motionSignal{3} = motionSignal{3}(1:sigPointer);                            %#ok<NASGU>

% save data 
address = srcPath(1:end-3);
address = [ address 'mat'];

uisave({'time', 'motionSignal', 'roi'}, address);                           % save time, motionSignal and roi into mat File

end

% -------------------------------------------------------------------------
% SUBFUNCTION: Generate preview image including ROIs
% -------------------------------------------------------------------------
function [image] = GeneratePreview(roi, image)

roiColorDef = [0, 255, 0; 255, 255, 0; 255, 0, 0];                          % frame colour specification

for i = 1:1:3
  if roi.selected(i) == true
    x0    = roi.dimension{i}(1);                                            % get roi parameters
    xEnd  = roi.dimension{i}(1) + roi.dimension{i}(3) - 1;
    y0    = roi.dimension{i}(2);
    yEnd  = roi.dimension{i}(2) + roi.dimension{i}(4) - 1;
    image(y0:yEnd, x0:x0+5, 1) = roiColorDef(i,1);                          % modify image
    image(y0:yEnd, x0:x0+5, 2) = roiColorDef(i,2);
    image(y0:yEnd, x0:x0+5, 3) = roiColorDef(i,3);
    image(y0:yEnd, xEnd-5:xEnd, 1) = roiColorDef(i,1);
    image(y0:yEnd, xEnd-5:xEnd, 2) = roiColorDef(i,2);
    image(y0:yEnd, xEnd-5:xEnd, 3) = roiColorDef(i,3);
    image(y0:y0+5, x0:xEnd, 1) = roiColorDef(i,1);
    image(y0:y0+5, x0:xEnd, 2) = roiColorDef(i,2);
    image(y0:y0+5, x0:xEnd, 3) = roiColorDef(i,3);
    image(yEnd-5:yEnd, x0:xEnd, 1) = roiColorDef(i,1);
    image(yEnd-5:yEnd, x0:xEnd, 2) = roiColorDef(i,2);
    image(yEnd-5:yEnd, x0:xEnd, 3) = roiColorDef(i,3);
  end
end

end

% -------------------------------------------------------------------------
% SUBFUNCTION: Get ROI part of image
% -------------------------------------------------------------------------
function [image] = GetExcerpt(roi, image, roiNum)                           % extract a region of interest of an image

x0    = roi.dimension{roiNum}(1);                                           % get roi parameters                   
xEnd  = roi.dimension{roiNum}(1) + roi.dimension{roiNum}(3) - 1;
y0    = roi.dimension{roiNum}(2);
yEnd  = roi.dimension{roiNum}(2) + roi.dimension{roiNum}(4) - 1;

image = image(y0:yEnd, x0:xEnd, :);                                         % resize image

end