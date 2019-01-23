function updateCustomDataFields(iTrial)
global BpodSystem
global TaskParameters
%% OutcomeRecord (if not before first trial)
if iTrial>0
    

    %get states & events of this trial
    statesThisTrial = BpodSystem.Data.RawData.OriginalStateNamesByNumber{iTrial}(BpodSystem.Data.RawData.OriginalStateData{iTrial});
    if isfield(BpodSystem.Data.RawEvents.Trial{iTrial},'Events') %not sure why this is necessary: why can there be trials without events if CenterPortIn is always necessary to proceed?
        eventsThisTrial = fieldnames(BpodSystem.Data.RawEvents.Trial{iTrial}.Events)';
        
        
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
        %     if TaskParameters.GUI.AllowBreakFixation==0&&any(strcmp('Cout_Early',statesThisTrial))
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
            EarlyWithdrawal = false;
            BrokeFixation = false;
        end
        
        %compute time animal spent at center port after first entry (nan on trials without center port entry)
        if any(strcmp(CenterPortIn,eventsThisTrial)) && any(strcmp(CenterPortOut,eventsThisTrial))
            CinDuration=eval(['BpodSystem.Data.RawEvents.Trial{iTrial}.Events.' CenterPortOut '(1)']) - ...
                eval(['BpodSystem.Data.RawEvents.Trial{iTrial}.Events.' CenterPortIn '(1)']);
            if CinDuration<0 %for case that animal was in center port at trial start cc
                cin=eval(['BpodSystem.Data.RawEvents.Trial{iTrial}.Events.' CenterPortIn]);
                cout=eval(['BpodSystem.Data.RawEvents.Trial{iTrial}.Events.' CenterPortOut ]);
                if length(cout)>1 %and got out, in and out again
                    CinDuration=cout(2)-cin(1);
                else %and got out, in and stayed until choice deadline over
                    CinDuration=BpodSystem.Data.RawEvents.Trial{iTrial}.States.EndOfTrial(2) - cin(1);
                end
                
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
        
        %mark whether animal gave correct or incorrect response on valid and invalid
        %trials
        if any(strcmp(CenterPortIn,eventsThisTrial))
            firstCenterPortIn=min(eval(['BpodSystem.Data.RawEvents.Trial{iTrial}.Events.' CenterPortIn]));%to consider trials where animal was in cneter at trialstart\
        else
            firstCenterPortIn=nan;
        end
        
        if any(strcmp(CenterPortOut,eventsThisTrial))
            allCenterPortOut=(eval(['BpodSystem.Data.RawEvents.Trial{iTrial}.Events.' CenterPortOut ]));%get all withdrawals from center port
            orderIdx=((allCenterPortOut-firstCenterPortIn)>0);%discard withdrawals if animal was at center at trial start
            firstCenterPortOut=min(allCenterPortOut(orderIdx));%take first withdrawal from center port as a reference point
        else
            firstCenterPortOut=nan;
        end
        if any(strcmp(CorrectPortIn,eventsThisTrial))
            correctPortInTime=eval(['BpodSystem.Data.RawEvents.Trial{iTrial}.Events.' CorrectPortIn ]);
            orderIdx=(correctPortInTime-firstCenterPortOut)>0;
            correctPortInTime=min(correctPortInTime(orderIdx));%select first correct Port Entry after first Center Port OUt
            if isempty(correctPortInTime); correctPortInTime=Inf; end
        else
            correctPortInTime=Inf;
        end
        if any(strcmp(ErrorPortIn,eventsThisTrial))
            errorPortInTime=eval(['BpodSystem.Data.RawEvents.Trial{iTrial}.Events.' ErrorPortIn ]);
            orderIdx=(errorPortInTime-firstCenterPortOut)>0;
            errorPortInTime=min(errorPortInTime(orderIdx));%select first Error Port Entry after first Center Port OUt
            if isempty(errorPortInTime); errorPortInTime=Inf; end
        else
            errorPortInTime=Inf;
        end
        
        if correctPortInTime<errorPortInTime%find correct Port In after first Center Port Out but before errorPortIn
            InvalidResponseCorrect=1;
        elseif errorPortInTime<correctPortInTime
            InvalidResponseCorrect=0;
        else
            InvalidResponseCorrect=nan;
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
        
        if (InvalidResponseCorrect==1 && SignalPresent) || ...%correct on signal trials -> left port
                (InvalidResponseCorrect==0 && ~SignalPresent) %incorrect on noise trials -> left port
            InvalidResponseLeft = 1;
        elseif (InvalidResponseCorrect==1 && ~SignalPresent) || ...%correct on noise trials -> right port
                (InvalidResponseCorrect==0 && SignalPresent) %incorrect on signal trials -> right port
            InvalidResponseLeft = 0;
        else
            InvalidResponseLeft = nan;
        end
        
        
        if ~isnan(ResponseLeft)
            ResponsePortNumber=ports(abs(ResponseLeft-1)*2+1);
            if  ~any(strcmp(strcat('Port',ResponsePortNumber,'In'),eventsThisTrial))
                error('No event corresponding to calculated response recorded. Check your code!')
            end
        end
        
        %compute time animal needed to give a response (nan if a valid or no response is made)
        if InvalidResponseCorrect==1
            InvalidResponseTime=correctPortInTime-firstCenterPortOut;
        elseif InvalidResponseCorrect==0
            InvalidResponseTime=errorPortInTime-firstCenterPortOut;
        else
            InvalidResponseTime = nan;
        end
        
        %compute time animal needed to give a response (nan if no response is made)
        if ResponseCorrect==1
            rt=eval(['BpodSystem.Data.RawEvents.Trial{iTrial}.Events.' CorrectPortIn]);
            ResponseTime=rt-BpodSystem.Data.RawEvents.Trial{iTrial}.States.Cin_Stim(1);
            ResponseTime=min(ResponseTime(ResponseTime>0));%to not count lateral port entries prior to stimulus start and after first entry
            
        elseif ResponseCorrect==0
            rt=eval(['BpodSystem.Data.RawEvents.Trial{iTrial}.Events.' ErrorPortIn]);
            ResponseTime=rt-BpodSystem.Data.RawEvents.Trial{iTrial}.States.Cin_Stim(1);
            ResponseTime=min(ResponseTime(ResponseTime>0));%to not count lateral port entries prior to stimulus start and after first entry
            
        else
            ResponseTime = nan;
        end
        
        
        %determine whether animal withdraw before set confidence waiting time was
        %over (correct trials only) ADAPT HERE FOR CATCH TRIALS
        if any(strcmp('LinCorrect_PreFb',statesThisTrial))&&~any(strcmp('LinCorrect_Fb',statesThisTrial))
            LoutEarly = true;
        else
            LoutEarly = false;
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
            RewardReceivedCenter = nanmax((RewardDuration/CenterValveTime) * BpodSystem.Data.Custom.RewardAmountCenter(iTrial),0);
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
            RewardReceivedError = nanmax((RewardDuration/ErrorValveTime) * BpodSystem.Data.Custom.RewardAmountError(iTrial),0);
        else
            RewardReceivedError = 0;
        end
        RewardReceivedTotal = RewardReceivedCenter + RewardReceivedCorrect + RewardReceivedError;
        
        %assemble output
        BpodSystem.Data.Custom.BeforeTrialInterval(iTrial) = BpodSystem.Data.Custom.AfterTrialInterval(iTrial);
        
        BpodSystem.Data.Custom.CoutEarly(iTrial) = CoutEarly;
        BpodSystem.Data.Custom.EarlyWithdrawal(iTrial) = EarlyWithdrawal;
        BpodSystem.Data.Custom.BrokeFixation(iTrial) = BrokeFixation;
        BpodSystem.Data.Custom.CinDuration(iTrial)=CinDuration;
        BpodSystem.Data.Custom.FixDur(iTrial)=FixDur;
        BpodSystem.Data.Custom.ST(iTrial)=ST;
        BpodSystem.Data.Custom.ResponseCorrect(iTrial)=ResponseCorrect;
        BpodSystem.Data.Custom.ResponseLeft(iTrial) = ResponseLeft;
        BpodSystem.Data.Custom.ResponseTime(iTrial) = ResponseTime;
        BpodSystem.Data.Custom.InvalidResponseCorrect(iTrial)=InvalidResponseCorrect;
        BpodSystem.Data.Custom.InvalidResponseLeft(iTrial) = InvalidResponseLeft;
        BpodSystem.Data.Custom.InvalidResponseTime(iTrial) = InvalidResponseTime;
        
        BpodSystem.Data.Custom.LoutEarly(iTrial) = LoutEarly;
        BpodSystem.Data.Custom.WaitingTime(iTrial) = WaitingTime;
        BpodSystem.Data.Custom.GracePeriodDuration(iTrial) = GracePeriodDuration;
        BpodSystem.Data.Custom.GracePeriodNumber(iTrial) = GracePeriodNumber;
        BpodSystem.Data.Custom.RewardReceivedCenter(iTrial) = RewardReceivedCenter;
        BpodSystem.Data.Custom.RewardReceivedCorrect(iTrial) = RewardReceivedCorrect;
        BpodSystem.Data.Custom.RewardReceivedError(iTrial) = RewardReceivedError;
        BpodSystem.Data.Custom.RewardReceivedTotal(iTrial) = RewardReceivedTotal;
        
    else
        BpodSystem.Data.Custom.BeforeTrialInterval(iTrial)=nan;
        BpodSystem.Data.Custom.CoutEarly(iTrial)=1;
        BpodSystem.Data.Custom.EarlyWithdrawal(iTrial)=1;
        BpodSystem.Data.Custom.BrokeFixation(iTrial)=0;
        BpodSystem.Data.Custom.CinDuration(iTrial)=nan;
        BpodSystem.Data.Custom.FixDur(iTrial)=nan;
        BpodSystem.Data.Custom.ST(iTrial)=nan;
        BpodSystem.Data.Custom.ResponseCorrect(iTrial)=nan;
        BpodSystem.Data.Custom.ResponseLeft(iTrial)=nan;
        BpodSystem.Data.Custom.ResponseTime(iTrial)=nan;
        BpodSystem.Data.Custom.InvalidResponseCorrect(iTrial)=nan;
        BpodSystem.Data.Custom.InvalidResponseLeft(iTrial)=nan;
        BpodSystem.Data.Custom.InvalidResponseTime(iTrial)=nan;
        
        BpodSystem.Data.Custom.LoutEarly(iTrial)=nan;
        BpodSystem.Data.Custom.WaitingTime(iTrial)=nan;
        BpodSystem.Data.Custom.GracePeriodDuration(iTrial)=0;
        BpodSystem.Data.Custom.GracePeriodNumber(iTrial)=0;
        BpodSystem.Data.Custom.RewardReceivedCenter(iTrial)=0;
        BpodSystem.Data.Custom.RewardReceivedCorrect(iTrial)=0;
        BpodSystem.Data.Custom.RewardReceivedError(iTrial)=0;
        BpodSystem.Data.Custom.RewardReceivedTotal(iTrial)=0;
        
        BpodSystem.Data.Custom.PsychtoolboxStartup=false;
        BpodSystem.Data.Custom.EmbedSignal(iTrial)=nan;
        BpodSystem.Data.Custom.RepeatMode(iTrial)=false;
        
        
    end
