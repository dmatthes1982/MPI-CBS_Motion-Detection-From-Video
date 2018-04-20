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

% Copyright (C) 2017, Daniel Matthes, MPI CBS

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

roi = uilabel(fig);
roi.Position = [20 60 980 20];
roi.Text = 'Region of interest:';

x0Label = uilabel(fig);
x0Label.Position = [140 60 40 20];
x0Label.Text = 'x0:';

roiData.x0 = uieditfield(fig, 'numeric');
roiData.x0.Position = [180 60 60 30];
roiData.x0.Value = 1;
roiData.x0.Limits = [1 1000];
roiData.x0.Enable = 'off';

y0Label = uilabel(fig);
y0Label.Position = [260 60 40 20];
y0Label.Text = 'y0:';

roiData.y0 = uieditfield(fig, 'numeric');
roiData.y0.Position = [300 60 60 30];
roiData.y0.Value = 1;
roiData.y0.Limits = [1 1000];
roiData.y0.Enable = 'off';

widthLabel = uilabel(fig);
widthLabel.Position = [380 60 40 20];
widthLabel.Text = 'width:';

roiData.width = uieditfield(fig, 'numeric');
roiData.width.Position = [420 60 60 30];
roiData.width.Value = 1000;
roiData.width.Limits = [1 1000];
roiData.width.Enable = 'off';

heightLabel = uilabel(fig);
heightLabel.Position = [500 60 40 20];
heightLabel.Text = 'height:';

roiData.height = uieditfield(fig, 'numeric');
roiData.height.Position = [540 60 60 30];
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

% Link callback functions
start.ButtonPushedFcn = @(start, evt)StartButtonPushed(fig, start, stop,... % connect callback func StartButtonPushed with corresponding button
                                    save, address, load, roiData);
stop.ButtonPushedFcn = @(stop, evt)StopButtonPushed(start, stop, save, ...  % connect callback func StopButtonPushed with corresponding button
                                    address, load, roiData);
save.ButtonPushedFcn = @(save, evt)SaveButtonPushed(time, motionSignal, ... % connect callback func SaveButtonPushed with corresponding button
                                    address);                                  
load.ButtonPushedFcn = @(load, evt)LoadButtonPushed(vid, start, roiData,... % connect callback func SaveButtonPushed with corresponding button
                                    address, load);   
address.ValueChangedFcn = @(address, evt)AddressFieldChanged(vid, ...       % connect callback func AddressFieldChanged with corresponding field
                                    start, roiData, address, load);
roiData.x0.ValueChangedFcn = @(x0, evt)X0FieldChanged(vid, roiData, load);
roiData.y0.ValueChangedFcn = @(y0, evt)Y0FieldChanged(vid, roiData, load);
roiData.width.ValueChangedFcn = @(width, evt)WidthFieldChanged(vid, ...
                                    roiData, load);
