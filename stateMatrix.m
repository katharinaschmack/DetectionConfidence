function sma = stateMatrix(iTrial)
global BpodSystem
global TaskParameters
%global StimulusSettings

%% Define ports
%determine whether this is a signal or a noise trial
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

CorrectValveTime  = GetValveTimes(BpodSystem.Data.Custom.RewardAmountCorrect(iTrial), CorrectPort)*(BpodSystem.Data.Custom.RewardAmountCorrect(iTrial)>0);
CenterValveTime  = GetValveTimes(BpodSystem.Data.Custom.RewardAmountCenter(iTrial), CenterPort)*(BpodSystem.Data.Custom.RewardAmountCenter(iTrial)>0);
ErrorValveTime  = GetValveTimes(BpodSystem.Data.Custom.RewardAmountError(iTrial), ErrorPort)*(BpodSystem.Data.Custom.RewardAmountError(iTrial)>0);


if BpodSystem.Data.Custom.EmbedSignal(iTrial) == 0 %none
    StimStartOutput = {};
    StimStopOutput = {};
elseif BpodSystem.Data.Custom.EmbedSignal(iTrial) == 1 %none
    StimStartOutput = {'SoftCode',23};
    StimStopOutput = {'SoftCode',24};
end

NoiseStartOutput = {'SoftCode',21};
NoiseStopOutput = {'SoftCode',22};

%make LED outputs depending on LightGuidance
CenterLedOn={strcat('PWM',num2str(CenterPort)),255};
if BpodSystem.Data.Custom.LightGuidance(iTrial)==true
    LED_wait_Lin={strcat('PWM',num2str(CorrectPort)),255,strcat('PWM',num2str(ErrorPort)),255};
    LED_wait_Cin=CenterLedOn;
else
    LED_wait_Lin={};
    LED_wait_Cin={};
end
    
sma = NewStateMatrix();
sma = SetGlobalTimer(sma,1,BpodSystem.Data.Custom.FeedbackDelay(iTrial));
sma = SetGlobalTimer(sma,2,TaskParameters.GUI.ErrorTimeout);
sma = SetGlobalTimer(sma,3,BpodSystem.Data.Custom.AfterTrialInterval(iTrial));
sma = SetGlobalTimer(sma,4,BpodSystem.Data.Custom.StimDuration(iTrial));
sma = SetGlobalTimer(sma,5,BpodSystem.Data.Custom.FeedbackDelayError(iTrial));

sma = AddState(sma, 'Name', 'wait_Cin',...
    'Timer', 0,...
    'StateChangeConditions', {CenterPortIn, 'Cin_PreStim'},...
    'OutputActions', [NoiseStartOutput LED_wait_Cin]);%HERE

sma = AddState(sma, 'Name', 'Cin_PreStim',...
    'Timer', BpodSystem.Data.Custom.PreStimDuration(iTrial),...
    'StateChangeConditions', {CenterPortOut, 'Cout_Early','Tup','Cin_Stim'},...
    'OutputActions', {});

if TaskParameters.GUI.AllowBreakFixation==0
sma = AddState(sma, 'Name', 'Cin_Stim',...
    'Timer', BpodSystem.Data.Custom.StimDuration(iTrial),...
    'StateChangeConditions', {CenterPortOut, 'Cout_Early_StopStim','Tup','Cin_PostStim'},...
    'OutputActions', [StimStartOutput CenterLedOn]);
sma = AddState(sma, 'Name', 'Cin_PostStim',...
    'Timer', BpodSystem.Data.Custom.PostStimDuration(iTrial),...
    'StateChangeConditions', {'Tup','Cin_Reward'},...%change here if poststimduration is needed
    'OutputActions', StimStopOutput);

elseif TaskParameters.GUI.AllowBreakFixation==1
    sma = AddState(sma, 'Name', 'Cin_Stim',...
    'Timer', BpodSystem.Data.Custom.StimDuration(iTrial),...
    'StateChangeConditions', {CenterPortOut, 'Cout_Stim','Tup','Cin_PostStim'},...
    'OutputActions', [StimStartOutput CenterLedOn]);
sma = AddState(sma, 'Name', 'Cin_PostStim',...
    'Timer', BpodSystem.Data.Custom.PostStimDuration(iTrial),...
    'StateChangeConditions', {'Tup','Cin_Reward'},...
    'OutputActions', StimStopOutput);