else
    
    BpodSystem.Data.Custom.BeforeTrialInterval = [];
    BpodSystem.Data.Custom.CoutEarly = [];
    BpodSystem.Data.Custom.EarlyWithdrawal = [];
    BpodSystem.Data.Custom.BrokeFixation = [];
    BpodSystem.Data.Custom.CinDuration=[];
    BpodSystem.Data.Custom.FixDur=[];
    BpodSystem.Data.Custom.ST=[];
    BpodSystem.Data.Custom.ResponseCorrect=[];
    BpodSystem.Data.Custom.ResponseLeft = [];
    BpodSystem.Data.Custom.ResponseTime = [];
    BpodSystem.Data.Custom.InvalidResponseCorrect=[];
    BpodSystem.Data.Custom.InvalidResponseLeft = [];
    BpodSystem.Data.Custom.InvalidResponseTime = [];
    
    BpodSystem.Data.Custom.LoutEarly = [];
    BpodSystem.Data.Custom.WaitingTime = [];
    BpodSystem.Data.Custom.GracePeriodDuration = [];
    BpodSystem.Data.Custom.GracePeriodNumber = [];
    BpodSystem.Data.Custom.RewardReceivedCenter = [];
    BpodSystem.Data.Custom.RewardReceivedCorrect = [];
    BpodSystem.Data.Custom.RewardReceivedError = [];
    BpodSystem.Data.Custom.RewardReceivedTotal = [];
    
    BpodSystem.Data.Custom.PsychtoolboxStartup=false;
    BpodSystem.Data.Custom.EmbedSignal=[];
    BpodSystem.Data.Custom.RepeatMode=[];
    BpodSystem.Data.Custom.NoiseVolumeRescaled=[];
    
    
