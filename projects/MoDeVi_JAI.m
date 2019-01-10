%% Export von Bewegungsparametern pro Bedingung

% Copyright (C) 2018, Christine Michel, Daniel Matthes, MPI CBS

% Das Skript berechnet für alle ROIs und alle Bedingungen den Mittelwert,
% den Median und die Summe über alle Bewegungswerte einer Bedingung. Die
% Ergebnisvariablen meanVal, medianVal und sumVal haben die Dimension NxM.
% N steht für die Anzahl der ROI und M für die Anzahl der Bedingungen.

%% Grundvoraussetzung: Output von MoDeVi_synch im Workspace

% Zunächst ist das M-file mit den Motion-Werten einzulesen, nachdem es
% unter Verwendung der Funktion modevi_synch mit dem vmrk-File
% synchronisiert und abgespeichert wurde. Danach ist dieses Skript 
% auszuführen.

%% Initialisierung
% -------------------------------------------------------------------------
% Spezifiziere Dyade
% -------------------------------------------------------------------------
dyad = 1;                                                                   % WICHTIG: hier vorliegende Dyadnummer richtig einstellen

% -------------------------------------------------------------------------
% Testen ob erforderlichen Variablen im Workspace vorhanden sind
% -------------------------------------------------------------------------
if ~exist('trialinfo', 'var') || ~exist('sampleinfo', 'var') || ...
    ~exist('motionSignalIntpl', 'var') || ~exist('roi', 'var')
  error('Load complete dataset first');
end

% -------------------------------------------------------------------------
% Speicher Allozierung (beschleunigt Berechnung)
% -------------------------------------------------------------------------
meanVal   = zeros(5, numel(trialinfo));
medianVal = zeros(5, numel(trialinfo));
sumVal    = zeros(5, numel(trialinfo));
data      = [];
condition = [];

% -------------------------------------------------------------------------
% Triggerwerte korrigieren (128-Bug)
% -------------------------------------------------------------------------
% Zu Beginn der Studie waren alle Triggerwerte noch um den Faktor 128 zu 
% hoch. Nach der Behebung des Fehlers lagen alle Trigger unter 128. 
% Wenn also alle Trigger in der trialinfo größer als 128 sind, 
% dann korrigiere die trialinfo

if all(trialinfo > 128)
  trialinfo = trialinfo - 128;
end

% -------------------------------------------------------------------------
% Spezifikation der Standartreihenfolge der Bedingungen
% -------------------------------------------------------------------------
% Da die Bedingungen für jeder Dyade in einer anderen Reihenfolge 
% aufgezeichnet wurden, muss das Ergebnis dieser Auswertung stets sortiert 
% werden, damit später die Daten aller Dyaden einfach miteinander 
% verglichen werden können.

trialinfo_default = [111,2,3,4,5,6,31,32,41,42,51,52,100,101,102,7,8,9,...
                     10,11,12,20,21,22,105];

% -------------------------------------------------------------------------
% Ermittlung der tatsächlichen Position im aktuellen Datensatz
% -------------------------------------------------------------------------
% Position wird in die Variable 'pos' gespeichert.
[~, pos] = ismember(trialinfo_default, trialinfo);

%% Processing
% -------------------------------------------------------------------------
% Berechnung von Mittelwert, Median und Summe der Bewegungswerte pro
% Bedingung
% -------------------------------------------------------------------------
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
  end
  
  if (endsample > numel(sampleNumIntpl))
    endsample = numel(sampleNumIntpl);
    warning off backtrace
    warning(['Video recording was to short for an exact evaluation of ' ...
              'condition %d'], trialinfo(i));
    warning on backtrace
  end
  
  for r = 1:5                                                               % da grundsätzlich fünf ROIs definiert sind
    window          = motionSignalIntpl{r}(begsample:endsample);
    meanVal(r,i)    = mean(window);
    medianVal(r,i)  = median(window);
    sumVal(r,i)     = sum(window);
  end
end

% Spezifikation und Status (aktiv / nicht aktiv) der ROIs aus der Variable
% 'roi' extrahieren, damit diese Information in den folgenden Schritten in
% die Exceltabellen hinzugefügt werden kann.

ROI = cell(5,4);
for r = 1:5 
  ROI(r,:) = num2cell(roi.dimension{r});
end

selected = roi.selected;
selected_vertical = selected';
selected_vertical = num2cell(selected_vertical);