sma = AddState(sma, 'Name', 'Cout_Stim',...
    'Timer', BpodSystem.Data.Custom.StimDuration(iTrial),...
    'StateChangeConditions', {'Tup','Cout_PostStim','GlobalTimer4_End','Cout_PostStim',ErrorPortIn,'LinError_PostStim',CorrectPortIn,'LinCorrect_PostStim'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'Cout_PostStim',...
    'Timer', BpodSystem.Data.Custom.PostStimDuration(iTrial),...
    'StateChangeConditions', {'Tup','wait_Lin'},...
    'OutputActions', StimStopOutput);
sma = AddState(sma, 'Name', 'LinError_PostStim',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','LinError_GraceStart'},...
    'OutputActions', StimStopOutput);
sma = AddState(sma, 'Name', 'LinCorrect_PostStim',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','LinCorrect_GraceStart'},...
    'OutputActions', StimStopOutput);
end

sma = AddState(sma, 'Name', 'Cout_Early_StopStim',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','Cout_Early'},...
    'OutputActions', StimStopOutput);

sma = AddState(sma, 'Name', 'Cout_Early',...
    'Timer', TaskParameters.GUI.CoutEarlyTimeout,...
    'StateChangeConditions', {'Tup','EndOfTrial'},...
    'OutputActions', NoiseStopOutput);

sma = AddState(sma, 'Name', 'Cin_Reward',...
    'Timer', CenterValveTime,...
    'StateChangeConditions', {CenterPortOut, 'wait_Lin','Tup','wait_Lin'},...
    'OutputActions', [{'ValveState', CenterValve}]);

    sma = AddState(sma, 'Name', 'wait_Lin',...
        'Timer', TaskParameters.GUI.ChoiceDeadline,...
        'StateChangeConditions', {CorrectPortIn, 'LinCorrect_GraceStart',ErrorPortIn, 'LinError_GraceStart','Tup','MissedChoice'},...
        'OutputActions', LED_wait_Lin);


%correct answer
sma = AddState(sma, 'Name', 'LinCorrect_GraceStart',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','LinCorrect_PreFb'},...
    'OutputActions', [{'GlobalTimerTrig',1},NoiseStopOutput]);
sma = AddState(sma, 'Name', 'LinCorrect_PreFb',...
    'Timer', BpodSystem.Data.Custom.FeedbackDelay(iTrial),...
    'StateChangeConditions', {CorrectPortOut,'LoutCorrect_GracePeriod','Tup','LinCorrect_CueFb','GlobalTimer1_End','LinCorrect_CueFb'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'LoutCorrect_GracePeriod',...
    'Timer',TaskParameters.GUI.FeedbackDelayGrace, ...
    'StateChangeConditions', {CorrectPortIn,'LinCorrect_PreFb','Tup','EndOfTrial'},...
    'OutputActions', {});
%sma = AddState(sma, 'Name', 'LoutCorrect_NoiseStop',...
    %'Timer', 0,...
    %'StateChangeConditions', {'Tup','EndOfTrial'},...
    %'OutputActions', NoiseStopOutput);
sma = AddState(sma, 'Name', 'LinCorrect_CueFb',...
    'Timer', BpodSystem.Data.Custom.StimDuration(iTrial),...
    'StateChangeConditions', {'Tup','LinCorrect_Fb'},...
    'OutputActions', {strcat('PWM',num2str(CorrectPort)),255});

sma = AddState(sma, 'Name', 'LinCorrect_Fb',...
    'Timer', CorrectValveTime,...
    'StateChangeConditions', {'Tup','EndOfTrial'},...
    'OutputActions', [{'ValveState', CorrectValve}]);

%incorrect answer
sma = AddState(sma, 'Name', 'LinError_GraceStart',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','LinError_PreFb'},...
    'OutputActions', [{'GlobalTimerTrig',1},NoiseStopOutput]);
sma = AddState(sma, 'Name', 'LinError_PreFb',...
    'Timer', BpodSystem.Data.Custom.FeedbackDelayError(iTrial),...
    'StateChangeConditions', {ErrorPortOut,'LoutError_GracePeriod','Tup','LinError_Fb','GlobalTimer5_End','LinError_Fb'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'LoutError_GracePeriod',...
    'Timer',TaskParameters.GUI.FeedbackDelayGrace, ...
    'StateChangeConditions', {ErrorPortIn,'LinError_PreFb','Tup','EndOfTrial'},...
    'OutputActions', {});
%sma = AddState(sma, 'Name', 'LoutError_NoiseStop',...
%    'Timer',0, ...
%    'StateChangeConditions', {'Tup','Error_Timeout'},...
 %   'OutputActions', NoiseStopOutput);
sma = AddState(sma, 'Name', 'LinError_Fb',...
    'Timer', ErrorValveTime,...
    'StateChangeConditions', {'Tup','Error_Timeout'},...
    'OutputActions', [{'ValveState', ErrorValve}]);
sma = AddState(sma, 'Name', 'Error_Timeout',...
    'Timer', TaskParameters.GUI.ErrorTimeout,...
    'StateChangeConditions', {'Tup','EndOfTrial'},...
    'OutputActions', {});

%no answer
    sma = AddState(sma, 'Name', 'MissedChoice',...
        'Timer', 0,...
        'StateChangeConditions', {'Tup','EndOfTrial'},...
        'OutputActions', NoiseStopOutput);

sma = AddState(sma, 'Name', 'EndOfTrial',...
    'Timer', BpodSystem.Data.Custom.AfterTrialInterval(iTrial),...
    'StateChangeConditions', {'Tup','exit'},...
    'OutputActions', {});


end