end

%% update times & stimulus
%update stimulus selection
switch TaskParameters.GUIMeta.DecisionVariable.String{TaskParameters.GUI.DecisionVariable}
    case 'discrete'
        nv=length(unique(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume));
        sv=length(unique(TaskParameters.GUI.NoiseVolumeTable.SignalVolume));
        
    case 'continuous'
        nv=length(unique(TaskParameters.GUI.ContinuousTable.NoiseLimits));
        sv=length(unique(TaskParameters.GUI.ContinuousTable.SignalLimits));
end
if nv==1 && sv>1
    BpodSystem.Data.Custom.Variation='signal';
elseif nv>1 && sv==1
    BpodSystem.Data.Custom.Variation='noise';
elseif nv>1 && sv>1
    BpodSystem.Data.Custom.Variation='both';
else
    BpodSystem.Data.Custom.Variation='none';
end


%% update times & stimulus
%update stimulus duration
switch TaskParameters.GUIMeta.PreStimDurationSelection.String{TaskParameters.GUI.PreStimDurationSelection}
    case 'AutoIncr'
        if iTrial>0
            History = 50; % Rat: History = 50
            Crit = 0.8; % Rat: Crit = 0.8
            ConsiderTrials = max(1,iTrial-History):1:iTrial;
            ConsiderTrials(isnan(BpodSystem.Data.Custom.CinDuration(ConsiderTrials)))=[];%only use trials with central port entry
            if TaskParameters.GUI.AllowBreakFixation==0
                ConsiderPerformance = sum(~BpodSystem.Data.Custom.CoutEarly(ConsiderTrials))/length(ConsiderTrials);
            elseif TaskParameters.GUI.AllowBreakFixation==1
                ConsiderPerformance = sum(~BpodSystem.Data.Custom.BrokeFixation(ConsiderTrials))/length(ConsiderTrials);
            end
            
            if  ConsiderPerformance > Crit && ~CoutEarly %if success over all trials AND on last trial: increase
                RampedPreStimDuration = BpodSystem.Data.Custom.PreStimDuration(iTrial) + TaskParameters.GUI.PreStimDurationRampUp;
            elseif ConsiderPerformance < Crit/2 && CoutEarly  %if failure over all trials (<crit/2) AND on last trial: decrease
                RampedPreStimDuration = BpodSystem.Data.Custom.PreStimDuration(iTrial) - TaskParameters.GUI.PreStimDurationRampDown;
            else %if any other case
                RampedPreStimDuration = BpodSystem.Data.Custom.PreStimDuration(iTrial);
            end
            BpodSystem.Data.Custom.PreStimDuration(iTrial+1) = min([TaskParameters.GUI.PreStimDurationMax,...
                max([TaskParameters.GUI.PreStimDurationMin,RampedPreStimDuration])]);
        else
            BpodSystem.Data.Custom.PreStimDuration(iTrial+1)=TaskParameters.GUI.PreStimDurationMin;
        end
        
    case 'TruncExp'
        BpodSystem.Data.Custom.PreStimDuration(iTrial+1) = TruncatedExponential(TaskParameters.GUI.PreStimDurationMin,...
            TaskParameters.GUI.PreStimDurationMax,TaskParameters.GUI.PreStimDurationTau);
    case 'Fix'
        BpodSystem.Data.Custom.PreStimDuration(iTrial+1) = TaskParameters.GUI.PreStimDurationMin;
