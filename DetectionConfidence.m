function DetectionConfidence()
% Script for training and performing mice a detection in noise task with
% confidence reports

global BpodSystem
global TaskParameters
global StimulusSettings

%% Task parameters
TaskParameters = BpodSystem.ProtocolSettings;
if isempty(fieldnames(TaskParameters))
    %general
    TaskParameters.GUI.Ports_LMR = '123'; %Port IDs signal center noise
    TaskParameters.GUI.AfterTrialInterval = .5; %DurAfterTrialIntervalon of after trial interval before next trial starts(s)
    TaskParameters.GUI.AfterTrialIntervalJitter = true; %Exponential jitter for after trial interval
    TaskParameters.GUIMeta.AfterTrialIntervalJitter.Style = 'checkbox';
    TaskParameters.GUIPanels.General = {'Ports_LMR','AfterTrialInterval','AfterTrialIntervalJitter'};
    
    %sampling period: events, duration and reinforcement for duration
    TaskParameters.GUI.PlayStimulus = 4; %stimulus to be played at center port
    TaskParameters.GUIMeta.PlayStimulus.Style = 'popupmenu';
    TaskParameters.GUIMeta.PlayStimulus.String = {'None','Noise','Noise+Signal (easy)','Noise+Signal (variable)'};% 
    TaskParameters.GUI.MinStimDuration = 0.05;%minimum sample time required for reward will not decrease further (0.05 in Marion's script)
    TaskParameters.GUI.StimDuration = TaskParameters.GUI.MinStimDuration;
    TaskParameters.GUIMeta.StimDuration.Style = 'text';
    TaskParameters.GUI.MaxStimDuration = 1; %sample time required for reward will not increase further (0.5)
    TaskParameters.GUI.AutoRampStimDuration = true; %for training
    TaskParameters.GUIMeta.AutoRampStimDuration.Style = 'checkbox';
    TaskParameters.GUI.StimDurationRampUp = 0.01;
    TaskParameters.GUI.StimDurationRampDown = 0.005;        
    TaskParameters.GUI.PreStimDuration = 0;
    TaskParameters.GUI.PostStimDuration = 0;
    TaskParameters.GUI.RewardAmountCenter = 0;%reward amount center ports (marion .5)
    TaskParameters.GUI.CoutEarlyTimeout = 1;%time out for early withdrawal (marion 1s)
    %TaskParameters.GUI.EarlyWithdrawalNoise = true;%punishing sound for early withdrawal (marion true)
    %TaskParameters.GUIMeta.EarlyWithdrawalNoise.Style='checkbox';
    TaskParameters.GUIPanels.Sampling = {'PlayStimulus','PreStimDuration','StimDuration','PostStimDuration',...
        'AutoRampStimDuration','MinStimDuration','MaxStimDuration','StimDurationRampUp','StimDurationRampDown',...
        'RewardAmountCenter','CoutEarlyTimeout'};
    
    %Stimulus Settings TO BE OUTCODED
    %TaskParameters.GUIPanels.Stimulus = {''};
    
    %Choice 
    TaskParameters.GUI.ChoiceDeadline = 5; %Maximal Interval for choice after stimulus presentAfterTrialIntervalon

    TaskParameters.GUI.MaxLightGuidance = 1;%proportion of trials with light guidance to correct port    TaskParameters.GUI.AutoRampLightGuidance = false; %for training
    TaskParameters.GUI.MinLightGuidance = 0;%proportion of trials with light guidance to correct port    TaskParameters.GUI.AutoRampLightGuidance = false; %for training
    TaskParameters.GUI.AutoRampLightGuidance = false;
    TaskParameters.GUIMeta.AutoRampLightGuidance.Style = 'checkbox';
    TaskParameters.GUI.LightGuidanceRampDown = .1; %for training
    TaskParameters.GUI.LightGuidanceRampUp = .1; %for training
    TaskParameters.GUI.LightGuidance = TaskParameters.GUI.MaxLightGuidance;
    TaskParameters.GUIMeta.LightGuidance.Style = 'text';

    TaskParameters.GUI.RewardAmountCorrect = 2;%reward amount lateral ports (marion 5)
    TaskParameters.GUI.RewardAmountError = 0;%reward amount lateral ports (marion 5)
    TaskParameters.GUI.ErrorTimeout = 1;%time out for errors 
    
    TaskParameters.GUIPanels.Choice = {'ChoiceDeadline','LightGuidance','AutoRampLightGuidance','MaxLightGuidance','MinLightGuidance','LightGuidanceRampDown','LightGuidanceRampUp','RewardAmountCorrect','RewardAmountError','ErrorTimeout'};%,'Deplete','DepleteRate','Jackpot','JackpotMin','JackpotTime'};

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
    TaskParameters.GUI.ShowLightGuidance = 1;
    TaskParameters.GUIMeta.ShowLightGuidance.Style = 'checkbox';
    TaskParameters.GUI.ShowStimDuration = 1;
    TaskParameters.GUIMeta.ShowStimDuration.Style = 'checkbox';

    TaskParameters.GUIPanels.ShowPlots = {'ShowPsycAud','ShowVevaiometric','ShowTrialRate','ShowFix','ShowST','ShowFeedback','ShowLightGuidance','ShowStimDuration'};
    
    TaskParameters.GUI = orderfields(TaskParameters.GUI);
    TaskParameters.Figures.OutcomePlot.Position = [200, 200, 1000, 400];
    
    
    TaskParameters.GUITabs.General = {'General'};
    TaskParameters.GUITabs.Stimulation = {'Sampling'}; 
    TaskParameters.GUITabs.Feedback = {'Choice','FeedbackDelay'};
    TaskParameters.GUITabs.Plots = {'ShowPlots'};
