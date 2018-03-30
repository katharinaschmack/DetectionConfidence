function sma = stateMatrix(iTrial)
global BpodSystem
global TaskParameters
global StimulusSettings

%% Define ports
%determine whether this is a signal or a noise trial
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

% if TaskParameters.GUI.Jackpot == 3 % Decremental Jackpot reward
%     JackpotFactor = max(2,10 - sum(BpodSystem.Data.Custom.Jackpot)); 
% else 
%     JackpotFactor = 2; % Fixed Jackpot reward
% end
% ErrorValveTimeJackpot  = JackpotFactor*GetValveTimes(BpodSystem.Data.Custom.RewardMagnitude(iTrial,1), ErrorPort);
% CorrectValveTimeJackpot  = JackpotFactor*GetValveTimes(BpodSystem.Data.Custom.RewardMagnitude(iTrial,2), CorrectPort);

if TaskParameters.GUI.PlayStimulus == 1 %none
    StimStartOutput = {};
    StimStopOutput = {};
elseif TaskParameters.GUI.PlayStimulus > 1 %noise or signals in noise
    StimStartOutput = {'SoftCode',21};
    StimStopOutput = {'SoftCode',22};
end


    
    
sma = NewStateMatrix();
sma = SetGlobalTimer(sma,1,BpodSystem.Data.Custom.ConfidenceWaitingTime(iTrial));
sma = SetGlobalTimer(sma,2,TaskParameters.GUI.ErrorTimeout);
sma = SetGlobalTimer(sma,3,BpodSystem.Data.Custom.AfterTrialInterval(iTrial));

sma = AddState(sma, 'Name', 'wait_Cin',...
    'Timer', 0,...
    'StateChangeConditions', {CenterPortIn, 'Cin_Stim'},...
    'OutputActions', {strcat('PWM',num2str(CenterPort)),255});
sma = AddState(sma, 'Name', 'Cin_Stim',...
    'Timer', BpodSystem.Data.Custom.StimDuration(iTrial),...
    'StateChangeConditions', {CenterPortOut, 'Cout_Early','Tup','Cin_PostStim'},...
    'OutputActions', StimStartOutput);
sma = AddState(sma, 'Name', 'Cout_Early',...
    'Timer', TaskParameters.GUI.CoutEarlyTimeout,...
    'StateChangeConditions', {'Tup','EndOfTrialStart'},...
    'OutputActions', StimStopOutput);
sma = AddState(sma, 'Name', 'Cin_PostStim',...
    'Timer', TaskParameters.GUI.PostStimDuration,...
    'StateChangeConditions', {CenterPortOut, 'Cout_Early','Tup','Cin_Reward'},...
    'OutputActions', StimStopOutput);
sma = AddState(sma, 'Name', 'Cin_Reward',...
    'Timer', CenterValveTime,...
    'StateChangeConditions', {CenterPortOut, 'wait_Lin','Tup','wait_Lin'},...
    'OutputActions', [{'ValveState', CenterValve}]);
sma = AddState(sma, 'Name', 'wait_Lin',...
    'Timer', TaskParameters.GUI.ChoiceDeadline,...
    'StateChangeConditions', {CorrectPortIn, 'LinCorrect_GraceStart',ErrorPortIn, 'LinError_GraceStart','Tup','EndOfTrialStart'},...
    'OutputActions', {strcat('PWM',num2str(CorrectPort)),255,strcat('PWM',num2str(ErrorPort)),255});
%correct answer
sma = AddState(sma, 'Name', 'LinCorrect_GraceStart',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','LinCorrect_PreFb'},...
    'OutputActions', {'GlobalTimerTrig',1});
sma = AddState(sma, 'Name', 'LinCorrect_PreFb',...
    'Timer', BpodSystem.Data.Custom.ConfidenceWaitingTime(iTrial),...
    'StateChangeConditions', {CorrectPortOut,'LoutCorrect_GracePeriod','Tup','LinCorrect_Fb','GlobalTimer1_End','LinCorrect_Fb'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'LoutCorrect_GracePeriod',...
    'Timer',TaskParameters.GUI.GracePeriod, ...
    'StateChangeConditions', {CorrectPortIn,'LinCorrect_PreFb','Tup','EndOfTrialStart'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'LinCorrect_Fb',...
    'Timer', CorrectValveTime,...
    'StateChangeConditions', {'Tup','LinCorrect_PostFb',CorrectPortOut,'EndOfTrialStart'},...
    'OutputActions', {'ValveState', CorrectValve});
sma = AddState(sma, 'Name', 'LinCorrect_PostFb',...
    'Timer', 0,...
    'StateChangeConditions', {CorrectPortOut,'EndOfTrialStart'},...
    'OutputActions', {});

%incorrect answer
sma = AddState(sma, 'Name', 'LinError_GraceStart',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','LinError_PreFb'},...
    'OutputActions', {'GlobalTimerTrig',1});
sma = AddState(sma, 'Name', 'LinError_PreFb',...
    'Timer', BpodSystem.Data.Custom.ConfidenceWaitingTime(iTrial),...
    'StateChangeConditions', {ErrorPortOut,'LoutError_GracePeriod','Tup','LinError_Fb','GlobalTimer1_End','LinError_Fb'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'LoutError_GracePeriod',...
    'Timer',TaskParameters.GUI.GracePeriod, ...
    'StateChangeConditions', {ErrorPortIn,'LinError_PreFb','Tup','LoutError_TimeoutStart'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'LinError_Fb',...
    'Timer', ErrorValveTime,...
    'StateChangeConditions', {'Tup','LinError_PostFb',ErrorPortOut,'LoutError_TimeoutStart'},...
    'OutputActions', {'ValveState', ErrorValve});
sma = AddState(sma, 'Name', 'LinError_PostFb',...
    'Timer', 0,...
    'StateChangeConditions', {ErrorPortOut,'LoutError_TimeoutStart'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'LoutError_TimeoutStart',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','LoutError_Timeout'},...
    'OutputActions', {'GlobalTimerTrig',2});
sma = AddState(sma, 'Name', 'LoutError_Timeout',...
    'Timer', TaskParameters.GUI.ErrorTimeout,...
    'StateChangeConditions', {ErrorPortIn,'LinError_Timeout','Tup','EndOfTrialStart','GlobalTimer2_End','EndOfTrialStart'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'LinError_Timeout',...
    'Timer', 0,...
    'StateChangeConditions', {ErrorPortOut,'LoutError_Timeout'},...
    'OutputActions', {});



sma = AddState(sma, 'Name', 'EndOfTrialStart',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','EndOfTrial'},...
    'OutputActions', {'GlobalTimerTrig',3});
sma = AddState(sma, 'Name', 'EndOfTrial',...
    'Timer', BpodSystem.Data.Custom.AfterTrialInterval(iTrial),...
    'StateChangeConditions', {'Tup','exit','GlobalTimer3_End','exit',CenterPortIn,'wait_Cout',ErrorPortIn,'wait_LoutError',CorrectPortIn,'wait_LoutCorrect'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'wait_Cout',...
    'Timer', 0,...
    'StateChangeConditions', {CenterPortOut,'EndOfTrial'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'wait_LoutError',...
    'Timer', 0,...
    'StateChangeConditions', {ErrorPortOut,'EndOfTrial'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'wait_LoutCorrect',...
    'Timer', 0,...
    'StateChangeConditions', {CorrectPortOut,'EndOfTrial'},...
    'OutputActions', {});


end