end
TaskParameters.GUI.PreStimDuration = BpodSystem.Data.Custom.PreStimDuration(iTrial+1);
BpodSystem.Data.Custom.StimDuration(iTrial+1) = TaskParameters.GUI.StimDuration;
BpodSystem.Data.Custom.PostStimDuration(iTrial+1) = 0;



%test if stimulus should be repeated due to previous catch or skipped fb
if iTrial>0
    switch TaskParameters.GUIMeta.SkippedCorrectCorrection.String{TaskParameters.GUI.SkippedCorrectCorrection}
        case 'None'
            repeatMode=false;
        case 'RepeatSkipped'
            repeatMode=BpodSystem.Data.Custom.RepeatMode(iTrial);
            lastCorrect=BpodSystem.Data.Custom.ResponseCorrect(iTrial)==1;
            lastSkippedCorrect=BpodSystem.Data.Custom.ResponseCorrect(iTrial)==1&~BpodSystem.Data.Custom.RewardReceivedCorrect(iTrial)&~BpodSystem.Data.Custom.CatchTrial(iTrial);
            if ~repeatMode&&lastSkippedCorrect
                repeatMode=true;
            elseif repeatMode&&lastCorrect&&~lastSkippedCorrect
                repeatMode=false;
            end
        case 'RepeatSkippedCatch'
            repeatMode=BpodSystem.Data.Custom.RepeatMode(iTrial);
            lastCorrect=BpodSystem.Data.Custom.ResponseCorrect(iTrial)==1;
            lastSkippedCorrect=BpodSystem.Data.Custom.ResponseCorrect(iTrial)==1&~BpodSystem.Data.Custom.RewardReceivedCorrect(iTrial)&~BpodSystem.Data.Custom.CatchTrial(iTrial);
            lastCatchCorrect=BpodSystem.Data.Custom.ResponseCorrect(iTrial)==1&~BpodSystem.Data.Custom.RewardReceivedCorrect(iTrial)&BpodSystem.Data.Custom.CatchTrial(iTrial);
            if ~repeatMode&&(lastSkippedCorrect||lastCatchCorrect)
                repeatMode=true;%but switch off catch
            elseif repeatMode&&lastCorrect&&~(lastSkippedCorrect||lastCatchCorrect)
                repeatMode=false;
            end
    end
