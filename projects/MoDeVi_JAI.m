% -------------------------------------------------------------------------
% check workspace
% -------------------------------------------------------------------------
if ~exist('trialinfo', 'var') || ~exist('sampleinfo', 'var') || ~exist('motionSignalIntpl', 'var')
  error('Load dataset first');
end

% -------------------------------------------------------------------------
% allocate memory
% -------------------------------------------------------------------------
meanVal   = zeros(1, numel(trialinfo));
medianVal = zeros(1, numel(trialinfo));
sumVal    = zeros(1, numel(trialinfo));
data      = [];
condition = [];

% -------------------------------------------------------------------------
% processing
% -------------------------------------------------------------------------
for i = 1:1:numel(trialinfo)
  switch trialinfo(i)
    case {111, 2, 3, 4, 5, 6}
      begsample = sampleinfo(i);
      endsample = sampleinfo(i) + 120*500 - 1;
    case {31, 32, 41, 42, 51, 52, 100, 101, 102, 7, 8, 9, 10, 11, 12, ...
          20, 21, 22}
      begsample = sampleinfo(i);
      endsample = sampleinfo(i) + 120*500 - 1;
    case 105
      begsample = sampleinfo(i);
      endsample = sampleinfo(i) + 120*500 - 1;
    case {239, 130, 131, 132, 133, 134}
      begsample = sampleinfo(i);
      endsample = sampleinfo(i) + 120*500 - 1;
      trialinfo = trialinfo - 128;
    case {159, 160, 169, 170, 179, 180, 228, 229, 230, 135, 136, 137, ...
          138, 139, 140, 148, 149, 150}
      begsample = sampleinfo(i);
      endsample = sampleinfo(i) + 120*500 - 1;
      trialinfo = trialinfo - 128;
    case 233
      begsample = sampleinfo(i);
      endsample = sampleinfo(i) + 120*500 - 1;
      trialinfo = trialinfo - 128;
  end
  
  if (endsample > numel(sampleNumIntpl))
    endsample = numel(sampleNumIntpl);
    warning('Video recording was to short for an exact evaluation of condition %d', trialinfo(i));
  end
  
  window        = motionSignalIntpl{1}(begsample:endsample);
  meanVal(i)    = mean(window);
  medianVal(i)  = median(window);
  sumVal(i)     = sum(window);
  
  data      = [ data, window ];                                             %#ok<AGROW>
  condition = [ condition, repmat(trialinfo(i), 1, numel(window)) ];        %#ok<AGROW>
end

boxplot(data, condition);
