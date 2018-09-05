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
fig.Position = [100 100 1060 600];
fig.Name = 'Motion Detection from Videos';
fig.CloseRequestFcn = @(fig, event)CloseRequestFunction(fig);               % connect callback func CloseRequestFunction with figure

vid = uiaxes(fig);                                                          % element for displaying the video during the processing
vid.XTick = [];
vid.YTick = [];
vid.Position = [20 290 500 290];
vid.Visible = 'off';

slid = uislider(fig);
slid.Position = [20 290 490 3];
slid.MajorTicks = [];
slid.MinorTicks = [];
slid.Visible = 'off';
slid.Enable = 'off';

sig = uiaxes(fig);                                                          % graph, wich shows the motion signal cource during 
sig.Position = [540 290 500 290];                                           % the video processing
sig.XLim = [0 75];
%sig.YLim = [0 2*10^-4];

label = uilabel(fig);                                                       % text label, which displays the current frame number and
label.Position = [20 260 980 20];                                           % and the current motion value during video processing
label.Text = 'Status:';

% Regions of interest - label ---------------------------------------------
roiLabel.description(1) = uilabel(fig);                                     % text label for regions of interest
roiLabel.description(2) = uilabel(fig);
roiLabel.description(3) = uilabel(fig);
roiLabel.description(4) = uilabel(fig);
roiLabel.description(5) = uilabel(fig);
roiLabel.description(1).Position = [20 220 120 20];
roiLabel.description(2).Position = [20 180 120 20];
roiLabel.description(3).Position = [20 140 120 20];
roiLabel.description(4).Position = [20 100 120 20];
roiLabel.description(5).Position = [20 60 120 20];
roiLabel.description(1).Text = 'Region of interest 1:';
roiLabel.description(2).Text = 'Region of interest 2:';
roiLabel.description(3).Text = 'Region of interest 3:';
roiLabel.description(4).Text = 'Region of interest 4:';
roiLabel.description(5).Text = 'Baseline :';
roiLabel.description(1).FontColor = [0 0.9 0];
roiLabel.description(2).FontColor = [1 0.5 0];
roiLabel.description(3).FontColor = [0 0 1];
roiLabel.description(4).FontColor = [1 0 1];
roiLabel.description(5).FontColor = [1 0 0];

roiLabel.x0(1) = uilabel(fig);                                              % text label for x zero point                                             
roiLabel.x0(2) = uilabel(fig);
roiLabel.x0(3) = uilabel(fig);
roiLabel.x0(4) = uilabel(fig);
roiLabel.x0(5) = uilabel(fig);
roiLabel.x0(1).Position = [140 220 40 20];
roiLabel.x0(2).Position = [140 180 40 20];
roiLabel.x0(3).Position = [140 140 40 20];
roiLabel.x0(4).Position = [140 100 40 20];
roiLabel.x0(5).Position = [140 60 40 20];
[roiLabel.x0(:).Text] = deal('x0');

roiLabel.y0(1) = uilabel(fig);                                              % text label for y zero point                                             
roiLabel.y0(2) = uilabel(fig);
roiLabel.y0(3) = uilabel(fig);
roiLabel.y0(4) = uilabel(fig);
roiLabel.y0(5) = uilabel(fig);
roiLabel.y0(1).Position = [260 220 40 20];
roiLabel.y0(2).Position = [260 180 40 20];
roiLabel.y0(3).Position = [260 140 40 20];
roiLabel.y0(4).Position = [260 100 40 20];
roiLabel.y0(5).Position = [260 60 40 20];
[roiLabel.y0(:).Text] = deal('y0');

roiLabel.width(1) = uilabel(fig);                                           % text label regions of interest width
roiLabel.width(2) = uilabel(fig);
roiLabel.width(3) = uilabel(fig);
roiLabel.width(4) = uilabel(fig);
roiLabel.width(5) = uilabel(fig);
roiLabel.width(1).Position = [380 220 40 20];
roiLabel.width(2).Position = [380 180 40 20];
roiLabel.width(3).Position = [380 140 40 20];
roiLabel.width(4).Position = [380 100 40 20];
roiLabel.width(5).Position = [380 60 40 20];
[roiLabel.width(:).Text] = deal('width');

roiLabel.height(1) = uilabel(fig);                                          % text label regions of interest height
roiLabel.height(2) = uilabel(fig);
roiLabel.height(3) = uilabel(fig);
roiLabel.height(4) = uilabel(fig);
roiLabel.height(5) = uilabel(fig);
roiLabel.height(1).Position = [500 220 40 20];
roiLabel.height(2).Position = [500 180 40 20];
roiLabel.height(3).Position = [500 140 40 20];
roiLabel.height(4).Position = [500 100 40 20];
roiLabel.height(5).Position = [500 60 40 20];
[roiLabel.height(:).Text] = deal('height');

% Regions of interest - fields and roi select buttons ---------------------
roiData.x0(1) = uieditfield(fig, 'numeric');                                % numeric field, which contains the x zero point
roiData.x0(2) = uieditfield(fig, 'numeric');                                % of the regions of interest
roiData.x0(3) = uieditfield(fig, 'numeric');
roiData.x0(4) = uieditfield(fig, 'numeric');
roiData.x0(5) = uieditfield(fig, 'numeric');
roiData.x0(1).Position = [180 220 60 30];
roiData.x0(2).Position = [180 180 60 30];
roiData.x0(3).Position = [180 140 60 30];
roiData.x0(4).Position = [180 100 60 30];
roiData.x0(5).Position = [180 60 60 30];
[roiData.x0(:).Value] = deal(1);
[roiData.x0(:).Limits] = deal([1 1000]);
[roiData.x0(:).Enable] = deal('off');

