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
if ~isnan(BpodSystem.Data.Custom.SignalEmbedTime(iTrial))%signal embedded    
    CorrectPort = str2num(ports(1));
    CenterPort = str2num(ports(2));
    ErrorPort = str2num(ports(3));
elseif isnan(BpodSystem.Data.Custom.SignalEmbedTime(iTrial))%no signal embedded
    CorrectPort = str2num(ports(3));
    CenterPort = str2num(ports(2));
    ErrorPort = str2num(ports(1));
else error('Cannot determine which port is the Error one. Check your code!')
end

CorrectPortOut = strcat('Port',num2str(CorrectPort),'Out');
CenterPortOut = strcat('Port',num2str(CenterPort),'Out');
ErrorPortOut = strcat('Port',num2str(ErrorPort),'Out');

CorrectPortIn = strcat('Port',num2str(CorrectPort),'In');
CenterPortIn = strcat('Port',num2str(CenterPort),'In');
ErrorPortIn = strcat('Port',num2str(ErrorPort),'In');

CorrectValve = 2^(CorrectPort-1);
CenterValve = 2^(CenterPort-1);
ErrorValve = 2^(ErrorPort-1);

CorrectValveTime  = GetValveTimes(BpodSystem.Data.Custom.RewardAmountCorrect(iTrial), CorrectPort);
CenterValveTime  = GetValveTimes(BpodSystem.Data.Custom.RewardAmountCenter(iTrial), CenterPort);
ErrorValveTime  = GetValveTimes(BpodSystem.Data.Custom.RewardAmountError(iTrial), ErrorPort);

%mark whether animal withdraw too early from center port
if any(strcmp('Cout_Early',statesThisTrial))
    Cout_Early = true;
else Cout_Early = false;
end

%compute time animal spent at center port after first entry (nan on trials without center port entry)
if any(strcmp(CenterPortIn,eventsThisTrial)) && any(strcmp(CenterPortOut,eventsThisTrial))
    Cin_Duration=eval(['BpodSystem.Data.RawEvents.Trial{iTrial}.Events.' CenterPortOut '(1)']) - ...
        eval(['BpodSystem.Data.RawEvents.Trial{iTrial}.Events.' CenterPortIn '(1)']);
else
    Cin_Duration=nan;
end

%mark whether animal gave correct or incorrect or no response (nan)
if any(strcmp('LinCorrect_GraceStart',statesThisTrial))
    ResponseCorrect = 1;
elseif any(strcmp('LinError_GraceStart',statesThisTrial))
    ResponseCorrect = 0;
else
    ResponseCorrect = nan;
end

%mark whether animal went left or right
SignalPresent=~isnan(BpodSystem.Data.Custom.SignalEmbedTime(iTrial));
if (ResponseCorrect==1 && SignalPresent) || ...%correct on signal trials -> left port
        (ResponseCorrect==0 && ~SignalPresent) %incorrect on noise trials -> left port
    ResponseSide = ports(1);
elseif (ResponseCorrect==1 && ~SignalPresent) || ...%correct on noise trials -> right port
        (ResponseCorrect==0 && SignalPresent) %incorrect on signal trials -> right port
    ResponseSide = ports(3);
else
    ResponseSide = nan;
end


if ~isnan(ResponseSide) && ~any(strcmp(strcat('Port',ResponseSide,'In'),eventsThisTrial)) 
   error('No event corresponding to calculated response recorded. Check your code!')
end

%compute time animal needed to give a response (nan if no response is made)
if ~isnan(ResponseSide)
    ResponseTime = diff(BpodSystem.Data.RawEvents.Trial{iTrial}.States.wait_Lin);
else
    ResponseTime = nan;
end

%compute time animal waited after response for a reward (nan if no response is made)
if ResponseCorrect==1
    if any(strcmp('LinCorrect_Fb',statesThisTrial))%correct trials with reward: take beginning Feedback
        WaitingTime = BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinCorrect_Fb(1,1) - ...
            BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinCorrect_GraceStart(1,1);
    elseif ~any(strcmp('LinCorrect_Fb',statesThisTrial)) %correct trials without reward: take end last Grace Period to include all grace periods (like in correct trials with reward)
        WaitingTime = BpodSystem.Data.RawEvents.Trial{iTrial}.States.LoutCorrect_GracePeriod(end,2) - ...
            BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinCorrect_GraceStart(1,1);
    end
    
