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
if (BpodSystem.Data.Custom.EmbedSignal(iTrial))>0%signal embedded    
    CorrectPort = str2num(ports(1));
    CenterPort = str2num(ports(2));
    ErrorPort = str2num(ports(3));
elseif (BpodSystem.Data.Custom.EmbedSignal(iTrial))==0 %no signal embedded
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
    if ~any(strcmp('Cin_Stim',statesThisTrial))
        BrokeFixation = true;
        EarlyWithdrawal = false;
    elseif any(strcmp('Cin_Stim',statesThisTrial))
        BrokeFixation = false;
        EarlyWithdrawal = true;
    end
    CoutEarly = true;
else
    CoutEarly = false;
    BrokeFixation = false;
    EarlyWithdrawal = false;
end

%compute time animal spent at center port after first entry (nan on trials without center port entry)
if any(strcmp(CenterPortIn,eventsThisTrial)) && any(strcmp(CenterPortOut,eventsThisTrial))
    CinDuration=eval(['BpodSystem.Data.RawEvents.Trial{iTrial}.Events.' CenterPortOut '(1)']) - ...
        eval(['BpodSystem.Data.RawEvents.Trial{iTrial}.Events.' CenterPortIn '(1)']);
    if CinDuration<0 %for case that animal was in center port at trial start and got out before it got in
            CinDuration=eval(['BpodSystem.Data.RawEvents.Trial{iTrial}.Events.' CenterPortOut '(2)']) - ...
        eval(['BpodSystem.Data.RawEvents.Trial{iTrial}.Events.' CenterPortIn '(1)']);
    end
else
    CinDuration=nan;
end

%compute time animal spent at center during prestimulus interval
if any(strcmp('Cin_PreStim',statesThisTrial)) 
    FixDur=BpodSystem.Data.RawEvents.Trial{iTrial}.States.Cin_PreStim(1,2) - BpodSystem.Data.RawEvents.Trial{iTrial}.States.Cin_PreStim(1,1);
else
    FixDur=nan;
end

%compute time animal spent at center during stimulus interval
if any(strcmp('Cin_Stim',statesThisTrial)) 
    ST=BpodSystem.Data.RawEvents.Trial{iTrial}.States.Cin_Stim(1,2) - BpodSystem.Data.RawEvents.Trial{iTrial}.States.Cin_Stim(1,1);
else
    ST=nan;
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
SignalPresent=(BpodSystem.Data.Custom.EmbedSignal(iTrial))>0;
if (ResponseCorrect==1 && SignalPresent) || ...%correct on signal trials -> left port
        (ResponseCorrect==0 && ~SignalPresent) %incorrect on noise trials -> left port
    ResponseLeft = 1;
elseif (ResponseCorrect==1 && ~SignalPresent) || ...%correct on noise trials -> right port
        (ResponseCorrect==0 && SignalPresent) %incorrect on signal trials -> right port
    ResponseLeft = 0;
else
    ResponseLeft = nan;
end

if ~isnan(ResponseLeft)
    ResponsePortNumber=ports(abs(ResponseLeft-1)*2+1);
    if  ~any(strcmp(strcat('Port',ResponsePortNumber,'In'),eventsThisTrial))
        error('No event corresponding to calculated response recorded. Check your code!')
    end
end

%compute time animal needed to give a response (nan if no response is made)
if ~isnan(ResponseLeft)
    ResponseTime = diff(BpodSystem.Data.RawEvents.Trial{iTrial}.States.wait_Lin);
else
    ResponseTime = nan;
end

%determine whether animal withdraw before set confidence waiting time was
%over (correct trials only) ADAPT HERE FOR CATCH TRIALS
if any(strcmp('LinCorrect_PreFb',statesThisTrial))&&~any(strcmp('LinCorrect_Fb',statesThisTrial))
    LoutEarly = true;
else LoutEarly = false;
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
RewardReceivedTotal = RewardReceivedCenter + RewardReceivedCorrect + RewardReceivedError;