end


BpodParameterGUI('init', TaskParameters);

%put trial-by-trial varying settings into BpodSystem.Data.Custom
BpodSystem.Data.Custom.PreStimDuration = TaskParameters.GUI.PreStimDuration;
BpodSystem.Data.Custom.StimDuration = TaskParameters.GUI.StimDuration;

%initialize delay
switch TaskParameters.GUIMeta.FeedbackDelaySelection.String{TaskParameters.GUI.FeedbackDelaySelection}
    case 'AutoIncr'
        TaskParameters.GUI.FeedbackDelay = TaskParameters.GUI.FeedbackDelayMin;
    case 'TruncExp'
        TaskParameters.GUI.FeedbackDelay = TruncatedExponential(TaskParameters.GUI.FeedbackDelayMin,...
            TaskParameters.GUI.FeedbackDelayMax,TaskParameters.GUI.FeedbackDelayTau);
    case 'Fix'
        TaskParameters.GUI.FeedbackDelay = TaskParameters.GUI.FeedbackDelayMin;
end
BpodSystem.Data.Custom.FeedbackDelay = TaskParameters.GUI.FeedbackDelay;
BpodSystem.Data.Custom.CatchTrial = rand<TaskParameters.GUI.PercentCatch;
 

if TaskParameters.GUI.AfterTrialIntervalJitter
    BpodSystem.Data.Custom.AfterTrialInterval = TruncatedExponential(0,5*TaskParameters.GUI.AfterTrialInterval,TaskParameters.GUI.AfterTrialInterval);% min( [ exprnd(TaskParameters.GUI.AfterTrialInterval) 5*TaskParameters.GUI.AfterTrialInterval ]);
else
    BpodSystem.Data.Custom.AfterTrialInterval = TaskParameters.GUI.AfterTrialInterval;
end
BpodSystem.Data.Custom.RewardAmountCorrect(1) = TaskParameters.GUI.RewardAmountCorrect;
BpodSystem.Data.Custom.RewardAmountCenter(1) = TaskParameters.GUI.RewardAmountCenter;
BpodSystem.Data.Custom.RewardAmountError(1) = TaskParameters.GUI.RewardAmountError;


BpodSystem.Data.Custom.LightGuidance = TaskParameters.GUI.MaxLightGuidance;
BpodSystem.Data.Custom.ErrorPortLightIntensity = ceil(255* (rand >= TaskParameters.GUI.LightGuidance));%set LED intensity to 0 on error port on some trials for training


%server data
[~,BpodSystem.Data.Custom.Rig] = system('hostname');
[~,BpodSystem.Data.Custom.Subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.DataPath))));

%stimulus presentatoin
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler';
BpodSystem.Data.Custom.PsychtoolboxStartup=false;


