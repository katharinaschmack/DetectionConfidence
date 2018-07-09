function PrepareStimulus(EmbedSignal,iTrial)  

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
StimulusSettings.EmbedSignal=EmbedSignal;

%% determine noise volume for next trial
if iTrial<TaskParameters.GUI.EasyTrials
    StimulusSettings.NoiseVolume=min(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);
else
    StimulusSettings.NoiseVolume=randsample(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume,1,1,TaskParameters.GUI.NoiseVolumeTable.Prob);
end
StimulusSettings.SignalVolume=TaskParameters.GUI.NoiseVolumeTable.SignalVolume(StimulusSettings.NoiseVolume==TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);

%     targetIdx=randsample(1:numel(TaskParameters.GUI.NoiseVolumeAdaptive.Target),1);
%     targetPerformance=TaskParameters.GUI.NoiseVolumeAdaptive.Target(targetIdx);
%     trialsPerformanceStream=find(BpodSystem.Data.Custom.TargetPerformance==targetPerformance&...       
%         ~isnan(BpodSystem.Data.Custom.ResponseCorrect)&...
%         BpodSystem.Data.Custom.EmbedSignal==1);
%    
%     if length(trialsPerformanceStream)<5 %start with easy trials per stream
%         StimulusSettings.NoiseVolume=TaskParameters.GUI.NoiseVolumeAdaptive.StartNoiseVolume(targetIdx);
%         StimulusSettings.SignalVolume=TaskParameters.GUI.NoiseVolumeAdaptive.StartSignalVolume(targetIdx);
%             
%     else %adapt according to performance in current performance stream
%         trialsToConsider=max(numel(trialsPerformanceStream)-TaskParameters.GUI.NoiseVolumeAdaptive.History(targetIdx),0)+1;
%         trialsIdx=trialsPerformanceStream(trialsToConsider:end);        
%         considerPerformance=mean(BpodSystem.Data.Custom.ResponseCorrect(trialsIdx)==1)*100;
% 
%         sameNoiseVolume=BpodSystem.Data.Custom.NoiseVolume(trialsIdx(end));
%         diffNoiseVolume=BpodSystem.Data.Custom.NoiseVolume(trialsIdx(end))+...%last volume
%             TaskParameters.GUI.NoiseVolumeAdaptive.StepDown(targetIdx);%evidence step down
%         easyNoiseVolume=BpodSystem.Data.Custom.NoiseVolume(trialsIdx(end))-...%last volume
%             TaskParameters.GUI.NoiseVolumeAdaptive.StepUp(targetIdx);%evidence step up
%         sameSignalVolume=BpodSystem.Data.Custom.SignalVolume(trialsIdx(end));
%         diffSignalVolume=BpodSystem.Data.Custom.SignalVolume(trialsIdx(end))-...%last signal volume
%             TaskParameters.GUI.NoiseVolumeAdaptive.StepDown(targetIdx);%step down
%         easySignalVolume=BpodSystem.Data.Custom.SignalVolume(trialsIdx(end))+...%last signal volume
%             TaskParameters.GUI.NoiseVolumeAdaptive.StepUp(targetIdx);%evidence step up
%         
%         %case 1: performance > target performance in +5 
%         if considerPerformance>=targetPerformance+5&&...
%                 StimulusSettings.EmbedSignal==1 %only adapt according to hits/misses
%                 
%             %first try to adapt SNR by increasing noise level
%             StimulusSettings.NoiseVolume=diffNoiseVolume;
%             StimulusSettings.SignalVolume=sameSignalVolume;
%             
%             %if required noise volume is out of bound, decrease signal volume
%             if  diffNoiseVolume>=StimulusSettings.MaxVolume&&...%if noise volume out of bound
%                 diffSignalVolume>=20&&...%if signal volume high enough TODO: outcode min and max volume for signal and noise
%                 TaskParameters.GUI.NoiseVolumeMode==2%if selected this option
%             
%                 StimulusSettings.NoiseVolume=sameNoiseVolume;
%                 StimulusSettings.SignalVolume=diffSignalVolume;
%             end
%             
%         elseif considerPerformance<targetPerformance-5&&...
%                 StimulusSettings.EmbedSignal==1%case 2: 1back error -> evidence step up - decrease noise volume
%             
%             %first try to adapt SNR by decreasing noise level
%             StimulusSettings.NoiseVolume=easyNoiseVolume;
%             StimulusSettings.SignalVolume=sameSignalVolume;
% 
%             %if required noise volume is out of bound, adapt SNR by
%             %increasing signal volume
%             if  easyNoiseVolume<StimulusSettings.MinVolume&&...% if NoiseVolume is further out of bound
%                     easySignalVolume<70&&...%TODO: outcode min and max volume for signal and noise
%                     TaskParameters.GUI.NoiseVolumeMode==2 %only adapt signal volume if selected this option
% 
%                 StimulusSettings.NoiseVolume=sameNoiseVolume;
%                 StimulusSettings.SignalVolume=easySignalVolume;
%             end
%         else %all other cases (<nback correct, missed choice) and no signal trials
%             StimulusSettings.NoiseVolume=sameNoiseVolume;
%             StimulusSettings.SignalVolume=sameSignalVolume;
%         end
%     end    
% %end

%generate stimuli EDIT HERE TO SAVE THEM
NoiseStream = GenerateNoise(StimulusSettings);
SignalStream = GenerateSignal(StimulusSettings).*StimulusSettings.EmbedSignal;

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
BpodSystem.Data.Custom.NoiseVolumePlot(iTrial+1) = StimulusSettings.NoiseVolume*(StimulusSettings.EmbedSignal/.5-1);

