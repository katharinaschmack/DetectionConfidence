function TaskParameters=defaultTaskParametersDefault(TaskParameters)
%% appends default values to TaskParametersDefault for DetectionConfidence
%% July 2019 katharinaschmack

%% define tabs
TaskParametersDefault.GUITabs.General = {'General','Photometry'};
TaskParametersDefault.GUITabs.Stimulus = {'Stimulus','NoiseVolumeTable','ContinuousTable','BiasVersion','BiasTable'};
TaskParametersDefault.GUITabs.Timing = {'Timing'};
TaskParametersDefault.GUITabs.Feedback = {'Sampling','Choice','FeedbackDelay'};
% TaskParametersDefault.GUITabs.Plots = {'ShowPlots'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 'General' tab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 'General' panel
TaskParametersDefault.GUIPanels.General = {'Ports_LMR','AfterTrialInterval','AfterTrialIntervalJitter',...
    'AfterTrialIntervalMin','AfterTrialIntervalMax','LightGuidance'};

TaskParametersDefault.GUI.Ports_LMR = '123'; %Port IDs for signal-center-noise
TaskParametersDefault.GUI.AfterTrialInterval = .5; %Duration before trial trial starts (s) (for historic reasons named AfterTrialInterval, should be 'BeforeTrialInterval')
TaskParametersDefault.GUI.AfterTrialIntervalJitter = true; %true sets exponential jitter with mean  defined by AfterTrialInterval, false fixed AfterTrialInterval
TaskParametersDefault.GUIMeta.AfterTrialIntervalJitter.Style = 'checkbox';
TaskParametersDefault.GUI.AfterTrialIntervalMin = .1;%Minimum for jitter
TaskParametersDefault.GUI.AfterTrialIntervalMax = 2.5;%Maximum for jitter
TaskParametersDefault.GUI.LightGuidance = true; %true LED ports indicate active ports, if false LED ports remain on when active
TaskParametersDefault.GUIMeta.LightGuidance.Style = 'checkbox';


% 'Photometry' panel
TaskParametersDefault.GUIPanels.Photometry = {'PhotometryOn','LED1_amp', 'LED2_amp',...
    'ch1','ch2','LED1_f', 'LED2_f','PostTrialRecording'};

TaskParametersDefault.GUI.LED1_amp = 2.5;
TaskParametersDefault.GUI.LED2_amp = 2.5;
TaskParametersDefault.GUI.PhotometryOn = 0;%0-no photometry, 1-photometry in channels as defined, 2-alternating between channels
TaskParametersDefault.GUI.LED1_f = 531;
TaskParametersDefault.GUI.LED2_f = 211;
TaskParametersDefault.GUI.PostTrialRecording = 2;%sets Time that will be recorded after trial end
TaskParametersDefault.GUI.ch1 = 1;
TaskParametersDefault.GUIMeta.ch1.Style = 'checkbox';
TaskParametersDefault.GUI.ch2 = 1;
TaskParametersDefault.GUIMeta.ch2.Style = 'checkbox';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 'Stimulus' tab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus panel
TaskParametersDefault.GUIPanels.Stimulus = {'DecisionVariable','BetaParam','EasyTrials','StimDuration'};

TaskParametersDefault.GUI.DecisionVariable=2;
TaskParametersDefault.GUIMeta.DecisionVariable.Style = 'popupmenu';
TaskParametersDefault.GUIMeta.DecisionVariable.String = {'discrete','continuous'};%discrete noise and signal volumes as defined NoiseVolumeTable, continuous defined in continuous table
TaskParametersDefault.GUI.BetaParam=0.1;%beta parameter determines distribution from which continuous stimuli are drawn (1-easy, 0.1-difficult)
TaskParametersDefault.GUI.EasyTrials=20;
TaskParametersDefault.GUI.StimDuration=0.1;

% NoiseVolume panel
TaskParametersDefault.GUIPanels.NoiseVolumeTable ={'NoiseVolumeTable'};

TaskParametersDefault.GUI.NoiseVolumeTable.NoiseVolume=[40 40 40]';
TaskParametersDefault.GUI.NoiseVolumeTable.SignalVolume=[30 45 60]';
TaskParametersDefault.GUI.NoiseVolumeTable.Prob=[1 1 1]';

TaskParametersDefault.GUIMeta.NoiseVolumeTable.Style = 'table';
TaskParametersDefault.GUIMeta.NoiseVolumeTable.String = 'Noise volumes';
TaskParametersDefault.GUIMeta.NoiseVolumeTable.ColumnLabel = {'noise','signal','probabilty'};

% ContinouusTable panel
TaskParametersDefault.GUIPanels.ContinuousTable ={'ContinuousTable'};

TaskParametersDefault.GUI.ContinuousTable.NoiseLimits=[40 40]';
TaskParametersDefault.GUI.ContinuousTable.SignalLimits=[35 65]';
TaskParametersDefault.GUIMeta.ContinuousTable.Style = 'table';
TaskParametersDefault.GUIMeta.ContinuousTable.String = 'Decision variable';
TaskParametersDefault.GUIMeta.ContinuousTable.ColumnLabel = {'noiseLims','signalLims'};

% BiasVersion panel
TaskParametersDefault.GUIPanels.BiasVersion={'BiasVersion'};

TaskParametersDefault.GUI.BiasVersion = 3;
TaskParametersDefault.GUIMeta.BiasVersion.Style = 'popupmenu';
TaskParametersDefault.GUIMeta.BiasVersion.String = {'None','Soft','Block','Noise'};%Soft: use for bias correction, calculates bias over all trials and presents non-prefered stimulus with p=1-bias.

% BiasTable panel (for presenting biased versions to induce perceptual
% priors)
TaskParametersDefault.GUIPanels.BiasTable={'BiasTable'};

TaskParametersDefault.GUI.BiasTable.Signal=[.3 .5 .7]';
TaskParametersDefault.GUI.BiasTable.Noise=[40 40 40]';
TaskParametersDefault.GUI.BiasTable.BlockLength=[200 200 200]';
TaskParametersDefault.GUIMeta.BiasTable.Style = 'table';
TaskParametersDefault.GUIMeta.BiasTable.String = 'Bias blocks';
TaskParametersDefault.GUIMeta.BiasTable.ColumnLabel = {'signal bias','noise','trials'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 'Timing' tab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Timing panel
TaskParametersDefault.GUIPanels.Timing = {'PreStimDuration',...
    'PreStimDurationSelection','PreStimDurationMin','PreStimDurationMax','PreStimDurationRampUp','PreStimDurationRampDown','PreStimDurationTau'};

TaskParametersDefault.GUI.PreStimDurationSelection = 3;
TaskParametersDefault.GUIMeta.PreStimDurationSelection.Style = 'popupmenu';
TaskParametersDefault.GUIMeta.PreStimDurationSelection.String = {'Fix','AutoIncr','TruncExp'};
TaskParametersDefault.GUI.PreStimDurationTau = 0.2;
TaskParametersDefault.GUI.PreStimDurationMin = 0.05;%minimum sample time required for reward will not decrease further (0.05 in Marion's script)
TaskParametersDefault.GUI.PreStimDuration = TaskParametersDefault.GUI.PreStimDurationMin;
TaskParametersDefault.GUIMeta.PreStimDuration.Style = 'text';
TaskParametersDefault.GUI.PreStimDurationMax = .5; %sample time required for reward will not increase further (0.5)
TaskParametersDefault.GUI.PreStimDurationRampUp = 0.01;
TaskParametersDefault.GUI.PreStimDurationRampDown = 0.005;
TaskParametersDefault.GUI.RewardAmountCenter = 0.5;%reward amount center ports (marion .5)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 'Feedback' tab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sampling panel
TaskParametersDefault.GUIPanels.Sampling = {'RewardAmountCenter',...
    'RewardAmountCenterSelection','RewardAmountCenterEasyTrials','CoutEarlyTimeout'};

TaskParametersDefault.GUI.RewardAmountCenterSelection = 2;
TaskParametersDefault.GUIMeta.RewardAmountCenterSelection.Style = 'text';
TaskParametersDefault.GUIMeta.RewardAmountCenterSelection.Style = 'popupmenu';
TaskParametersDefault.GUIMeta.RewardAmountCenterSelection.String = {'Fix','Decrease'};
TaskParametersDefault.GUI.RewardAmountCenterEasyTrials = 50;
TaskParametersDefault.GUI.CoutEarlyTimeout = 0;%time out for early withdrawal (marion 1s)


% Choice panel
TaskParametersDefault.GUIPanels.Choice = {'ChoiceDeadline','RewardAmountCorrect',...
    'RewardAmountError','ErrorTimeout'};%,'Deplete','DepleteRate','Jackpot','JackpotMin','JackpotTime'};

TaskParametersDefault.GUI.ChoiceDeadline = 5; %Maximal Interval for choice after stimulus presentAfterTrialIntervalon
TaskParametersDefault.GUI.RewardAmountCorrect = 5;%reward amount lateral ports (marion 5)
TaskParametersDefault.GUI.RewardAmountError = 0;%reward amount lateral ports (marion 5)
TaskParametersDefault.GUI.ErrorTimeout = 0;%time out for errors

% FeedbackDelay panel
TaskParametersDefault.GUIPanels.FeedbackDelay = {'FeedbackDelay','FeedbackDelaySelection','FeedbackDelayMin','FeedbackDelayMax','FeedbackDelayIncr','FeedbackDelayDecr','FeedbackDelayTau',...
    'FeedbackDelayGrace','PercentCatch','CatchError','StartNoCatchTrials','SkippedCorrectCorrection'};

TaskParametersDefault.GUI.FeedbackDelaySelection = 1;
TaskParametersDefault.GUIMeta.FeedbackDelaySelection.Style = 'popupmenu';
TaskParametersDefault.GUIMeta.FeedbackDelaySelection.String = {'Fix','AutoIncr','TruncExp'};
TaskParametersDefault.GUI.FeedbackDelayMin = 0;
TaskParametersDefault.GUI.FeedbackDelayMax = 0;
TaskParametersDefault.GUI.FeedbackDelayIncr = 0.01;
TaskParametersDefault.GUI.FeedbackDelayDecr = 0.01;
TaskParametersDefault.GUI.FeedbackDelayTau = 0.05;
TaskParametersDefault.GUI.FeedbackDelayGrace = 0;
TaskParametersDefault.GUI.PercentCatch = 0;
TaskParametersDefault.GUI.CatchError = false;
TaskParametersDefault.GUIMeta.CatchError.Style = 'checkbox';
TaskParametersDefault.GUI.FeedbackDelay = TaskParametersDefault.GUI.FeedbackDelayMin;
TaskParametersDefault.GUIMeta.FeedbackDelay.Style = 'text';
TaskParametersDefault.GUI.StartNoCatchTrials = 20;
TaskParametersDefault.GUI.SkippedCorrectCorrection = 1;
TaskParametersDefault.GUIMeta.SkippedCorrectCorrection.Style = 'popupmenu';
TaskParametersDefault.GUIMeta.SkippedCorrectCorrection.String = {'None','RepeatSkipped','RepeatSkippedCatch'};%BruteForce: presents the same stimulus until a correct choice is made, then resumes stimulus sequence; Soft: calculates bias over all trials and presents non-prefered stimulus with p=1-bias.

% %Plot
% TaskParametersDefault.GUI.ShowPsycAud = 1;
% TaskParametersDefault.GUIMeta.ShowPsycAud.Style = 'checkbox';
% TaskParametersDefault.GUI.ShowVevaiometric = 1;
% TaskParametersDefault.GUIMeta.ShowVevaiometric.Style = 'checkbox';
% TaskParametersDefault.GUI.ShowTrialRate = 1;
% TaskParametersDefault.GUIMeta.ShowTrialRate.Style = 'checkbox';
% TaskParametersDefault.GUI.ShowFix = 1;
% TaskParametersDefault.GUIMeta.ShowFix.Style = 'checkbox';
% TaskParametersDefault.GUI.ShowST = 1;
% TaskParametersDefault.GUIMeta.ShowST.Style = 'checkbox';
% TaskParametersDefault.GUI.ShowFix = 1;
% TaskParametersDefault.GUIMeta.ShowFix.Style = 'checkbox';
% TaskParametersDefault.GUI.ShowST = 1;
% TaskParametersDefault.GUIMeta.ShowST.Style = 'checkbox';
% TaskParametersDefault.GUI.ShowFeedback = 1;
% TaskParametersDefault.GUIMeta.ShowFeedback.Style = 'checkbox';
% TaskParametersDefault.GUIPanels.ShowPlots = {'ShowPsycAud','ShowVevaiometric','ShowTrialRate','ShowFix','ShowST','ShowFeedback'};



%% organize Tabs Tabs
TaskParametersDefault.GUI = orderfields(TaskParametersDefault.GUI);