roiData.y0(1) = uieditfield(fig, 'numeric');                                % numeric field, which contains the y zero point
roiData.y0(2) = uieditfield(fig, 'numeric');                                % of the regions of interest
roiData.y0(3) = uieditfield(fig, 'numeric');
roiData.y0(4) = uieditfield(fig, 'numeric');
roiData.y0(5) = uieditfield(fig, 'numeric');
roiData.y0(1).Position = [300 220 60 30];
roiData.y0(2).Position = [300 180 60 30];
roiData.y0(3).Position = [300 140 60 30];
roiData.y0(4).Position = [300 100 60 30];
roiData.y0(5).Position = [300 60 60 30];
[roiData.y0(:).Value] = deal(1);
[roiData.y0(:).Limits] = deal([1 1000]);
[roiData.y0(:).Enable] = deal('off');

roiData.width(1) = uieditfield(fig, 'numeric');                             % numeric field, which contains the regions of interest
roiData.width(2) = uieditfield(fig, 'numeric');                             % width
roiData.width(3) = uieditfield(fig, 'numeric');
roiData.width(4) = uieditfield(fig, 'numeric');
roiData.width(5) = uieditfield(fig, 'numeric');
roiData.width(1).Position = [420 220 60 30];
roiData.width(2).Position = [420 180 60 30];
roiData.width(3).Position = [420 140 60 30];
roiData.width(4).Position = [420 100 60 30];
roiData.width(5).Position = [420 60 60 30];
[roiData.width(:).Value] = deal(1000);
[roiData.width(:).Limits] = deal([1 1000]);
[roiData.width(:).Enable] = deal('off');

roiData.height(1) = uieditfield(fig, 'numeric');                            % numeric field, which contains the regions of interest
roiData.height(2) = uieditfield(fig, 'numeric');                            % height
roiData.height(3) = uieditfield(fig, 'numeric');
roiData.height(4) = uieditfield(fig, 'numeric');
roiData.height(5) = uieditfield(fig, 'numeric');
roiData.height(1).Position = [540 220 60 30];
roiData.height(2).Position = [540 180 60 30];
roiData.height(3).Position = [540 140 60 30];
roiData.height(4).Position = [540 100 60 30];
roiData.height(5).Position = [540 60 60 30];
[roiData.height(:).Value] = deal(1000);
[roiData.height(:).Limits] = deal([1 1000]);
[roiData.height(:).Enable] = deal('off');

roiData.select(1) = uibutton(fig);                                          % roi select button for graphical selection
roiData.select(2) = uibutton(fig);
roiData.select(3) = uibutton(fig);
roiData.select(4) = uibutton(fig);
roiData.select(5) = uibutton(fig);
roiData.select(1).Position = [620 220 100 30];
roiData.select(2).Position = [620 180 100 30];
roiData.select(3).Position = [620 140 100 30];
roiData.select(4).Position = [620 100 100 30];
roiData.select(5).Position = [620 60 100 30];
roiData.select(1).Text = 'Select ROI 1';
roiData.select(2).Text = 'Select ROI 2';
roiData.select(3).Text = 'Select ROI 3';
roiData.select(4).Text = 'Select ROI 4';
roiData.select(5).Text = 'Select base ROI';
[roiData.select(:).Enable] = deal('off');

roiData.index(1) = 1;                                                       % add index number to the different regions
roiData.index(2) = 2;
roiData.index(3) = 3;
roiData.index(4) = 4;
roiData.index(5) = 5;

% Regions of interest - activate ------------------------------------------
roiActiv.cb(1) = uicheckbox(fig);
roiActiv.cb(2) = uicheckbox(fig);
roiActiv.cb(3) = uicheckbox(fig);
roiActiv.cb(4) = uicheckbox(fig);
roiActiv.cb(5) = uicheckbox(fig);
roiActiv.cb(1).Position = [740 212 120 30];
roiActiv.cb(2).Position = [740 172 120 30];
roiActiv.cb(3).Position = [740 132 120 30];
roiActiv.cb(4).Position = [740 92 120 30];
roiActiv.cb(5).Position = [740 52 120 30];
roiActiv.cb(1).Text = 'Activate ROI 1';
roiActiv.cb(2).Text = 'Activate ROI 2';
roiActiv.cb(3).Text = 'Activate ROI 3';
roiActiv.cb(4).Text = 'Activate ROI 4';
roiActiv.cb(3).Text = 'Activate base ROI';
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

export  = uibutton(fig);                                                    % export roi button
export.Position = [380 20 100 30];
export.Text = 'export ROIs';
export.Enable = 'off';

noVis = uibutton(fig);                                                      % analyze without visualization
noVis.Position = [500 20 100 30];
noVis.Text = 'run without vis';
noVis.Enable = 'off';

load    = uibutton(fig);                                                    % load video button
load.Position = [940 20 100 30];
load.Text = 'load';
load.Enable = 'on';
load.UserData = struct('Width', 1000, 'Height', 1000, 'Image', []);

address = uieditfield(fig);                                                 % field, wich contains location and name of selected 
address.Position = [620 20 300 30];                                         % video file (editable)

