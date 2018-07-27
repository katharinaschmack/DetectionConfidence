function PrepareStimulus(iTrial)  

global BpodSystem
global TaskParameters

%invariant Settings
StimulusSettings.SamplingRate=192000;%sampling rate of sound card
StimulusSettings.Ramp=.02;%duration (s) of ramping at on and offset of noise used to avoid clicking sounds
StimulusSettings.NoiseDuration=10;%length of noise stream (s) that will be looped
StimulusSettings.NoiseColor='WhiteGaussian';
StimulusSettings.MaxVolume=70;
StimulusSettings.MinVolume=-20;
StimulusSettings.SignalForm='LinearUpsweep';
StimulusSettings.SignalMinFreq=10E3;
StimulusSettings.SignalMaxFreq=15E3;
%variable settings
StimulusSettings.SignalDuration=TaskParameters.GUI.StimDuration;


%% determine whether signal or no signal trial is shown next 
if TaskParameters.GUI.BiasCorrection==2 && iTrial > 5 && BpodSystem.Data.Custom.ResponseCorrect(iTrial)~=1
    % repeat stimulus in case of BruteForce bias correction
    StimulusSettings.EmbedSignal=BpodSystem.Data.Custom.EmbedSignal(iTrial);
    
elseif TaskParameters.GUI.BiasCorrection==3 && iTrial > 5
    %show non-prefered stimulus with p=1-bias (max .9) in case of Soft bias
    %correction
    CurrentBias=min(.9,max(.1,nansum(BpodSystem.Data.Custom.ResponseLeft)./sum(~isnan(BpodSystem.Data.Custom.ResponseLeft))));
    StimulusSettings.EmbedSignal=randsample(0:1,1,1,[CurrentBias 1-CurrentBias]);
    
else
    %draw randomly in all aother cases
    StimulusSettings.EmbedSignal=randsample(0:1,1,1,[.5 .5]);
end


%% determine noise and signal volume for next trial
if TaskParameters.GUI.BiasCorrection==2 && iTrial > 5 && BpodSystem.Data.Custom.ResponseCorrect(iTrial)~=1
    % repeat stimulus in case of BruteForce bias correction
    StimulusSettings.NoiseVolume=BpodSystem.Data.Custom.NoiseVolume(iTrial);
    StimulusSettings.SignalVolume=BpodSystem.Data.Custom.SignalVolume(iTrial);
else
    % draw from specified noise levels in all other cases
    if iTrial<TaskParameters.GUI.EasyTrials %start with easy trials
        StimulusSettings.NoiseVolume=min(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);
    else %draw randomly with given probability
        StimulusSettings.NoiseVolume=randsample(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume,1,1,TaskParameters.GUI.NoiseVolumeTable.Prob);
    end
    
    %match signal level
    StimulusSettings.SignalVolume=TaskParameters.GUI.NoiseVolumeTable.SignalVolume(StimulusSettings.NoiseVolume==TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);
end

%generate stimuli EDIT HERE TO SAVE THEM
NoiseStream = GenerateNoise(StimulusSettings);
SignalStream = GenerateSignal(StimulusSettings).*StimulusSettings.EmbedSignal;

%noiseName = fullfile(BpodSystem.Data.Custom.StimulusPath,sprintf('noise%04.0f.mat',iTrial+1));
%save(noiseName,'NoiseStream');
%noiseName = fullfile(BpodSystem.Custom.StimulusPath,sprintf('noise%04.0f.mat',iTrial));

%prepare Psychotoolbox if necessary
if  ~BpodSystem.Data.Custom.PsychtoolboxStartup
    PsychToolboxSoundServerLoop('init');
    BpodSystem.Data.Custom.PsychtoolboxStartup=true;
end

%load stimuli to Psychtoolbox
PsychToolboxSoundServerLoop('Load', 1, NoiseStream);%load noise to slave 1
PsychToolboxSoundServerLoop('Load', 2, SignalStream);%load signal to slave 2

%put trial-by-trial varying settings into BpodSystem.Data.Custom
BpodSystem.Data.Custom.MaxVolume(iTrial+1) = StimulusSettings.MaxVolume;
BpodSystem.Data.Custom.MinVolume(iTrial+1) = StimulusSettings.MinVolume;
BpodSystem.Data.Custom.EmbedSignal(iTrial+1) = StimulusSettings.EmbedSignal;
BpodSystem.Data.Custom.SignalDuration(iTrial+1) = StimulusSettings.SignalDuration;
BpodSystem.Data.Custom.SignalVolume(iTrial+1) = StimulusSettings.SignalVolume;
BpodSystem.Data.Custom.NoiseVolume(iTrial+1) = StimulusSettings.NoiseVolume;
%BpodSystem.Data.Custom.NoiseVolumePlot(iTrial+1) = StimulusSettings.NoiseVolume*(StimulusSettings.EmbedSignal/.5-1);

