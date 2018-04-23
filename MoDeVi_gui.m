% MODEVI_GUI (Motion Detection from Video Data) offers a little graphical
% user interface which calculates a motion signal by analysing the changes
% in successive pictures of a video stream.
%
% Currently, only WMV video files are supported. The extracted motion
% signal and the corresponding time vector can be exported into a MAT file.
%
% IMPORTANT for MPI CBS staff members: Please start matlab with the 
% following command: MATLAB --syslibpatch. 
% Otherwise matlab cannot deal with the WMV format.
%
% SEE also VIDEOREADER, READFRAME

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Making the graphical user interface
% -------------------------------------------------------------------------

fig = uifigure;                                                             % figure
fig.Position = [100 300 1060 440];
fig.Name = 'Motion Detection from Videos';
fig.CloseRequestFcn = @(fig, event)CloseRequestFunction(fig);               % connect callback func CloseRequestFunction with figure

vid = uiaxes(fig);                                                          % element for displaying the video during the processing
vid.XTick = [];
vid.YTick = [];
vid.Position = [20 130 500 290];
vid.Visible = 'off';

sig = uiaxes(fig);                                                          % graph, wich shows the motion signal cource during 
sig.Position = [540 130 500 290];                                           % the video processing 
sig.XLim = [0 75];
%sig.YLim = [0 2*10^-4];

label = uilabel(fig);                                                       % text label, which displays the current frame number and
label.Position = [20 100 980 20];                                           % and the current motion value during video processing
label.Text = 'Status:';

roi = uilabel(fig);                                                         % text label for region of interest
roi.Position = [20 60 980 20];                                                
roi.Text = 'Region of interest:';

x0Label = uilabel(fig);                                                     % text label for x zero point of region of interest
x0Label.Position = [140 60 40 20];
x0Label.Text = 'x0:';

roiData.x0 = uieditfield(fig, 'numeric');                                   % numeric field, which contains the x zero point of 
roiData.x0.Position = [180 60 60 30];                                       % the region of interest 
roiData.x0.Value = 1;
roiData.x0.Limits = [1 1000];
roiData.x0.Enable = 'off';

y0Label = uilabel(fig);                                                     % text label for y zero point of region of interest
y0Label.Position = [260 60 40 20];
y0Label.Text = 'y0:';

roiData.y0 = uieditfield(fig, 'numeric');                                   % numeric field, which contains the y zero point of 
roiData.y0.Position = [300 60 60 30];                                       % the region of interest
roiData.y0.Value = 1;
roiData.y0.Limits = [1 1000];
roiData.y0.Enable = 'off';

widthLabel = uilabel(fig);                                                  % text label for the region of interest width
widthLabel.Position = [380 60 40 20];
widthLabel.Text = 'width:';

roiData.width = uieditfield(fig, 'numeric');                                % numeric field, which contains the region of interest 
roiData.width.Position = [420 60 60 30];                                    % width
roiData.width.Value = 1000;
roiData.width.Limits = [1 1000];
roiData.width.Enable = 'off';

heightLabel = uilabel(fig);                                                 % text label for the region of interest height
heightLabel.Position = [500 60 40 20];
heightLabel.Text = 'height:';

roiData.height = uieditfield(fig, 'numeric');                               % numeric field, which contains the region of interest 
roiData.height.Position = [540 60 60 30];                                   % height
roiData.height.Value = 1000;
roiData.height.Limits = [1 1000];
roiData.height.Enable = 'off';

start   = uibutton(fig);                                                    % start processing button
start.Position = [20 20 100 30];
start.Text = 'start';
start.Enable = 'off';

stop    = uibutton(fig);                                                    % stop processing button
stop.Position = [140 20 100 30];
stop.Text = 'stop';
stop.Enable = 'off';

save    = uibutton(fig);                                                    % save data button
save.Position = [260 20 100 30];
save.Text = 'save';
save.Enable = 'off';

load    = uibutton(fig);                                                    % load video button
load.Position = [940 20 100 30];
load.Text = 'load';
load.Enable = 'on';
load.UserData = struct('Width', 1000, 'Height', 1000, 'Image', []);

address = uieditfield(fig);                                                 % field, wich contains location and name of selected 
address.Position = [380 20 540 30];                                         % video file (editable)

motionSignal = 0;
time = 0;
roi = 0;

% Link callback functions
start.ButtonPushedFcn = @(start, evt)StartButtonPushed(fig, start, stop,... % connect callback func StartButtonPushed with corresponding button
                                    save, address, load, roiData);
stop.ButtonPushedFcn = @(stop, evt)StopButtonPushed(start, stop, save, ...  % connect callback func StopButtonPushed with corresponding button
                                    address, load, roiData);
save.ButtonPushedFcn = @(save, evt)SaveButtonPushed(time, motionSignal, ... % connect callback func SaveButtonPushed with corresponding button
                                    roi, address); 
