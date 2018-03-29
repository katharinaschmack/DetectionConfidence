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
    TaskParameters.GUI.AfterTrialInterval = 1; %DurAfterTrialIntervalon of after trial interval before next trial starts(s)
    TaskParameters.GUI.AfterTrialIntervalJitter = false; %Exponential jitter for after trial interval
    TaskParameters.GUIMeta.AfterTrialIntervalJitter.Style = 'checkbox';
    TaskParameters.GUI.ChoiceDeadline = 10; %Maximal Interval for choice after stimulus presentAfterTrialIntervalon
    TaskParameters.GUIPanels.General = {'Ports_LMR','AfterTrialInterval','AfterTrialIntervalJitter','ChoiceDeadline'};
    
    %"stimulus"
    TaskParameters.GUI.PlayStimulus = 3; %stimulus to be played at center port
    TaskParameters.GUIMeta.PlayStimulus.Style = 'popupmenu';
    TaskParameters.GUIMeta.PlayStimulus.String = {'None','Noise','Noise+Signal (easy)','Noise+Signal (variable)'};%
    TaskParameters.GUI.LightIntensity = 1; 
    
    
    %timing
    TaskParameters.GUI.MinSampleTime = 0.05;%minimum sample time required for reward will not decrease further (0.05 in Marion's script)
    TaskParameters.GUI.MaxSampleTime = 1; %sample time required for reward will not increase further (0.5)
    TaskParameters.GUI.AutoIncrSample = true; %for training
    TaskParameters.GUIMeta.AutoIncrSample.Style = 'checkbox';
    %TaskParameters.GUI.AutoIncrSampleUp = 0.01;
    %TaskParameters.GUI.AutoIncrSampleDown = 0.005;
    
    TaskParameters.GUI.CoutEarlyTimeout = 1;%time out for early withdrawal (marion 1s)
    TaskParameters.GUI.ErrorTimeout = 1;%time out for errors 

    %TaskParameters.GUI.EarlyWithdrawalNoise = true;%punishing sound for early withdrawal (marion true)
    %TaskParameters.GUIMeta.EarlyWithdrawalNoise.Style='checkbox';
    TaskParameters.GUI.GracePeriod = 1;%grace period at center port
    TaskParameters.GUI.StimDuration = TaskParameters.GUI.MinSampleTime;
    TaskParameters.GUI.PostStimDuration = .05;

    TaskParameters.GUIPanels.Sampling = {'PlayStimulus','LightIntensity','MinSampleTime','MaxSampleTime','AutoIncrSample','CoutEarlyTimeout','ErrorTimeout','GracePeriod','StimDuration','PostStimDuration'};
    %Reward
    TaskParameters.GUI.RewardAmountCorrect = 4;%reward amount lateral ports (marion 5)
    TaskParameters.GUI.RewardAmountError = 2;%reward amount lateral ports (marion 5)
    TaskParameters.GUI.RewardAmountCenter = .5;%reward amount center ports (marion .5)

    TaskParameters.GUI.Deplete = true;%deplete for correct choice biases (marion true)
    TaskParameters.GUIMeta.Deplete.Style = 'checkbox';
    TaskParameters.GUI.DepleteRate = 0.8;%deplete reward if twice the same port
    TaskParameters.GUI.Jackpot = 1;
    TaskParameters.GUIMeta.Jackpot.Style = 'popupmenu';
    TaskParameters.GUIMeta.Jackpot.String = {'No Jackpot','Fixed Jackpot','Decremental Jackpot','RewardCenterPort'};
    TaskParameters.GUI.JackpotMin = 1;
    TaskParameters.GUI.JackpotTime = 1;
    TaskParameters.GUIMeta.JackpotTime.Style = 'text';
    TaskParameters.GUIPanels.Reward = {'RewardAmountCorrect','RewardAmountError','RewardAmountCenter','Deplete','DepleteRate','Jackpot','JackpotMin','JackpotTime'};
    TaskParameters.GUI = orderfields(TaskParameters.GUI);
    TaskParameters.Figures.OutcomePlot.Position = [200, 200, 1000, 400];
end
BpodParameterGUI('init', TaskParameters);

%% Initializing data (trial type) vectors and first values
%intervals
BpodSystem.Data.Custom.StimDuration = TaskParameters.GUI.MinSampleTime;
BpodSystem.Data.Custom.ConfidenceWaitingTime = 10; 
BpodSystem.Data.Custom.PostStimulusDuration = .2;

if TaskParameters.GUI.AfterTrialIntervalJitter
    BpodSystem.Data.Custom.AfterTrialInterval = min( [ exprnd(TaskParameters.GUI.AfterTrialInterval) 5*TaskParameters.GUI.AfterTrialInterval ]);
else
    BpodSystem.Data.Custom.AfterTrialInterval = TaskParameters.GUI.AfterTrialInterval;
end

BpodSystem.Data.Custom.RewardAmountCorrect(1) = TaskParameters.GUI.RewardAmountCorrect;
BpodSystem.Data.Custom.RewardAmountCenter(1) = TaskParameters.GUI.RewardAmountCenter;
BpodSystem.Data.Custom.RewardAmountError(1) = TaskParameters.GUI.RewardAmountError;

%BpodSystem.Data.Custom.LightIntensity = floor(255 * TaskParameters.GUI.LightIntensity);

%BpodSystem.Data.Custom.Rewarded = false;
%BpodSystem.Data.Custom.CenterPortRewarded = false;
%BpodSystem.Data.Custom.GracePeriod = 0;

%server data
[~,BpodSystem.Data.Custom.Rig] = system('hostname');
[~,BpodSystem.Data.Custom.Subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.DataPath))));

