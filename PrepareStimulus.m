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




% %% determine noise and signal volume for next trial
% if TaskParameters.GUI.BiasCorrection==2 && iTrial > 5 && BpodSystem.Data.Custom.ResponseCorrect(iTrial)~=1
% else
switch TaskParameters.GUIMeta.DecisionVariable.String{TaskParameters.GUI.DecisionVariable}
    
    case 'discrete'
        %first get Noise and Signal Volume
        if iTrial<TaskParameters.GUI.EasyTrials %start with easy trials
            StimulusSettings.NoiseVolume=min(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);
        else %draw randomly with given probability
            StimulusSettings.NoiseVolume=randsample(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume,1,1,TaskParameters.GUI.NoiseVolumeTable.Prob);
        end
        StimulusSettings.SignalVolume=TaskParameters.GUI.NoiseVolumeTable.SignalVolume(StimulusSettings.NoiseVolume==TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);
        
        %then decide whether to embed signal depending on Bias
        %Correction
        switch TaskParameters.GUIMeta.BiasCorrection.String{TaskParameters.GUI.BiasCorrection}
            case 'None'
                %draw randomly
                StimulusSettings.EmbedSignal=randsample(0:1,1,1,[.5 .5]);
                
            case 'BruteForce'
                % repeat stimulus in case of error in 50% of trials
                % (overall switch probabily after error = .25)
                % (overwrite Signal and noise Volume)
                if iTrial > 5 && BpodSystem.Data.Custom.ResponseCorrect(iTrial)~=1 && rand>.5
                    StimulusSettings.EmbedSignal=BpodSystem.Data.Custom.EmbedSignal(iTrial);
                    StimulusSettings.NoiseVolume=BpodSystem.Data.Custom.NoiseVolume(iTrial);
                    StimulusSettings.SignalVolume=BpodSystem.Data.Custom.SignalVolume(iTrial);
                else
                    %draw randomly
                    StimulusSettings.EmbedSignal=randsample(0:1,1,1,[.5 .5]);
                end
                
            case 'Soft'
                if iTrial > 5
                    %show non-prefered stimulus with p=1-bias (max .9) in case of Soft bias
                    %correction
                    CurrentBias=min(.9,max(.1,nansum(BpodSystem.Data.Custom.ResponseLeft)./sum(~isnan(BpodSystem.Data.Custom.ResponseLeft))));
                    StimulusSettings.EmbedSignal=randsample(0:1,1,1,[CurrentBias 1-CurrentBias]);
                else
                    %draw randomly
                    StimulusSettings.EmbedSignal=randsample(0:1,1,1,[.5 .5]);
                end
                
            case 'PerLevel'
                if iTrial>5 && sum(BpodSystem.Data.Custom.NoiseVolume==StimulusSettings.NoiseVolume) > 5
                    noiseIdx=BpodSystem.Data.Custom.NoiseVolume==StimulusSettings.NoiseVolume;
                    CurrentBias=min(.9,max(.1,nansum(BpodSystem.Data.Custom.ResponseLeft(noiseIdx))./sum(~isnan(BpodSystem.Data.Custom.ResponseLeft(noiseIdx)))));
                    StimulusSettings.EmbedSignal=randsample(0:1,1,1,[CurrentBias 1-CurrentBias]);
                else
                    %draw randomly
                    StimulusSettings.EmbedSignal=randsample(0:1,1,1,[.5 .5]);
                end
        end
        beta=rescaleNoise(StimulusSettings.NoiseVolume,StimulusSettings.EmbedSignal);

        
    case 'continuous'
        alpha=TaskParameters.GUI.BetaParam;
        noiseRange=-range(TaskParameters.GUI.ContinuousTable.NoiseLimits);%ACHTUNG! noise volumes inverted to evidence
        noiseMin=max(TaskParameters.GUI.ContinuousTable.NoiseLimits);%ACHTUNG! noise volumes inverted to evidence
        signalRange=range(TaskParameters.GUI.ContinuousTable.SignalLimits);
        signalMin=min(TaskParameters.GUI.ContinuousTable.SignalLimits);
        
        switch TaskParameters.GUIMeta.BiasCorrection.String{TaskParameters.GUI.BiasCorrection}
            case {'None'}
                if iTrial<TaskParameters.GUI.EasyTrials %make beta and random embed signal for easy trials
                    beta=betarnd(alpha/4,alpha/4,1,1)*2-1;%symmetric beta between -1 and 1
                else
                    %sample from symmetric beta distribution
                    beta=betarnd(alpha,alpha,1,1)*2-1;%symmetric beta between -1 and 1
                end
                StimulusSettings.EmbedSignal=beta>0;
                StimulusSettings.NoiseVolume=(abs(beta)*noiseRange)+noiseMin;
                StimulusSettings.SignalVolume=(abs(beta)*signalRange)+signalMin;
            case {'BruteForce'}
                % repeat stimulus in case of error in 50% of trials
                % (overall switch probabily after error = .25)
                if iTrial > 5 && BpodSystem.Data.Custom.ResponseCorrect(iTrial)~=1 && rand>.5
                    beta=BpodSystem.Data.Custom.NoiseVolumeRescaled(iTrial);
                else
                    if iTrial<TaskParameters.GUI.EasyTrials %make beta and random embed signal for easy trials
                        beta=betarnd(alpha/4,alpha/4,1,1)*2-1;%symmetric beta between -1 and 1
                    else
                        %sample from symmetric beta distribution
                        beta=betarnd(alpha,alpha,1,1)*2-1;%symmetric beta between -1 and 1
                    end
                end
                StimulusSettings.EmbedSignal=beta>0;
                StimulusSettings.NoiseVolume=(abs(beta)*noiseRange)+noiseMin;
                StimulusSettings.SignalVolume=(abs(beta)*signalRange)+signalMin;

            case {'Soft'}
                if iTrial<TaskParameters.GUI.EasyTrials %make beta and random embed signal for easy trials
                    StimulusSettings.EmbedSignal=randsample(0:1,1,1,[.5 .5]);
                    beta=betarnd(alpha/4,alpha/4,1,1)*2-1;%easy abd symmetric between -1 and 1
                else
                    CurrentBias=min(.9,max(.1,nansum(BpodSystem.Data.Custom.ResponseLeft)./sum(~isnan(BpodSystem.Data.Custom.ResponseLeft))));
                    StimulusSettings.EmbedSignal=randsample(0:1,1,1,[CurrentBias 1-CurrentBias]);
                    beta=betarnd(alpha,alpha,1,1)*2-1;%symmetric beta between -1 and 1
                end
                StimulusSettings.NoiseVolume=(abs(beta)*noiseRange)+noiseMin;
                StimulusSettings.SignalVolume=(abs(beta)*signalRange)+signalMin;
                
            case {'PerLevel'}
                if iTrial<TaskParameters.GUI.EasyTrials %make beta for easy trials
                    beta=betarnd(alpha/4,alpha/4,1,1)*2-1;%symmetric between -1 and 1
                else  % make beta distribution according to specified beta
                    CurrentBias=min(.9,max(.1,nansum(BpodSystem.Data.Custom.ResponseLeft)./sum(~isnan(BpodSystem.Data.Custom.ResponseLeft))));
                    BetaRatio = (1 - min(0.9,max(0.1,CurrentBias))) / min(0.9,max(0.1,CurrentBias));
                    BetaA =  (2*alpha*BetaRatio) / (1+BetaRatio); %make a,b symmetric around BetaParams to make B symmetric
                    BetaB = (alpha-BetaA) + alpha;
                    beta = betarnd(max(0,BetaA),max(0,BetaB),1,1)*2-1;%assymmetric beta between -1 and 1
                end
                StimulusSettings.EmbedSignal=beta>0;
                StimulusSettings.NoiseVolume=(abs(beta)*noiseRange)+noiseMin;
                StimulusSettings.SignalVolume=(abs(beta)*signalRange)+signalMin;                
        end
        
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
BpodSystem.Data.Custom.NoiseVolumeRescaled(iTrial+1)=beta;