load.ButtonPushedFcn = @(load, evt)LoadButtonPushed(vid, start, roiData,... % connect callback func LoadButtonPushed with corresponding button
                                    address, load);   
address.ValueChangedFcn = @(address, evt)AddressFieldChanged(vid, ...       % connect callback func AddressFieldChanged with corresponding field
                                    start, roiData, address, load);
roiData.x0.ValueChangedFcn = @(x0, evt)X0FieldChanged(vid, roiData, load);  % connect callback func X0FieldChanged with corresponding field
roiData.y0.ValueChangedFcn = @(y0, evt)Y0FieldChanged(vid, roiData, load);  % connect callback func Y0FieldChanged with corresponding field
roiData.width.ValueChangedFcn = @(width, evt)WidthFieldChanged(vid, ...     % connect callback func WidthFieldChanged with corresponding field
                                    roiData, load);
roiData.height.ValueChangedFcn = @(height, evt)HeightFieldChanged(vid, ...  % connect callback func HeightFieldChanged with corresponding field
                                    roiData, load);
                                  
% -------------------------------------------------------------------------
% Main video processing loop
% -------------------------------------------------------------------------                                  
while(1)
  uiwait(fig);                                                              % wait until a new video processing was started
  
  if ~ishandle(fig)                                                         % if figure was closed clear workspace and quit this script
    clear;
    return;
  end
  
  VidObj = VideoReader(address.Value);                                      %#ok<TNMLP>, create video file handle  
  numOfFrames = ceil(VidObj.FrameRate * VidObj.Duration);                   % estimate approximate number of frames

  dispBufLength = 75;                                                       % determine length of display buffer for visualization
  motionSignal  = zeros(1, numOfFrames + dispBufLength);                    % allocate memory for the motion signal 
  time          = zeros(1, numOfFrames);                                    % allocate memory for the time vector

  if hasFrame(VidObj)                                                   
    OldImg      = readFrame(VidObj);                                        % load first image
    numOfFrames = 1;
  end

  sig0  = 0;                                                                % variable for the current motion value
  sig1  = 0;                                                                % variable for the predecessor
  sig2  = 0;                                                                % variable for the pre-predecessor
  
  while hasFrame(VidObj) && strcmp(stop.Enable, 'on')                       % do as long as Frames available or until stop was pushed
    NewImg      = readFrame(VidObj);                                        % get new frame
    numOfFrames = numOfFrames + 1;                                          % increase number of Frames Counter
    sigPointer  = numOfFrames + dispBufLength - 1;                          % determine pointer to current field of the motion signal vector
    timePointer = numOfFrames - 1;                                          % determine pointer to current field of the time vector
    NewImage    = im2double(NewImg);                                        % convert pixel values into double format
    OldImage    = im2double(OldImg);
    NewImage    = rgb2gray(NewImage);                                       % convert images into a grayscale images
    OldImage    = rgb2gray(OldImage);
    NewROI      = GetExcerpt(NewImage, roiData);                            % extract the part of the image, wich is defined as region of interest
    OldROI      = GetExcerpt(OldImage, roiData);    
    NewHist     = imhist(NewROI)./numel(NewROI);                            % estimate weighted histogram of the region of interests
    OldHist     = imhist(OldROI)./numel(OldROI);

    sig0 = sum((OldHist - NewHist).^2);                                     % estimate current value
    motionSignal(sigPointer) = median([sig0 sig1 sig2]);                    % apply median filter to reject outliers and add the result to the motion signal vector
    sig2 = sig1;                                                            % update predecessor and pre-predecessor
    sig1 = sig0;
    time(timePointer) = VidObj.CurrentTime;                                 % add current timestamp to time vector

    warning off;
    imshow(AddRoi2Image(NewImage - OldImage, roiData), 'Parent', vid);      % display diffence of current grayscale image and its predecessor
    plot(sig, motionSignal((numOfFrames - 1):1:(numOfFrames + 75 - 1)));    % update motion signal time course
    drawnow;                                                                % IMPORTANT: update figures and process callbacks
    warning on;
    msg = sprintf('Status: Frame: %d - Current Motion Value: %d', ...       % update text label
                      numOfFrames, motionSignal(numOfFrames + 75 - 1));
    label.Text = msg;
    
    OldImg = NewImg;                                                        % copy current Image to variable containing the predecessor
  end
  
  % After either the whole video processing was done or stop button pushed
  time = time(1:timePointer);                                               % shrink time vector to its actual length                               
  motionSignal = motionSignal(dispBufLength+1:sigPointer);                  % shrink motion signal vector to its actual length
  roi = [roiData.x0.Value roiData.y0.Value roiData.width.Value ...          % get current roi selection
          roiData.height.Value];
  save.ButtonPushedFcn = @(save, evt)SaveButtonPushed(time, ...             % update callback for the save SaveButtonPushed event
                                    motionSignal, roi, address);
