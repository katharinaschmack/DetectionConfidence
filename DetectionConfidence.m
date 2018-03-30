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
    
    %"stimulus
    TaskParameters.GUI.PlayStimulus = 3; %stimulus to be played at center port
    TaskParameters.GUIMeta.PlayStimulus.Style = 'popupmenu';
    TaskParameters.GUIMeta.PlayStimulus.String = {'None','Noise','Noise+Signal (easy)','Noise+Signal (variable)'};%
    %TaskParameters.GUI.LightIntensity = 1; 
    TaskParameters.GUI.MinStimDuration = 0.05;%minimum sample time required for reward will not decrease further (0.05 in Marion's script)
    TaskParameters.GUI.StimDuration = TaskParameters.GUI.MinStimDuration;
    TaskParameters.GUIMeta.StimDuration.Style = 'text';
    TaskParameters.GUI.MaxStimDuration = 1; %sample time required for reward will not increase further (0.5)
    TaskParameters.GUI.AutoRampStimDuration = true; %for training
    TaskParameters.GUIMeta.AutoRampStimDuration.Style = 'checkbox';
    TaskParameters.GUI.StimDurationRampUp = 0.01;
    TaskParameters.GUI.StimDurationRampDown = 0.005;        
    TaskParameters.GUI.PostStimDuration = .05;
    TaskParameters.GUI.RewardAmountCenter = .5;%reward amount center ports (marion .5)
    TaskParameters.GUI.CoutEarlyTimeout = 1;%time out for early withdrawal (marion 1s)

    %TaskParameters.GUI.EarlyWithdrawalNoise = true;%punishing sound for early withdrawal (marion true)
    %TaskParameters.GUIMeta.EarlyWithdrawalNoise.Style='checkbox';
    TaskParameters.GUIPanels.Stimulus = {'PlayStimulus','StimDuration','PostStimDuration','RewardAmountCenter','CoutEarlyTimeout',...
        'AutoRampStimDuration','MinStimDuration','MaxStimDuration','StimDurationRampUp','StimDurationRampDown'};
    
    %Reward & Punishment
    TaskParameters.GUI.ChoiceDeadline = 5; %Maximal Interval for choice after stimulus presentAfterTrialIntervalon
    TaskParameters.GUI.RewardAmountCorrect = 4;%reward amount lateral ports (marion 5)
    TaskParameters.GUI.RewardAmountError = 2;%reward amount lateral ports (marion 5)
    TaskParameters.GUI.GracePeriod = 0;%grace period
    %TaskParameters.GUI.ConfidenceWaitingTime = 1;
    TaskParameters.GUI.ErrorTimeout = 1;%time out for errors 
    TaskParameters.GUIPanels.Response = {'ChoiceDeadline','RewardAmountCorrect','RewardAmountError','GracePeriod','ErrorTimeout'};%,'Deplete','DepleteRate','Jackpot','JackpotMin','JackpotTime'};
   
    TaskParameters.GUI = orderfields(TaskParameters.GUI);
    TaskParameters.Figures.OutcomePlot.Position = [200, 200, 1000, 400];
end
BpodParameterGUI('init', TaskParameters);

%put trial-by-trial varying settings into BpodSystem.Data.Custom
BpodSystem.Data.Custom.StimDuration = TaskParameters.GUI.StimDuration;
BpodSystem.Data.Custom.ConfidenceWaitingTime = 0;%update here for confidence report training
if TaskParameters.GUI.AfterTrialIntervalJitter
    BpodSystem.Data.Custom.AfterTrialInterval = min( [ exprnd(TaskParameters.GUI.AfterTrialInterval) 5*TaskParameters.GUI.AfterTrialInterval ]);
else
    BpodSystem.Data.Custom.AfterTrialInterval = TaskParameters.GUI.AfterTrialInterval;
end
BpodSystem.Data.Custom.RewardAmountCorrect(1) = TaskParameters.GUI.RewardAmountCorrect;
BpodSystem.Data.Custom.RewardAmountCenter(1) = TaskParameters.GUI.RewardAmountCenter;
BpodSystem.Data.Custom.RewardAmountError(1) = TaskParameters.GUI.RewardAmountError;
%BpodSystem.Data.Custom.LightIntensity = floor(255 * TaskParameters.GUI.LightIntensity);

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
    StimulusSettings.NoiseVolume=40;%in dB
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
        StimulusSettings.SignalVolume=40;%in dB
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



