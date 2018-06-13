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
    TaskParameters.GUI.AfterTrialIntervalMin = .1;%Minimum for jitter 
    TaskParameters.GUI.AfterTrialIntervalMax = 2.5;%Maximum for jitter 

    TaskParameters.GUIMeta.AfterTrialIntervalJitter.Style = 'checkbox';
    TaskParameters.GUIPanels.General = {'Ports_LMR','AfterTrialInterval','AfterTrialIntervalJitter','AfterTrialIntervalMin','AfterTrialIntervalMax'};
    
    %sampling period: events, duration and reinforcement for duration
    
    
    %TaskParameters.GUI.PlayStimulus =  3;%stimulus to be played at center port
    %TaskParameters.GUIMeta.PlayStimulus.Style = 'popupmenu';
    %TaskParameters.GUIMeta.PlayStimulus.String = {'None','Noise','Noise+Signal (easy)','Noise+Signal (variable)'};% 
    
    TaskParameters.GUI.NoiseSettings =  2;%how noise is being played
    TaskParameters.GUIMeta.NoiseSettings.Style = 'popupmenu'; %1-continuous 2-when mouse is in centerport 
    TaskParameters.GUIMeta.NoiseSettings.String = {'Continuous','Centerport'};% 
    
    TaskParameters.GUI.NoiseVolumeTable.NoiseVolume = [30:5:50]';
    TaskParameters.GUI.NoiseVolumeTable.NoiseProb = ones(size(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume))/numel(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);
    TaskParameters.GUIMeta.NoiseVolumeTable.Style = 'table';
    TaskParameters.GUIMeta.NoiseVolumeTable.String = 'Noise volume probabilities';
    TaskParameters.GUIMeta.NoiseVolumeTable.ColumnLabel = {'noise level (dB)','P'};  

    TaskParameters.GUI.StimDuration=0.05;
    TaskParameters.GUI.MaxSignalVolume=30;
    TaskParameters.GUIPanels.Stimulus = {'NoiseSettings',...
        'MaxSignalVolume','StimDuration'};
    TaskParameters.GUIPanels.NoiseVolumeTable = {'NoiseVolumeTable'};


    
    TaskParameters.GUI.PreStimDurationSelection = 3;
    TaskParameters.GUIMeta.PreStimDurationSelection.Style = 'popupmenu';
    TaskParameters.GUIMeta.PreStimDurationSelection.String = {'Fix','AutoIncr','TruncExp'};
    TaskParameters.GUI.PreStimDurationTau = 0.2;

    TaskParameters.GUI.PreStimDurationMin = 0.05;%minimum sample time required for reward will not decrease further (0.05 in Marion's script)
    TaskParameters.GUI.PreStimDuration = TaskParameters.GUI.PreStimDurationMin;
    TaskParameters.GUIMeta.PreStimDuration.Style = 'text';
    TaskParameters.GUI.PreStimDurationMax = .5; %sample time required for reward will not increase further (0.5)
   % TaskParameters.GUI.AutoRampPreStimDuration = true; %for training
    %TaskParameters.GUIMeta.AutoRampPreStimDuration.Style = 'checkbox';
    TaskParameters.GUI.PreStimDurationRampUp = 0.01;
    TaskParameters.GUI.PreStimDurationRampDown = 0.005;        
    %TaskParameters.GUI.PreStimDuration = 0;
    %TaskParameters.GUI.PostStimDuration = 0.05;
    TaskParameters.GUI.RewardAmountCenter = 0.5;%reward amount center ports (marion .5)
    
    TaskParameters.GUI.RewardAmountCenterSelection = 2;
    TaskParameters.GUIMeta.RewardAmountCenterSelection.Style = 'text';
    TaskParameters.GUIMeta.RewardAmountCenterSelection.Style = 'popupmenu';
    TaskParameters.GUIMeta.RewardAmountCenterSelection.String = {'Fix','Decrease'};
    TaskParameters.GUI.RewardAmountCenterEasyTrials = 50;

    TaskParameters.GUI.AllowBreakFixation = 1;
    TaskParameters.GUIMeta.AllowBreakFixation.Style = 'checkbox';

    TaskParameters.GUI.CoutEarlyTimeout = 0;%time out for early withdrawal (marion 1s)
    %TaskParameters.GUI.EarlyWithdrawalNoise = true;%punishing sound for early withdrawal (marion true)
    %TaskParameters.GUIMeta.EarlyWithdrawalNoise.Style='checkbox';
    TaskParameters.GUIPanels.Timing = {'PreStimDuration',...
        'PreStimDurationSelection','PreStimDurationMin','PreStimDurationMax','PreStimDurationRampUp','PreStimDurationRampDown','PreStimDurationTau'};
    
    TaskParameters.GUIPanels.Sampling = {'RewardAmountCenter','AllowBreakFixation'...
        'RewardAmountCenterSelection','RewardAmountCenterEasyTrials','CoutEarlyTimeout'};
    %Stimulus Settings TO BE OUTCODED
    %TaskParameters.GUIPanels.Stimulus = {''};
    
    %Choice 
    TaskParameters.GUI.ChoiceDeadline = 5; %Maximal Interval for choice after stimulus presentAfterTrialIntervalon    
    TaskParameters.GUI.BiasCorrection = 3;
    TaskParameters.GUIMeta.BiasCorrection.Style = 'popupmenu';
    TaskParameters.GUIMeta.BiasCorrection.String = {'None','BruteForce','Soft'};%BruteForce: presents the same stimulus until a correct choice is made, then resumes stimulus sequence; Soft: calculates bias over all trials and presents non-prefered stimulus with p=1-bias.


    %TaskParameters.GUI.MaxLightGuidance = 0;%proportion of trials with light guidance to correct port    TaskParameters.GUI.AutoRampLightGuidance = false; %for training
    %TaskParameters.GUI.MinLightGuidance = 0;%proportion of trials with light guidance to correct port    TaskParameters.GUI.AutoRampLightGuidance = false; %for training
    %TaskParameters.GUI.AutoRampLightGuidance = false;
    %TaskParameters.GUIMeta.AutoRampLightGuidance.Style = 'checkbox';
    %TaskParameters.GUI.LightGuidanceRampDown = .1; %for training
    %TaskParameters.GUI.LightGuidanceRampUp = .1; %for training
    %TaskParameters.GUI.LightGuidance = TaskParameters.GUI.MaxLightGuidance;
    %TaskParameters.GUIMeta.LightGuidance.Style = 'text';

    TaskParameters.GUI.RewardAmountCorrect = 3;%reward amount lateral ports (marion 5)
    TaskParameters.GUI.RewardAmountError = 0;%reward amount lateral ports (marion 5)
    TaskParameters.GUI.ErrorTimeout = 0;%time out for errors 
    
    %TaskParameters.GUIPanels.Choice = {'ChoiceDeadline','BiasCorrection','LightGuidance','AutoRampLightGuidance','MaxLightGuidance','MinLightGuidance','LightGuidanceRampDown','LightGuidanceRampUp','RewardAmountCorrect','RewardAmountError','ErrorTimeout'};%,'Deplete','DepleteRate','Jackpot','JackpotMin','JackpotTime'};
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
    %TaskParameters.GUI.ShowLightGuidance = 1;
    %TaskParameters.GUIMeta.ShowLightGuidance.Style = 'checkbox';
    TaskParameters.GUI.ShowPreStimDuration = 1;
    TaskParameters.GUIMeta.ShowPreStimDuration.Style = 'checkbox';

    %TaskParameters.GUIPanels.ShowPlots = {'ShowPsycAud','ShowVevaiometric','ShowTrialRate','ShowFix','ShowST','ShowFeedback','ShowLightGuidance','ShowPreStimDuration'};
        TaskParameters.GUIPanels.ShowPlots = {'ShowPsycAud','ShowVevaiometric','ShowTrialRate','ShowFix','ShowST','ShowFeedback','ShowPreStimDuration'};

    TaskParameters.GUI = orderfields(TaskParameters.GUI);
    TaskParameters.Figures.OutcomePlot.Position = [200, 200, 1000, 400];

    
    TaskParameters.GUITabs.General = {'General'};
    TaskParameters.GUITabs.Stimulation = {'Stimulus','NoiseVolumeTable','Timing'}; 
    TaskParameters.GUITabs.Feedback = {'Sampling','Choice','FeedbackDelay'};
    TaskParameters.GUITabs.Plots = {'ShowPlots'};