elseif ResponseCorrect==0
    if any(strcmp('LinError_Fb',statesThisTrial))%error trials with (mock) reward: take beginning Feedback
        WaitingTime = BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinError_Fb(1,1) - ...
            BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinError_GraceStart(1,1);
    elseif ~any(strcmp('LinError_Fb',statesThisTrial)) %error trials without (mock) reward: take end last Grace Period to include all grace periods (like in correct trials with reward)
        WaitingTime = BpodSystem.Data.RawEvents.Trial{iTrial}.States.LoutError_GracePeriod(end,2) - ...
            BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinError_GraceStart(1,1);
    end
    
else
    WaitingTime = nan;
end
    
%compute time animal spent in grace period during waiting time
if ResponseCorrect==1
    if any(strcmp('LoutCorrect_GracePeriod',statesThisTrial))
        GracePeriodDuration = sum(BpodSystem.Data.RawEvents.Trial{iTrial}.States.LoutCorrect_GracePeriod(:,2) - ...
            BpodSystem.Data.RawEvents.Trial{iTrial}.States.LoutCorrect_GracePeriod(:,1));
        GracePeriodNumber = size(BpodSystem.Data.RawEvents.Trial{iTrial}.States.LoutCorrect_GracePeriod,1);
    else
        GracePeriodDuration = 0;
        GracePeriodNumber = 0;
    end
elseif ResponseCorrect==0
    if any(strcmp('LoutError_GracePeriod',statesThisTrial))
        GracePeriodDuration = sum(BpodSystem.Data.RawEvents.Trial{iTrial}.States.LoutError_GracePeriod(:,2) - ...
            BpodSystem.Data.RawEvents.Trial{iTrial}.States.LoutError_GracePeriod(:,1));
        GracePeriodNumber = size(BpodSystem.Data.RawEvents.Trial{iTrial}.States.LoutError_GracePeriod,1);
    else
        GracePeriodDuration = 0;
        GracePeriodNumber = 0;
    end
else
    GracePeriodDuration = nan;
    GracePeriodNumber = nan;
end

%compute rewards the animal got in this trial
if any(strcmp('Cin_Reward',statesThisTrial))
   RewardDuration = diff(BpodSystem.Data.RawEvents.Trial{iTrial}.States.Cin_Reward(1,:));%
   RewardReceivedCenter = (RewardDuration/CenterValveTime) * BpodSystem.Data.Custom.RewardAmountCenter(iTrial);
else 
    RewardReceivedCenter=0;
end
if any(strcmp('LinCorrect_Fb',statesThisTrial))
   RewardDuration = diff(BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinCorrect_Fb(1,:));%
   RewardReceivedCorrect = (RewardDuration/CorrectValveTime) * BpodSystem.Data.Custom.RewardAmountCorrect(iTrial);
else
    RewardReceivedCorrect = 0;
end
if any(strcmp('LinError_Fb',statesThisTrial))
   RewardDuration = diff(BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinError_Fb(1,:));%
   RewardReceivedError = (RewardDuration/ErrorValveTime) * BpodSystem.Data.Custom.RewardAmountError(iTrial);
else
    RewardReceivedError = 0;
end

%assemble output
BpodSystem.Data.Custom.Cout_Early(iTrial) = Cout_Early;
BpodSystem.Data.Custom.Cin_Duration(iTrial)=Cin_Duration;
BpodSystem.Data.Custom.ResponseCorrect(iTrial)=ResponseCorrect;
BpodSystem.Data.Custom.ResponseSide(iTrial) = ResponseSide;
BpodSystem.Data.Custom.ResponseTime(iTrial) = ResponseTime;
BpodSystem.Data.Custom.WaitingTime(iTrial) = WaitingTime;
BpodSystem.Data.Custom.GracePeriodDuration(iTrial) = GracePeriodDuration;
BpodSystem.Data.Custom.GracePeriodNumber(iTrial) = GracePeriodNumber;
BpodSystem.Data.Custom.RewardReceivedCenter(iTrial) = RewardReceivedCenter;
BpodSystem.Data.Custom.RewardReceivedCorrect(iTrial) = RewardReceivedCorrect;
BpodSystem.Data.Custom.RewardReceivedError(iTrial) = RewardReceivedError;


