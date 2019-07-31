function sma = stateMatrix(iTrial)
global BpodSystem
global TaskParameters
%global StimulusSettings

%% Define ports
npgBNCArg = 1; % BNC 1 source to trigger Nidaq is hard coded

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
if BpodSystem.Data.Custom.RewardAmountCenter(iTrial)>0
    CenterValveTime  = GetValveTimes(BpodSystem.Data.Custom.RewardAmountCenter(iTrial), CenterPort)*(BpodSystem.Data.Custom.RewardAmountCenter(iTrial)>0);
else
    CenterValveTime=0;
end
if BpodSystem.Data.Custom.RewardAmountError(iTrial)>0
    ErrorValveTime  = GetValveTimes(BpodSystem.Data.Custom.RewardAmountError(iTrial), ErrorPort)*(BpodSystem.Data.Custom.RewardAmountError(iTrial)>0);
else 
    ErrorValveTime = 0;
end

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
    LED.wait_Cin={strcat('PWM',num2str(CenterPort)),255};
    LED.Pre_Stim={};
    LED.Cin_Stim={strcat('PWM',num2str(CenterPort)),255};
    LED.wait_Lin={strcat('PWM',num2str(CorrectPort)),255,strcat('PWM',num2str(ErrorPort)),255};
    LED.LinCorrect_GraceStart={};
    LED.LinCorrect_PreFb={};
    LED.LoutCorrect_GracePeriod={};
    LED.LinCorrect_CueFb={strcat('PWM',num2str(CorrectPort)),255};
    LED.LinError_GraceStart={};
    LED.LinError_PreFb={};
    LED.LoutError_GracePeriod={};
    LinCorrect_CueFb_Duration=BpodSystem.Data.Custom.StimDuration(iTrial);

else
    LED.wait_Cin={strcat('PWM',num2str(CenterPort)),100};
    LED.Pre_Stim={strcat('PWM',num2str(CenterPort)),100};
    LED.Cin_Stim={};
    LED.wait_Lin={strcat('PWM',num2str(CorrectPort)),100,strcat('PWM',num2str(ErrorPort)),100};
    LED.LinCorrect_GraceStart={strcat('PWM',num2str(CorrectPort)),100,strcat('PWM',num2str(ErrorPort)),100};
    LED.LinCorrect_PreFb={strcat('PWM',num2str(CorrectPort)),100,strcat('PWM',num2str(ErrorPort)),100};
    LED.LoutCorrect_GracePeriod={strcat('PWM',num2str(CorrectPort)),100,strcat('PWM',num2str(ErrorPort)),100};
    LED.LinCorrect_CueFb={};
    LED.LinError_GraceStart={strcat('PWM',num2str(CorrectPort)),100,strcat('PWM',num2str(ErrorPort)),100};
    LED.LinError_PreFb={strcat('PWM',num2str(CorrectPort)),100,strcat('PWM',num2str(ErrorPort)),100};
    LED.LoutError_GracePeriod={strcat('PWM',num2str(CorrectPort)),100,strcat('PWM',num2str(ErrorPort)),100};
    LinCorrect_CueFb_Duration=0;
end
    
sma = NewStateMatrix();
sma = SetGlobalTimer(sma,1,BpodSystem.Data.Custom.FeedbackDelay(iTrial));
% sma = SetGlobalTimer(sma,2,TaskParameters.GUI.ErrorTimeout);
sma = SetGlobalTimer(sma,3,BpodSystem.Data.Custom.PreStimDuration(iTrial));
sma = SetGlobalTimer(sma,4,BpodSystem.Data.Custom.StimDuration(iTrial));
% sma = SetGlobalTimer(sma,5,BpodSystem.Data.Custom.FeedbackDelayError(iTrial));


if BpodSystem.Data.Custom.PhotometryOn(iTrial)==1||BpodSystem.Data.Custom.PhotometryOn(iTrial)==2
    if  ~BpodSystem.Data.Custom.recordBaselineTrial
        sma = AddState(sma, 'Name', 'StartRecording',...
            'Timer',0.025,...
            'StateChangeConditions', {'Tup', 'startOfTrial'},...
            'OutputActions', {'BNCState', npgBNCArg}); % trigger photometry acq global timer, nidaq trigger, point grey camera
    else %% get baseline photometry without behavior
        sma = AddState(sma, 'Name', 'StartRecording',...
            'Timer',0.025,...
            'StateChangeConditions', {'Tup', 'Recording'},...
            'OutputActions', {'BNCState', npgBNCArg}); % trigger photometry acq global timer, nidaq trigger, point grey camera
        sma = AddState(sma, 'Name', 'Recording',...
            'Timer',TaskParameters.GUI.BaselineRecording,...
            'StateChangeConditions', {'Tup', 'EndOfTrial'},...
            'OutputActions', {}); % trigger photometry acq global timer, nidaq trigger, point grey camera
    end
