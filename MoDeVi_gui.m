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
fig.Position = [100 300 1060 520];
fig.Name = 'Motion Detection from Videos';
fig.CloseRequestFcn = @(fig, event)CloseRequestFunction(fig);               % connect callback func CloseRequestFunction with figure

vid = uiaxes(fig);                                                          % element for displaying the video during the processing
vid.XTick = [];
vid.YTick = [];
vid.Position = [20 210 500 290];
vid.Visible = 'off';

sig = uiaxes(fig);                                                          % graph, wich shows the motion signal cource during 
sig.Position = [540 210 500 290];                                           % the video processing 
sig.XLim = [0 75];
%sig.YLim = [0 2*10^-4];

label = uilabel(fig);                                                       % text label, which displays the current frame number and
label.Position = [20 180 980 20];                                           % and the current motion value during video processing
label.Text = 'Status:';

% Regions of interest - label ---------------------------------------------
roiLabel.description(1) = uilabel(fig);                                     % text label for regions of interest
roiLabel.description(2) = uilabel(fig);
roiLabel.description(3) = uilabel(fig);
roiLabel.description(1).Position = [20 140 120 20];
roiLabel.description(2).Position = [20 100 120 20];
roiLabel.description(3).Position = [20 60 120 20];
roiLabel.description(1).Text = 'Region of interest 1:';
roiLabel.description(2).Text = 'Region of interest 2:';
roiLabel.description(3).Text = 'Baseline :';

roiLabel.x0(1) = uilabel(fig);                                              % text label for x zero point                                             
roiLabel.x0(2) = uilabel(fig);
roiLabel.x0(3) = uilabel(fig);
roiLabel.x0(1).Position = [140 140 40 20];
roiLabel.x0(2).Position = [140 100 40 20];
roiLabel.x0(3).Position = [140 60 40 20];
[roiLabel.x0(:).Text] = deal('x0');

roiLabel.y0(1) = uilabel(fig);                                              % text label for y zero point                                             
roiLabel.y0(2) = uilabel(fig);
roiLabel.y0(3) = uilabel(fig);
roiLabel.y0(1).Position = [260 140 40 20];
roiLabel.y0(2).Position = [260 100 40 20];
roiLabel.y0(3).Position = [260 60 40 20];
[roiLabel.y0(:).Text] = deal('y0');

roiLabel.width(1) = uilabel(fig);                                           % text label regions of interest width
roiLabel.width(2) = uilabel(fig);
roiLabel.width(3) = uilabel(fig);
roiLabel.width(1).Position = [380 140 40 20];
roiLabel.width(2).Position = [380 100 40 20];
roiLabel.width(3).Position = [380 60 40 20];
[roiLabel.width(:).Text] = deal('width');

roiLabel.height(1) = uilabel(fig);                                          % text label regions of interest height
roiLabel.height(2) = uilabel(fig);
roiLabel.height(3) = uilabel(fig);
roiLabel.height(1).Position = [500 140 40 20];
roiLabel.height(2).Position = [500 100 40 20];
roiLabel.height(3).Position = [500 60 40 20];
[roiLabel.height(:).Text] = deal('height');

% Regions of interest - fields --------------------------------------------
roiData.x0(1) = uieditfield(fig, 'numeric');                                % numeric field, which contains the x zero point
roiData.x0(2) = uieditfield(fig, 'numeric');                                % of the regions of interest
roiData.x0(3) = uieditfield(fig, 'numeric');
roiData.x0(1).Position = [180 140 60 30];
roiData.x0(2).Position = [180 100 60 30];
roiData.x0(3).Position = [180 60 60 30];
[roiData.x0(:).Value] = deal(1);
[roiData.x0(:).Limits] = deal([1 1000]);
[roiData.x0(:).Enable] = deal('off');