%state of Psychtoolbox
BpodSystem.Data.Custom.PsychtoolboxStartup=false;

BpodSystem.Data.Custom = orderfields(BpodSystem.Data.Custom);

%[BpodSystem.Data.Custom.RightClickTrain,BpodSystem.Data.Custom.LeftClickTrain] = getClickStimulus(BpodSystem.Data.Custom.MaxSampleTime);

%% Prepare First Auditory Stimulus delivery
%stimulus settings
StimulusSettings.SamplingRate=192000;%sampling rate of sound card
StimulusSettings.EmbedSignal=rand>.5;%if false only noise will be played
if TaskParameters.GUI.PlayStimulus == 2
    StimulusSettings.EmbedSignal=false;
end
StimulusSettings.NoiseDuration=BpodSystem.Data.Custom.StimDuration;
StimulusSettings.NoiseColor='WhiteGaussian';
StimulusSettings.NoiseVolume=40;%in dB
StimulusSettings.SignalDuration=min([0.1 BpodSystem.Data.Custom.StimDuration]);%plays signal of 0.1 s or sample time duration (if shorter)
StimulusSettings.SignalLatency=(StimulusSettings.NoiseDuration-StimulusSettings.SignalDuration)./2;%mean of exponential distribution from which latency is drawn (exponential to keep the hazard ratio flat)
StimulusSettings.SignalForm='QuadraticConvex';
StimulusSettings.SignalMinFreq=5E3;
StimulusSettings.SignalMaxFreq=10E3;
StimulusSettings.SignalVolume=40;%in dB

[BpodSystem.Data.Custom.Stimulus BpodSystem.Data.Custom.SignalEmbedTime] = GenerateSignalInNoiseStimulus(StimulusSettings);
BpodSystem.Data.Custom.SignalVolume = StimulusSettings.SignalVolume;
BpodSystem.Data.Custom.SignalDuration = StimulusSettings.SignalDuration;

%tell that stimuli will be played by Psychtoolbox via the SoftCodeHandler
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler';

%prepare Psychotoolbox if necessary
% if ~BpodSystem.EmulatorMode && ~BpodSystem.Data.Custom.PsychtoolboxStartup
if  ~BpodSystem.Data.Custom.PsychtoolboxStartup
    PsychToolboxSoundServer('init');
    BpodSystem.Data.Custom.PsychtoolboxStartup=true;
end
PsychToolboxSoundServer('Load', 1, BpodSystem.Data.Custom.Stimulus);%load noise to slave 1



%% Configure PulsePal
load PulsePalParamStimulus.mat
load PulsePalParamFeedback.mat
BpodSystem.Data.Custom.PulsePalParamStimulus=PulsePalParamStimulus;
BpodSystem.Data.Custom.PulsePalParamFeedback=PulsePalParamFeedback;
clear PulsePalParamFeedback PulsePalParamStimulus
if ~BpodSystem.EmulatorMode
    ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamStimulus);
    %SendCustomPulseTrain(1, BpodSystem.Data.Custom.RightClickTrain, ones(1,length(BpodSystem.Data.Custom.RightClickTrain))*5);
    %SendCustomPulseTrain(2, BpodSystem.Data.Custom.LeftClickTrain, ones(1,length(BpodSystem.Data.Custom.LeftClickTrain))*5);
end


%% Initialize plots
BpodSystem.ProtocolFigures.SideOutcomePlotFig = figure('Position', TaskParameters.Figures.OutcomePlot.Position,'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleOutcome = axes('Position',    [  .055            .15 .91 .3]);
BpodSystem.GUIHandles.OutcomePlot.HandleGracePeriod = axes('Position',  [1*.05           .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate = axes('Position',    [3*.05 + 2*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleST = axes('Position',           [5*.05 + 4*.08   .6  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleMT = axes('Position',           [6*.05 + 6*.08   .6  .1  .3], 'Visible', 'off');
%MouseNosePoke_PlotSideOutcome(BpodSystem.GUIHandles.OutcomePlot,'init');

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
    %MouseNosePoke_PlotSideOutcome(BpodSystem.GUIHandles.OutcomePlot,'update',iTrial);
    iTrial = iTrial + 1;
end
end



