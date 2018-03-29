function updateCustomDataFields(iTrial)
global BpodSystem
global TaskParameters
global StimulusSettings

%% OutcomeRecord
%get states & events of this trial
statesThisTrial = BpodSystem.Data.RawData.OriginalStateNamesByNumber{iTrial}(BpodSystem.Data.RawData.OriginalStateData{iTrial});
if isfield(BpodSystem.Data.RawEvents.Trial{iTrial},'Events') %not sure why this is necessary: why can there be trials without events if CenterPortIn is always necessary to proceed?
    eventsThisTrial = fieldnames(BpodSystem.Data.RawEvents.Trial{iTrial}.Events)';
else eventsThisTrial = {};
end

%get port IDs
ports=num2str(TaskParameters.GUI.Ports_LMR);

%mark whether animal withdraw too early from center port
if any(strcmp('Cout_Early',statesThisTrial))
    Cout_Early = true;
else Cout_Early = false;
end

%compute time animal spent at center port after first entry (nan on trials without center port entry)
CenterPort = ports(2);
CenterPortIn = strcat('Port',CenterPort,'In');
CenterPortOut = strcat('Port',CenterPort,'Out');

if any(strcmp(CenterPortIn,eventsThisTrial)) && any(strcmp(CenterPortOut,eventsThisTrial))
    Cin_Duration=eval(['BpodSystem.Data.RawEvents.Trial{iTrial}.Events.' CenterPortOut]) - ...
        eval(['BpodSystem.Data.RawEvents.Trial{iTrial}.Events.' CenterPortIn '(1)']);
else
    Cin_Duration=nan;
end

%mark whether animal gave correct or incorrect or no response (nan)
if any(strcmp('LinCorrect_GraceStart',statesThisTrial))
    ResponseCorrect = 1;
elseif any(strcmp('LinError_GraceStart',statesThisTrial))
    ResponseCorrect = 0;
else ResponseCorrect = nan;
end

%mark whether animal went left or right
SignalPresent=~isnan(BpodSystem.Data.Custom.SignalEmbedTime(iTrial));
if (ResponseCorrect==1 && SignalPresent) || ...%correct on signal trials -> left port
        (ResponseCorrect==0 && ~SignalPresent) %incorrect on noise trials -> left port
    ResponseSide = ports(1);
elseif (ResponseCorrect==1 && ~SignalPresent) || ...%correct on noise trials -> right port
        (ResponseCorrect==0 && SignalPresent) %incorrect on signal trials -> right port
    ResponseSide = ports(3);
else     ResponseSide = nan;
end


if ~isnan(ResponseSide) && ~any(strcmp(strcat('Port',ResponseSide,'In'),eventsThisTrial)) 
   error('No event corresponding to calculated response recorded. Check your code!')
end

%compute time animal needed to give a response (nan if no response is made)
if ~isnan(ResponseSide)
    ResponseTime = diff(BpodSystem.Data.RawEvents.Trial{iTrial}.States.wait_Lin);
else ResponseTime = nan;
end

%compute time animal waited after response for a reward (nan if no response is made)
if ResponseCorrect==1
    if any(strcmp('LinCorrect_Fb',statesThisTrial))%correct trials with reward: take beginning Feedback
        WaitingTime = BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinCorrect_Fb(1,1) - ...
            BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinCorrect_GraceStart(1,1);
    elseif ~any(strcmp('LinCorrect_Fb',statesThisTrial)) %correct trials without reward: take end last Grace Period to include all grace periods (like in correct trials with reward)
        WaitingTime = BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinCorrect_GracePeriod(end,2) - ...
            BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinCorrect_GraceStart(1,1);
    end
    
elseif ResponseCorrect==0
    if any(strcmp('LinError_Fb',statesThisTrial))%error trials with (mock) reward: take beginning Feedback
        WaitingTime = BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinError_Fb(1,1) - ...
            BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinError_GraceStart(1,1);
    elseif ~any(strcmp('LinError_Fb',statesThisTrial)) %error trials without (mock) reward: take end last Grace Period to include all grace periods (like in correct trials with reward)
        WaitingTime = BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinError_GracePeriod(end,2) - ...
            BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinError_GraceStart(1,1);
    end
    
else
    WaitingTime = nan;
end
    
%compute time animal spent in grace period during waiting time
if ResponseCorrect==1
    if any(strcmp('LinCorrect_GracePeriod',statesThisTrial))
        GracePeriodDuration = sum(BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinCorrect_GracePeriod(:,2) - ...
            BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinCorrect_GracePeriod(:,1));
        GracePeriodNumber = size(BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinCorrect_GracePeriod,1);
    else
        GracePeriodDuration = 0;
        GracePeriodNumber = 0;
    end
