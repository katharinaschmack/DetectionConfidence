function ResultData=OnlineAnalysis(SessionData)

trialIdx=1:length(SessionData.Custom.ResponseCorrect);

SessionData.Custom.EmbedSignal=SessionData.Custom.EmbedSignal(trialIdx);
SessionData.Custom.NoiseVolumeRescaled=SessionData.Custom.NoiseVolumeRescaled(trialIdx);
SessionData.Custom.CatchTrial=SessionData.Custom.CatchTrial(trialIdx);

%accuracy
ResultData.acc.both=nanmean(SessionData.Custom.ResponseCorrect==1)*100;
ResultData.acc.signal=sum(SessionData.Custom.ResponseCorrect==1&SessionData.Custom.EmbedSignal==1)/sum(SessionData.Custom.EmbedSignal==1)*100;
ResultData.acc.noise=sum(SessionData.Custom.ResponseCorrect==1&SessionData.Custom.EmbedSignal==0)/sum(SessionData.Custom.EmbedSignal==0)*100;

%lapse rate on 10% easiest trials
easyTrialIdx=abs(SessionData.Custom.NoiseVolumeRescaled)>prctile(abs(SessionData.Custom.NoiseVolumeRescaled),90);
ResultData.lapse.both=nanmean(SessionData.Custom.ResponseCorrect(easyTrialIdx)==1)*100;
ResultData.lapse.signal=sum(SessionData.Custom.ResponseCorrect(easyTrialIdx)==1&SessionData.Custom.EmbedSignal(easyTrialIdx)==1)/sum(SessionData.Custom.EmbedSignal(easyTrialIdx)==1)*100;
ResultData.lapse.noise=sum(SessionData.Custom.ResponseCorrect(easyTrialIdx)==1&SessionData.Custom.EmbedSignal(easyTrialIdx)==0)/sum(SessionData.Custom.EmbedSignal(easyTrialIdx)==0)*100;


%skipped Fb
skippedCorrectIdx=SessionData.Custom.ResponseCorrect==1&SessionData.Custom.RewardReceivedCorrect==0&SessionData.Custom.CatchTrial~=1;
ResultData.skipped.both=sum(SessionData.Custom.ResponseCorrect(skippedCorrectIdx)==1)/sum(SessionData.Custom.ResponseCorrect==1)*100;
ResultData.skipped.signal=sum(SessionData.Custom.ResponseCorrect(skippedCorrectIdx)==1&SessionData.Custom.EmbedSignal(skippedCorrectIdx)==1)/sum(SessionData.Custom.ResponseCorrect==1&SessionData.Custom.EmbedSignal==1)*100;
ResultData.skipped.noise=sum(SessionData.Custom.ResponseCorrect(skippedCorrectIdx)==1&SessionData.Custom.EmbedSignal(skippedCorrectIdx)==0)/sum(SessionData.Custom.ResponseCorrect==1&SessionData.Custom.EmbedSignal==0)*100;

%coutEarly
ResultData.coutEarly.both=mean(SessionData.Custom.CoutEarly==1)*100;
ResultData.nTrials=max(trialIdx);
ResultData.Reward=round(sum(SessionData.Custom.RewardReceivedTotal)*10)/10;
ResultData.Duration=round((max(SessionData.TrialStartTimestamp)-min(SessionData.TrialStartTimestamp))/60);