roiData.y0(1) = uieditfield(fig, 'numeric');                                % numeric field, which contains the y zero point
roiData.y0(2) = uieditfield(fig, 'numeric');                                % of the regions of interest
roiData.y0(3) = uieditfield(fig, 'numeric');
roiData.y0(1).Position = [300 140 60 30];
roiData.y0(2).Position = [300 100 60 30];
roiData.y0(3).Position = [300 60 60 30];
[roiData.y0(:).Value] = deal(1);
[roiData.y0(:).Limits] = deal([1 1000]);
[roiData.y0(:).Enable] = deal('off');

roiData.width(1) = uieditfield(fig, 'numeric');                             % numeric field, which contains the regions of interest
roiData.width(2) = uieditfield(fig, 'numeric');                             % width
roiData.width(3) = uieditfield(fig, 'numeric');
roiData.width(1).Position = [420 140 60 30];
roiData.width(2).Position = [420 100 60 30];
roiData.width(3).Position = [420 60 60 30];
[roiData.width(:).Value] = deal(1000);
[roiData.width(:).Limits] = deal([1 1000]);
[roiData.width(:).Enable] = deal('off');

roiData.height(1) = uieditfield(fig, 'numeric');                            % numeric field, which contains the regions of interest
roiData.height(2) = uieditfield(fig, 'numeric');                            % height
roiData.height(3) = uieditfield(fig, 'numeric');
roiData.height(1).Position = [540 140 60 30];
roiData.height(2).Position = [540 100 60 30];
roiData.height(3).Position = [540 60 60 30];
[roiData.height(:).Value] = deal(1000);
[roiData.height(:).Limits] = deal([1 1000]);
[roiData.height(:).Enable] = deal('off');

roiData.index(1) = 1;                                                       % add index number to the different regions
roiData.index(2) = 2;
roiData.index(3) = 3;

% Regions of interest - activate ------------------------------------------
roiActiv.cb(1) = uicheckbox(fig);
roiActiv.cb(2) = uicheckbox(fig);
roiActiv.cb(3) = uicheckbox(fig);
roiActiv.cb(1).Position = [620 132 120 30];
roiActiv.cb(2).Position = [620 92 120 30];
roiActiv.cb(3).Position = [620 52 120 30];
roiActiv.cb(1).Text = 'Select ROI 1';
roiActiv.cb(2).Text = 'Select ROI 2';
roiActiv.cb(3).Text = 'Select base ROI';
[roiActiv.cb(:).Enable] = deal('off');
[roiActiv.cb(:).Value] = deal(1);


% Main control buttons ----------------------------------------------------
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

% Global variables --------------------------------------------------------
motionSignal(1:3)     = {0};
time                  = 0;
roi.dimension{3}       = [];
roi.selected(1:3)     = [false false false];
roi.description(1:3)  = {'first', 'second', 'base'};

% Link callback functions -------------------------------------------------
start.ButtonPushedFcn = @(start, evt)StartButtonPushed(fig, start, stop,... % connect callback func StartButtonPushed with corresponding button
                                    save, address, load, roiData, ...
                                    roiActiv);
stop.ButtonPushedFcn = @(stop, evt)StopButtonPushed(start, stop, save, ...  % connect callback func StopButtonPushed with corresponding button
                                    address, load, roiData, roiActiv);
save.ButtonPushedFcn = @(save, evt)SaveButtonPushed(time, motionSignal, ... % connect callback func SaveButtonPushed with corresponding button
                                    roi, address); 
load.ButtonPushedFcn = @(load, evt)LoadButtonPushed(vid, start, ...         % connect callback func LoadButtonPushed with corresponding button
                                    roiData, roiActiv, address, load);   
address.ValueChangedFcn = @(address, evt)AddressFieldChanged(vid, ...       % connect callback func AddressFieldChanged with corresponding field
                                    start, roiData, roiActiv, address, ...
                                    load);

roiData.x0(1).ValueChangedFcn = @(x0, evt)X0FieldChanged(vid, roiData, ...  % connect callback func X0FieldChanged with corresponding field of ROI 1 selection
                                    roiActiv, load, roiData.index(1));