else
    repeatMode=false;
end
BpodSystem.Data.Custom.RepeatMode(iTrial+1)=repeatMode;
    
    
%update confidence waiting time
%update catch trial
if iTrial > TaskParameters.GUI.StartNoCatchTrials && ~BpodSystem.Data.Custom.RepeatMode(iTrial+1)
    BpodSystem.Data.Custom.CatchTrial(iTrial+1) = logical(randsample([1 0],1,1,[TaskParameters.GUI.PercentCatch 1-TaskParameters.GUI.PercentCatch]));
else
    BpodSystem.Data.Custom.CatchTrial(iTrial+1) = false;
end

%feedback delay correct answers
switch TaskParameters.GUIMeta.FeedbackDelaySelection.String{TaskParameters.GUI.FeedbackDelaySelection}
    case 'AutoIncr' %increase if correct and reward on last trial
        if iTrial>0
            if BpodSystem.Data.Custom.RewardReceivedCorrect(iTrial)>0
                RampedFeedbackDelay= BpodSystem.Data.Custom.FeedbackDelay(iTrial)+TaskParameters.GUI.FeedbackDelayIncr;
            elseif BpodSystem.Data.Custom.ResponseCorrect(iTrial)==1&&~BpodSystem.Data.Custom.RewardReceivedCorrect(iTrial) %decrease if correct and no reward on last trial
                RampedFeedbackDelay=BpodSystem.Data.Custom.FeedbackDelay(iTrial)-TaskParameters.GUI.FeedbackDelayDecr;
            else
                RampedFeedbackDelay=BpodSystem.Data.Custom.FeedbackDelay(iTrial);
            end
            TaskParameters.GUI.FeedbackDelay = min(TaskParameters.GUI.FeedbackDelayMax,...
                max(TaskParameters.GUI.FeedbackDelayMin,RampedFeedbackDelay));
        else
            TaskParameters.GUI.FeedbackDelay=TaskParameters.GUI.FeedbackDelayMax;
        end
    case 'TruncExp'
        TaskParameters.GUI.FeedbackDelay = TruncatedExponential(TaskParameters.GUI.FeedbackDelayMin,...
            TaskParameters.GUI.FeedbackDelayMax,TaskParameters.GUI.FeedbackDelayTau);
    case 'Fix'
        TaskParameters.GUI.FeedbackDelay = TaskParameters.GUI.FeedbackDelayMax;
