function DetectionConfidence()
% Script for training and performing mice a detection in noise task with
% confidence reports

global BpodSystem
global TaskParameters
%global StimulusSettings

%% Task parameters
TaskParameters = BpodSystem.ProtocolSettings;
try TaskParameters=rmfield(TaskParameters,'nidaq');end
if isempty(fieldnames(TaskParameters))
    %general
    TaskParameters.GUI.Ports_LMR = '123'; %Port IDs signal center noise
    TaskParameters.GUI.AfterTrialInterval = .5; %DurAfterTrialIntervalon of after trial interval before next trial starts(s)
    TaskParameters.GUI.AfterTrialIntervalJitter = true; %Exponential jitter for after trial interval
    TaskParameters.GUI.AfterTrialIntervalMin = .1;%Minimum for jitter
    TaskParameters.GUI.AfterTrialIntervalMax = 2.5;%Maximum for jitter
    TaskParameters.GUIMeta.AfterTrialIntervalJitter.Style = 'checkbox';
    TaskParameters.GUI.LightGuidance = true;%LED ports indicate active ports, if false LED ports remain on when active
    TaskParameters.GUIMeta.LightGuidance.Style = 'checkbox';   
    TaskParameters.GUIPanels.General = {'Ports_LMR','AfterTrialInterval','AfterTrialIntervalJitter','AfterTrialIntervalMin','AfterTrialIntervalMax','LightGuidance'};
    
    %sampling period: events, duration and reinforcement for duration
    TaskParameters.GUI.DecisionVariable=2;
    TaskParameters.GUIMeta.DecisionVariable.Style = 'popupmenu';
    TaskParameters.GUIMeta.DecisionVariable.String = {'discrete','continuous'};
    TaskParameters.GUI.BetaParam=0.1;
    
    TaskParameters.GUI.NoiseVolumeTable.NoiseVolume=[20 40 60]';
    TaskParameters.GUI.NoiseVolumeTable.SignalVolume=[50 45 40]';
    TaskParameters.GUI.NoiseVolumeTable.Prob=[1 1 1]';
    
    TaskParameters.GUIMeta.NoiseVolumeTable.Style = 'table';
    TaskParameters.GUIMeta.NoiseVolumeTable.String = 'Noise volumes';
    TaskParameters.GUIMeta.NoiseVolumeTable.ColumnLabel = {'noise','signal','probabilty'};
    
    TaskParameters.GUI.ContinuousTable.NoiseLimits=[35 50]';
    TaskParameters.GUI.ContinuousTable.SignalLimits=[45 30]';
    
    TaskParameters.GUIMeta.ContinuousTable.Style = 'table';
    TaskParameters.GUIMeta.ContinuousTable.String = 'Decision variable';
    TaskParameters.GUIMeta.ContinuousTable.ColumnLabel = {'noiseLims','signalLims'};
    
    TaskParameters.GUI.BiasVersion = 3;
    TaskParameters.GUIMeta.BiasVersion.Style = 'popupmenu';
    TaskParameters.GUIMeta.BiasVersion.String = {'None','Soft','Block','Noise'};%Soft: use for bias correction, calculates bias over all trials and presents non-prefered stimulus with p=1-bias.
    TaskParameters.GUI.BiasTable.Signal=[.3 .5 .7]';
    TaskParameters.GUI.BiasTable.Noise=[35 40 45]';
    TaskParameters.GUI.BiasTable.BlockLength=[2000 0 0]';
    TaskParameters.GUIMeta.BiasTable.Style = 'table';
    TaskParameters.GUIMeta.BiasTable.String = 'Bias blocks';
    TaskParameters.GUIMeta.BiasTable.ColumnLabel = {'signal bias','noise','trials'};

    
    TaskParameters.GUI.EasyTrials=20;
    TaskParameters.GUI.StimDuration=0.1;
    TaskParameters.GUIPanels.Stimulus = {'DecisionVariable','BetaParam','EasyTrials','StimDuration'};
    TaskParameters.GUIPanels.NoiseVolumeTable ={'NoiseVolumeTable'};
    TaskParameters.GUIPanels.ContinuousTable ={'ContinuousTable'};
    TaskParameters.GUIPanels.BiasVersion={'BiasVersion'};
    TaskParameters.GUIPanels.BiasTable={'BiasTable'};
    

    
    TaskParameters.GUI.PreStimDurationSelection = 3;
    TaskParameters.GUIMeta.PreStimDurationSelection.Style = 'popupmenu';
    TaskParameters.GUIMeta.PreStimDurationSelection.String = {'Fix','AutoIncr','TruncExp'};
    TaskParameters.GUI.PreStimDurationTau = 0.2;
    
    TaskParameters.GUI.PreStimDurationMin = 0.05;%minimum sample time required for reward will not decrease further (0.05 in Marion's script)
    TaskParameters.GUI.PreStimDuration = TaskParameters.GUI.PreStimDurationMin;
    TaskParameters.GUIMeta.PreStimDuration.Style = 'text';
    TaskParameters.GUI.PreStimDurationMax = .5; %sample time required for reward will not increase further (0.5)
    TaskParameters.GUI.PreStimDurationRampUp = 0.01;
    TaskParameters.GUI.PreStimDurationRampDown = 0.005;
    TaskParameters.GUI.RewardAmountCenter = 0.5;%reward amount center ports (marion .5)
    
    TaskParameters.GUI.RewardAmountCenterSelection = 2;
    TaskParameters.GUIMeta.RewardAmountCenterSelection.Style = 'text';
    TaskParameters.GUIMeta.RewardAmountCenterSelection.Style = 'popupmenu';
    TaskParameters.GUIMeta.RewardAmountCenterSelection.String = {'Fix','Decrease'};
    TaskParameters.GUI.RewardAmountCenterEasyTrials = 50;
    
    
    TaskParameters.GUI.CoutEarlyTimeout = 0;%time out for early withdrawal (marion 1s)
    TaskParameters.GUIPanels.Timing = {'PreStimDuration',...
        'PreStimDurationSelection','PreStimDurationMin','PreStimDurationMax','PreStimDurationRampUp','PreStimDurationRampDown','PreStimDurationTau'};
    
    TaskParameters.GUIPanels.Sampling = {'RewardAmountCenter',...
        'RewardAmountCenterSelection','RewardAmountCenterEasyTrials','CoutEarlyTimeout'};
    
    %Choice
    TaskParameters.GUI.ChoiceDeadline = 5; %Maximal Interval for choice after stimulus presentAfterTrialIntervalon   
    TaskParameters.GUI.RewardAmountCorrect = 5;%reward amount lateral ports (marion 5)
    TaskParameters.GUI.RewardAmountError = 0;%reward amount lateral ports (marion 5)
    TaskParameters.GUI.ErrorTimeout = 0;%time out for errors
    TaskParameters.GUIPanels.Choice = {'ChoiceDeadline','RewardAmountCorrect','RewardAmountError','ErrorTimeout'};%,'Deplete','DepleteRate','Jackpot','JackpotMin','JackpotTime'};
    
    %Feedback delay %UPDATE TO GRAY OUT IRRELEVANT FIELDS
    TaskParameters.GUI.FeedbackDelaySelection = 1;
    TaskParameters.GUIMeta.FeedbackDelaySelection.Style = 'popupmenu';
    TaskParameters.GUIMeta.FeedbackDelaySelection.String = {'Fix','AutoIncr','TruncExp'};
    TaskParameters.GUI.FeedbackDelayMin = 0;
    TaskParameters.GUI.FeedbackDelayMax = 0;
    TaskParameters.GUI.FeedbackDelayIncr = 0.01;
    TaskParameters.GUI.FeedbackDelayDecr = 0.01;
    TaskParameters.GUI.FeedbackDelayTau = 0.05;
    TaskParameters.GUI.FeedbackDelayGrace = 0;
    TaskParameters.GUI.PercentCatch = 0;
    TaskParameters.GUI.CatchError = false;
    TaskParameters.GUIMeta.CatchError.Style = 'checkbox';
    TaskParameters.GUI.FeedbackDelay = TaskParameters.GUI.FeedbackDelayMin;
    TaskParameters.GUIMeta.FeedbackDelay.Style = 'text';
    TaskParameters.GUI.StartNoCatchTrials = 20;
    TaskParameters.GUI.SkippedCorrectCorrection = 1;
    TaskParameters.GUIMeta.SkippedCorrectCorrection.Style = 'popupmenu';
    TaskParameters.GUIMeta.SkippedCorrectCorrection.String = {'None','RepeatSkipped','RepeatSkippedCatch'};%BruteForce: presents the same stimulus until a correct choice is made, then resumes stimulus sequence; Soft: calculates bias over all trials and presents non-prefered stimulus with p=1-bias.
    TaskParameters.GUIPanels.FeedbackDelay = {'FeedbackDelay','FeedbackDelaySelection','FeedbackDelayMin','FeedbackDelayMax','FeedbackDelayIncr','FeedbackDelayDecr','FeedbackDelayTau',...
        'FeedbackDelayGrace','PercentCatch','CatchError','StartNoCatchTrials','SkippedCorrectCorrection'};
    
    %Plot
    TaskParameters.GUI.ShowPsycAud = 1;
    TaskParameters.GUIMeta.ShowPsycAud.Style = 'checkbox';
    TaskParameters.GUI.ShowVevaiometric = 1;
    TaskParameters.GUIMeta.ShowVevaiometric.Style = 'checkbox';
    TaskParameters.GUI.ShowTrialRate = 1;
    TaskParameters.GUIMeta.ShowTrialRate.Style = 'checkbox';
    TaskParameters.GUI.ShowFix = 1;
    TaskParameters.GUIMeta.ShowFix.Style = 'checkbox';
    TaskParameters.GUI.ShowST = 1;
    TaskParameters.GUIMeta.ShowST.Style = 'checkbox';
    TaskParameters.GUI.ShowFix = 1;
    TaskParameters.GUIMeta.ShowFix.Style = 'checkbox';
    TaskParameters.GUI.ShowST = 1;
    TaskParameters.GUIMeta.ShowST.Style = 'checkbox';
    TaskParameters.GUI.ShowFeedback = 1;
    TaskParameters.GUIMeta.ShowFeedback.Style = 'checkbox';
    TaskParameters.GUIPanels.ShowPlots = {'ShowPsycAud','ShowVevaiometric','ShowTrialRate','ShowFix','ShowST','ShowFeedback'};
    
    TaskParameters.GUIPanels.Photometry = {'PhotometryOn','LED1_amp', 'LED2_amp','ch1','ch2','LED1_f', 'LED2_f','PostTrialRecording'};
    TaskParameters.GUI.LED1_amp = 2.5;
    TaskParameters.GUI.LED2_amp = 2.5;
    TaskParameters.GUI.PhotometryOn = 0;%2
    TaskParameters.GUI.LED1_f = 0;%531
    TaskParameters.GUI.LED2_f = 0;%211
    TaskParameters.GUI.PostTrialRecording = 2;%sets Time that will be recorded after trial end
    TaskParameters.GUI.ch1 = 1;
    TaskParameters.GUIMeta.ch1.Style = 'checkbox';
    TaskParameters.GUI.ch2 = 1;
    TaskParameters.GUIMeta.ch2.Style = 'checkbox';

    TaskParameters.Figures.OutcomePlot.Position = [0, 600, 1000, 400];
    
    TaskParameters.GUITabs.General = {'General','Photometry'};
    TaskParameters.GUITabs.Stimulus = {'Stimulus','NoiseVolumeTable','ContinuousTable','BiasVersion','BiasTable'};
    TaskParameters.GUITabs.Timing = {'Timing'};
    TaskParameters.GUITabs.Feedback = {'Sampling','Choice','FeedbackDelay'};
    TaskParameters.GUITabs.Plots = {'ShowPlots'};
    TaskParameters.GUI = orderfields(TaskParameters.GUI);
    