roiData.x0(2).ValueChangedFcn = @(x0, evt)X0FieldChanged(vid, roiData, ...  % connect callback func X0FieldChanged with corresponding field of ROI 2 selection
                                    roiActiv, load, roiData.index(2));
roiData.x0(3).ValueChangedFcn = @(x0, evt)X0FieldChanged(vid, roiData, ...  % connect callback func X0FieldChanged with corresponding field of ROI 3 selection
                                    roiActiv, load, roiData.index(3));                                  
                                  
roiData.y0(1).ValueChangedFcn = @(y0, evt)Y0FieldChanged(vid, roiData, ...  % connect callback func Y0FieldChanged with corresponding field of ROI 1 selection
                                    roiActiv, load, roiData.index(1));
roiData.y0(2).ValueChangedFcn = @(y0, evt)Y0FieldChanged(vid, roiData, ...  % connect callback func Y0FieldChanged with corresponding field of ROI 2 selection
                                    roiActiv, load, roiData.index(2));
roiData.y0(3).ValueChangedFcn = @(y0, evt)Y0FieldChanged(vid, roiData, ...  % connect callback func Y0FieldChanged with corresponding field of ROI 3 selection
                                    roiActiv, load, roiData.index(3)); 
                                 
roiData.width(1).ValueChangedFcn = @(width, evt)WidthFieldChanged(vid, ...  % connect callback func WidthFieldChanged with corresponding field of ROI 1 selection
                                    roiData, roiActiv, load, ...
                                    roiData.index(1));
roiData.width(2).ValueChangedFcn = @(width, evt)WidthFieldChanged(vid, ...  % connect callback func WidthFieldChanged with corresponding field of ROI 2 selection
                                    roiData, roiActiv, load, ...
                                    roiData.index(2));
roiData.width(3).ValueChangedFcn = @(width, evt)WidthFieldChanged(vid, ...  % connect callback func WidthFieldChanged with corresponding field of ROI 3 selection
                                    roiData, roiActiv, load, ...
                                    roiData.index(3)); 

roiData.height(1).ValueChangedFcn = @(height, evt)HeightFieldChanged(...    % connect callback func HeightFieldChanged with corresponding field of ROI 1 selection
                                    vid, roiData, roiActiv, load, ...
                                    roiData.index(1));
roiData.height(2).ValueChangedFcn = @(height, evt)HeightFieldChanged(...    % connect callback func HeightFieldChanged with corresponding field of ROI 2 selection
                                    vid, roiData, roiActiv, load, ...
                                    roiData.index(2));
roiData.height(3).ValueChangedFcn = @(height, evt)HeightFieldChanged(...    % connect callback func HeightFieldChanged with corresponding field of ROI 3 selection
                                    vid, roiData, roiActiv, load, ...
                                    roiData.index(3));                                   
             
roiActiv.cb(1).ValueChangedFcn = @(cb, evt)CheckBoxSwitched(vid, load, ...  % connect callback func CheckBoxSwitched with corresponding checkbox of ROI 1 selection
                                    start, roiData, roiActiv);
roiActiv.cb(2).ValueChangedFcn = @(cb, evt)CheckBoxSwitched(vid, load, ...  % connect callback func CheckBoxSwitched with corresponding checkbox of ROI 2 selection
                                    start, roiData, roiActiv);