%% update times & stimulus
%update stimulus duration     
if TaskParameters.GUI.AutoRampStimDuration
    History = 50; % Rat: History = 50
    Crit = 0.8; % Rat: Crit = 0.8
    ConsiderTrials = max(1,iTrial-History):1:iTrial;
    ConsiderTrials(isnan(BpodSystem.Data.Custom.Cin_Duration(ConsiderTrials)))=[];%only use trials with central port entry 
    ConsiderPerformance = sum(~BpodSystem.Data.Custom.Cout_Early(ConsiderTrials))/length(ConsiderTrials);
    if  ConsiderPerformance > Crit && ~Cout_Early %if success over all trials AND on last trial: increase
            BpodSystem.Data.Custom.StimDuration(iTrial+1) = BpodSystem.Data.Custom.StimDuration(iTrial) + TaskParameters.GUI.StimDurationRampUp; % StimDuration increased
    elseif ConsiderPerformance < Crit/2 && Cout_Early  %if failure over all trials (<crit/2) AND on last trial: decrease
            BpodSystem.Data.Custom.StimDuration(iTrial+1) = BpodSystem.Data.Custom.StimDuration(iTrial) - TaskParameters.GUI.StimDurationRampDown; % StimDuration increased
    else %if any other case 
        BpodSystem.Data.Custom.StimDuration(iTrial+1) = BpodSystem.Data.Custom.StimDuration(iTrial); 
    end
    %clip to max and min StimDuration
    BpodSystem.Data.Custom.StimDuration(BpodSystem.Data.Custom.StimDuration>TaskParameters.GUI.MaxStimDuration)=TaskParameters.GUI.MaxStimDuration;
    BpodSystem.Data.Custom.StimDuration(BpodSystem.Data.Custom.StimDuration<TaskParameters.GUI.MinStimDuration)=TaskParameters.GUI.MinStimDuration;
end
TaskParameters.GUI.StimDuration = BpodSystem.Data.Custom.StimDuration(iTrial+1); % update StimDuration in GUI

%update confidence waiting time EDIT HERE FOR TRAINING STAGE 4
BpodSystem.Data.Custom.ConfidenceWaitingTime(iTrial+1) = BpodSystem.Data.Custom.ConfidenceWaitingTime(iTrial); 
TaskParameters.GUI.ConfidenceWaitingTime = BpodSystem.Data.Custom.ConfidenceWaitingTime(iTrial+1); % update Confidence Waiting Time in GUI

%update afterstimulusinterval
if TaskParameters.GUI.AfterTrialIntervalJitter
    BpodSystem.Data.Custom.AfterTrialInterval(iTrial+1) = min( [ exprnd(TaskParameters.GUI.AfterTrialInterval) 5*TaskParameters.GUI.AfterTrialInterval ]);
else
    BpodSystem.Data.Custom.AfterTrialInterval(iTrial+1) = TaskParameters.GUI.AfterTrialInterval;
end

%update stimuli
if TaskParameters.GUI.PlayStimulus>1
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
        StimulusSettings.SignalVolume=StimulusSettings.EmbedSignal*40;%UPDATE HERE FOR TRAINING STAGE 3
    end

    %put trial-by-trial varying settings into BpodSystem.Data.Custom
    %%UDPATE HERE IF SYSTEM GETS SLOW (maybe it's too much to save all the
    %%stimuli)
    [BpodSystem.Data.Custom.Stimulus{iTrial+1} BpodSystem.Data.Custom.SignalEmbedTime(iTrial+1)] = GenerateSignalInNoiseStimulus(StimulusSettings);
    BpodSystem.Data.Custom.EmbedSignal(iTrial+1) = StimulusSettings.EmbedSignal;
    BpodSystem.Data.Custom.SignalDuration(iTrial+1) = StimulusSettings.SignalDuration;
    BpodSystem.Data.Custom.SignalVolume(iTrial+1) = StimulusSettings.SignalVolume;

    %prepare Psychotoolbox if necessary
    % if ~BpodSystem.EmulatorMode && ~BpodSystem.Data.Custom.PsychtoolboxStartup
    if  ~BpodSystem.Data.Custom.PsychtoolboxStartup
        PsychToolboxSoundServer('init');
        BpodSystem.Data.Custom.PsychtoolboxStartup=true;
    end
    PsychToolboxSoundServer('Load', 1, BpodSystem.Data.Custom.Stimulus{iTrial+1});%load noise to slave 1
end

%reward depletion
BpodSystem.Data.Custom.RewardAmountCorrect(iTrial+1)=BpodSystem.Data.Custom.RewardAmountCorrect(iTrial);
BpodSystem.Data.Custom.RewardAmountError(iTrial+1)=BpodSystem.Data.Custom.RewardAmountError(iTrial);
BpodSystem.Data.Custom.RewardAmountCenter(iTrial+1)=BpodSystem.Data.Custom.RewardAmountCenter(iTrial);

%%send bpod status to server
try
script = 'receivebpodstatus.php';
SendTrialStatusToServer(script,BpodSystem.Data.Custom.Rig,outcome,BpodSystem.Data.Custom.Subject,BpodSystem.CurrentProtocolName);
catch
end

end