elseif ResponseCorrect==0
    if any(strcmp('LinError_GracePeriod',statesThisTrial))
        GracePeriodDuration = sum(BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinError_GracePeriod(:,2) - ...
            BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinError_GracePeriod(:,1));
        GracePeriodNumber = size(BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinError_GracePeriod,1);
    else
        GracePeriodDuration = 0;
        GracePeriodNumber = 0;
    end
else GracePeriodDuration = nan;
    GracePeriodNumber = nan;
end

%compute rewards the animal got in this trial
if any(strcmp('Cin_Reward',statesThisTrial))
   RewardReceivedCenter=1:%IWAS HERE 
end
    %% assemble
BpodSystem.Data.Custom.Cout_Early(iTrial) = Cout_Early;
BpodSystem.Data.Custom.Cin_Duration(iTrial)=Cin_Duration;
BpodSystem.Data.Custom.ResponseCorrect(iTrial)=ResponseCorrect;
BpodSystem.Data.Custom.ResponseSide(iTrial) = ResponseSide;
BpodSystem.Data.Custom.ResponseTime(iTrial) = ResponseTime;
BpodSystem.Data.Custom.WaitingTime(iTrial) = WaitingTime;
BpodSystem.Data.Custom.GracePeriodDuration(iTrial) = GracePeriodDuration;
BpodSystem.Data.Custom.GracePeriodNumber(iTrial) = GracePeriodNumber;



% Compute grace period:
if any(strcmp('GracePeriod',statesThisTrial))
    for nb_graceperiod =  1: size(BpodSystem.Data.RawEvents.Trial{iTrial}.States.GracePeriod,1)
        BpodSystem.Data.Custom.GracePeriod(nb_graceperiod,iTrial) = (BpodSystem.Data.RawEvents.Trial{iTrial}.States.GracePeriod(nb_graceperiod,2)...
            -BpodSystem.Data.RawEvents.Trial{iTrial}.States.GracePeriod(nb_graceperiod,1));
    end
end  

if any(strncmp('water_L',statesThisTrial,7))
    BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 1;
    BpodSystem.Data.Custom.Rewarded(iTrial) = true;
    BpodSystem.Data.Custom.MT(iTrial) = BpodSystem.Data.RawEvents.Trial{iTrial}.States.water_L(1,2) - BpodSystem.Data.RawEvents.Trial{iTrial}.States.wait_Sin(1,1);
elseif any(strncmp('water_R',statesThisTrial,7))
    BpodSystem.Data.Custom.ChoiceLeft(iTrial) = 0;
    BpodSystem.Data.Custom.Rewarded(iTrial) = true;
    BpodSystem.Data.Custom.MT(iTrial) = BpodSystem.Data.RawEvents.Trial{iTrial}.States.water_R(1,2) - BpodSystem.Data.RawEvents.Trial{iTrial}.States.wait_Sin(1,1);
elseif any(strcmp('EarlyWithdrawal',statesThisTrial))
    BpodSystem.Data.Custom.EarlyWithdrawal(iTrial) = true;
end
if any(strcmp('water_LJackpot',statesThisTrial)) || any(strcmp('water_RJackpot',statesThisTrial))
    BpodSystem.Data.Custom.Jackpot(iTrial) = true;
    BpodSystem.Data.Custom.Rewarded(iTrial) = true;
    if any(strcmp('water_LJackpot',statesThisTrial))
        BpodSystem.Data.Custom.MT(iTrial) = BpodSystem.Data.RawEvents.Trial{iTrial}.States.water_LJackpot(1,2) - BpodSystem.Data.RawEvents.Trial{iTrial}.States.wait_SinJackpot(1,1);
    elseif any(strcmp('water_LJackpot',statesThisTrial))
        BpodSystem.Data.Custom.MT(iTrial) = BpodSystem.Data.RawEvents.Trial{iTrial}.States.water_RJackpot(1,2) - BpodSystem.Data.RawEvents.Trial{iTrial}.States.wait_SinJackpot(1,1);
    end
end

if any(strcmp('lat_Go_signal',statesThisTrial))
    BpodSystem.Data.Custom.CenterPortRewarded(iTrial) = true;
end
%% initialize next trial values
BpodSystem.Data.Custom.ChoiceLeft(iTrial+1) = NaN;
BpodSystem.Data.Custom.EarlyWithdrawal(iTrial+1) = false;
BpodSystem.Data.Custom.Jackpot(iTrial+1) = false;
BpodSystem.Data.Custom.ST(iTrial+1) = NaN;
BpodSystem.Data.Custom.MT(iTrial+1) = NaN;
BpodSystem.Data.Custom.Rewarded(iTrial+1) = false;
BpodSystem.Data.Custom.CenterPortRewarded(iTrial+1) = false;
BpodSystem.Data.Custom.GracePeriod(1:50,iTrial+1) = NaN(50,1);