end


% -------------------------------------------------------------------------
% Callback functions
% -------------------------------------------------------------------------
function LoadButtonPushed(vid, start, roiData, address, load)               % LoadButtonPushed callback

[file,path] = uigetfile('*.wmv', 'Select video file...');                   % get filename

if ~any(file)                                                               % if cancel was pressed
  roiData.x0.Enable = 'off';                                                % disable roi selection
  roiData.y0.Enable = 'off';
  roiData.width.Enable = 'off';
  roiData.height.Enable = 'off';
  start.Enable = 'off';                                                     % disable start button
  address.Value = '';                                                       % clear address field
  
  imshow([], 'Parent', vid);                                                % clear previous preview
  
  return;                                             
end

try                                                                         % validity check
  VidObj = VideoReader([path file]);                                        % try to get video handle
catch                                                                       % if not possible
  roiData.x0.Enable = 'off';                                                % disable roi selection
  roiData.y0.Enable = 'off';
  roiData.width.Enable = 'off';
  roiData.height.Enable = 'off';
  start.Enable = 'off';                                                     % disable start button
  address.Value = '';                                                       % clear address field
  
  imshow([], 'Parent', vid);                                                % clear previous preview
  
  return;                                             
end
                                                                            % if video handle is valid
roiData.x0.Enable = 'on';                                                   % enable roi selection
roiData.y0.Enable = 'on';
roiData.width.Enable = 'on';
roiData.height.Enable = 'on';
start.Enable = 'on';                                                        % enable 
address.Value = [path file];                                                % set address field

NewImg = readFrame(VidObj);                                                 % load first frame

roiData.x0.Limits = [1 VidObj.Width];                                       % set roi limits to the maximum values of the selected image
roiData.y0.Limits = [1 VidObj.Height];
roiData.width.Limits = [1 VidObj.Width];
roiData.height.Limits = [1 VidObj.Height];

roiData.x0.Value = 1;                                                       % define initial region of interest which covers the whole image
roiData.y0.Value = 1;
roiData.width.Value = VidObj.Width;
roiData.height.Value = VidObj.Height;

load.UserData.Width = VidObj.Width;                                         % keep data of first image and its parameters
load.UserData.Height = VidObj.Height;
load.UserData.Image = NewImg;  

UpdateVidObject(vid, roiData, NewImg);                                      % add region of interest to the image and show image

end

function AddressFieldChanged(vid, start, roiData, address, load)            % AddressFieldChanged callback

try                                                                         % validity check
  VidObj = VideoReader(address.Value);                                      % try to get video handle
catch                                                                       % if not possible
  roiData.x0.Enable = 'off';                                                % disable roi selection
  roiData.y0.Enable = 'off';
  roiData.width.Enable = 'off';
  roiData.height.Enable = 'off';
  start.Enable = 'off';                                                     % disable start button
  
  imshow([], 'Parent', vid);                                                % clear previous preview
  
  return;                                             
end
                                                                            % if video handle is valid
roiData.x0.Enable = 'on';                                                   % enable roi selection
roiData.y0.Enable = 'on';
roiData.width.Enable = 'on';
roiData.height.Enable = 'on';
start.Enable = 'on';                                                        % enable 

NewImg = readFrame(VidObj);                                                 % load first frame

roiData.x0.Limits = [1 VidObj.Width];                                       % set roi limits to the maximum values of the selected image
roiData.y0.Limits = [1 VidObj.Height];
roiData.width.Limits = [1 VidObj.Width];
roiData.height.Limits = [1 VidObj.Height];

roiData.x0.Value = 1;                                                       % define initial region of interest which covers the whole image
roiData.y0.Value = 1;
roiData.width.Value = VidObj.Width;
roiData.height.Value = VidObj.Height;

load.UserData.Width = VidObj.Width;                                         % keep data of first image and its parameters
load.UserData.Height = VidObj.Height;
load.UserData.Image = NewImg;  

UpdateVidObject(vid, roiData, NewImg);                                      % add region of interest to the image and show image

end

function StartButtonPushed(fig, start, stop, save, address, load, roiData)  % StartButtonPushed callback

start.Enable = 'off';                                                       % disable start, save and load buttons
save.Enable = 'off';
load.Enable = 'off';
stop.Enable = 'on';                                                         % enable stop button
address.Enable = 'off';                                                     % disable address field
roiData.x0.Enable = 'off';                                                  % disable roi selection
roiData.y0.Enable = 'off';
roiData.width.Enable = 'off';
roiData.height.Enable = 'off';
uiresume(fig);                                                              % activate video processing in the main loop 

end