end


BpodParameterGUI('init', TaskParameters);


%put trial-by-trial varying settings into BpodSystem.Data.Custom
switch TaskParameters.GUIMeta.PreStimDurationSelection.String{TaskParameters.GUI.PreStimDurationSelection}
    case 'AutoIncr'
        TaskParameters.GUI.PreStimDuration = TaskParameters.GUI.PreStimDurationMin;
    case 'TruncExp'
        TaskParameters.GUI.PreStimDuration = TruncatedExponential(TaskParameters.GUI.PreStimDurationMin,...
            TaskParameters.GUI.PreStimDurationMax,TaskParameters.GUI.PreStimDurationTau);
    case 'Fix'
        TaskParameters.GUI.PreStimDuration = TaskParameters.GUI.PreStimDurationMin;
end
BpodSystem.Data.Custom.PreStimDuration = TaskParameters.GUI.PreStimDuration;

BpodSystem.Data.Custom.StimDuration = TaskParameters.GUI.StimDuration;
BpodSystem.Data.Custom.PostStimDuration = 0;
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


%BpodSystem.Data.Custom.LightGuidance = TaskParameters.GUI.MaxLightGuidance;
%BpodSystem.Data.Custom.ErrorPortLightIntensity = ceil(255* (rand >= TaskParameters.GUI.LightGuidance));%set LED intensity to 0 on error port on some trials for training