% -------------------------------------------------------------------------
% Erstelle Excel-Tabelle für Parameter meanVal
% -------------------------------------------------------------------------
% Spalten (Bedingungen) in die Default-Reihenfolge(sihe 'trialinfo_default')
% bringen
meanVal = meanVal(:,pos);
meanVal= num2cell(meanVal);
% ROI Spezifikation/Status hinzufügen
meanVal = [ROI meanVal];
meanVal = [selected_vertical meanVal];
% ROI Namen hinzufügen (ist sozusagen die Zeilenbezeichnung)
meanVal =  [{'roi1'; 'roi2'; 'roi3'; 'roi4'; 'roi5'} meanVal];
T = cell2table(meanVal);
% Spalten benennen
T.Properties.VariableNames = { 'ROI', 'activated', 'ROI_Start_X', ...
    'ROI_Start_Y', 'ROI_width', 'ROI_height', 'S111', 'S2', 'S3', 'S4', ...
    'S5', 'S6', 'S31', 'S32', 'S41', 'S42', 'S51', 'S52', 'S100', ...
    'S101', 'S102', 'S7', 'S8', 'S9', 'S10', 'S11', 'S12', 'S20', 'S21',...
    'S22', 'S105'};
% Export der Tabelle mit der Dyadennummer, wie ganz oben definiert
writetable(T, sprintf('JAI_exports/dyad%02d_mean.xls', dyad));

% -------------------------------------------------------------------------
% Erstelle Excel-Tabelle für Parameter medianVal
% -------------------------------------------------------------------------
% Spalten (Bedingungen) in die Default-Reihenfolge(sihe 'trialinfo_default')
% bringen
medianVal = medianVal(:,pos);
medianVal = num2cell(medianVal);
% ROI Spezifikation/Status hinzufügen
medianVal = [ROI medianVal];
medianVal = [selected_vertical medianVal];
% ROI Namen hinzufügen (ist sozusagen die Zeilenbezeichnung)
medianVal =  [{'roi1'; 'roi2'; 'roi3'; 'roi4'; 'roi5'} medianVal];
T = cell2table(medianVal);
% Spalten benennen
T.Properties.VariableNames = { 'ROI', 'activated', 'ROI_Start_X', ...
    'ROI_Start_Y', 'ROI_width', 'ROI_height', 'S111', 'S2', 'S3', 'S4', ...
    'S5', 'S6', 'S31', 'S32', 'S41', 'S42', 'S51', 'S52', 'S100', ...
    'S101', 'S102', 'S7', 'S8', 'S9', 'S10', 'S11', 'S12', 'S20', 'S21',...
    'S22', 'S105'};
% Export der Tabelle mit der Dyadennummer, wie ganz oben definiert
writetable(T, sprintf('JAI_exports/dyad%02d_median.xls', dyad));

% -------------------------------------------------------------------------
% Erstelle Excel-Tabelle für Parameter sumVal
% -------------------------------------------------------------------------
% Spalten (Bedingungen) in die Default-Reihenfolge(sihe 'trialinfo_default')
% bringen
sumVal = sumVal(:,pos);
sumVal = num2cell(sumVal);
% ROI Spezifikation/Status hinzufügen
sumVal = [ROI sumVal];
sumVal = [selected_vertical sumVal];
% ROI Namen hinzufügen (ist sozusagen die Zeilenbezeichnung)
sumVal =  [{'roi1'; 'roi2'; 'roi3'; 'roi4'; 'roi5'} sumVal];
T = cell2table(sumVal);
% Spalten benennen
T.Properties.VariableNames = { 'ROI', 'activated', 'ROI_Start_X', ...
    'ROI_Start_Y', 'ROI_width', 'ROI_height', 'S111', 'S2', 'S3', 'S4', ...
    'S5', 'S6', 'S31', 'S32', 'S41', 'S42', 'S51', 'S52', 'S100', ...
    'S101', 'S102', 'S7', 'S8', 'S9', 'S10', 'S11', 'S12', 'S20', 'S21',...
    'S22', 'S105'};
% Export der Tabelle mit der Dyadennummer, wie ganz oben definiert
writetable(T, sprintf('JAI_exports/dyad%02d_sum.xls', dyad));

% -------------------------------------------------------------------------
% Lösche workspace
% -------------------------------------------------------------------------
clear