%update confidence waiting time
BpodSystem.Data.Custom.StimDuration(iTrial+1) = BpodSystem.Data.Custom.StimDuration(iTrial);
TaskParameters.GUI.StimDuration = BpodSystem.Data.Custom.StimDuration(iTrial+1); % update StimDuration
BpodSystem.Data.Custom.ConfidenceWaitingTime(iTrial+1) = BpodSystem.Data.Custom.ConfidenceWaitingTime(iTrial); 


%stimuli
%TO UPDATE 
if TaskParameters.GUI.PlayStimulus == 1
    StimulusSettings.EmbedSignal=0;
    StimulusSettings.NoiseDuration=0;
elseif TaskParameters.GUI.PlayStimulus == 2 
    StimulusSettings.EmbedSignal=0;%if 0 only noise will be played
    StimulusSettings.NoiseDuration=BpodSystem.Data.Custom.StimDuration(iTrial+1);
elseif TaskParameters.GUI.PlayStimulus == 3
    StimulusSettings.EmbedSignal=(fix(rand*2));
    StimulusSettings.NoiseDuration=BpodSystem.Data.Custom.StimDuration(iTrial+1);
elseif TaskParameters.GUI.PlayStimulus == 4 
     StimulusSettings.EmbedSignal=(fix(rand*5))/4;%for 5 signal intensities
     StimulusSettings.NoiseDuration=BpodSystem.Data.Custom.StimDuration(iTrial+1);
end
StimulusSettings.SignalVolume=40;%in dB %ADAPT HERE FOR PRIOR PERFORMANCE
StimulusSettings.SignalDuration=min([0.1 StimulusSettings.NoiseDuration]);%plays signal of 0.1 s or sample time duration (if shorter)
StimulusSettings.SignalLatency=(StimulusSettings.NoiseDuration-StimulusSettings.SignalDuration)./2;%mean of exponential distribution from which latency is drawn (exponential to keep the hazard ratio flat)

%save parameters of interest
[BpodSystem.Data.Custom.Stimulus BpodSystem.Data.Custom.SignalEmbedTime(iTrial+1)] = GenerateSignalInNoiseStimulus(StimulusSettings);
BpodSystem.Data.Costum.SignalVolume(iTrial+1) = StimulusSettings.SignalVolume;
BpodSystem.Data.Costum.SignalDuration(iTrial+1) = StimulusSettings.SignalDuration;
BpodSystem.Data.Costum.SignalDifficulty(iTrial+1) = StimulusSettings.EmbedSignal;

%load new stimulus
if  ~BpodSystem.Data.Custom.PsychtoolboxStartup
    PsychToolboxSoundServer('init');
    BpodSystem.Data.Custom.PsychtoolboxStartup=true;
end
PsychToolboxSoundServer('Load', 1, BpodSystem.Data.Custom.Stimulus);%load noise to slave 1



%jackpot time
% if  TaskParameters.GUI.Jackpot ==2 || TaskParameters.GUI.Jackpot ==3
%     if sum(~isnan(BpodSystem.Data.Custom.ChoiceLeft(1:iTrial)))>10
%         TaskParameters.GUI.JackpotTime = max(TaskParameters.GUI.JackpotMin,quantile(BpodSystem.Data.Custom.ST,0.95));
%     else
%         TaskParameters.GUI.JackpotTime = TaskParameters.GUI.JackpotMin;
%     end
% end

% %reward depletion
BpodSystem.Data.Custom.RewardAmountCorrect(iTrial+1)=BpodSystem.Data.Custom.RewardAmountCorrect(iTrial);
BpodSystem.Data.Custom.RewardAmountError(iTrial+1)=BpodSystem.Data.Custom.RewardAmountError(iTrial);
BpodSystem.Data.Custom.RewardAmountCenter(iTrial+1)=BpodSystem.Data.Custom.RewardAmountCenter(iTrial);
% if BpodSystem.Data.Custom.ChoiceLeft(iTrial) == 1 && TaskParameters.GUI.Deplete
%     BpodSystem.Data.Custom.RewardMagnitude(iTrial+1,1) = BpodSystem.Data.Custom.RewardMagnitude(iTrial,1)*TaskParameters.GUI.DepleteRate;
%     BpodSystem.Data.Custom.RewardMagnitude(iTrial+1,2) = TaskParameters.GUI.rewardAmount;
% elseif BpodSystem.Data.Custom.ChoiceLeft(iTrial) == 0 && TaskParameters.GUI.Deplete
%     BpodSystem.Data.Custom.RewardMagnitude(iTrial+1,2) = BpodSystem.Data.Custom.RewardMagnitude(iTrial,2)*TaskParameters.GUI.DepleteRate;
%     BpodSystem.Data.Custom.RewardMagnitude(iTrial+1,1) = TaskParameters.GUI.rewardAmount;
% elseif isnan(BpodSystem.Data.Custom.ChoiceLeft(iTrial)) && TaskParameters.GUI.Deplete
%     BpodSystem.Data.Custom.RewardMagnitude(iTrial+1,:) = BpodSystem.Data.Custom.RewardMagnitude(iTrial,:);
% else
%     BpodSystem.Data.Custom.RewardMagnitude(iTrial+1,:) = [TaskParameters.GUI.rewardAmount,TaskParameters.GUI.rewardAmount];
% end