%server data
[~,BpodSystem.Data.Custom.Rig] = system('hostname');
[~,BpodSystem.Data.Custom.Subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.DataPath))));

%stimulus presentatoin
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler';
BpodSystem.Data.Custom.PsychtoolboxStartup=false;


%% Prepare First Auditory Stimulus delivery
%stimulus settings
%if TaskParameters.GUI.PlayStimulus>1
    StimulusSettings.SamplingRate=192000;%sampling rate of sound card
    StimulusSettings.Ramp=.05;%duration (s) of ramping at on and offset of noise used to avoid clicking sounds
    StimulusSettings.NoiseDuration=10;%length of noise stream (s) that will be looped
    StimulusSettings.NoiseColor='WhiteGaussian';
    %StimulusSettings.NoiseVolume=40;%in dB
    StimulusSettings.SignalForm='LinearUpsweep';
    StimulusSettings.SignalMinFreq=10E3;
    StimulusSettings.SignalMaxFreq=15E3;
    StimulusSettings.SignalDuration=BpodSystem.Data.Custom.StimDuration;%plays signal of 0.1 s or sample time duration (if shorter)
    StimulusSettings.EmbedSignal=randsample(0:1,1);
    StimulusSettings.SignalVolume=StimulusSettings.EmbedSignal*TaskParameters.GUI.MaxSignalVolume;%in dB
    StimulusSettings.NoiseVolume=TaskParameters.GUI.NoiseVolumeTable.NoiseVolume(randsample(length(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume),1,true,TaskParameters.GUI.NoiseVolumeTable.NoiseProb));%in dB

   % if TaskParameters.GUI.PlayStimulus == 1 || TaskParameters.GUI.PlayStimulus == 2 %no stimulus or only noise
   %     StimulusSettings.EmbedSignal=0;
   %     StimulusSettings.SignalDuration=0;%min([0.1 BpodSystem.Data.Custom.StimDuration]);%plays signal of 0.1 s or sample time duration (if shorter)
   %     StimulusSettings.SignalVolume=0;%in dB
    %elseif TaskParameters.GUI.PlayStimulus == 3 %noie plus easy signals
      %  StimulusSettings.EmbedSignal=(fix(rand*2));
      %  StimulusSettings.SignalDuration=0.05;%min([0.1 BpodSystem.Data.Custom.StimDuration]);%plays signal of 0.1 s or sample time duration (if shorter)
      %  StimulusSettings.SignalVolume=StimulusSettings.EmbedSignal*TaskParameters.GUI.SignalVolume;%in dB
    %elseif TaskParameters.GUI.PlayStimulus == 4 %signals plus easy and difficult noise
     %   StimulusSettings.EmbedSignal=(fix(rand*2));%for 5 signal intensities between 0(noise) and 1 (signal)
     %   StimulusSettings.SignalDuration=0.05;%min([0.1 BpodSystem.Data.Custom.StimDuration]);%plays signal of 0.1 s or sample time duration (if shorter)
     %   StimulusSettings.SignalVolume=StimulusSettings.EmbedSignal*TaskParameters.GUI.SignalVolume;%in dB
     %   StimulusSettings.NoiseVolume=StimulusSettings.EmbedSignal*TaskParameters.GUI.SignalVolume;%in dB    end

    %put trial-by-trial varying settings into BpodSystem.Data.Custom
    %[BpodSystem.Data.Custom.Stimulus{1} BpodSystem.Data.Custom.SignalEmbedTime] = GenerateSignalInNoiseStimulus(StimulusSettings);
    %BpodSystem.Data.Custom.EmbedSignal = StimulusSettings.EmbedSignal;
    BpodSystem.Data.Custom.Noise = GenerateNoise(StimulusSettings).*(StimulusSettings.NoiseVolume>0);
    BpodSystem.Data.Custom.Signal = GenerateSignal(StimulusSettings).*StimulusSettings.EmbedSignal;
    BpodSystem.Data.Custom.NoiseVolume = StimulusSettings.NoiseVolume;
    BpodSystem.Data.Custom.SignalDuration = StimulusSettings.SignalDuration;
    BpodSystem.Data.Custom.SignalVolume = StimulusSettings.SignalVolume;
        BpodSystem.Data.Custom.MaxSignalVolume = TaskParameters.GUI.MaxSignalVolume;

    BpodSystem.Data.Custom.EmbedSignal=StimulusSettings.EmbedSignal;

    %prepare Psychotoolbox if necessary
    % if ~BpodSystem.EmulatorMode && ~BpodSystem.Data.Custom.PsychtoolboxStartup
    if  ~BpodSystem.Data.Custom.PsychtoolboxStartup
        PsychToolboxSoundServer('init');
        BpodSystem.Data.Custom.PsychtoolboxStartup=true;
    end
    PsychToolboxSoundServer('Load', 1, BpodSystem.Data.Custom.Noise);%load stimulus to slave 1
    if TaskParameters.GUI.NoiseSettings==1
        PsychToolboxSoundServerLoop('Play', 1);%start noise stream if continuous noise
    end
    PsychToolboxSoundServer('Load', 2, BpodSystem.Data.Custom.Signal);%load stimulus to slave 1