end
if BpodSystem.Data.Custom.RepeatMode(iTrial+1)&&BpodSystem.Data.Custom.FeedbackDelay(iTrial)<60
    TaskParameters.GUI.FeedbackDelay=.1;
end
if ~BpodSystem.Data.Custom.CatchTrial(iTrial+1)
    BpodSystem.Data.Custom.FeedbackDelay(iTrial+1) = TaskParameters.GUI.FeedbackDelay;%no catch trial
else
    BpodSystem.Data.Custom.FeedbackDelay(iTrial+1)=60;%set to 60s on catch trials
end

%feedback delay error answers
if ~TaskParameters.GUI.CatchError&&~BpodSystem.Data.Custom.CatchTrial(iTrial+1)
    BpodSystem.Data.Custom.FeedbackDelayError(iTrial+1) = TaskParameters.GUI.FeedbackDelay; %no catch trial
else
    BpodSystem.Data.Custom.FeedbackDelayError(iTrial+1) = 60;%set to 60s on catch trials
end

%update afterstimulusinterval
if TaskParameters.GUI.AfterTrialIntervalJitter
    BpodSystem.Data.Custom.AfterTrialInterval(iTrial+1) = TruncatedExponential(TaskParameters.GUI.AfterTrialIntervalMin,TaskParameters.GUI.AfterTrialIntervalMax,...
        TaskParameters.GUI.AfterTrialInterval);
else
    BpodSystem.Data.Custom.AfterTrialInterval(iTrial+1) = TaskParameters.GUI.AfterTrialInterval;
end




%otherwise create new stimulus
PrepareStimulus(iTrial);

%reward depletion %UPDATE HERE IF BIAS CORRECTION IS NEEDED
BpodSystem.Data.Custom.RewardAmountCorrect(iTrial+1)=TaskParameters.GUI.RewardAmountCorrect;
BpodSystem.Data.Custom.RewardAmountError(iTrial+1)=TaskParameters.GUI.RewardAmountError;
if TaskParameters.GUI.RewardAmountCenterSelection==1
    BpodSystem.Data.Custom.RewardAmountCenter(iTrial+1)=TaskParameters.GUI.RewardAmountCenter;
elseif TaskParameters.GUI.RewardAmountCenterSelection==2
    %remove Reward if 50 Trials are sucessfully completed
    if sum(~isnan(BpodSystem.Data.Custom.ResponseCorrect))>TaskParameters.GUI.RewardAmountCenterEasyTrials
        BpodSystem.Data.Custom.RewardAmountCenter(iTrial+1)=0;
    else
        BpodSystem.Data.Custom.RewardAmountCenter(iTrial+1)=TaskParameters.GUI.RewardAmountCenter;
        
    end
end

%Light Guidance
BpodSystem.Data.Custom.LightGuidance(iTrial+1) = TaskParameters.GUI.LightGuidance;
    
    
end