end
BpodParameterGUI('init', TaskParameters);
BpodSystem.Pause = 1;
HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
TaskParameters = BpodParameterGUI('sync', TaskParameters); % Sync parameters with BpodParameterGUI plugin
BpodSystem.ProtocolSettings = TaskParameters; % copy settings back prior to saving
SaveBpodProtocolSettings;

%server data
[~,BpodSystem.Data.Custom.Rig] = system('hostname');
[~,BpodSystem.Data.Custom.Subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.DataPath))));
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler';


%% init photometry raster function handle
%     prfh = str2func(S.GUI.PhotometryRasterFcn); %for being flexible, just
%     choose one for now

%% Initialize NIDAQ
TaskParameters.nidaq.duration = 120;
TaskParameters.nidaq.IsContinuous = true;
TaskParameters.nidaq.updateInterval = 0.1; % save new data every n seconds
BpodSystem.PluginObjects.Photometry.baselinePeriod = [0 1]; % kludge, FS
BpodSystem.ProtocolSettings = TaskParameters; % copy settings back because syncPhotometrySettings relies upon BpodSystem.ProtocolSettings
if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
    TaskParameters = initPhotometry(TaskParameters);
end
%% photometry plot
if TaskParameters.GUI.PhotometryOn 
    updatePhotometryPlotKatharina('init');