%assemble output
BpodSystem.Data.Custom.CoutEarly(iTrial) = CoutEarly;
BpodSystem.Data.Custom.EarlyWithdrawal(iTrial) = EarlyWithdrawal;
BpodSystem.Data.Custom.BrokeFixation(iTrial) = BrokeFixation;
BpodSystem.Data.Custom.CinDuration(iTrial)=CinDuration;
BpodSystem.Data.Custom.FixDur(iTrial)=FixDur;
BpodSystem.Data.Custom.ST(iTrial)=ST;
BpodSystem.Data.Custom.ResponseCorrect(iTrial)=ResponseCorrect;
BpodSystem.Data.Custom.ResponseLeft(iTrial) = ResponseLeft;
BpodSystem.Data.Custom.ResponseTime(iTrial) = ResponseTime;
BpodSystem.Data.Custom.LoutEarly(iTrial) = LoutEarly;
BpodSystem.Data.Custom.WaitingTime(iTrial) = WaitingTime;
BpodSystem.Data.Custom.GracePeriodDuration(iTrial) = GracePeriodDuration;
BpodSystem.Data.Custom.GracePeriodNumber(iTrial) = GracePeriodNumber;
BpodSystem.Data.Custom.RewardReceivedCenter(iTrial) = RewardReceivedCenter;
BpodSystem.Data.Custom.RewardReceivedCorrect(iTrial) = RewardReceivedCorrect;
BpodSystem.Data.Custom.RewardReceivedError(iTrial) = RewardReceivedError;
BpodSystem.Data.Custom.RewardReceivedTotal(iTrial) = RewardReceivedTotal;


%% update times & stimulus
%update stimulus duration 

%put trial-by-trial varying settings into BpodSystem.Data.Custom
switch TaskParameters.GUIMeta.PreStimDurationSelection.String{TaskParameters.GUI.PreStimDurationSelection}
    case 'AutoIncr'
    History = 50; % Rat: History = 50
    Crit = 0.8; % Rat: Crit = 0.8
    ConsiderTrials = max(1,iTrial-History):1:iTrial;
    ConsiderTrials(isnan(BpodSystem.Data.Custom.CinDuration(ConsiderTrials)))=[];%only use trials with central port entry 
    ConsiderPerformance = sum(~BpodSystem.Data.Custom.CoutEarly(ConsiderTrials))/length(ConsiderTrials);
    if  ConsiderPerformance > Crit && ~CoutEarly %if success over all trials AND on last trial: increase
            RampedPreStimDuration = BpodSystem.Data.Custom.PreStimDuration(iTrial) + TaskParameters.GUI.PreStimDurationRampUp;
    elseif ConsiderPerformance < Crit/2 && CoutEarly  %if failure over all trials (<crit/2) AND on last trial: decrease
        RampedPreStimDuration = BpodSystem.Data.Custom.PreStimDuration(iTrial) - TaskParameters.GUI.PreStimDurationRampDown;
    else %if any other case 
        RampedPreStimDuration = BpodSystem.Data.Custom.PreStimDuration(iTrial);
    end
    BpodSystem.Data.Custom.PreStimDuration(iTrial+1) = min([TaskParameters.GUI.PreStimDurationMax,...
    max([TaskParameters.GUI.PreStimDurationMin,RampedPreStimDuration])]);
    case 'TruncExp'
        BpodSystem.Data.Custom.PreStimDuration(iTrial+1) = TruncatedExponential(TaskParameters.GUI.PreStimDurationMin,...
            TaskParameters.GUI.PreStimDurationMax,TaskParameters.GUI.PreStimDurationTau);
    case 'Fix'
        BpodSystem.Data.Custom.PreStimDuration(iTrial+1) = TaskParameters.GUI.PreStimDurationMin;
end
TaskParameters.GUI.PreStimDuration = BpodSystem.Data.Custom.PreStimDuration(iTrial+1);
BpodSystem.Data.Custom.StimDuration(iTrial+1) = TaskParameters.GUI.StimDuration; 