roiActiv.cb(3).ValueChangedFcn = @(cb, evt)CheckBoxSwitched(vid, load, ...  % connect callback func CheckBoxSwitched with corresponding checkbox of ROI 3 selection
                                    start, roiData, roiActiv);
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

  dispBufLength     = 75;                                                   % determine length of display buffer for visualization
  motionSignal(1:3) = {zeros(1, numOfFrames + dispBufLength)};              % allocate memory for the motion signal 
  time              = zeros(1, numOfFrames);                                % allocate memory for the time vector

  if hasFrame(VidObj)                                                   
    OldImg      = readFrame(VidObj);                                        % load first image
    numOfFrames = 1;
  end

  while hasFrame(VidObj) && strcmp(stop.Enable, 'on')                       % do as long as Frames available or until stop was pushed
    NewImg      = readFrame(VidObj);                                        % get new frame
    numOfFrames = numOfFrames + 1;                                          % increase number of Frames Counter
    sigPointer  = numOfFrames + dispBufLength - 1;                          % determine pointer to current field of the motion signal vector
    timePointer = numOfFrames - 1;                                          % determine pointer to current field of the time vector
    NewImage    = im2double(NewImg);                                        % convert pixel values into double format
    OldImage    = im2double(OldImg);
    NewImage    = rgb2gray(NewImage);                                       % convert images into a grayscale images
    OldImage    = rgb2gray(OldImage);
    
    status = [roiActiv.cb(:).Value];                                        % check which regions of interest are selected
    
    for i=1:1:3                                                             % do it for all selected regions of interest
      if status(i) == true
        NewROI      = GetExcerpt(NewImage, roiData, i);                     % extract the part of the image, wich is defined as region of interest
        OldROI      = GetExcerpt(OldImage, roiData, i);    
      
        motionSignal{i}(sigPointer) = mean(mean((OldROI - NewROI).^2));      % estimate current value
      end
    end
    time(timePointer) = VidObj.CurrentTime;                                 % add current timestamp to time vector

    warning off;
    DiffImage = NewImage - OldImage;
    imshow(AddRoi2Image(DiffImage, roiData, roiActiv), 'Parent', vid);      % display diffence of current grayscale image and its predecessor
    
    sigColour = {'green', 'yellow', 'red'};
    for i=1:1:3                                                             % update motion signal time course for all selected regions of interest
      if status(i) == true
        plot(sig, motionSignal{i}((numOfFrames - 1):1: ...
              (numOfFrames + 75 - 1)), 'Color', sigColour{i}); 
        hold(sig, 'on')
      end
    end
    drawnow;                                                                % IMPORTANT: command updates figures and process callbacks
    hold(sig, 'off');
    warning on;
    
    msg = sprintf('Status: Frame: %d - ', numOfFrames);                     % update text label
    for i = 1:1:3
      if status(i) == true
        msg = [msg sprintf('    %s ROI Value: %d ', roi.description{i}, ...                        
                       motionSignal{i}(numOfFrames + 75 - 1))];             %#ok<AGROW>
      end
    end
    label.Text = msg;
    
    OldImg = NewImg;                                                        % copy current Image to variable containing the predecessor
  end
  
  % After either the whole video processing was done or stop button pushed
  time = time(1:timePointer);                                               % shrink time vector to its actual length                               
  motionSignal{1} = motionSignal{1}(dispBufLength+1:sigPointer);            % shrink motion signal vector to its actual length
  motionSignal{2} = motionSignal{2}(dispBufLength+1:sigPointer);
  motionSignal{3} = motionSignal{3}(dispBufLength+1:sigPointer);
  roi.selected(:) = [roiActiv.cb(:).Value];
  
  for i=1:1:3
    if roi.selected(i) == true
      roi.dimension{i} = [roiData.x0(i).Value roiData.y0(i).Value ...        % get current selection of roi
                          roiData.width(i).Value roiData.height(i).Value];
    else
      roi.dimension{i} = [0 0 0 0];
    end
  end
  
  save.ButtonPushedFcn = @(save, evt)SaveButtonPushed(time, ...             % update callback for the save SaveButtonPushed event
                                    motionSignal, roi, address);
end


% -------------------------------------------------------------------------
% Callback functions
% -------------------------------------------------------------------------
function LoadButtonPushed(vid, start, roiData, roiActiv, address, load)     % LoadButtonPushed callback

[file,path] = uigetfile('*.wmv', 'Select video file...');                   % get filename

