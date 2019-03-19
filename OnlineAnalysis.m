function Results=OnlineAnalysis(trialTab,sessionTab)

if height(sessionTab)==1
Results=sessionTab(:,{'Day','Date','SessionNumber','Trials','Duration','TotalReward','Variation','Evidence','Easy','Intermediate','Difficult','FbDelay','Catch'});
end
responseIdx=~isnan(trialTab.ResponseLeft);
signalIdx=trialTab.EmbedSignal==1;
correctIdx=trialTab.ResponseCorrect==1;

switch sessionTab{1,'Variation'}{1}
    case 'signal'
        dv=trialTab.SignalVolume;
        dv(~signalIdx)=nan;
    case 'noise'
        dv=-trialTab.NoiseVolume;
        dv(~signalIdx)=nan;
    case {'both','none'}
        dv=trialTab.SignalVolume-trialTab.NoiseVolume;
        dv(~signalIdx)=nan;
end
switch sessionTab{1,'DecisionVariable'}{1}
    case 'continuous'
        easyIdx=dv>=prctile(dv,95);
        interIdx=dv<prctile(dv,55)&dv>prctile(dv,45);
        diffIdx=dv<=prctile(dv,5);
    case 'discrete'
        easyIdx=dv==max(dv);
        interIdx=dv>min(dv)&dv<max(dv);
        diffIdx=dv==min(dv);
end
Results.Accuracy=mean(trialTab.ResponseCorrect(responseIdx))*100;
Results.HitsEasy=mean(trialTab.ResponseCorrect(responseIdx&easyIdx))*100;
Results.HitsIntermediate=mean(trialTab.ResponseCorrect(responseIdx&interIdx))*100;
Results.HitsDifficult=mean(trialTab.ResponseCorrect(responseIdx&diffIdx))*100;
Results.Rejects=mean(trialTab.ResponseCorrect(responseIdx&~signalIdx))*100;
Results.Bias=mean(trialTab.ResponseLeft(responseIdx))*100;
Results.CoutEarly=mean(trialTab.CoutEarly)*100;
Results.SkippedFeedback=nanmean(trialTab.SkippedFeedback(correctIdx))*100;
Results.Catch=mean(trialTab.CatchTrial(correctIdx))*100;
if height(sessionTab)==1
Results.Date=datestr(datenum(Results.Date),'mm/dd/yy');
end
