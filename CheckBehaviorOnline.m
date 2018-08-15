function [Data, FigHdl]=CheckBehaviorOnline(SessionData,titlestring)%

if nargin<2
    titlestring='';
end
SessionData.Custom.Noise=[];
SessionData.Custom.Signal=[];

SessionData=correctErrors(SessionData);
% %correct for previous error in calculation CinDuration
% index=find(SessionData.Custom.CinDuration<0);
% if ~isempty(index)
%     for k=index
%         if length(SessionData.RawEvents.Trial{k}.Events.Port2Out)>length(SessionData.RawEvents.Trial{k}.Events.Port2Out)
%             SessionData.Custom.CinDuration(k)=SessionData.RawEvents.Trial{k}.Events.Port2Out(2)-SessionData.RawEvents.Trial{k}.Events.Port2In(1);
%         else
%             SessionData.Custom.CinDuration(k)= SessionData.RawEvents.Trial{k}.States.EndOfTrial(2)-SessionData.RawEvents.Trial{k}.Events.Port2In(1);
%         end
%     end
% end
% 
% index=find(SessionData.Custom.CinDuration<0);
% if ~isempty(index)
%     for k=index
%         if length(SessionData.RawEvents.Trial{k}.Events.Port2Out)>length(SessionData.RawEvents.Trial{k}.Events.Port2Out)
%             SessionData.Custom.CinDuration(k)=SessionData.RawEvents.Trial{k}.Events.Port2Out(2)-SessionData.RawEvents.Trial{k}.Events.Port2In(1);
%         else
%             SessionData.Custom.CinDuration(k)= SessionData.RawEvents.Trial{k}.States.EndOfTrial(2)-SessionData.RawEvents.Trial{k}.Events.Port2In(1);
%         end
%     end
% end
% 
% %correct for previous error in calculation EarlyWithdrawal and
% %Stimulus
% statesOnTrials=cellfun(@(x,y) x(y),SessionData.RawData.OriginalStateNamesByNumber,SessionData.RawData.OriginalStateData,'uni',0);
% SessionData.Custom.CoutEarly=cellfun(@(x) any(strcmp(x,'Cout_Early'))|any(strcmp(x,'Cout_Stim')),statesOnTrials);
% SessionData.Custom.EarlyWithdrawal=cellfun(@(x) any(strcmp(x,'Cin_Stim')),statesOnTrials) & SessionData.Custom.CoutEarly;
% SessionData.Custom.BrokeFixation=cellfun(@(x) ~any(strcmp(x,'Cin_Stim')),statesOnTrials) & SessionData.Custom.CoutEarly;
% 
% %correct for erroneous last time stamps
% if (SessionData.TrialStartTimestamp(end)-SessionData.TrialStartTimestamp(end-1))<0 
%     SessionData.TrialStartTimestamp(end)=[];
% end
% 
% %put extreme noise values in session data for plotting
% NoiseVolumeMax=max(SessionData.Settings.GUI.NoiseVolumeTable.NoiseVolume);
% NoiseVolumeMin=min(SessionData.Settings.GUI.NoiseVolumeTable.NoiseVolume);
% SessionData.Custom.NoiseVolumeMax=ones(SessionData.nTrials)*NoiseVolumeMax;
% SessionData.Custom.NoiseVolumeMin=ones(SessionData.nTrials)*NoiseVolumeMin;

%put data in table
try  SessionData.Custom=rmfield(SessionData.Custom,{'Signal'});end
fieldIdx=structfun(@length,SessionData.Custom)~=SessionData.nTrials+1&structfun(@length,SessionData.Custom)~=SessionData.nTrials&structfun(@length,SessionData.Custom)~=SessionData.nTrials-1;
fieldNames=fieldnames(SessionData.Custom);
SessionData.Custom=rmfield(SessionData.Custom,fieldNames(fieldIdx));%delete fields that do not contain trial by trial data
SessionData.Custom=structfun(@(x) x(1:length(SessionData.Custom.RewardReceivedTotal))',SessionData.Custom,'uni',0);%clip field to trial number

trials=num2cell([1:length(SessionData.Custom.RewardReceivedTotal)]');
newTrialTab=[cell2table(trials),struct2table(SessionData.Custom)];
newTrialTab.Properties.VariableNames{1}='trialNumber';



%calculate missed trials, accuracy, bias, reaction time and waiting time
nTrials=SessionData.nTrials;
nComTrials=sum(~isnan(SessionData.Custom.ResponseCorrect));
TrainTime=round((SessionData.TrialStartTimestamp(end)-SessionData.TrialStartTimestamp(1))./60);
try
    TotalRew=sum(SessionData.Custom.RewardReceivedTotal)/1000;
catch
    TotalRew=sum(SessionData.Custom.RewardReceivedCorrect+SessionData.Custom.RewardReceivedCenter+SessionData.Custom.RewardReceivedError)/1000;
end
%     Miss=(nTrials-nComTrials)./nTrials*100;
CoutEarly=sum(SessionData.Custom.CoutEarly)/nTrials*100;
%     MissedChoice=sum((SessionData.Custom.CoutEarly==0)&isnan(SessionData.Custom.ResponseCorrect))/nTrials*100;
%     LoutEarly=sum(SessionData.Custom.LoutEarly==1)/nTrials*100;
Bias=nansum(SessionData.Custom.ResponseLeft)/nComTrials*100;
Acc=nansum(SessionData.Custom.ResponseCorrect)/nComTrials*100;
%     RT=SessionData.Custom.ResponseTime;
%     ndxCorrect=(SessionData.Custom.ResponseCorrect==1);
%     ndxError=(SessionData.Custom.ResponseCorrect==0);
%     ndxHuge=RT>10;
%     meanRT=mean(RT((ndxCorrect|ndxError)&~ndxHuge));
%     errorRT=mean(RT((ndxError)&~ndxHuge));
%     correctRT=mean(RT((ndxCorrect)&~ndxHuge));


Data.nTrials=height(newTrialTab);
Data.nComTrials=sum(~isnan(newTrialTab.ResponseCorrect));
Data.TrainTime=TrainTime;
Data.TotalRew=TotalRew;
Data.CoutEarly=CoutEarly;
%     Data.LoutEarly=LoutEarly;
%     Data.MissedChoice=MissedChoice;
Data.Bias=Bias;
Data.Acc=Acc;
%     Data.meanRT=meanRT;
%     Data.errorRT=errorRT;
%     Data.correctRT=correctRT;

%plotSessionSummary
[FigHdl]=plotSessionSummary(newTrialTab,sprintf('%s\n%d trials, %2.0f minutes, %2.2f ml reward',titlestring,nTrials,TrainTime,TotalRew));

end