if ~any(file)                                                               % if cancel was pressed
  [roiData.x0(:).Enable] = deal('off');                                     % disable roi selection
  [roiData.y0(:).Enable] = deal('off');
  [roiData.width(:).Enable] = deal('off');
  [roiData.height(:).Enable] = deal('off');
  [roiActiv.cb(:).Enable] = deal('off');
  start.Enable = 'off';                                                     % disable start button
  address.Value = '';                                                       % clear address field
  
  imshow([], 'Parent', vid);                                                % clear previous preview
  
  return;                                             
end

try                                                                         % validity check
  VidObj = VideoReader([path file]);                                        % try to get video handle
catch                                                                       % if not possible
  [roiData.x0(:).Enable] = deal('off');                                     % disable roi selection
  [roiData.y0(:).Enable] = deal('off');
  [roiData.width(:).Enable] = deal('off');
  [roiData.height(:).Enable] = deal('off');
  [roiActiv.cb(:).Enable] = deal('off');
  start.Enable = 'off';                                                     % disable start button
  address.Value = '';                                                       % clear address field
  
  imshow([], 'Parent', vid);                                                % clear previous preview
  
  return;                                             
end
                                                                            % if video handle is valid
status = [roiActiv.cb(:).Value];
[roiData.x0(status).Enable] = deal('on');                                   % enable roi selection
[roiData.y0(status).Enable] = deal('on');
[roiData.width(status).Enable] = deal('on');
[roiData.height(status).Enable] = deal('on');
[roiActiv.cb(:).Enable] = deal('on');
if any(status)                                                              % motion analysis is only possible, if at least one roi is activ                                                           
  start.Enable = 'on';
else
  start.Enable = 'off';
end                                                        % enable 
address.Value = [path file];                                                % set address field

NewImg = readFrame(VidObj);                                                 % load first frame

[roiData.x0(:).Limits] = deal([1 VidObj.Width]);                            % set roi limits to the maximum values of the selected image
[roiData.y0(:).Limits] = deal([1 VidObj.Height]);
[roiData.width(:).Limits] = deal([1 VidObj.Width]);
[roiData.height(:).Limits] = deal([1 VidObj.Height]);

[roiData.x0(1:2).Value] = deal(1);                                          % define initial regions of interest which cover the whole image
[roiData.y0(1:2).Value] = deal(1);
[roiData.width(1:2).Value] = deal(VidObj.Width);
[roiData.height(1:2).Value] = deal(VidObj.Height);

[roiData.x0(3).Value] = deal(VidObj.Width - 200);                           % define the initial base region at top right of the image
[roiData.y0(3).Value] = deal(1);
[roiData.width(3).Value] = deal(200);
[roiData.height(3).Value] = deal(200);

load.UserData.Width = VidObj.Width;                                         % keep data of first image and its parameters
load.UserData.Height = VidObj.Height;
load.UserData.Image = NewImg;  

UpdateVidObject(vid, roiData, roiActiv, NewImg);                            % add regions of interest to the image and show image

end

function AddressFieldChanged(vid, start, roiData, roiActiv, address, load)  % AddressFieldChanged callback

try                                                                         % validity check
  VidObj = VideoReader(address.Value);                                      % try to get video handle
catch                                                                       % if not possible
  [roiData.x0(:).Enable] = deal('off');                                     % disable roi selection
  [roiData.y0(:).Enable] = deal('off');
  [roiData.width(:).Enable] = deal('off');
  [roiData.height(:).Enable] = deal('off');
  [roiActiv.cb(:).Enable] = deal('off');
  start.Enable = 'off';                                                     % disable start button
  
  imshow([], 'Parent', vid);                                                % clear previous preview
  
  return;                                             
end
                                                                            % if video handle is valid
status = [roiActiv.cb(:).Value];
[roiData.x0(status).Enable] = deal('on');                                   % enable roi selection
[roiData.y0(status).Enable] = deal('on');
[roiData.width(status).Enable] = deal('on');
[roiData.height(status).Enable] = deal('on');
[roiActiv.cb(:).Enable] = deal('on');
if any(status)                                                              % motion analysis is only possible, if at least one roi is activ                                                           
  start.Enable = 'on';
