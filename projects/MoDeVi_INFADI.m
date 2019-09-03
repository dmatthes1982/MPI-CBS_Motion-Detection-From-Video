%% Export von Bewegungsparametern pro Bedingung

% Copyright (C) 2019, Christine Michel, Daniel Matthes, MPI CBS

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
dyad = 4;                                                                   % WICHTIG: hier vorliegende Dyadnummer richtig einstellen

% -------------------------------------------------------------------------
% Testen ob erforderlichen Variablen im Workspace vorhanden sind
% -------------------------------------------------------------------------
if ~exist('trialinfo', 'var') || ~exist('sampleinfo', 'var') || ...
    ~exist('motionSignalIntpl', 'var') || ~exist('roi', 'var')
  error('Load complete dataset first');
end

% -------------------------------------------------------------------------
% Spezifikation der Standartreihenfolge der Bedingungen
% -------------------------------------------------------------------------
% Da die Bedingungen für jeder Dyade in einer anderen Reihenfolge 
% aufgezeichnet wurden, muss das Ergebnis dieser Auswertung stets sortiert 
% werden, damit später die Daten aller Dyaden einfach miteinander 
% verglichen werden können.

trialinfo_default = [5,2,3,4];
default_cond      = trialinfo_default;
default_stopmrk   = [6,9,99];

% -------------------------------------------------------------------------
% Speicher Allozierung (beschleunigt Berechnung)
% -------------------------------------------------------------------------
meanVal   = zeros(5, numel(trialinfo_default));
medianVal = zeros(5, numel(trialinfo_default));
sumVal    = zeros(5, numel(trialinfo_default));
data      = [];
condition = [];

% -------------------------------------------------------------------------
% Anpassung von trialinfo und sampleinfo: Marker 6,9 und 99 stehen für das
% Ende eines Trials der Bedingungen 5,2,3 oder 4
% -------------------------------------------------------------------------
% Lösche alle Einträge die nicht den default conditions oder den default
% Stop markern entsprechen
pos = ~ismember(trialinfo, [default_cond, default_stopmrk]);
trialinfo(pos) = [];
sampleinfo(pos) = [];

% Modifiziere trialinfo und sampleinfo
cond = ismember(trialinfo, default_cond);
stopmrk = circshift(cond, 1);
if ~all(ismember(trialinfo(stopmrk), default_stopmrk))
  error('Es existiert nicht für jede Bedingung ein Stopmarker. Korrigiere zunächst das VMRK file!');
end

sampleinfo(cond,2) = sampleinfo(stopmrk,1);
trialinfo = trialinfo(cond);
sampleinfo = sampleinfo(cond,:);

%% Processing
% -------------------------------------------------------------------------
% Berechnung von Mittelwert, Median und Summe der Bewegungswerte pro
% Bedingung
% -------------------------------------------------------------------------
for r = 1:5                                                                 % da grundsätzlich fünf ROIs definiert sind
  for i = 1:1:numel(trialinfo_default)
    window = [];
    trials = sampleinfo(ismember(trialinfo, trialinfo_default(i)),:);
    for j=1:1:size(trials,1)
      window = [window motionSignalIntpl{r}(trials(j,1):trials(j,2))];          %#ok<AGROW>
    end
    
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

if ~exist('INFADI_exports', 'dir')
  mkdir INFADI_exports
end

% -------------------------------------------------------------------------
% Erstelle Excel-Tabelle für Parameter meanVal
% -------------------------------------------------------------------------
meanVal= num2cell(meanVal);
% ROI Spezifikation/Status hinzufügen
meanVal = [ROI meanVal];
meanVal = [selected_vertical meanVal];
% ROI Namen hinzufügen (ist sozusagen die Zeilenbezeichnung)
meanVal =  [{'roi1'; 'roi2'; 'roi3'; 'roi4'; 'roi5'} meanVal];
T = cell2table(meanVal);
% Spalten benennen
T.Properties.VariableNames = { 'ROI', 'activated', 'ROI_Start_X', ...
    'ROI_Start_Y', 'ROI_width', 'ROI_height', 'S5', 'S2', 'S3', 'S4'};
% Export der Tabelle mit der Dyadennummer, wie ganz oben definiert
writetable(T, sprintf('INFADI_exports/dyad%02d_mean.xls', dyad));

% -------------------------------------------------------------------------
% Erstelle Excel-Tabelle für Parameter medianVal
% -------------------------------------------------------------------------
medianVal = num2cell(medianVal);
% ROI Spezifikation/Status hinzufügen
medianVal = [ROI medianVal];
medianVal = [selected_vertical medianVal];
% ROI Namen hinzufügen (ist sozusagen die Zeilenbezeichnung)
medianVal =  [{'roi1'; 'roi2'; 'roi3'; 'roi4'; 'roi5'} medianVal];
T = cell2table(medianVal);
% Spalten benennen
T.Properties.VariableNames = { 'ROI', 'activated', 'ROI_Start_X', ...
    'ROI_Start_Y', 'ROI_width', 'ROI_height', 'S5', 'S2', 'S3', 'S4'};
% Export der Tabelle mit der Dyadennummer, wie ganz oben definiert
writetable(T, sprintf('INFADI_exports/dyad%02d_median.xls', dyad));

% -------------------------------------------------------------------------
% Erstelle Excel-Tabelle für Parameter sumVal
% -------------------------------------------------------------------------
sumVal = num2cell(sumVal);
% ROI Spezifikation/Status hinzufügen
sumVal = [ROI sumVal];
sumVal = [selected_vertical sumVal];
% ROI Namen hinzufügen (ist sozusagen die Zeilenbezeichnung)
sumVal =  [{'roi1'; 'roi2'; 'roi3'; 'roi4'; 'roi5'} sumVal];
T = cell2table(sumVal);
% Spalten benennen

T.Properties.VariableNames = { 'ROI', 'activated', 'ROI_Start_X', ...
    'ROI_Start_Y', 'ROI_width', 'ROI_height', 'S5', 'S2', 'S3', 'S4'};
% Export der Tabelle mit der Dyadennummer, wie ganz oben definiert
writetable(T, sprintf('INFADI_exports/dyad%02d_sum.xls', dyad));

% -------------------------------------------------------------------------
% Lösche workspace
% -------------------------------------------------------------------------
clear