%update confidence waiting time EDIT HERE FOR TRAINING STAGE 4
%feedback delay
switch TaskParameters.GUIMeta.FeedbackDelaySelection.String{TaskParameters.GUI.FeedbackDelaySelection}
    case 'AutoIncr' %increase if correct and reward on last trial 
        if BpodSystem.Data.Custom.ResponseCorrect(iTrial)==1&&BpodSystem.Data.Custom.RewardReceivedCorrect(iTrial)     
           RampedFeedbackDelay= BpodSystem.Data.Custom.FeedbackDelay(iTrial)+TaskParameters.GUI.FeedbackDelayIncr;
        elseif BpodSystem.Data.Custom.ResponseCorrect(iTrial)==1&&~BpodSystem.Data.Custom.RewardReceivedCorrect(iTrial) %decrease if correct and no reward on last trial
            RampedFeedbackDelay=BpodSystem.Data.Custom.FeedbackDelay(iTrial)-TaskParameters.GUI.FeedbackDelayDecr;
        else 
            RampedFeedbackDelay=BpodSystem.Data.Custom.FeedbackDelay(iTrial);
        end
        TaskParameters.GUI.FeedbackDelay = min(TaskParameters.GUI.FeedbackDelayMax,...
                max(TaskParameters.GUI.FeedbackDelayMin,RampedFeedbackDelay));

    case 'TruncExp'
        TaskParameters.GUI.FeedbackDelay = TruncatedExponential(TaskParameters.GUI.FeedbackDelayMin,...
            TaskParameters.GUI.FeedbackDelayMax,TaskParameters.GUI.FeedbackDelayTau);
    case 'Fix'
        %     ATTEMPT TO GRAY OUT FIELDS
        %     if ~strcmp('edit',TaskParameters.GUIMeta.FeedbackDelay.Style)
        %         TaskParameters.GUIMeta.FeedbackDelay.Style = 'edit';
        %     end
        TaskParameters.GUI.FeedbackDelay = TaskParameters.GUI.FeedbackDelayMax;
end
BpodSystem.Data.Custom.FeedbackDelay(iTrial+1) = TaskParameters.GUI.FeedbackDelay;

%update catch trial 
if iTrial > TaskParameters.GUI.StartEasyTrials
    BpodSystem.Data.Custom.CatchTrial(iTrial+1) = rand(1,1) < TaskParameters.GUI.PercentCatch;
else
    BpodSystem.Data.Custom.CatchTrial(iTrial+1) = false;
end


%update afterstimulusinterval
if TaskParameters.GUI.AfterTrialIntervalJitter
    BpodSystem.Data.Custom.AfterTrialInterval(iTrial+1) = TruncatedExponential(0,5*TaskParameters.GUI.AfterTrialInterval,...
    TaskParameters.GUI.AfterTrialInterval);
else
    BpodSystem.Data.Custom.AfterTrialInterval(iTrial+1) = TaskParameters.GUI.AfterTrialInterval;
end

%update stimuli (unless stimulus will be repeated due to active bias correction)
RepeatStimulus=(TaskParameters.GUI.BiasCorrection==1&&BpodSystem.Data.Custom.ResponseCorrect(iTrial)~=1);
if ~RepeatStimulus
    if TaskParameters.GUI.PlayStimulus==1 || TaskParameters.GUI.PlayStimulus == 2
        StimulusSettings.EmbedSignal=0;
        StimulusSettings.SignalDuration=0;%min([0.1 BpodSystem.Data.Custom.StimDuration]);%plays signal of 0.1 s or sample time duration (if shorter)
        StimulusSettings.SignalVolume=0;%in dB
    elseif TaskParameters.GUI.PlayStimulus == 3 %noie plus easy signals
        StimulusSettings.EmbedSignal=(fix(rand*2));
        StimulusSettings.SignalDuration=TaskParameters.GUI.StimDuration;%min([0.1 BpodSystem.Data.Custom.StimDuration(iTrial+1)]);%plays signal of 0.1 s or sample time duration (if shorter)
        StimulusSettings.SignalVolume=StimulusSettings.EmbedSignal*TaskParameters.GUI.MaxSignalVolume;%in dB
    elseif TaskParameters.GUI.PlayStimulus == 4 %noise plus easy and difficult signals
        StimulusSettings.EmbedSignal=(fix(rand*5))/4;%for 5 signal intensities between 0(noise) and 1 (signal)
        StimulusSettings.SignalDuration=TaskParameters.GUI.StimDuration;%min([0.1 BpodSystem.Data.Custom.StimDuration(iTrial+1)]);%plays signal of 0.1 s or sample time duration (if shorter)
        StimulusSettings.SignalVolume=StimulusSettings.EmbedSignal*TaskParameters.GUI.MaxSignalVolume;%UPDATE HERE FOR TRAINING STAGE 3
    end
