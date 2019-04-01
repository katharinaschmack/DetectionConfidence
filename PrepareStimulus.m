function PrepareStimulus(iTrial)

global BpodSystem
global TaskParameters

%invariant Settings
StimulusSettings.SamplingRate=192000;%sampling rate of sound card
StimulusSettings.Ramp=.1;%duration (s) of ramping at on and offset of noise used to avoid clicking sounds
StimulusSettings.NoiseDuration=10;%length of noise stream (s) that will be looped
StimulusSettings.NoiseColor='WhiteGaussian';
StimulusSettings.MaxVolume=70;
StimulusSettings.MinVolume=-20;
StimulusSettings.SignalForm='LinearUpsweep';
StimulusSettings.SignalMinFreq=10E3;
StimulusSettings.SignalMaxFreq=15E3;
%variable settings
StimulusSettings.SignalDuration=TaskParameters.GUI.StimDuration;

% determine noise and signal volume for next trial
% if TaskParameters.GUI.BiasCorrection==2 && iTrial > 5 && BpodSystem.Data.Custom.ResponseCorrect(iTrial)~=1
% else
switch TaskParameters.GUIMeta.DecisionVariable.String{TaskParameters.GUI.DecisionVariable}
    case 'discrete'
        switch BpodSystem.Data.Custom.Variation%% update times & stimulus
            case {'noise','both','none'}
                %first find out whether Noise, Signal or both are varied
                if iTrial<TaskParameters.GUI.EasyTrials %start with easy trials
                    StimulusSettings.NoiseVolume=min(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);
                else %draw randomly with given probability
                    StimulusSettings.NoiseVolume=randsample(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume,1,1,TaskParameters.GUI.NoiseVolumeTable.Prob);
                end
                StimulusSettings.SignalVolume=TaskParameters.GUI.NoiseVolumeTable.SignalVolume(StimulusSettings.NoiseVolume==TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);
            case {'signal'}
                if iTrial<TaskParameters.GUI.EasyTrials %start with easy trials
                    StimulusSettings.SignalVolume=max(TaskParameters.GUI.NoiseVolumeTable.SignalVolume);
                else
                    StimulusSettings.SignalVolume=randsample(TaskParameters.GUI.NoiseVolumeTable.SignalVolume,1,1,TaskParameters.GUI.NoiseVolumeTable.Prob);
                end
                StimulusSettings.NoiseVolume=TaskParameters.GUI.NoiseVolumeTable.NoiseVolume(StimulusSettings.SignalVolume==TaskParameters.GUI.NoiseVolumeTable.SignalVolume);
        end
        
    case 'continuous'
        alpha=TaskParameters.GUI.BetaParam;
        noiseRange=-range(TaskParameters.GUI.ContinuousTable.NoiseLimits);%ACHTUNG! noise volumes inverted to evidence
        noiseMin=max(TaskParameters.GUI.ContinuousTable.NoiseLimits);%ACHTUNG! noise volumes inverted to evidence
        signalRange=range(TaskParameters.GUI.ContinuousTable.SignalLimits);
        signalMin=min(TaskParameters.GUI.ContinuousTable.SignalLimits);
        if iTrial<TaskParameters.GUI.EasyTrials %make beta and random embed signal for easy trials
            beta=betarnd(0.1,0.1,1,1)*2-1;%symmetric beta between -1 and 1
        else
            %sample from symmetric beta distribution
            beta=betarnd(alpha,alpha,1,1)*2-1;%symmetric beta between -1 and 1
        end
        StimulusSettings.NoiseVolume=(abs(beta)*noiseRange)+noiseMin;
        StimulusSettings.SignalVolume=(abs(beta)*signalRange)+signalMin;
end

%decide whether to embed signal or not
switch TaskParameters.GUIMeta.BiasVersion.String{TaskParameters.GUI.BiasVersion}
    case {'None'}
        CurrentBias=.5;
        BpodSystem.Data.Custom.BlockBias(iTrial+1)=CurrentBias;

    case {'Soft'}
        if iTrial<TaskParameters.GUI.EasyTrials %make beta and random embed signal for easy trials
            CurrentBias=.5;
        else
            CurrentBias=1-min(.9,max(.1,nansum(BpodSystem.Data.Custom.ResponseLeft)./sum(~isnan(BpodSystem.Data.Custom.ResponseLeft))));
        end
        BpodSystem.Data.Custom.BlockBias(iTrial+1)=CurrentBias;
        
    case 'Block'
        %look up current bias
        CurrentBias=BpodSystem.Data.Custom.BlockBias(iTrial+1);
end
StimulusSettings.EmbedSignal=randsample(0:1,1,1,[1-CurrentBias CurrentBias]);
% fprintf('CurrentBias %2.1f\tBlockTrial %2.1f\n',CurrentBias,BpodSystem.Data.Custom.BlockTrial(iTrial+1));
if BpodSystem.Data.Custom.RepeatMode(iTrial+1) %overwrite stimulus difficult and identity if in repeat mode
    StimulusSettings.EmbedSignal=BpodSystem.Data.Custom.EmbedSignal(iTrial);
    StimulusSettings.SignalVolume=BpodSystem.Data.Custom.SignalVolume(iTrial);
    StimulusSettings.NoiseVolume=BpodSystem.Data.Custom.NoiseVolume(iTrial);
    beta=BpodSystem.Data.Custom.Beta(iTrial);
end

%% set random numbers based on current time
StimulusSettings.RandomStream=rng('shuffle');

%generate stimuli EDIT HERE TO SAVE THEM
NoiseStream = GenerateNoise(StimulusSettings);
SignalStream = GenerateSignal(StimulusSettings).*StimulusSettings.EmbedSignal;

stimulusName = fullfile(BpodSystem.Data.Custom.StimulusPath,sprintf('StimulusSettings_%04.0f.mat',iTrial+1));
save(stimulusName,'StimulusSettings');

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
BpodSystem.Data.Custom.NoiseVolumeRescaled(iTrial+1)=rescaleNoise(StimulusSettings.NoiseVolume,StimulusSettings.EmbedSignal);
switch TaskParameters.GUIMeta.DecisionVariable.String{TaskParameters.GUI.DecisionVariable}
    case 'discrete'
        BpodSystem.Data.Custom.Beta(iTrial+1)=nan;
    case 'continuous'
        BpodSystem.Data.Custom.Beta(iTrial+1)=beta;
end