%increase sample time
% if TaskParameters.GUI.AutoIncrSample
%     History = 50; % Rat: History = 50
%     Crit = 0.8; % Rat: Crit = 0.8
%     if iTrial<5
%         ConsiderTrials = iTrial;
%     else
%         ConsiderTrials = max(1,iTrial-History):1:iTrial;
%     end
%     ConsiderTrials = ConsiderTrials(~isnan(BpodSystem.Data.Custom.ChoiceLeft(ConsiderTrials))|BpodSystem.Data.Custom.EarlyWithdrawal(ConsiderTrials));
%     if sum(~BpodSystem.Data.Custom.EarlyWithdrawal(ConsiderTrials))/length(ConsiderTrials) > Crit % If SuccessRate > crit (80%)
%         if ~BpodSystem.Data.Custom.EarlyWithdrawal(iTrial) % If last trial is not EWD
%             BpodSystem.Data.Custom.StimDuration(iTrial+1) = min(TaskParameters.GUI.MaxSampleTime,max(TaskParameters.GUI.MinSampleTime,BpodSystem.Data.Custom.StimDuration(iTrial) + TaskParameters.GUI.MinSampleIncr)); % StimDuration increased
%         else % If last trial = EWD
%             BpodSystem.Data.Custom.StimDuration(iTrial+1) = min(TaskParameters.GUI.MaxSampleTime,max(TaskParameters.GUI.MinSampleTime,BpodSystem.Data.Custom.StimDuration(iTrial))); % StimDuration = max(MinSampleTime or StimDuration)
%         end
%     elseif sum(~BpodSystem.Data.Custom.EarlyWithdrawal(ConsiderTrials))/length(ConsiderTrials) < Crit/2  % If SuccessRate < crit/2 (40%)
%         if BpodSystem.Data.Custom.EarlyWithdrawal(iTrial) % If last trial = EWD
%             BpodSystem.Data.Custom.StimDuration(iTrial+1) = max(TaskParameters.GUI.MinSampleTime,min(TaskParameters.GUI.MaxSampleTime,BpodSystem.Data.Custom.StimDuration(iTrial) - TaskParameters.GUI.MinSampleDecr)); % StimDuration decreased
%         else
%             BpodSystem.Data.Custom.StimDuration(iTrial+1) = min(TaskParameters.GUI.MaxSampleTime,max(TaskParameters.GUI.MinSampleTime,BpodSystem.Data.Custom.StimDuration(iTrial))); % StimDuration = max(MinSampleTime or StimDuration)
%         end
%     else % If crit/2 < SuccessRate < crit
%         BpodSystem.Data.Custom.StimDuration(iTrial+1) =  BpodSystem.Data.Custom.StimDuration(iTrial); % StimDuration unchanged
%     end
% else
%     BpodSystem.Data.Custom.StimDuration(iTrial+1) = TaskParameters.GUI.MinSampleTime;
% end
% if BpodSystem.Data.Custom.Jackpot(iTrial) % If last trial is Jackpottrial
%     BpodSystem.Data.Custom.StimDuration(iTrial+1) = BpodSystem.Data.Custom.StimDuration(iTrial+1)+0.05*TaskParameters.GUI.JackpotTime; % StimDuration = StimDuration + 5% JackpotTime
% end

%send bpod status to server
try
script = 'receivebpodstatus.php';
%create a common "outcome" vector
outcome = BpodSystem.Data.Custom.ChoiceLeft(1:iTrial); %1=left, 0=right
outcome(BpodSystem.Data.Custom.EarlyWithdrawal(1:iTrial))=3; %early withdrawal=3
outcome(BpodSystem.Data.Custom.Jackpot(1:iTrial))=4;%jackpot=4
SendTrialStatusToServer(script,BpodSystem.Data.Custom.Rig,outcome,BpodSystem.Data.Custom.Subject,BpodSystem.CurrentProtocolName);
catch
end

end
function [RightClickTrain,LeftClickTrain]=getClickStimulus(time)
rr = rand(1,1)*0.6+0.2;
l = ceil(rr*100);
r=100-l;
RightClickTrain=GeneratePoissonClickTrain(r,time);
LeftClickTrain=GeneratePoissonClickTrain(l,time);
end