else
  start.Enable = 'off';
end 

NewImg = readFrame(VidObj);                                                 % load first frame

[roiData.x0(:).Limits] = deal([1 VidObj.Width]);                            % set roi limits to the maximum values of the selected image
[roiData.y0(:).Limits] = deal([1 VidObj.Height]);
[roiData.width(:).Limits] = deal([1 VidObj.Width]);
[roiData.height(:).Limits] = deal([1 VidObj.Height]);

[roiData.x0(1:2).Value] = deal(1);                                          % define initial regions of interest which cover the whole image
[roiData.y0(1:2).Value] = deal(1);
[roiData.width(1:2).Value] = deal(VidObj.Width);
[roiData.height(1:2).Value] = deal(VidObj.Height);

[roiData.x0(3).Value] = deal(VidObj.Width - 200);                           % define the initial base region at top right of the image
[roiData.y0(3).Value] = deal(0);
[roiData.width(3).Value] = deal(200);
[roiData.height(3).Value] = deal(200);

load.UserData.Width = VidObj.Width;                                         % keep data of first image and its parameters
load.UserData.Height = VidObj.Height;
load.UserData.Image = NewImg;  

UpdateVidObject(vid, roiData, roiActiv, NewImg);                            % add regions of interest to the image and show image

end

function StartButtonPushed(fig, start, stop, save, address, load, ...       % StartButtonPushed callback
                           roiData, roiActiv)  

start.Enable = 'off';                                                       % disable start, save and load buttons
save.Enable = 'off';
load.Enable = 'off';
stop.Enable = 'on';                                                         % enable stop button
address.Enable = 'off';                                                     % disable address field
[roiData.x0(:).Enable] = deal('off');                                       % disable roi selection
[roiData.y0(:).Enable] = deal('off');
[roiData.width(:).Enable] = deal('off');
[roiData.height(:).Enable] = deal('off');
[roiActiv.cb(:).Enable] = deal('off');
uiresume(fig);                                                              % activate video processing in the main loop 

end

function StopButtonPushed(start, stop, save, address, load, roiData, ...    % StopButtonPushed callback
                          roiActiv)

start.Enable = 'on';                                                        % enable start, save and load buttons
save.Enable = 'on';
load.Enable = 'on';
stop.Enable = 'off';                                                        % disable stop button
address.Enable = 'on';                                                      % enable address field
status = [roiActiv.cb(:).Value];
[roiData.x0(status).Enable] = deal('on');                                   % enable roi selection
[roiData.y0(status).Enable] = deal('on');
[roiData.width(status).Enable] = deal('on');
[roiData.height(status).Enable] = deal('on');
[roiActiv.cb(:).Enable] = deal('on');
  
end

function SaveButtonPushed(time, motionSignal, roi, address)                 %#ok<INUSL> SaveButtonPushed callback

address = address.Value(1:end-3);
address = [ address 'mat'];

uisave({'time', 'motionSignal', 'roi'}, address);                           % save time, motionSignal and roi into mat File

end

function CloseRequestFunction(fig)                                          % CloseRequestFunction callback

delete(fig);                                                                % destroy gui

end

function X0FieldChanged(vid, roiData, roiActiv, load, index)                % X0FieldChanged callback

widthMax = load.UserData.Width-roiData.x0(index).Value+1;                   % adapt width, if necessary
if roiData.width(index).Value > widthMax
  roiData.width(index).Value = widthMax;
end

UpdateVidObject(vid, roiData, roiActiv, load.UserData.Image);               % add updated regions of interest to the image and show image

end

function Y0FieldChanged(vid, roiData, roiActiv, load, index)                % Y0FieldChanged callback

heightMax = load.UserData.Height-roiData.y0(index).Value+1;                 % adapt height, if necessary
if roiData.height(index).Value > heightMax
  roiData.height(index).Value = heightMax;
