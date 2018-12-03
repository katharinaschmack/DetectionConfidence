function ResultData=OnlineAnalysis(trialTab,sessionTab,ResultData)

responseIdx=~isnan(trialTab.ResponseLeft);
signalIdx=trialTab.EmbedSignal==1;
correctIdx=trialTab.ResponseCorrect==1;
switch sessionTab.variation{1}
    case 'signal'
        dv=trialTab.SignalVolume;
        dv(~signalIdx)=nan;
    case 'noise'
        dv=-trialTab.NoiseVolume;
        dv(~signalIdx)=nan;
    case 'both'
        dv=trialTab.SignalVolume-trialTab.NoiseVolume;
        dv(~signalIdx)=nan;
end
switch sessionTab.decisionVariable{1}
    case 'continuous'
        easyIdx=dv>prctile(dv,90);
        interIdx=dv<prctile(dv,55)&dv>prctile(dv,45);
        diffIdx=dv<prctile(dv,10);
    case 'discrete'
        easyIdx=dv==max(dv);
        interIdx=dv>min(dv)&dv<max(dv);
        diffIdx=dv==min(dv);
end
ResultData.Accuracy=mean(trialTab.ResponseCorrect(responseIdx))*100;
ResultData.HitsEasy=mean(trialTab.ResponseCorrect(responseIdx&easyIdx))*100;
ResultData.HitsIntermediate=mean(trialTab.ResponseCorrect(responseIdx&interIdx))*100;
ResultData.HitsDifficult=mean(trialTab.ResponseCorrect(responseIdx&diffIdx))*100;
ResultData.Rejects=mean(trialTab.ResponseCorrect(responseIdx&~signalIdx))*100;
ResultData.Bias=mean(trialTab.ResponseLeft(responseIdx))*100;
ResultData.CoutEarly=mean(trialTab.CoutEarly)*100;
ResultData.SkippedFeedback=mean(trialTab.CoutEarly)*100;
ResultData.Catch=mean(trialTab.CatchTrial(correctIdx))*100;