function StopButtonPushed(start, stop, save, address, load, roiData)        % StopButtonPushed callback

start.Enable = 'on';                                                        % enable start, save and load buttons
save.Enable = 'on';
load.Enable = 'on';
stop.Enable = 'off';                                                        % disable stop button
address.Enable = 'on';                                                      % enable address field
roiData.x0.Enable = 'on';                                                   % enable roi selection
roiData.y0.Enable = 'on';
roiData.width.Enable = 'on';
roiData.height.Enable = 'on';
  
end

function SaveButtonPushed(time, motionSignal, roi, address)                 %#ok<INUSL> SaveButtonPushed callback

address = address.Value(1:end-3);
address = [ address 'mat'];

uisave({'time', 'motionSignal', 'roi'}, address);                           % save time, motionSignal and roi into mat File

end

function CloseRequestFunction(fig)                                          % CloseRequestFunction callback

delete(fig);                                                                % destroy gui

end

function X0FieldChanged(vid, roiData, load)                                 % X0FieldChanged callback

widthMax = load.UserData.Width-roiData.x0.Value+1;                          % adapt width, if necessary
if roiData.width.Value > widthMax
  roiData.width.Value = widthMax;
end

UpdateVidObject(vid, roiData, load.UserData.Image);                         % add updated region of interest to the image and show image

end

function Y0FieldChanged(vid, roiData, load)                                 % Y0FieldChanged callback

heightMax = load.UserData.Height-roiData.y0.Value+1;                        % adapt height, if necessary
if roiData.height.Value > heightMax
  roiData.height.Value = heightMax;
end

UpdateVidObject(vid, roiData, load.UserData.Image);                         % add updated region of interest to the image and show image

end

function WidthFieldChanged(vid,roiData,load)                                % WidthFieldChanged callback

x0Max = load.UserData.Width-roiData.width.Value+1;                          % adapt x0, if necessary
if roiData.x0.Value > x0Max
  roiData.x0.Value = x0Max;
end

UpdateVidObject(vid, roiData, load.UserData.Image);                         % add updated region of interest to the image and show image

end

function HeightFieldChanged(vid, roiData, load)                             % HeightFieldChanged callback

y0Max = load.UserData.Height-roiData.height.Value+1;                        % adapt y0, if necessary
if roiData.y0.Value > y0Max
  roiData.y0.Value = y0Max;
end

UpdateVidObject(vid, roiData, load.UserData.Image);                         % add updated region of interest to the image and show image

end

% -------------------------------------------------------------------------
% Other subfunctions
% -------------------------------------------------------------------------
function [image] = AddRoi2Image(image, roiData)                             % add region of interest in green (for rgb images)
                                                                            % or white (for grayscale images) colour to image
x0    = roiData.x0.Value;                                                   % get roi parameters
xEnd  = roiData.x0.Value + roiData.width.Value - 1;
y0    = roiData.y0.Value;
yEnd  = roiData.y0.Value + roiData.height.Value - 1;

if size(image, 3) == 1                                                      % if image is in grayscale
  image(y0:yEnd, x0:x0+5) = 1;
  image(y0:yEnd, xEnd-5:xEnd) = 1;
  image(y0:y0+5, x0:xEnd) = 1;
  image(yEnd-5:yEnd, x0:xEnd) = 1;
elseif size(image, 3) == 3                                                  % if image is colored                                            
  image(y0:yEnd, x0:x0+5, 1) = 0;
  image(y0:yEnd, x0:x0+5, 2) = 255;
  image(y0:yEnd, x0:x0+5, 3) = 0;
  image(y0:yEnd, xEnd-5:xEnd, 1) = 0;
  image(y0:yEnd, xEnd-5:xEnd, 2) = 255;
  image(y0:yEnd, xEnd-5:xEnd, 3) = 0;
  image(y0:y0+5, x0:xEnd, 1) = 0;
  image(y0:y0+5, x0:xEnd, 2) = 255;
  image(y0:y0+5, x0:xEnd, 3) = 0;
  image(yEnd-5:yEnd, x0:xEnd, 1) = 0;
  image(yEnd-5:yEnd, x0:xEnd, 2) = 255;
  image(yEnd-5:yEnd, x0:xEnd, 3) = 0;
end

end

function UpdateVidObject(vid, roiData, image)                               % update and display image
image = AddRoi2Image(image, roiData);
imshow(image, 'Parent', vid);
drawnow;
end

function [image] = GetExcerpt(image, roiData)                               % extract a region of interest of an image

x0    = roiData.x0.Value;                                                   % get roi parameters                   
xEnd  = roiData.x0.Value + roiData.width.Value - 1;
y0    = roiData.y0.Value;
yEnd  = roiData.y0.Value + roiData.height.Value - 1;

image = image(y0:yEnd, x0:xEnd, :);                                         %resize image

end