% Global variables --------------------------------------------------------
motionSignal(1:5)     = {0};
time                  = 0;
roi.dimension{5}      = [];
roi.selected(1:5)     = [false false false false false];
roi.description(1:5)  = {'first', 'second', 'third', 'fourth', 'base'};

% Link callback functions -------------------------------------------------
start.ButtonPushedFcn = @(start, evt)StartButtonPushed(fig, start, stop,... % connect callback func StartButtonPushed with corresponding button
                                    save, export, noVis, address, load, ...
                                    roiData, roiActiv, slid);
stop.ButtonPushedFcn = @(stop, evt)StopButtonPushed(vid, start, stop, ...   % connect callback func StopButtonPushed with corresponding button
                                    save, export, noVis, address, load, ...
                                    roiData, roiActiv, slid);
save.ButtonPushedFcn = @(save, evt)SaveButtonPushed(time, motionSignal, ... % connect callback func SaveButtonPushed with corresponding button
                                    roi, address); 
load.ButtonPushedFcn = @(load, evt)LoadButtonPushed(vid, slid, start, ...   % connect callback func LoadButtonPushed with corresponding button
                                    export, noVis, roiData, roiActiv, ...
                                    address, load);
export.ButtonPushedFcn = @(export, evt)ExportButtonPushed(roiData, ...      % connect callback func ExportButtonPushed with corresponding button
                                    roiActiv, address);
noVis.ButtonPushedFcn = @(noVis, evt)NoVisButtonPushed(start, save, ...     % connect callback func NoVisButtonPushed with corresponding button
                                    export, noVis, load, slid, address, ...
                                    roiData, roiActiv);
address.ValueChangedFcn = @(address, evt)AddressFieldChanged(vid, slid, ... % connect callback func AddressFieldChanged with corresponding field
                                    start, export, noVis, roiData, ...
                                    roiActiv, address, load);

roiData.x0(1).ValueChangedFcn = @(x0, evt)X0FieldChanged(vid, roiData, ...  % connect callback func X0FieldChanged with corresponding field of ROI 1 selection
                                    roiActiv, load, roiData.index(1));
roiData.x0(2).ValueChangedFcn = @(x0, evt)X0FieldChanged(vid, roiData, ...  % connect callback func X0FieldChanged with corresponding field of ROI 2 selection
                                    roiActiv, load, roiData.index(2));
roiData.x0(3).ValueChangedFcn = @(x0, evt)X0FieldChanged(vid, roiData, ...  % connect callback func X0FieldChanged with corresponding field of ROI 3 selection
                                    roiActiv, load, roiData.index(3));                                  
roiData.x0(4).ValueChangedFcn = @(x0, evt)X0FieldChanged(vid, roiData, ...  % connect callback func X0FieldChanged with corresponding field of ROI 4 selection
                                    roiActiv, load, roiData.index(4));
roiData.x0(5).ValueChangedFcn = @(x0, evt)X0FieldChanged(vid, roiData, ...  % connect callback func X0FieldChanged with corresponding field of ROI 5 selection
                                    roiActiv, load, roiData.index(5));

roiData.y0(1).ValueChangedFcn = @(y0, evt)Y0FieldChanged(vid, roiData, ...  % connect callback func Y0FieldChanged with corresponding field of ROI 1 selection
                                    roiActiv, load, roiData.index(1));
roiData.y0(2).ValueChangedFcn = @(y0, evt)Y0FieldChanged(vid, roiData, ...  % connect callback func Y0FieldChanged with corresponding field of ROI 2 selection
                                    roiActiv, load, roiData.index(2));
roiData.y0(3).ValueChangedFcn = @(y0, evt)Y0FieldChanged(vid, roiData, ...  % connect callback func Y0FieldChanged with corresponding field of ROI 3 selection
                                    roiActiv, load, roiData.index(3)); 
roiData.y0(4).ValueChangedFcn = @(y0, evt)Y0FieldChanged(vid, roiData, ...  % connect callback func Y0FieldChanged with corresponding field of ROI 4 selection
                                    roiActiv, load, roiData.index(4));
roiData.y0(5).ValueChangedFcn = @(y0, evt)Y0FieldChanged(vid, roiData, ...  % connect callback func Y0FieldChanged with corresponding field of ROI 5 selection
                                    roiActiv, load, roiData.index(5));

roiData.width(1).ValueChangedFcn = @(width, evt)WidthFieldChanged(vid, ...  % connect callback func WidthFieldChanged with corresponding field of ROI 1 selection
                                    roiData, roiActiv, load, ...
                                    roiData.index(1));
roiData.width(2).ValueChangedFcn = @(width, evt)WidthFieldChanged(vid, ...  % connect callback func WidthFieldChanged with corresponding field of ROI 2 selection
                                    roiData, roiActiv, load, ...
                                    roiData.index(2));
roiData.width(3).ValueChangedFcn = @(width, evt)WidthFieldChanged(vid, ...  % connect callback func WidthFieldChanged with corresponding field of ROI 3 selection
                                    roiData, roiActiv, load, ...
                                    roiData.index(3));
roiData.width(4).ValueChangedFcn = @(width, evt)WidthFieldChanged(vid, ...  % connect callback func WidthFieldChanged with corresponding field of ROI 4 selection
                                    roiData, roiActiv, load, ...
                                    roiData.index(4));
roiData.width(5).ValueChangedFcn = @(width, evt)WidthFieldChanged(vid, ...  % connect callback func WidthFieldChanged with corresponding field of ROI 5 selection
                                    roiData, roiActiv, load, ...
                                    roiData.index(5));

