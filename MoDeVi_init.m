% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------

filepath = fileparts(mfilename('fullpath'));
addpath(sprintf('%s/:%s/utilities', filepath, filepath));

clear filepath