BpodSystem.Data.Custom = orderfields(BpodSystem.Data.Custom);


%% Configure PulsePal
%load PulsePalParamStimulus.mat
%load PulsePalParamFeedback.mat
%BpodSystem.Data.Custom.PulsePalParamStimulus=PulsePalParamStimulus;
%BpodSystem.Data.Custom.PulsePalParamFeedback=PulsePalParamFeedback;
%clear PulsePalParamFeedback PulsePalParamStimulus
%if ~BpodSystem.EmulatorMode
    %ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamStimulus);
    %SendCustomPulseTrain(1, BpodSystem.Data.Custom.RightClickTrain, ones(1,length(BpodSystem.Data.Custom.RightClickTrain))*5);
    %SendCustomPulseTrain(2, BpodSystem.Data.Custom.LeftClickTrain, ones(1,length(BpodSystem.Data.Custom.LeftClickTrain))*5);
%end

%% Initialize plots
BpodSystem.ProtocolFigures.SideOutcomePlotFig = figure('Position', TaskParameters.Figures.OutcomePlot.Position,'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleOutcome = axes('Position',    [  .055          .15 .91 .3]);
BpodSystem.GUIHandles.OutcomePlot.HandlePsycAud = axes('Position',    [2*.05 + 1*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate = axes('Position',  [3*.05 + 2*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleFix = axes('Position',        [4*.05 + 3*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleST = axes('Position',         [5*.05 + 4*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleFeedback = axes('Position',   [6*.05 + 5*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric = axes('Position',   [7*.05 + 6*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleLightGuidance = axes('Position',   [8*.05 + 7*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandlePreStimDuration = axes('Position',   [9*.05 + 8*.08   .6  .1  .3], 'Visible', 'off');

MainPlot(BpodSystem.GUIHandles.OutcomePlot,'init');
%BpodSystem.ProtocolFigures.ParameterGUI.Position = TaskParameters.Figures.ParameterGUI.Position;


%% Main loop
RunSession = true;
iTrial = 1;

while RunSession
    TaskParameters = BpodParameterGUI('sync', TaskParameters);
%     if TaskParameters.GUI.PlayStimulus>0 && ~BpodSystem.Data.Custom.PsychtoolboxStartup
%         PsychToolboxSoundServer('init');
%         BpodSystem.Data.Custom.PsychtoolboxStartup=true;
%         PsychToolboxSoundServer('Load', 1, BpodSystem.Data.Custom.Stimulus);%load stimulus to slave 1
%     end
    
    sma = stateMatrix(iTrial);
    SendStateMatrix(sma);
    try
    RawEvents = RunStateMatrix;
    catch
    disp(['Trial' iTrial ' an error occurred\n']);
      UserKillScriptKatharinaCatchError;
      pause  
    end
    if ~isempty(fieldnames(RawEvents))
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        SaveBpodSessionData;
    end
%     if length(erBpodSystem.GUIHandles.OutcomePlot.TrialRate.XData)>20
%     trialtimes=BpodSystem.GUIHandles.OutcomePlot.TrialRate.XData(end-2:end);
%     trialrate=3./(trialtimes(3)-trialtimes(1));
%     if trialrate<1
%        UserKillScriptKatharinaMouseNotWorking;
%     end
%     end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.BeingUsed == 0
        %PsychToolboxSoundServer('Stop', 1);%stop noise stream
        %UserKillScript;
        return
    end

    updateCustomDataFields(iTrial)%get data and create new stimuli here

    MainPlot(BpodSystem.GUIHandles.OutcomePlot,'update',iTrial);

    iTrial = iTrial + 1;
end


end