roiData.height(1).ValueChangedFcn = @(height, evt)HeightFieldChanged(...    % connect callback func HeightFieldChanged with corresponding field of ROI 1 selection
                                    vid, roiData, roiActiv, load, ...
                                    roiData.index(1));
roiData.height(2).ValueChangedFcn = @(height, evt)HeightFieldChanged(...    % connect callback func HeightFieldChanged with corresponding field of ROI 2 selection
                                    vid, roiData, roiActiv, load, ...
                                    roiData.index(2));
roiData.height(3).ValueChangedFcn = @(height, evt)HeightFieldChanged(...    % connect callback func HeightFieldChanged with corresponding field of ROI 3 selection
                                    vid, roiData, roiActiv, load, ...
                                    roiData.index(3));
roiData.height(4).ValueChangedFcn = @(height, evt)HeightFieldChanged(...    % connect callback func HeightFieldChanged with corresponding field of ROI 4 selection
                                    vid, roiData, roiActiv, load, ...
                                    roiData.index(4));
roiData.height(5).ValueChangedFcn = @(height, evt)HeightFieldChanged(...    % connect callback func HeightFieldChanged with corresponding field of ROI 5 selection
                                    vid, roiData, roiActiv, load, ...
                                    roiData.index(5));

roiData.select(1).ButtonPushedFcn = @(select, evt)SelectButtonPushed( ...   % connect callback func SelectButtonPushed with corresponding button of ROI 1 selection
                                    vid, start, save, export, noVis, ...
                                    load, slid, address, roiData, ...
                                    roiActiv, roiData.index(1));
roiData.select(2).ButtonPushedFcn = @(select, evt)SelectButtonPushed( ...   % connect callback func SelectButtonPushed with corresponding button of ROI 2 selection
                                    vid, start, save, export, noVis, ...
                                    load, slid, address, roiData, ...
                                    roiActiv, roiData.index(2));
roiData.select(3).ButtonPushedFcn = @(select, evt)SelectButtonPushed( ...   % connect callback func SelectButtonPushed with corresponding button of ROI 3 selection
                                    vid, start, save, export, noVis, ...
                                    load, slid, address, roiData, ...
                                    roiActiv, roiData.index(3));
roiData.select(4).ButtonPushedFcn = @(select, evt)SelectButtonPushed( ...   % connect callback func SelectButtonPushed with corresponding button of ROI 4 selection
                                    vid, start, save, export, noVis, ...
                                    load, slid, address, roiData, ...
                                    roiActiv, roiData.index(4));
roiData.select(5).ButtonPushedFcn = @(select, evt)SelectButtonPushed( ...   % connect callback func SelectButtonPushed with corresponding button of ROI 5 selection
                                    vid, start, save, export, noVis, ...
                                    load, slid, address, roiData, ...
                                    roiActiv, roiData.index(5));

roiActiv.cb(1).ValueChangedFcn = @(cb, evt)CheckBoxSwitched(vid, load, ...  % connect callback func CheckBoxSwitched with corresponding checkbox of ROI 1 selection
                                    start, roiData, roiActiv);
roiActiv.cb(2).ValueChangedFcn = @(cb, evt)CheckBoxSwitched(vid, load, ...  % connect callback func CheckBoxSwitched with corresponding checkbox of ROI 2 selection
                                    start, roiData, roiActiv);
roiActiv.cb(3).ValueChangedFcn = @(cb, evt)CheckBoxSwitched(vid, load, ...  % connect callback func CheckBoxSwitched with corresponding checkbox of ROI 3 selection
                                    start, roiData, roiActiv);
roiActiv.cb(4).ValueChangedFcn = @(cb, evt)CheckBoxSwitched(vid, load, ...  % connect callback func CheckBoxSwitched with corresponding checkbox of ROI 4 selection
                                    start, roiData, roiActiv);
roiActiv.cb(5).ValueChangedFcn = @(cb, evt)CheckBoxSwitched(vid, load, ...  % connect callback func CheckBoxSwitched with corresponding checkbox of ROI 5 selection
                                    start, roiData, roiActiv);

