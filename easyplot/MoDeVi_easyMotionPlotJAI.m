function MoDeVi_easyMotionPlotJAI(motionSignalIntpl, sampleNumIntpl, trialinfo, sampleinfo, roiNum)
% MODEVI_EASYMOTIONPLOTJAI is plotting the interpolated motion signal and
% and highighting each condition.
%
% Use as
%   MoDeVi_easyMotionPlotJAI(motionSignalIntpl, sampleNumIntpl, trialinfo, sampleinfo, roiNum)
%
% where the input data has to be a result of the MoDeVi_synch script.
%
% Copyright (C) 2018, Daniel Matthes, MPI CBS 

plot(sampleNumIntpl, motionSignalIntpl{roiNum});

for i = 1:1:numel(trialinfo)
  switch trialinfo(i)
    case {111, 2, 3, 4, 5, 6}
      begsample = sampleinfo(i);
      endsample = sampleinfo(i) + 120*500 - 1;
    case {31, 32, 41, 42, 51, 52, 100, 101, 102, 7, 8, 9, 10, 11, 12, ...
          20, 21, 22}
      begsample = sampleinfo(i);
      endsample = sampleinfo(i) + 180*500 - 1;
    case 105
      begsample = sampleinfo(i);
      endsample = sampleinfo(i) + 300*500 - 1;
    case {239, 130, 131, 132, 133, 134}
      begsample = sampleinfo(i);
      endsample = sampleinfo(i) + 120*500 - 1;
      trialinfo = trialinfo - 128;
    case {159, 160, 169, 170, 179, 180, 228, 229, 230, 135, 136, 137, ...
          138, 139, 140, 148, 149, 150}
      begsample = sampleinfo(i);
      endsample = sampleinfo(i) + 180*500 - 1;
      trialinfo = trialinfo - 128;
    case 233
      begsample = sampleinfo(i);
      endsample = sampleinfo(i) + 130*500 - 1;
      trialinfo = trialinfo - 128;
  end

  x_vect = [begsample endsample endsample begsample];
  currAxis = gca;
  y_vect = [currAxis.YLim(1) currAxis.YLim(1) ...
              currAxis.YLim(2) currAxis.YLim(2)];
  text(begsample, currAxis.YLim(2) - 0.05*(currAxis.YLim(2)-currAxis.YLim(1)), sprintf('%d', trialinfo(i)));
  patch(x_vect, y_vect, [0.8 0.8 0.8], 'LineStyle', 'none');
end

set(currAxis,'children',flipud(get(currAxis,'children')));