roiData.height.ValueChangedFcn = @(height, evt)HeightFieldChanged(vid, ...
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
    NewImageSub = GetExcerpt(NewImage, roiData);
    OldImageSub = GetExcerpt(OldImage, roiData);    
    NewHist     = imhist(NewImageSub)./numel(NewImageSub);                  % estimate weighted histogram of the images
    OldHist     = imhist(OldImageSub)./numel(OldImageSub);

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
  save.ButtonPushedFcn = @(save, evt)SaveButtonPushed(time, ...             % update callback for the save SaveButtonPushed event
                                    motionSignal, address);
end


% -------------------------------------------------------------------------
% Callback functions
% -------------------------------------------------------------------------
function LoadButtonPushed(vid, start, roiData, address, load)               % LoadButtonPushed callback

[file,path] = uigetfile('*.wmv', 'Select video file...');
start.Enable = 'on';
address.Value = [path file];

roiData.x0.Enable = 'on';
roiData.y0.Enable = 'on';
roiData.width.Enable = 'on';
roiData.height.Enable = 'on';

VidObj = VideoReader(address.Value);                                        % load and show first frame
NewImg = readFrame(VidObj);

roiData.x0.Limits = [1 VidObj.Width];
roiData.y0.Limits = [1 VidObj.Height];
roiData.width.Limits = [1 VidObj.Width];
roiData.height.Limits = [1 VidObj.Height];

roiData.x0.Value = 1;
roiData.y0.Value = 1;
roiData.width.Value = VidObj.Width;
roiData.height.Value = VidObj.Height;

load.UserData.Width = VidObj.Width;
load.UserData.Height = VidObj.Height;
load.UserData.Image = NewImg;  

UpdateVidObject(vid, roiData, NewImg);

end

function AddressFieldChanged(vid, start, roiData, address, load)            % AddressFieldChanged callback

try                                                                         % validity check
  VidObj = VideoReader(address.Value);
catch
  roiData.x0.Enable = 'off';
  roiData.y0.Enable = 'off';
  roiData.width.Enable = 'off';
  roiData.height.Enable = 'off';
  start.Enable = 'off';
  
  imshow([], 'Parent', vid);
  
  return;
end

roiData.x0.Enable = 'on';
roiData.y0.Enable = 'on';
roiData.width.Enable = 'on';
roiData.height.Enable = 'on';
start.Enable = 'on';

NewImg = readFrame(VidObj);

roiData.x0.Limits = [1 VidObj.Width];
roiData.y0.Limits = [1 VidObj.Height];
roiData.width.Limits = [1 VidObj.Width];
roiData.height.Limits = [1 VidObj.Height];

roiData.x0.Value = 1;
roiData.y0.Value = 1;
roiData.width.Value = VidObj.Width;
roiData.height.Value = VidObj.Height;

load.UserData.Width = VidObj.Width;
load.UserData.Height = VidObj.Height;
load.UserData.Image = NewImg;  

UpdateVidObject(vid, roiData, NewImg);

end

function StartButtonPushed(fig, start, stop, save, address, load, roiData)  % StartButtonPushed callback

start.Enable = 'off';
stop.Enable = 'on';
save.Enable = 'off';
load.Enable = 'off';
address.Enable = 'off';
roiData.x0.Enable = 'off';
roiData.y0.Enable = 'off';
roiData.width.Enable = 'off';
roiData.height.Enable = 'off';
uiresume(fig);                                                              % activate video processing in the main loop 

end

function StopButtonPushed(start, stop, save, address, load, roiData)        % StopButtonPushed callback

start.Enable = 'on';
save.Enable = 'on';
load.Enable = 'on';
stop.Enable = 'off';
address.Enable = 'on';
roiData.x0.Enable = 'on';
roiData.y0.Enable = 'on';
roiData.width.Enable = 'on';
roiData.height.Enable = 'on';
  
end

function SaveButtonPushed(time, motionSignal, address)                      %#ok<INUSL> SaveButtonPushed callback
uisave({'time', 'motionSignal'}, address.Value);
end

function CloseRequestFunction(fig)                                          % CloseRequestFunction callback
delete(fig);                                                                % destroy gui
end

function X0FieldChanged(vid, roiData, load)

widthMax = load.UserData.Width-roiData.x0.Value+1;
if roiData.width.Value > widthMax
  roiData.width.Value = widthMax;
end

UpdateVidObject(vid, roiData, load.UserData.Image);

end

function Y0FieldChanged(vid, roiData, load)

heightMax = load.UserData.Height-roiData.y0.Value+1;
if roiData.height.Value > heightMax
  roiData.height.Value = heightMax;
end

UpdateVidObject(vid, roiData, load.UserData.Image);

end

function WidthFieldChanged(vid,roiData,load)

x0Max = load.UserData.Width-roiData.width.Value+1;
if roiData.x0.Value > x0Max
  roiData.x0.Value = x0Max;
end

UpdateVidObject(vid, roiData, load.UserData.Image);

end

function HeightFieldChanged(vid, roiData, load)

y0Max = load.UserData.Height-roiData.height.Value+1;
if roiData.y0.Value > y0Max
  roiData.y0.Value = y0Max;
end

UpdateVidObject(vid, roiData, load.UserData.Image);

end

% -------------------------------------------------------------------------
% Other subfunctions
% -------------------------------------------------------------------------
function [image] = AddRoi2Image(image, roiData)

x0    = roiData.x0.Value;
xEnd  = roiData.x0.Value + roiData.width.Value - 1;
y0    = roiData.y0.Value;
yEnd  = roiData.y0.Value + roiData.height.Value - 1;

if size(image, 3) == 1
  image(y0:yEnd, x0:x0+5) = 1;
  image(y0:yEnd, xEnd-5:xEnd) = 1;
  image(y0:y0+5, x0:xEnd) = 1;
  image(yEnd-5:yEnd, x0:xEnd) = 1;
elseif size(image, 3) == 3
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

function UpdateVidObject(vid, roiData, image)
image = AddRoi2Image(image, roiData);
imshow(image, 'Parent', vid);
drawnow;
end

function [image] = GetExcerpt(image, roiData)

x0    = roiData.x0.Value;
xEnd  = roiData.x0.Value + roiData.width.Value - 1;
y0    = roiData.y0.Value;
yEnd  = roiData.y0.Value + roiData.height.Value - 1;

image = image(y0:yEnd, x0:xEnd, :);

end