else
    sma = AddState(sma, 'Name', 'StartRecording',...
        'Timer',0.025,...
        'StateChangeConditions', {'Tup', 'startOfTrial'},...
        'OutputActions', {}); % add StartRecording state even if there is no recording to make sure that temporal sequence of trial does not change with photometry acquisition
end

sma = AddState(sma, 'Name', 'startOfTrial',...
    'Timer', BpodSystem.Data.Custom.AfterTrialInterval(iTrial),...
    'StateChangeConditions', {'Tup', 'wait_Cin'},...
    'OutputActions', {});%HERE

sma = AddState(sma, 'Name', 'wait_Cin',...
    'Timer', 0,...
    'StateChangeConditions', {CenterPortIn, 'Cin_GraceStart'},...
    'OutputActions', [NoiseStartOutput LED.wait_Cin]);%HERE

sma = AddState(sma, 'Name', 'Cin_GraceStart',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'Cin_PreStim'},...
    'OutputActions', {'GlobalTimerTrig',3});

sma = AddState(sma, 'Name', 'Cin_PreStim',...
    'Timer', BpodSystem.Data.Custom.PreStimDuration(iTrial),...
    'StateChangeConditions', {CenterPortOut, 'Cout_Grace','Tup','Cin_Stim','GlobalTimer3_End','Cin_Stim'},...
    'OutputActions', LED.Pre_Stim);

sma = AddState(sma, 'Name', 'Cout_Grace',...
    'Timer', BpodSystem.Data.Custom.CoutEarlyGrace(iTrial),...
    'StateChangeConditions', {CenterPortIn, 'Cin_PreStim','Tup','Cout_Early'},...
    'OutputActions', LED.Pre_Stim);

sma = AddState(sma, 'Name', 'Cin_Stim',...
    'Timer', BpodSystem.Data.Custom.StimDuration(iTrial),...
    'StateChangeConditions', {CenterPortOut, 'Cout_Stim','Tup','Cin_PostStim'},...
    'OutputActions', [StimStartOutput LED.Cin_Stim]);

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
% end

sma = AddState(sma, 'Name', 'Cout_Early_StopStim',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','Cout_Early'},...
    'OutputActions', StimStopOutput);

sma = AddState(sma, 'Name', 'Cout_Early',...
    'Timer', TaskParameters.GUI.CoutEarlyTimeout,...
    'StateChangeConditions', {'Tup','EndOfTrial'},...
    'OutputActions', NoiseStopOutput);

if CenterValveTime>0
sma = AddState(sma, 'Name', 'Cin_Reward',...
    'Timer', CenterValveTime,...
    'StateChangeConditions', {CenterPortOut, 'wait_Lin','Tup','wait_Lin'},...
    'OutputActions', [{'ValveState', CenterValve}]);
else
    sma = AddState(sma, 'Name', 'Cin_Reward',...
    'Timer', CenterValveTime,...
    'StateChangeConditions', {CenterPortOut, 'wait_Lin','Tup','wait_Lin'},...
    'OutputActions', []);
end
sma = AddState(sma, 'Name', 'wait_Lin',...
    'Timer', TaskParameters.GUI.ChoiceDeadline,...
    'StateChangeConditions', {CorrectPortIn, 'LinCorrect_GraceStart',ErrorPortIn, 'LinError_GraceStart','Tup','MissedChoice'},...
    'OutputActions', LED.wait_Lin);

%correct answer
sma = AddState(sma, 'Name', 'LinCorrect_GraceStart',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','LinCorrect_PreFb'},...
    'OutputActions', [{'GlobalTimerTrig',1},NoiseStopOutput,LED.LinCorrect_GraceStart]);
sma = AddState(sma, 'Name', 'LinCorrect_PreFb',...
    'Timer', BpodSystem.Data.Custom.FeedbackDelay(iTrial),...
    'StateChangeConditions', {CorrectPortOut,'LoutCorrect_GracePeriod','Tup','LinCorrect_Fb','GlobalTimer1_End','LinCorrect_Fb'},...
    'OutputActions', LED.LinCorrect_PreFb);
sma = AddState(sma, 'Name', 'LoutCorrect_GracePeriod',...
    'Timer',TaskParameters.GUI.FeedbackDelayGrace, ...
    'StateChangeConditions', {CorrectPortIn,'LinCorrect_PreFb','Tup','EndOfTrial'},...
    'OutputActions', LED.LoutCorrect_GracePeriod);
