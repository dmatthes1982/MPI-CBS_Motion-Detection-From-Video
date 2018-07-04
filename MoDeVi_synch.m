% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------
clc;                                                                        % clear workspace
MoDeVi_init;                                                                % add utilities folder to path

cprintf([0,0.6,0], '<strong>-----------------------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>Motion detection from Video</strong>\n');
cprintf([0,0.6,0], '<strong>Synchronization of video timestamps with eeg sample numbers</strong>\n');
cprintf([0,0.6,0], '<strong>Version: 0.1</strong>\n');
cprintf([0,0.6,0], 'Copyright (C) 2018, Daniel Matthes, MPI CBS\n');
cprintf([0,0.6,0], '<strong>-----------------------------------------------------------</strong>\n');

% -------------------------------------------------------------------------
% Check if fieldtrip is on the system
% -------------------------------------------------------------------------
try [~] = ft_version;
catch
  cprintf([1,0.5,0], '\nThis script requires the fieldtrip toolbox\n');
  cprintf([1,0.5,0], 'But fieldtrip seems not to be on your system.\n');
  return;
end

% -------------------------------------------------------------------------
% Select associated MAT, VMRK and VHDR files
% -------------------------------------------------------------------------
fprintf('\n<strong>Select files...</strong>\n');

[motionSigFile, motionSigPath] = uigetfile('/data/*.mat', 'Select MAT file containing motion signals...');
motionSigFile = [motionSigPath motionSigFile];
fprintf('\n<strong>Selected MAT file:</strong> %s\n', motionSigFile);

[vmrkFile, vmrkPath] = uigetfile('/data/*.vmrk', 'Select corresponding VMRK file...');
vmrkFile = [vmrkPath vmrkFile];
fprintf('<strong>Selected VMRK file:</strong> %s\n', vmrkFile);

vhdrFile = strsplit(vmrkFile, '.vmrk');
vhdrFile = vhdrFile{1};
vhdrFile = [vhdrFile '.vhdr'];

% -------------------------------------------------------------------------
% Load data
% -------------------------------------------------------------------------
load(motionSigFile, 'motionSignal', 'roi', 'time');

if ~exist('motionSignal','var') || ~exist('roi','var') || ...               % check if the selected MAT file is valid
    ~exist('time','var')
  cprintf([1,0.5,0], 'The selected MAT-File contains wrong content\n');
  return;
end

event = ft_read_event(vmrkFile);                                            % get all events from VMRK file
hdr   = ft_read_header(vhdrFile);                                           % get header informations

% -------------------------------------------------------------------------
% Extract trigger and sampling frequency
% -------------------------------------------------------------------------
fsample = hdr.Fs;                                                           % extract sampling frequency
types = { event(:).type };                                                  % get all trigger types
index = ismember(types, 'Response');
index = index | ismember(types, 'Stimulus');
event = event(index);                                                       % prune the event matrix (only response and stimulus events are of interest)

trigger     = { event(:).value };                                           % extract all trigger values from the pruned event matrix
videoStart  = find(ismember(trigger, 'R128'), 1, 'first');                  % locate first video trigger
stimuli     = contains(trigger, 'S');                                       % locate all stimulus triggers
trialinfo   = cell2mat(cellfun(@(x) sscanf(x,'S%d'), trigger(stimuli), ...  % create trialinfo from the set of stimulus triggers
              'UniformOutput', false)');                                    %#ok<*NASGU>

videoStart = event(videoStart).sample;                                      % estimate sampling point, when recording was started
sampleinfo = [ event(stimuli).sample ]';                                    % create sampleinfo
duration = [ event(stimuli).duration ]';
sampleinfo(:,2) = sampleinfo(:,1) + duration - 1;

% -------------------------------------------------------------------------
% Calculate sample vector
% -------------------------------------------------------------------------
fprintf('\n<strong>Estimate sample number vector...</strong>\n');

sampleNum = round(time*fsample);                                            % convert video image timestamps to sampling point numbers
sampleNum = sampleNum + videoStart - 1;                                     % add video start offset

% -------------------------------------------------------------------------
% Interpolate the data to get for the motion Signal the same resolution
% which also the eeg signal has.
% -------------------------------------------------------------------------
fprintf('<strong>Interpolate motion signals...</strong>\n');

begsample = sampleNum(1);
endsample = sampleNum(end);
sampleNumIntpl = begsample:1:endsample;                                     % create sampling point vector for the interpolated data

numOfSignals = length(motionSignal);                                        % estimate total number of motion signals
motionSignalIntpl{numOfSignals} = [];                                       % allocate memory for the interpolated motion signals

for i = 1:1:numOfSignals
  if ~isempty(motionSignal{i})
    motionSignalIntpl{i} = interp1(sampleNum, motionSignal{i}, ...          % interpolate motion signals
                                      sampleNumIntpl, 'spline');
  end
end

% -------------------------------------------------------------------------
% Save workspace
% -------------------------------------------------------------------------
fprintf('Save workspace into MAT file...\n');
save(motionSigFile, 'fsample', 'motionSignal', 'motionSignalIntpl', ...     % add all estimated values to the dataset with motion signals
      'roi', 'sampleinfo', 'sampleNum', 'sampleNumIntpl', 'time', ...
      'trialinfo', 'videoStart')

% -------------------------------------------------------------------------
% Clear workspace
% -------------------------------------------------------------------------
clear motionSigFile motionSigPath vmrkFile vmrkPath vhdrFile event hdr ...
      types index trigger stimuli duration fsample motionSignal roi ...
      sampleinfo sampleNum time trialinfo videoStart begsample begsample ...
      endsample sampleNumIntpl numOfSignals motionSignalIntpl i