end
%put trial-by-trial varying settings into BpodSystem.Data.Custom
%%UDPATE HERE IF SYSTEM GETS SLOW (maybe it's too much to save all the
%%stimuli)
[BpodSystem.Data.Custom.Signal{iTrial+1}] = GenerateSignal(StimulusSettings);
BpodSystem.Data.Custom.EmbedSignal(iTrial+1) = StimulusSettings.EmbedSignal;
BpodSystem.Data.Custom.SignalDuration(iTrial+1) = StimulusSettings.SignalDuration;
BpodSystem.Data.Custom.SignalVolume(iTrial+1) = StimulusSettings.SignalVolume;

PsychToolboxSoundServer('Load', 2, BpodSystem.Data.Custom.Signal{iTrial+1});%load signal to slave 2


%reward depletion %UPDATE HERE IF BIAS CORRECTION IS NEEDED
BpodSystem.Data.Custom.RewardAmountCorrect(iTrial+1)=TaskParameters.GUI.RewardAmountCorrect;
BpodSystem.Data.Custom.RewardAmountError(iTrial+1)=TaskParameters.GUI.RewardAmountError;
BpodSystem.Data.Custom.RewardAmountCenter(iTrial+1)=TaskParameters.GUI.RewardAmountCenter;

%light guidance updating (later used to determine whether error port LED will be switched
%off or switched on on next trial
if TaskParameters.GUI.AutoRampLightGuidance && iTrial > 0 %start after 10th trial
    HistoryLight = 50;
    CritLight = 0.9;
    ConsiderTrialsLight = max(1,iTrial-HistoryLight):1:iTrial;
    ConsiderTrialsLight(isnan(BpodSystem.Data.Custom.CinDuration(ConsiderTrialsLight)))=[];%only use trials with central port entry
    ConsiderPerformance = nansum(BpodSystem.Data.Custom.ResponseCorrect(ConsiderTrialsLight))/length(ConsiderTrialsLight);%count missed responses as errors
    
    if  ConsiderPerformance > CritLight && ResponseCorrect == 1%if success over all trials AND on last trial: decrease percentage of light guidance
        BpodSystem.Data.Custom.LightGuidance(iTrial+1) = min([TaskParameters.GUI.MaxLightGuidance,...
            (BpodSystem.Data.Custom.LightGuidance(iTrial) - TaskParameters.GUI.LightGuidanceRampDown)]);
    elseif ConsiderPerformance < CritLight/2 && ResponseCorrect ~= 1  %if failure over all trials (<crit/2) AND on last trial: increase percentage of light guidance
        BpodSystem.Data.Custom.LightGuidance(iTrial+1) = max([TaskParameters.GUI.MinLightGuidance,...
            (BpodSystem.Data.Custom.LightGuidance(iTrial) + TaskParameters.GUI.LightGuidanceRampUp)]);
    else %if any other case do not chance      
        BpodSystem.Data.Custom.LightGuidance(iTrial+1) = min([TaskParameters.GUI.MaxLightGuidance,...
            max([TaskParameters.GUI.MinLightGuidance,BpodSystem.Data.Custom.LightGuidance(iTrial)])]);
    end
else
    BpodSystem.Data.Custom.LightGuidance(iTrial+1) = TaskParameters.GUI.MaxLightGuidance;
end
BpodSystem.Data.Custom.ErrorPortLightIntensity(iTrial+1) = ceil(255* (rand >= BpodSystem.Data.Custom.LightGuidance(iTrial+1)));%set LED intensity to 0 on error port on some trials for training
TaskParameters.GUI.LightGuidance = BpodSystem.Data.Custom.LightGuidance(iTrial+1); % update Light Guidance in GUI

%%send bpod status to server
try
script = 'receivebpodstatus.php';
SendTrialStatusToServer(script,BpodSystem.Data.Custom.Rig,outcome,BpodSystem.Data.Custom.Subject,BpodSystem.CurrentProtocolName);
catch
end

end