%sma = AddState(sma, 'Name', 'LoutCorrect_NoiseStop',...
    %'Timer', 0,...
    %'StateChangeConditions', {'Tup','EndOfTrial'},...
    %'OutputActions', NoiseStopOutput);

sma = AddState(sma, 'Name', 'LinCorrect_Fb',...
    'Timer', CorrectValveTime,...
    'StateChangeConditions', {'Tup','LinCorrect_CueFb',CorrectPortOut,'LoutCorrect_CueFb'},...
    'OutputActions', [{'ValveState', CorrectValve,'GlobalTimerTrig',4}, LED.LinCorrect_CueFb]);

sma = AddState(sma, 'Name', 'LinCorrect_CueFb',...
    'Timer',BpodSystem.Data.Custom.StimDuration(iTrial),...
    'StateChangeConditions', {'Tup','LinCorrect_WaitLout','GlobalTimer4_End','LinCorrect_WaitLout',CorrectPortOut,'LoutCorrect_CueFb'},...
    'OutputActions', [LED.LinCorrect_CueFb]);

sma = AddState(sma, 'Name', 'LoutCorrect_CueFb',...
    'Timer',BpodSystem.Data.Custom.StimDuration(iTrial),...
    'StateChangeConditions', {'Tup','EndOfTrial','GlobalTimer4_End','EndOfTrial',CorrectPortIn,'LinCorrect_CueFb'},...
    'OutputActions', [LED.LinCorrect_CueFb]);

sma = AddState(sma, 'Name', 'LinCorrect_WaitLout',...
    'Timer', 60,...
    'StateChangeConditions', {'Tup','EndOfTrial',CorrectPortOut,'EndOfTrial'},...
    'OutputActions', {});

%incorrect answer
sma = AddState(sma, 'Name', 'LinError_GraceStart',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','LinError_PreFb'},...
    'OutputActions', [{'GlobalTimerTrig',1},NoiseStopOutput,LED.LinError_GraceStart]);
sma = AddState(sma, 'Name', 'LinError_PreFb',...
    'Timer', BpodSystem.Data.Custom.FeedbackDelayError(iTrial),...
    'StateChangeConditions', {ErrorPortOut,'LoutError_GracePeriod','Tup','LinError_Fb','GlobalTimer5_End','LinError_Fb'},...
    'OutputActions', LED.LinError_PreFb);
sma = AddState(sma, 'Name', 'LoutError_GracePeriod',...
    'Timer',TaskParameters.GUI.FeedbackDelayGrace, ...
    'StateChangeConditions', {ErrorPortIn,'LinError_PreFb','Tup','EndOfTrial'},...
    'OutputActions', LED.LoutError_GracePeriod);
%sma = AddState(sma, 'Name', 'LoutError_NoiseStop',...
%    'Timer',0, ...
%    'StateChangeConditions', {'Tup','Error_Timeout'},...
 %   'OutputActions', NoiseStopOutput);
 if ErrorValveTime>0
     sma = AddState(sma, 'Name', 'LinError_Fb',...
         'Timer', ErrorValveTime,...
         'StateChangeConditions', {'Tup','LinError_WaitLout',ErrorPortOut,'Error_Timeout'},...
         'OutputActions', [{'ValveState', ErrorValve}]);
 else
     sma = AddState(sma, 'Name', 'LinError_Fb',...
         'Timer', ErrorValveTime,...
         'StateChangeConditions', {'Tup','LinError_WaitLout',ErrorPortOut,'Error_Timeout'},...
         'OutputActions', []);
 end
sma = AddState(sma, 'Name', 'LinError_WaitLout',...
    'Timer', 60,...
    'StateChangeConditions', {'Tup','EndOfTrial',ErrorPortOut,'Error_Timeout'},...
    'OutputActions', {});

sma = AddState(sma, 'Name', 'Error_Timeout',...
    'Timer', TaskParameters.GUI.ErrorTimeout,...
    'StateChangeConditions', {'Tup','EndOfTrial'},...
    'OutputActions', {});

%no answer
sma = AddState(sma, 'Name', 'MissedChoice',...
        'Timer', 0,...
        'StateChangeConditions', {'Tup','EndOfTrial'},...
        'OutputActions', NoiseStopOutput);

sma = AddState(sma, 'Name', 'EndOfTrial',...%added some seconds post recording buffer
    'Timer', BpodSystem.Data.Custom.PostTrialRecording(iTrial),...
    'StateChangeConditions', {'Tup','exit'},...
    'OutputActions', {});




end