end

UpdateVidObject(vid, roiData, roiActiv, load.UserData.Image);               % add updated regions of interest to the image and show image

end

function WidthFieldChanged(vid, roiData, roiActiv, load, index)             % WidthFieldChanged callback

x0Max = load.UserData.Width-roiData.width(index).Value+1;                   % adapt x0, if necessary
if roiData.x0(index).Value > x0Max
  roiData.x0(index).Value = x0Max;
end

UpdateVidObject(vid, roiData, roiActiv, load.UserData.Image);               % add updated regions of interest to the image and show image

end

function HeightFieldChanged(vid, roiData, roiActiv, load, index)            % HeightFieldChanged callback

y0Max = load.UserData.Height-roiData.height(index).Value+1;                 % adapt y0, if necessary
if roiData.y0(index).Value > y0Max
  roiData.y0(index).Value = y0Max;
end

UpdateVidObject(vid, roiData, roiActiv, load.UserData.Image);               % add updated regions of interest to the image and show image

end

function CheckBoxSwitched(vid, load, start, roiData, roiActiv)

status = ~[roiActiv.cb(:).Value];                                           

[roiData.x0(status).Enable] = deal('off');                                  % disable all unselected region of interest
[roiData.y0(status).Enable] = deal('off');
[roiData.width(status).Enable] = deal('off');
[roiData.height(status).Enable] = deal('off');

status = [roiActiv.cb(:).Value];

[roiData.x0(status).Enable] = deal('on');                                   % enable all selected region of interest
[roiData.y0(status).Enable] = deal('on');
[roiData.width(status).Enable] = deal('on');
[roiData.height(status).Enable] = deal('on');

if any(status)                                                              % motion analysis is only possible, if at least one roi is activ                                                           
  start.Enable = 'on';
else
  start.Enable = 'off';
end

UpdateVidObject(vid, roiData, roiActiv, load.UserData.Image);

end

% -------------------------------------------------------------------------
% Other subfunctions
% -------------------------------------------------------------------------
function [image] = AddRoi2Image(image, roiData, roiActiv)                   % add regions of interest in different colours (for rgb images)
                                                                            % or white (for grayscale images) colour to image
roiColorDef = [0, 255, 0; 255, 255, 0; 255, 0, 0];
status = [roiActiv.cb(:).Value]; 

for i = 1:1:3
  if status(i) == true
    x0    = roiData.x0(i).Value;                                              % get roi parameters
    xEnd  = roiData.x0(i).Value + roiData.width(i).Value - 1;
    y0    = roiData.y0(i).Value;
    yEnd  = roiData.y0(i).Value + roiData.height(i).Value - 1;

    if size(image, 3) == 1                                                    % if image is in grayscale
      image(y0:yEnd, x0:x0+5) = 1;
      image(y0:yEnd, xEnd-5:xEnd) = 1;
      image(y0:y0+5, x0:xEnd) = 1;
      image(yEnd-5:yEnd, x0:xEnd) = 1;
    elseif size(image, 3) == 3                                                % if image is colored
      image(y0:yEnd, x0:x0+5, 1) = roiColorDef(i,1);
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
  
end

function UpdateVidObject(vid, roiData, roiActiv, image)                     % update and display image

image = AddRoi2Image(image, roiData, roiActiv);
imshow(image, 'Parent', vid);
drawnow;

end

function [image] = GetExcerpt(image, roiData, roiNum)                       % extract a region of interest of an image

x0    = roiData.x0(roiNum).Value;                                           % get roi parameters                   
xEnd  = roiData.x0(roiNum).Value + roiData.width(roiNum).Value - 1;
y0    = roiData.y0(roiNum).Value;
yEnd  = roiData.y0(roiNum).Value + roiData.height(roiNum).Value - 1;

image = image(y0:yEnd, x0:xEnd, :);                                         % resize image

end