%% Prepare First Auditory Stimulus delivery
%stimulus settings
if TaskParameters.GUI.PlayStimulus>1
    StimulusSettings.SamplingRate=192000;%sampling rate of sound card
    StimulusSettings.NoiseDuration=BpodSystem.Data.Custom.StimDuration;
    StimulusSettings.NoiseColor='WhiteGaussian';
    StimulusSettings.NoiseVolume=50;%in dB
    StimulusSettings.SignalForm='QuadraticConvex';
    StimulusSettings.SignalMinFreq=5E3;
    StimulusSettings.SignalMaxFreq=10E3;

    if TaskParameters.GUI.PlayStimulus == 2 %only noise
        StimulusSettings.EmbedSignal=0;
        StimulusSettings.SignalDuration=0;%min([0.1 BpodSystem.Data.Custom.StimDuration]);%plays signal of 0.1 s or sample time duration (if shorter)
        StimulusSettings.SignalVolume=0;%in dB
    elseif TaskParameters.GUI.PlayStimulus == 3 %noie plus easy signals
        StimulusSettings.EmbedSignal=(fix(rand*2));
        StimulusSettings.SignalDuration=min([0.1 BpodSystem.Data.Custom.StimDuration]);%plays signal of 0.1 s or sample time duration (if shorter)
        StimulusSettings.SignalVolume=StimulusSettings.EmbedSignal*40;%in dB
    elseif TaskParameters.GUI.PlayStimulus == 4 %noise plus easy and difficult signals
        StimulusSettings.EmbedSignal=(fix(rand*5))/4;%for 5 signal intensities between 0(noise) and 1 (signal)
        StimulusSettings.SignalDuration=min([0.1 BpodSystem.Data.Custom.StimDuration]);%plays signal of 0.1 s or sample time duration (if shorter)
        StimulusSettings.SignalVolume=StimulusSettings.EmbedSignal*40;%in dB
    end

    %put trial-by-trial varying settings into BpodSystem.Data.Custom
    [BpodSystem.Data.Custom.Stimulus{1} BpodSystem.Data.Custom.SignalEmbedTime] = GenerateSignalInNoiseStimulus(StimulusSettings);
    BpodSystem.Data.Custom.EmbedSignal = StimulusSettings.EmbedSignal;
    BpodSystem.Data.Custom.SignalDuration = StimulusSettings.SignalDuration;
    BpodSystem.Data.Custom.SignalVolume = StimulusSettings.SignalVolume;

    %prepare Psychotoolbox if necessary
    % if ~BpodSystem.EmulatorMode && ~BpodSystem.Data.Custom.PsychtoolboxStartup
    if  ~BpodSystem.Data.Custom.PsychtoolboxStartup
        PsychToolboxSoundServer('init');
        BpodSystem.Data.Custom.PsychtoolboxStartup=true;
    end
    PsychToolboxSoundServer('Load', 1, BpodSystem.Data.Custom.Stimulus{1});%load stimulus to slave 1
end
BpodSystem.Data.Custom = orderfields(BpodSystem.Data.Custom);


%% Initialize plots
BpodSystem.ProtocolFigures.SideOutcomePlotFig = figure('Position', TaskParameters.Figures.OutcomePlot.Position,'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleOutcome = axes('Position',    [  .055            .15 .91 .3]);
BpodSystem.GUIHandles.OutcomePlot.HandleFeedbackDelayGrace = axes('Position',  [1*.05           .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate = axes('Position',    [3*.05 + 2*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleST = axes('Position',           [5*.05 + 4*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleMT = axes('Position',           [6*.05 + 6*.08   .6  .1  .3], 'Visible', 'off');

BpodSystem.ProtocolFigures.SideOutcomePlotFig = figure('Position', TaskParameters.Figures.OutcomePlot.Position,'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleOutcome = axes('Position',    [  .055          .15 .91 .3]);
BpodSystem.GUIHandles.OutcomePlot.HandlePsycAud = axes('Position',    [2*.05 + 1*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate = axes('Position',  [3*.05 + 2*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleFix = axes('Position',        [4*.05 + 3*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleST = axes('Position',         [5*.05 + 4*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleFeedback = axes('Position',   [6*.05 + 5*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric = axes('Position',   [7*.05 + 6*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleLightGuidance = axes('Position',   [8*.05 + 7*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleStimDuration = axes('Position',   [9*.05 + 8*.08   .6  .1  .3], 'Visible', 'off');

MainPlot(BpodSystem.GUIHandles.OutcomePlot,'init');
%BpodSystem.ProtocolFigures.ParameterGUI.Position = TaskParameters.Figures.ParameterGUI.Position;


%% Main loop
RunSession = true;
iTrial = 1;

while RunSession
    TaskParameters = BpodParameterGUI('sync', TaskParameters);
    if TaskParameters.GUI.PlayStimulus>0 && ~BpodSystem.Data.Custom.PsychtoolboxStartup
        PsychToolboxSoundServer('init');
        BpodSystem.Data.Custom.PsychtoolboxStartup=true;
        PsychToolboxSoundServer('Load', 1, BpodSystem.Data.Custom.Stimulus);%load noise to slave 1
    end
    
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



