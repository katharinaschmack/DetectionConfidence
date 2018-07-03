function PrepareStimulus(EmbedSignal,iTrial)  

global BpodSystem
global TaskParameters

%invariant Settings
StimulusSettings.SamplingRate=192000;%sampling rate of sound card
StimulusSettings.Ramp=.02;%duration (s) of ramping at on and offset of noise used to avoid clicking sounds
StimulusSettings.NoiseDuration=5;%length of noise stream (s) that will be looped
StimulusSettings.NoiseColor='WhiteGaussian';
StimulusSettings.MaxVolume=80;
StimulusSettings.MinVolume=-20;
StimulusSettings.SignalForm='LinearUpsweep';
StimulusSettings.SignalMinFreq=10E3;
StimulusSettings.SignalMaxFreq=15E3;
%variable settings
StimulusSettings.SignalDuration=TaskParameters.GUI.StimDuration;
StimulusSettings.SignalVolume=TaskParameters.GUI.SignalVolume;
StimulusSettings.EmbedSignal=EmbedSignal;

%% determine noise volume for next trial
% if strcmp(TaskParameters.GUIMeta.NoiseVolumeMode.String{TaskParameters.GUI.NoiseVolumeMode},'Constant')
%   %sample value from NoiseVolumeConstant Table
%     if EmbedSignal
%         values=TaskParameters.GUI.NoiseVolumeConstant.SignalTrials;
%         index=randsample(length(TaskParameters.GUI.NoiseVolumeConstant.SignalTrials),1,true,TaskParameters.GUI.NoiseVolumeConstant.Prob);
%     else
%         values=TaskParameters.GUI.NoiseVolumeConstant.NoiseTrials;
%         index=randsample(length(TaskParameters.GUI.NoiseVolumeConstant.NoiseTrials),1,true,TaskParameters.GUI.NoiseVolumeConstant.Prob);
%     end
%     StimulusSettings.NoiseVolume=values(index);
%     StimulusSettings.SignalVolume=TaskParameters.GUI.SignalVolume;
%     TargetPerformance=nan;
%     
% elseif strcmp(TaskParameters.GUIMeta.NoiseVolumeMode.String{TaskParameters.GUI.NoiseVolumeMode},'Adaptive') 
    %determine according to performance stream (only consider signal trials
    %for this)
    targetIdx=randsample(1:numel(TaskParameters.GUI.NoiseVolumeAdaptive.Target),1);
    TargetPerformance=TaskParameters.GUI.NoiseVolumeAdaptive.Target(targetIdx);
    trialsPerformanceStream=find(BpodSystem.Data.Custom.TargetPerformance==TargetPerformance&...       
        BpodSystem.Data.Custom.EarlyWithdrawal==0&BpodSystem.Data.Custom.EmbedSignal==1);
    
    
    if length(trialsPerformanceStream)<3 %start with easy trials per stream
        StimulusSettings.NoiseVolume=TaskParameters.GUI.NoiseVolumeAdaptive.StartNoiseVolume(targetIdx);
        StimulusSettings.SignalVolume=TaskParameters.GUI.SignalVolume;%NoiseVolumeAdaptive.StartSignalVolume(targetIdx);
            
    else %adapt according to performance in current performance stream (ONLY TRIALS WITHOUT EARLY WITHDRAWAL)
        trialsToConsider=numel(trialsPerformanceStream)-TaskParameters.GUI.NoiseVolumeAdaptive.StaircaseRule(targetIdx)+1;
        trialsIdx=trialsPerformanceStream(trialsToConsider:end);
        %first try to adapt SNR by changing noise level
        if sum(BpodSystem.Data.Custom.ResponseCorrect(trialsIdx))==length(trialsIdx)&&BpodSystem.Data.Custom.EmbedSignal(iTrial)==1 %case 1: nback correct -> evidence step down - increase noise volume or decrease signal volume
            StimulusSettings.NoiseVolume=BpodSystem.Data.Custom.NoiseVolume(trialsIdx(end))+...%last volume
                TaskParameters.GUI.NoiseVolumeAdaptive.StepSize(targetIdx)*TaskParameters.GUI.NoiseVolumeAdaptive.DeltaRatio(targetIdx);%step down
%             if BpodSystem.Data.Custom.NoiseVolume(trialsIdx(end))>StimulusSettings.MaxVolume %decrease signal volume if NoiseVolume is further out of bound
%                 StimulusSettings.SignalVolume=BpodSystem.Data.Custom.SignalVolume(trialsIdx(end))-...%last signal volume
%                 TaskParameters.GUI.NoiseVolumeAdaptive.StepSize(targetIdx)*TaskParameters.GUI.NoiseVolumeAdaptive.DeltaRatio(targetIdx);%step down
%             else
%                 StimulusSettings.SignalVolume=BpodSystem.Data.Custom.SignalVolume(trialsIdx(end));
%             end
        elseif BpodSystem.Data.Custom.ResponseCorrect(trialsIdx(end))==0&&BpodSystem.Data.Custom.EmbedSignal(iTrial)==1%case 2: 1back error -> evidence step up - decrease noise volume
            StimulusSettings.NoiseVolume=BpodSystem.Data.Custom.NoiseVolume(trialsIdx(end))-...%last volume
                TaskParameters.GUI.NoiseVolumeAdaptive.StepSize(targetIdx);%step up
%             if BpodSystem.Data.Custom.NoiseVolume(trialsIdx(end))<StimulusSettings.MinVolume %increase signal volume if NoiseVolume is further out of bound
%                 StimulusSettings.SignalVolume=BpodSystem.Data.Custom.SignalVolume(trialsIdx(end))+...%last signal volume
%                     TaskParameters.GUI.NoiseVolumeAdaptive.StepSize(targetIdx);%step down
%             else
%                 StimulusSettings.SignalVolume=BpodSystem.Data.Custom.SignalVolume(trialsIdx(end));
%             end

        else %all other cases (<nback correct, missed choice) and no signal trials
            StimulusSettings.NoiseVolume=BpodSystem.Data.Custom.NoiseVolume(trialsIdx(end));
        end
    end
    
    
%end

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
BpodSystem.Data.Custom.TargetPerformance(iTrial+1)=TargetPerformance;

