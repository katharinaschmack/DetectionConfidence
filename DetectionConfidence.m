function DetectionConfidence()
% Script for training and performing mice a detection in noise task with
% confidence reports

global BpodSystem
global TaskParameters
%global StimulusSettings

%% Task parameters
TaskParameters = BpodSystem.ProtocolSettings;
if isempty(fieldnames(TaskParameters))
    %general
    TaskParameters.GUI.Ports_LMR = '123'; %Port IDs signal center noise
    TaskParameters.GUI.AfterTrialInterval = .5; %DurAfterTrialIntervalon of after trial interval before next trial starts(s)
    TaskParameters.GUI.AfterTrialIntervalJitter = true; %Exponential jitter for after trial interval
    TaskParameters.GUI.AfterTrialIntervalMin = .1;%Minimum for jitter
    TaskParameters.GUI.AfterTrialIntervalMax = 2.5;%Maximum for jitter
    TaskParameters.GUIMeta.AfterTrialIntervalJitter.Style = 'checkbox';
    TaskParameters.GUI.LightGuidance = false;%LED ports indicate active ports
    TaskParameters.GUIMeta.LightGuidance.Style = 'checkbox';
    
    TaskParameters.GUIPanels.General = {'Ports_LMR','AfterTrialInterval','AfterTrialIntervalJitter','AfterTrialIntervalMin','AfterTrialIntervalMax','LightGuidance'};
    
    %sampling period: events, duration and reinforcement for duration
    TaskParameters.GUI.NoiseVolumeTable.NoiseVolume=[20 40 60]';
    TaskParameters.GUI.NoiseVolumeTable.SignalVolume=[50 45 40]';
    TaskParameters.GUI.NoiseVolumeTable.Prob=[1 1 1]';
    
    TaskParameters.GUIMeta.NoiseVolumeTable.Style = 'table';
    TaskParameters.GUIMeta.NoiseVolumeTable.String = 'Noise volumes';
    TaskParameters.GUIMeta.NoiseVolumeTable.ColumnLabel = {'noise','signal','probabilty'};

    TaskParameters.GUI.EasyTrials=20;
    TaskParameters.GUI.StimDuration=0.05;
    TaskParameters.GUIPanels.Stimulus = {'StimDuration'};
    TaskParameters.GUIPanels.NoiseVolumeTable ={'NoiseVolumeTable','EasyTrials'};


    
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

    TaskParameters.GUI.AllowBreakFixation = 1;
    TaskParameters.GUIMeta.AllowBreakFixation.Style = 'checkbox';

    TaskParameters.GUI.CoutEarlyTimeout = 0;%time out for early withdrawal (marion 1s)
    TaskParameters.GUIPanels.Timing = {'PreStimDuration',...
        'PreStimDurationSelection','PreStimDurationMin','PreStimDurationMax','PreStimDurationRampUp','PreStimDurationRampDown','PreStimDurationTau'};
    
    TaskParameters.GUIPanels.Sampling = {'RewardAmountCenter','AllowBreakFixation'...
        'RewardAmountCenterSelection','RewardAmountCenterEasyTrials','CoutEarlyTimeout'};
    
    %Choice 
    TaskParameters.GUI.ChoiceDeadline = 5; %Maximal Interval for choice after stimulus presentAfterTrialIntervalon    
    TaskParameters.GUI.BiasCorrection = 3;
    TaskParameters.GUIMeta.BiasCorrection.Style = 'popupmenu';
    TaskParameters.GUIMeta.BiasCorrection.String = {'None','BruteForce','Soft'};%BruteForce: presents the same stimulus until a correct choice is made, then resumes stimulus sequence; Soft: calculates bias over all trials and presents non-prefered stimulus with p=1-bias.
    TaskParameters.GUI.RewardAmountCorrect = 5;%reward amount lateral ports (marion 5)
    TaskParameters.GUI.RewardAmountError = 0;%reward amount lateral ports (marion 5)
    TaskParameters.GUI.ErrorTimeout = 0;%time out for errors     
    TaskParameters.GUIPanels.Choice = {'ChoiceDeadline','BiasCorrection','RewardAmountCorrect','RewardAmountError','ErrorTimeout'};%,'Deplete','DepleteRate','Jackpot','JackpotMin','JackpotTime'};

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
    TaskParameters.GUI.FeedbackDelay = TaskParameters.GUI.FeedbackDelayMin;
    TaskParameters.GUIMeta.FeedbackDelay.Style = 'text';    
    TaskParameters.GUI.StartEasyTrials = 0;

    TaskParameters.GUIPanels.FeedbackDelay = {'FeedbackDelay','FeedbackDelaySelection','FeedbackDelayMin','FeedbackDelayMax','FeedbackDelayIncr','FeedbackDelayDecr','FeedbackDelayTau','FeedbackDelayGrace','PercentCatch','StartEasyTrials'};
    
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

    TaskParameters.GUI = orderfields(TaskParameters.GUI);
    TaskParameters.Figures.OutcomePlot.Position = [0, 400, 1000, 400];

    
    TaskParameters.GUITabs.General = {'General'};
        TaskParameters.GUITabs.Stimulation = {'Stimulus','NoiseVolumeTable','Timing'}; 

    TaskParameters.GUITabs.Feedback = {'Sampling','Choice','FeedbackDelay'};
    TaskParameters.GUITabs.Plots = {'ShowPlots'};
end


BpodParameterGUI('init', TaskParameters);

%server data
[~,BpodSystem.Data.Custom.Rig] = system('hostname');
[~,BpodSystem.Data.Custom.Subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.DataPath))));
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler';

%initialize values and put into BpodSystem.Data.Custom
updateCustomDataFields(0)


%% order fields
BpodSystem.Data.Custom = orderfields(BpodSystem.Data.Custom);

%% Initialize plots
BpodSystem.ProtocolFigures.SideOutcomePlotFig = figure('Position', TaskParameters.Figures.OutcomePlot.Position,'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleOutcome = axes('Position',    [  .05  0.08 0.9 .5]);
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

while RunSession
    TaskParameters = BpodParameterGUI('sync', TaskParameters);   
    sma = stateMatrix(iTrial);
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents))
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        SaveBpodSessionData;
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.BeingUsed == 0
        return
    end
    updateCustomDataFields(iTrial)%get data and create new stimuli here

    MainPlot(BpodSystem.GUIHandles.OutcomePlot,'update',iTrial);

    iTrial = iTrial + 1;
end


end



