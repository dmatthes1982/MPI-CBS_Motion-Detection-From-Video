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
fig.Position = [100 300 1060 420];
fig.Name = 'Motion Detection from Videos';
fig.CloseRequestFcn = @(fig, event)CloseRequestFunction(fig);               % connect callback func CloseRequestFunction with figure

vid = uiaxes(fig);                                                          % element for displaying the video during the processing
vid.XTick = [];
vid.YTick = [];
vid.Position = [20 110 500 290];
vid.Visible = 'off';

sig = uiaxes(fig);                                                          % graph, wich shows the motion signal cource during 
sig.Position = [540 110 500 290];                                           % the video processing 
sig.XLim = [0 75];
%sig.YLim = [0 2*10^-4];

label = uilabel(fig);                                                       % text label, which displays the current frame number and
label.Position = [20 70 980 20];                                            % and the current motion value during video processing
label.Text = '';

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

address = uieditfield(fig);                                                 % field, wich contains location and name of selected 
address.Position = [380 20 540 30];                                         % video file (editable)

motionSignal = 0;
time = 0;
folder = [];
filename = [];

% Link event functions
start.ButtonPushedFcn = @(start, evt)StartButtonPushed(fig, start, stop,... % connect callback func StartButtonPushed with corresponding button
                                    save, address, load);
stop.ButtonPushedFcn = @(stop, evt)StopButtonPushed(start, stop, save, ...  % connect callback func StopButtonPushed with corresponding button
                                    address, load);
save.ButtonPushedFcn = @(save, evt)SaveButtonPushed(time, motionSignal, ... % connect callback func SaveButtonPushed with corresponding button
                                    address);                                  
load.ButtonPushedFcn = @(load, evt)LoadButtonPushed(vid, start, address);   % connect callback func SaveButtonPushed with corresponding button
address.ValueChangedFcn = @(address, load)AddressFieldChanged(start, ...    % connect callback func AddressFieldChanged with corresponding field
                                    address);

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
    NewHist     = imhist(NewImage)./numel(NewImage);                        % estimate weighted histogram of the images
    OldHist     = imhist(OldImage)./numel(OldImage);

    sig0 = sum((OldHist - NewHist).^2);                                     % estimate current value
    motionSignal(sigPointer) = median([sig0 sig1 sig2]);                    % apply median filter to reject outliers and add the result to the motion signal vector
    sig2 = sig1;                                                            % update predecessor and pre-predecessor
    sig1 = sig0;
    time(timePointer) = VidObj.CurrentTime;                                 % add current timestamp to time vector

    warning off;
    imshow(NewImage - OldImage, 'Parent', vid);                             % display diffence of current grayscale image and its predecessor
    plot(sig, motionSignal((numOfFrames - 1):1:(numOfFrames + 75 - 1)));    % update motion signal time course
    drawnow;                                                                % IMPORTANT: update figures and process callbacks
    warning on;
    msg = sprintf('Frame: %d - Current Motion Value: %d', numOfFrames, ...  % update text label
                      motionSignal(numOfFrames + 75 - 1));
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
function LoadButtonPushed(vid, start, address)                              % LoadButtonPushed callback

[file,path] = uigetfile('*.wmv', 'Select video file...');
start.Enable = 'on';
address.Value = [path file];

VidObj = VideoReader(address.Value);                                        % load and show first frame
NewImg = readFrame(VidObj);
imshow(NewImg, 'Parent', vid);
drawnow;

end

function AddressFieldChanged(start, address)                                % AddressFieldChanged callback

if isempty(address.Value)                                                   % validity check
  start.Enable = 'off';
else
  addressLength = length(address.Value);
  if addressLength < 5
    start.Enable = 'off';
  else
    fileSuffix = extractAfter(address.Value, addressLength - 4);
    if strcmp (fileSuffix, '.wmv')
      start.Enable = 'on';
    else
      start.Enable = 'off';
    end
  end
end

end

function StartButtonPushed(fig, start, stop, save, address, load)           % StartButtonPushed callback

start.Enable = 'off';
stop.Enable = 'on';
save.Enable = 'off';
load.Enable = 'off';
address.Enable = 'off';
uiresume(fig);                                                              % activate video processing in the main loop 

end

function StopButtonPushed(start, stop, save, address, load)                 % StopButtonPushed callback

start.Enable = 'on';
save.Enable = 'on';
load.Enable = 'on';
stop.Enable = 'off';
address.Enable = 'on';

end

function SaveButtonPushed(time, motionSignal, address)                      %#ok<INUSL> SaveButtonPushed callback
uisave({'time', 'motionSignal'}, address.Value);
end

function CloseRequestFunction(fig)                                          % CloseRequestFunction callback
delete(fig);                                                                % destroy gui
end