end

[filepath,filename,~]=fileparts(BpodSystem.DataPath);
BpodSystem.Data.Custom.StimulusPath=fullfile(strrep(filepath,'Session Data','Session Stimuli'),filename);
if ~exist(BpodSystem.Data.Custom.StimulusPath,'dir')
    mkdir(BpodSystem.Data.Custom.StimulusPath)
end

%initialize values and put into BpodSystem.Data.Custom
updateCustomDataFields(0)


%% order fields
BpodSystem.Data.Custom = orderfields(BpodSystem.Data.Custom);

%% Initialize plots
BpodSystem.ProtocolFigures.SideOutcomePlotFig = figure('Position', TaskParameters.Figures.OutcomePlot.Position,'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleOutcome = axes('Position',    [  .05  0.08 0.9 .45]);
BpodSystem.GUIHandles.OutcomePlot.HandlePsycAud = axes('Position',    [2*.05 + 1*.08   .62  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate = axes('Position',  [3*.05 + 2*.08   .62  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleFix = axes('Position',        [4*.05 + 3*.08   .62  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleST = axes('Position',         [5*.05 + 4*.08   .62  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleFeedback = axes('Position',   [6*.05 + 5*.08   .62  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric = axes('Position',   [7*.05 + 6*.08   .62  .1  .3], 'Visible', 'off');

MainPlot(BpodSystem.GUIHandles.OutcomePlot,'init');
%BpodSystem.ProtocolFigures.ParameterGUI.Position = TaskParameters.Figures.ParameterGUI.Position;



%% Main loop
RunSession = true;
iTrial = 1;
TaskParameters = BpodParameterGUI('sync', TaskParameters);
if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
    site = questdlg('Where are you recording from?', ...
        'photometry site', ...
        'rightVS','leftVS','leftTS','rightVS');
    BpodSystem.Data.Custom.PhotometrySite=site;
end

% %if TaskParameters.GUI.PharmacologyOn 
%     drug = questdlg('What did you administer?', ...
%         'drug condition', ...
%         'ketamine','placebo','ketamine');
%     BpodSystem.Data.Custom.Pharmacology=drug;
% %end
% firstblock = questdlg('Which block do you want to start with?', ...
%     'first block', ...
%     '30','50','70','50');
% BpodSystem.Data.Custom.firstblock=firstblock;



%% alternate LED modulation mode
if TaskParameters.GUI.PhotometryOn==2
    % store initial LED settings
    storedLED1_amp = TaskParameters.GUI.LED1_amp;
    storedLED2_amp = TaskParameters.GUI.LED2_amp;
end

while RunSession

   if TaskParameters.GUI.PhotometryOn==2
       LEDmode = rem(iTrial, 3);
       switch LEDmode
           case 1
               TaskParameters.GUI.LED1_amp = storedLED1_amp;
               TaskParameters.GUI.LED2_amp = storedLED2_amp;
           case 2
               TaskParameters.GUI.LED1_amp = storedLED1_amp;
               TaskParameters.GUI.LED2_amp = 0;
           case 0
               TaskParameters.GUI.LED1_amp = 0;
               TaskParameters.GUI.LED2_amp = storedLED2_amp;
       end
   end    
    TaskParameters = BpodParameterGUI('sync', TaskParameters);
    BpodSystem.ProtocolSettings = TaskParameters; % copy settings back prior to saving
    SaveBpodProtocolSettings;

    sma = stateMatrix(iTrial);
    SendStateMatrix(sma);
    %% prep data acquisition
    if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
        preparePhotometryAcq(TaskParameters);
    end
    
    RawEvents = RunStateMatrix();
    
    %% Stop Photometry session
    if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
        stopPhotometryAcq;
    end
    
    if ~isempty(fieldnames(RawEvents))
        %% Process NIDAQ session
        if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
            try
                processPhotometryAcq(iTrial);
            catch
                disp('*** Data not saved, issue with processPhotometryAcq ***');
            end
            
        end
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        SaveBpodSessionData;
    else
        disp([' *** Trial # ' num2str(iTrial) ':  aborted, data not saved ***']); % happens when you abort early (I think), e.g. when you are halting session
    end
    
    if BpodSystem.BeingUsed == 0
        return
    end
    updateCustomDataFields(iTrial)%get data and create new stimuli here
    
    %% update plots
    %behavior
    MainPlot(BpodSystem.GUIHandles.OutcomePlot,'update',iTrial);
    
    if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
        processPhotometryOnline(iTrial);
        startX=[BpodSystem.Data.Custom.RewardStartTime(iTrial) BpodSystem.Data.Custom.StimulusStartTime(iTrial)];
        updatePhotometryPlotKatharina('update', startX,{'reward','stimulus'});        
    end   

    iTrial = iTrial + 1;
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.

end


end