slid.ValueChangedFcn = @(slid, evt)SliderMoved(slid, vid, load, ...         % connect callback func SliderMoved with corresponding slider
                                    roiData, roiActiv);

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
  motionSignal(1:5) = {zeros(1, numOfFrames + dispBufLength)};              % allocate memory for the motion signal
  time              = zeros(1, numOfFrames);                                % allocate memory for the time vector

  if hasFrame(VidObj)                                                   
    OldImg      = readFrame(VidObj);                                        % load first image
    load.UserData.Image = OldImg;                                           % update image preview buffer, since slider was reset when start was pressed
    numOfFrames = 1;
  end

  while hasFrame(VidObj) && strcmp(stop.Enable, 'on')                       % do as long as frames available or until stop was pushed
    NewImg      = readFrame(VidObj);                                        % get new frame
    numOfFrames = numOfFrames + 1;                                          % increase number of frames Counter
    sigPointer  = numOfFrames + dispBufLength - 1;                          % determine pointer to current field of the motion signal vector
    timePointer = numOfFrames - 1;                                          % determine pointer to current field of the time vector
    NewImage    = im2double(NewImg);                                        % convert pixel values into double format
    OldImage    = im2double(OldImg);
    NewImage    = rgb2gray(NewImage);                                       % convert images into a grayscale images
    OldImage    = rgb2gray(OldImage);
    
    status = [roiActiv.cb(:).Value];                                        % check which regions of interest are selected
    
    for i=1:1:length(motionSignal)                                          % do it for all selected regions of interest
      if status(i) == true
        NewROI      = GetExcerpt(NewImage, roiData, i);                     % extract the part of the image, wich is defined as region of interest
        OldROI      = GetExcerpt(OldImage, roiData, i);    
      
        motionSignal{i}(sigPointer) = mean(mean((OldROI - NewROI).^2));     % estimate current value
      end
    end
    time(timePointer) = VidObj.CurrentTime;                                 % add current timestamp to time vector

    warning off;
    DiffImage = NewImage - OldImage;
    imshow(AddRoi2Image(DiffImage, roiData, roiActiv), 'Parent', vid);      % display diffence of current grayscale image and its predecessor
    
    sigColour = {[0 0.9 0], [1 0.5 0], 'blue', 'magenta', 'red'};
    for i=1:1:length(motionSignal)                                          % update motion signal time course for all selected regions of interest
      if status(i) == true
        plot(sig, motionSignal{i}((numOfFrames - 1):1: ...
              (numOfFrames + 75 - 1)), 'Color', sigColour{i}); 
        hold(sig, 'on')
      end
    end
    drawnow;                                                                % IMPORTANT: command updates figures and process callbacks
    hold(sig, 'off');
    warning on;
    
    msg = sprintf('Status: Frame: %d ', numOfFrames);                       % update text label
    for i = 1:1:length(motionSignal)
      if status(i) == true
        msg = [msg sprintf('    %s ROI Val.: %d ', roi.description{i}, ...
                       motionSignal{i}(numOfFrames + 75 - 1))];             %#ok<AGROW>
      end
    end
    label.Text = msg;
    
    OldImg = NewImg;                                                        % copy current Image to variable containing the predecessor
  end
  
  % After either the whole video processing was done or stop button pushed
  time = time(1:timePointer);                                               % shrink time vector to its actual length                               
  for i=1:1:length(motionSignal)
    motionSignal{i} = motionSignal{i}(dispBufLength+1:sigPointer);          % shrink motion signal vector to its actual length
  end
  roi.selected(:) = [roiActiv.cb(:).Value];
  
  for i=1:1:length(motionSignal)
    if roi.selected(i) == true
      roi.dimension{i} = [roiData.x0(i).Value roiData.y0(i).Value ...       % get current selection of roi
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
function LoadButtonPushed(vid, slid, start, export, noVis, roiData, ...     % LoadButtonPushed callback
                            roiActiv, address, load)

[file, path] = uigetfile('*.wmv', 'Select video file...');                  % get filename

if ~any(file)                                                               % if cancel was pressed
  [roiData.x0(:).Enable] = deal('off');                                     % disable roi selection
  [roiData.y0(:).Enable] = deal('off');
  [roiData.width(:).Enable] = deal('off');
  [roiData.height(:).Enable] = deal('off');
  [roiData.select(:).Enable] = deal('off');
  [roiActiv.cb(:).Enable] = deal('off');
  start.Enable = 'off';                                                     % disable start button
  export.Enable = 'off';                                                    % disable export button
  noVis.Enable = 'off';                                                     % disable noVis button
  slid.Visible = 'off';                                                     % hide video slider
  slid.Enable = 'off';                                                      % disable video slider
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
  [roiData.select(:).Enable] = deal('off');
  [roiActiv.cb(:).Enable] = deal('off');
  start.Enable = 'off';                                                     % disable start button
  export.Enable = 'off';                                                    % disable export button
  noVis.Enable = 'off';                                                     % disable noVis button
  slid.Visible = 'off';                                                     % hide video slider
  slid.Enable = 'off';                                                      % disable video slider
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
[roiData.select(status).Enable] = deal('on');
[roiActiv.cb(:).Enable] = deal('on');
if any(status)                                                              % motion analysis is only possible, if at least one roi is activ                                                           
  start.Enable = 'on';
  export.Enable = 'on';
  noVis.Enable = 'on';
else
  start.Enable = 'off';
  export.Enable = 'off';
  noVis.Enable = 'off';
end
address.Value = [path file];                                                % set address field

NewImg = readFrame(VidObj);                                                 % load first frame

[roiData.x0(:).Limits] = deal([1 VidObj.Width]);                            % set roi limits to the maximum values of the selected image
[roiData.y0(:).Limits] = deal([1 VidObj.Height]);
[roiData.width(:).Limits] = deal([1 VidObj.Width]);
[roiData.height(:).Limits] = deal([1 VidObj.Height]);

[roiData.x0(1:4).Value] = deal(1);                                          % define initial regions of interest which cover the whole image
[roiData.y0(1:4).Value] = deal(1);
[roiData.width(1:4).Value] = deal(VidObj.Width);
[roiData.height(1:4).Value] = deal(VidObj.Height);

[roiData.x0(5).Value] = deal(VidObj.Width - 200);                           % define the initial base region at top right of the image
[roiData.y0(5).Value] = deal(1);
[roiData.width(5).Value] = deal(200);
[roiData.height(5).Value] = deal(200);

load.UserData.VidObj = VidObj;                                              % keep video object, data of first image and its parameters
load.UserData.Width = VidObj.Width;
load.UserData.Height = VidObj.Height;
load.UserData.Image = NewImg;  

slid.Visible = 'on';                                                        % show video slider
slid.Enable = 'on';                                                         % enable video slider
slid.Limits = [0 (VidObj.duration*1000-2)];                                 % adapt slider limits to video duration
slid.Value = 0;                                                             % reset slider setting

UpdateVidObject(vid, roiData, roiActiv, NewImg);                            % add regions of interest to the image and show image

end

function AddressFieldChanged(vid, slid, start, export, noVis, roiData, ...  % AddressFieldChanged callback
                              roiActiv, address, load)

try                                                                         % validity check
  VidObj = VideoReader(address.Value);                                      % try to get video handle
catch                                                                       % if not possible
  [roiData.x0(:).Enable] = deal('off');                                     % disable roi selection
  [roiData.y0(:).Enable] = deal('off');
  [roiData.width(:).Enable] = deal('off');
  [roiData.height(:).Enable] = deal('off');
  [roiData.select(:).Enable] = deal('off');
  [roiActiv.cb(:).Enable] = deal('off');
  start.Enable = 'off';                                                     % disable start button
  export.Enable = 'off';                                                    % disable export button
  noVis.Enable = 'off';                                                     % disable noVis button
  slid.Visible = 'off';                                                     % hide video slider
  slid.Enable = 'off';                                                      % disable video slider

  imshow([], 'Parent', vid);                                                % clear previous preview
  
  return;                                             
end
                                                                            % if video handle is valid
status = [roiActiv.cb(:).Value];
[roiData.x0(status).Enable] = deal('on');                                   % enable roi selection
[roiData.y0(status).Enable] = deal('on');
[roiData.width(status).Enable] = deal('on');
[roiData.height(status).Enable] = deal('on');
[roiData.select(status).Enable] = deal('on');
[roiActiv.cb(:).Enable] = deal('on');
if any(status)                                                              % motion analysis is only possible, if at least one roi is activ                                                           
  start.Enable = 'on';
  export.Enable = 'on';
  noVis.Enable = 'on';
else
  start.Enable = 'off';
  export.Enable = 'off';
  noVis.Enable = 'off';
end 

NewImg = readFrame(VidObj);                                                 % load first frame

[roiData.x0(:).Limits] = deal([1 VidObj.Width]);                            % set roi limits to the maximum values of the selected image
[roiData.y0(:).Limits] = deal([1 VidObj.Height]);
[roiData.width(:).Limits] = deal([1 VidObj.Width]);
[roiData.height(:).Limits] = deal([1 VidObj.Height]);

[roiData.x0(1:4).Value] = deal(1);                                          % define initial regions of interest which cover the whole image
[roiData.y0(1:4).Value] = deal(1);
[roiData.width(1:4).Value] = deal(VidObj.Width);
[roiData.height(1:4).Value] = deal(VidObj.Height);

[roiData.x0(5).Value] = deal(VidObj.Width - 200);                           % define the initial base region at top right of the image
[roiData.y0(5).Value] = deal(1);
[roiData.width(5).Value] = deal(200);
[roiData.height(5).Value] = deal(200);

load.UserData.VidObj = VidObj;                                              % keep video object, data of first image and its parameters
load.UserData.Width = VidObj.Width;
load.UserData.Height = VidObj.Height;
load.UserData.Image = NewImg;  

slid.Visible = 'on';                                                        % show video slider
slid.Enable = 'on';                                                         % enable video slider
slid.Limits = [0 (VidObj.duration*1000-2)];                                 % adapt slider limits to video duration
slid.Value = 0;                                                             % reset slider setting
UpdateVidObject(vid, roiData, roiActiv, NewImg);                            % add regions of interest to the image and show image

end

function StartButtonPushed(fig, start, stop, save, export, noVis, ...       % StartButtonPushed callback
                           address, load, roiData, roiActiv, slid)

start.Enable = 'off';                                                       % disable start, save, export, noVis and load button
save.Enable = 'off';
export.Enable = 'off';
noVis.Enable = 'off';
load.Enable = 'off';
slid.Enable = 'off';                                                        % disable video slider
slid.Value = 0;                                                             % reset slider position
stop.Enable = 'on';                                                         % enable stop button
address.Enable = 'off';                                                     % disable address field
[roiData.x0(:).Enable] = deal('off');                                       % disable roi selection
[roiData.y0(:).Enable] = deal('off');
[roiData.width(:).Enable] = deal('off');
[roiData.height(:).Enable] = deal('off');
[roiData.select(:).Enable] = deal('off');
[roiActiv.cb(:).Enable] = deal('off');
uiresume(fig);                                                              % activate video processing in the main loop 

end

function StopButtonPushed(vid, start, stop, save, export, noVis, ...        % StopButtonPushed callback
                          address, load, roiData, roiActiv, slid)

start.Enable = 'on';                                                        % enable start, save, export, noVis and load button
save.Enable = 'on';
export.Enable = 'on';
noVis.Enable = 'on';
load.Enable = 'on';
slid.Enable = 'on';                                                         % enable video slider
stop.Enable = 'off';                                                        % disable stop button
address.Enable = 'on';                                                      % enable address field
status = [roiActiv.cb(:).Value];
[roiData.x0(status).Enable] = deal('on');                                   % enable roi selection
[roiData.y0(status).Enable] = deal('on');
[roiData.width(status).Enable] = deal('on');
[roiData.height(status).Enable] = deal('on');
[roiData.select(status).Enable] = deal('on');
[roiActiv.cb(:).Enable] = deal('on');

UpdateVidObject(vid, roiData, roiActiv, load.UserData.Image);               % add updated regions of interest to the image and show image
  
end

function SaveButtonPushed(time, motionSignal, roi, address)                 %#ok<INUSL> SaveButtonPushed callback

address = address.Value(1:end-3);
address = [ address 'mat'];

uisave({'time', 'motionSignal', 'roi'}, address);                           % save time, motionSignal and roi into mat File

end

function ExportButtonPushed(roiData, roiActiv, address)

cfg = [];
cfg.srcPath = address.Value;

cfg.ROI1 = [roiData.x0(1).Value, roiData.y0(1).Value, ...
            roiData.width(1).Value, roiData.height(1).Value];
cfg.ROI2 = [roiData.x0(2).Value, roiData.y0(2).Value, ...
            roiData.width(2).Value, roiData.height(2).Value];
cfg.ROI3 = [roiData.x0(3).Value, roiData.y0(3).Value, ...
            roiData.width(3).Value, roiData.height(3).Value];
cfg.ROI4 = [roiData.x0(4).Value, roiData.y0(4).Value, ...
            roiData.width(4).Value, roiData.height(4).Value];
cfg.baseROI = [roiData.x0(5).Value, roiData.y0(5).Value, ...
               roiData.width(5).Value, roiData.height(5).Value];

cfg.selROI1 = roiActiv.cb(1).Value;
cfg.selROI2 = roiActiv.cb(2).Value;
cfg.selROI3 = roiActiv.cb(3).Value;
cfg.selROI4 = roiActiv.cb(4).Value;
cfg.selbaseROI = roiActiv.cb(5).Value;

address = address.Value(1:end-4);
address = [ address '_roi.mat'];

uisave({'cfg'}, address);

end

function NoVisButtonPushed(start, save, export, noVis, load, slid, ...      % NoVisButtonPushed callback
                           address, roiData, roiActiv)

start.Enable = 'off';                                                       % disable start, save, export, noVis and load button
saveButtonStatus = save.Enable;
save.Enable = 'off';
export.Enable ='off';
noVis.Enable = 'off';
load.Enable = 'off';
slid.Enable = 'off';                                                        % disable video slider
address.Enable = 'off';                                                     % disable address field
[roiData.x0(:).Enable] = deal('off');                                       % disable roi selection
[roiData.y0(:).Enable] = deal('off');
[roiData.width(:).Enable] = deal('off');
[roiData.height(:).Enable] = deal('off');
[roiData.select(:).Enable] = deal('off');
[roiActiv.cb(:).Enable] = deal('off');

cfg = [];
cfg.srcPath = address.Value;

cfg.ROI1 = [roiData.x0(1).Value, roiData.y0(1).Value, ...
            roiData.width(1).Value, roiData.height(1).Value];
cfg.ROI2 = [roiData.x0(2).Value, roiData.y0(2).Value, ...
            roiData.width(2).Value, roiData.height(2).Value];
cfg.ROI3 = [roiData.x0(3).Value, roiData.y0(3).Value, ...
            roiData.width(3).Value, roiData.height(3).Value];
cfg.ROI4 = [roiData.x0(4).Value, roiData.y0(4).Value, ...
            roiData.width(4).Value, roiData.height(4).Value];
cfg.baseROI = [roiData.x0(5).Value, roiData.y0(5).Value, ...
               roiData.width(5).Value, roiData.height(5).Value];

cfg.selROI1 = roiActiv.cb(1).Value;
cfg.selROI2 = roiActiv.cb(2).Value;
cfg.selROI3 = roiActiv.cb(3).Value;
cfg.selROI4 = roiActiv.cb(4).Value;
cfg.selbaseROI = roiActiv.cb(5).Value;

cfg.showpreview = false;

MoDeVi_noView(cfg);

start.Enable = 'on';                                                        % enable start, save, export, noVis and load button
save.Enable = saveButtonStatus;
export.Enable = 'on';
noVis.Enable = 'on';
load.Enable = 'on';
slid.Enable = 'on';                                                         % enable video slider
address.Enable = 'on';                                                      % enable address field
[roiData.x0(:).Enable] = deal('on');                                        % enable roi selection
[roiData.y0(:).Enable] = deal('on');
[roiData.width(:).Enable] = deal('on');
[roiData.height(:).Enable] = deal('on');
[roiData.select(:).Enable] = deal('on');
[roiActiv.cb(:).Enable] = deal('on');

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

function SelectButtonPushed(vid, start, save, export, noVis, load, ...      % SelectButtonPushed callback
                            slid, address, roiData, roiActiv, index)

falseSelection = false;
start.Enable = 'off';                                                       % disable start, save, export, noVis and load button
saveButtonStatus = save.Enable;
save.Enable = 'off';
export.Enable ='off';
noVis.Enable = 'off';
load.Enable = 'off';
slid.Enable = 'off';                                                        % disable video slider
address.Enable = 'off';                                                     % disable address field
[roiData.x0(:).Enable] = deal('off');                                       % disable roi selection
[roiData.y0(:).Enable] = deal('off');
[roiData.width(:).Enable] = deal('off');
[roiData.height(:).Enable] = deal('off');
[roiData.select(:).Enable] = deal('off');
[roiActiv.cb(:).Enable] = deal('off');

h = figure('Name','Select Region of interest','NumberTitle','off');
h.MenuBar = 'none';
warning('off', 'Images:initSize:adjustingMag');
imshow(load.UserData.Image);
warning('on', 'Images:initSize:adjustingMag');
rect = getrect(h);
rect = round(rect);

x0 = rect(1);
y0 = rect(2);
width = rect(3);
height = rect(4);

if x0 > load.UserData.Width                                                 % do nothing, if selection is on the right side of the image
  falseSelection = true;
end

if y0 > load.UserData.Height                                                % do nothing, if selection is below the image
  falseSelection = true;
end

if (x0 + width) < 6                                                         % do nothing, if selection is on the left side of the image
  falseSelection = true;
end

if (y0 + height) < 6                                                        % do nothing, if selection is over the image
  falseSelection = true;
end

if x0 < 1                                                                   % check if horizontal zero point is within the image
  x0 = 1;
  width = width + x0 + 1;
end

if y0 < 1                                                                   % check if vertical zero point is within the image
  y0 = 1;
  height = height + y0 + 1;
end

if (x0 + width -1) > load.UserData.Width                                    % check if horizontal end point is within the image
  width = load.UserData.Width - x0 + 1;
end

if (y0 + height -1) > load.UserData.Height                                  % check if vertical end point is within the image
  height = load.UserData.Height - y0 + 1;
end

pause(1)
start.Enable = 'on';                                                        % enable start, save, export, noVis and load button
save.Enable = saveButtonStatus;
export.Enable = 'on';
noVis.Enable = 'on';
load.Enable = 'on';
slid.Enable = 'on';                                                         % enable video slider
address.Enable = 'on';                                                      % enable address field
[roiData.x0(:).Enable] = deal('on');                                        % enable roi selection
[roiData.y0(:).Enable] = deal('on');
[roiData.width(:).Enable] = deal('on');
[roiData.height(:).Enable] = deal('on');
[roiData.select(:).Enable] = deal('on');
[roiActiv.cb(:).Enable] = deal('on');
close(h);

if falseSelection
  return;
end

roiData.x0(index).Value = x0;                                               % adjust region of interest
roiData.y0(index).Value = y0;
roiData.width(index).Value = width;
roiData.height(index).Value = height;

UpdateVidObject(vid, roiData, roiActiv, load.UserData.Image);               % add regions of interest to the updated image and show image

end

function CheckBoxSwitched(vid, load, start, roiData, roiActiv)

status = ~[roiActiv.cb(:).Value];                                           

[roiData.x0(status).Enable] = deal('off');                                  % disable all unselected region of interest
[roiData.y0(status).Enable] = deal('off');
[roiData.width(status).Enable] = deal('off');
[roiData.height(status).Enable] = deal('off');
[roiData.select(status).Enable] = deal('off');

status = [roiActiv.cb(:).Value];

[roiData.x0(status).Enable] = deal('on');                                   % enable all selected region of interest
[roiData.y0(status).Enable] = deal('on');
[roiData.width(status).Enable] = deal('on');
[roiData.height(status).Enable] = deal('on');
[roiData.select(status).Enable] = deal('on');

if any(status)                                                              % motion analysis is only possible, if at least one roi is activ                                                           
  start.Enable = 'on';
else
  start.Enable = 'off';
end

UpdateVidObject(vid, roiData, roiActiv, load.UserData.Image);               % add updated regions of interest to the image and show image

end

function SliderMoved(slid, vid, load, roiData, roiActiv)

VidObj = load.UserData.VidObj;                                              % get video object
VidObj.CurrentTime = slid.Value/1000;                                       % synchronize slider position with current time in video object

load.UserData.Image = readFrame(VidObj);                                    % load video image which corresponds to slider position and keep it

UpdateVidObject(vid, roiData, roiActiv, load.UserData.Image);               % add regions of interest to the updated image and show image

end

% -------------------------------------------------------------------------
% Other subfunctions
% -------------------------------------------------------------------------
function [image] = AddRoi2Image(image, roiData, roiActiv)                   % add regions of interest in different colours (for rgb images)
                                                                            % or white (for grayscale images) colour to image
roiColorDef = [0, 230, 0; 255, 180, 0; 0, 0, 255; 255, 0, 255; 255, 0, 0];  % frame colour specification
status = [roiActiv.cb(:).Value]; 

for i = 1:1:5
  if status(i) == true
    x0    = roiData.x0(i).Value;                                            % get roi parameters
    xEnd  = roiData.x0(i).Value + roiData.width(i).Value - 1;
    y0    = roiData.y0(i).Value;
    yEnd  = roiData.y0(i).Value + roiData.height(i).Value - 1;

    if size(image, 3) == 1                                                  % if image is in grayscale
      image(y0:yEnd, x0:x0+5) = 1;
      image(y0:yEnd, xEnd-5:xEnd) = 1;
      image(y0:y0+5, x0:xEnd) = 1;
      image(yEnd-5:yEnd, x0:xEnd) = 1;
    elseif size(image, 3) == 3                                              % if image is colored
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
warning('off', 'Images:initSize:adjustingMag');
imshow(image, 'Parent', vid);
warning('on', 'Images:initSize:adjustingMag');
drawnow;

end

function [image] = GetExcerpt(image, roiData, roiNum)                       % extract a region of interest of an image

x0    = roiData.x0(roiNum).Value;                                           % get roi parameters                   
xEnd  = roiData.x0(roiNum).Value + roiData.width(roiNum).Value - 1;
y0    = roiData.y0(roiNum).Value;
yEnd  = roiData.y0(roiNum).Value + roiData.height(roiNum).Value - 1;

image = image(y0:yEnd, x0:xEnd, :);                                         % resize image

end
