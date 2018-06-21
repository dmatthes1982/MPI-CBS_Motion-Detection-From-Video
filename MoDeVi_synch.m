% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------
clc;
MoDeVi_init;

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
  cprintf([1,0.5,0], '\This script requires the fieldtrip toolbox\n');
  cprintf([1,0.5,0], 'But fieldtrip seems not to be on your system.\n');
  return;
end

% -------------------------------------------------------------------------
% Select associated MAT and VMRK files
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

if ~exist('motionSignal','var') || ~exist('roi','var') || ...
    ~exist('time','var')
  cprintf([1,0.5,0], 'The selected MAT-File contains wrong content\n');
  return;
end

event = ft_read_event(vmrkFile);
hdr   = ft_read_header(vhdrFile);

% -------------------------------------------------------------------------
% Extract trigger and sampling frequency
% -------------------------------------------------------------------------
fsample = hdr.Fs;
types = { event(:).type };
index = ismember(types, 'Response');
index = index | ismember(types, 'Stimulus');
event = event(index);

trigger     = { event(:).value };
videoStart  = find(ismember(trigger, 'R128'), 1, 'first');
stimuli     = contains(trigger, 'S');
trialinfo   = cell2mat(cellfun(@(x) sscanf(x,'S%d'), trigger(stimuli), ...
              'UniformOutput', false)');                                    %#ok<*NASGU>

videoStart = event(videoStart).sample;
sampleinfo = [ event(stimuli).sample ]';
duration = [ event(stimuli).duration ]';
sampleinfo(:,2) = sampleinfo(:,1) + duration - 1;

% -------------------------------------------------------------------------
% Calculate sample vector
% -------------------------------------------------------------------------
fprintf('\n<strong>Estimate sample number vector...</strong>\n');

sampleNum = round(time*fsample);
sampleNum = sampleNum + videoStart - 1;

% -------------------------------------------------------------------------
% Interpolate the data to get for the motion Signal the same resolution
% which also the eeg signal has.
% -------------------------------------------------------------------------
fprintf('<strong>Interpolate motion signals...</strong>\n');

begsample = sampleNum(1);
endsample = sampleNum(end);
sampleNumIntpl = begsample:1:endsample;

numOfSignals = length(motionSignal);
motionSignalIntpl{numOfSignals} = [];

for i = 1:1:numOfSignals
  if ~isempty(motionSignal{i})
    motionSignalIntpl{i} = interp1(sampleNum, motionSignal{i}, ...
                                      sampleNumIntpl, 'spline');
  end
end

% -------------------------------------------------------------------------
% Save workspace
% -------------------------------------------------------------------------
fprintf('Save workspace into MAT file...\n');
save(motionSigFile, 'fsample', 'motionSignal', 'motionSignalIntpl', ...
      'roi', 'sampleinfo', 'sampleNum', 'sampleNumIntpl', 'time', ...
      'trialinfo', 'videoStart')

% -------------------------------------------------------------------------
% Clear workspace
% -------------------------------------------------------------------------
clear motionSigFile motionSigPath vmrkFile vmrkPath vhdrFile event hdr ...
      types index trigger stimuli duration fsample motionSignal roi ...
      sampleinfo sampleNum time trialinfo videoStart begsample begsample ...
      endsample sampleNumIntpl numOfSignals motionSignalIntpl i
