function MainPlot(AxesHandles, Action, varargin)
global nTrialsToShow %this is for convenience
global BpodSystem
global TaskParameters


BpodSystem.Data.Custom.NoiseVolumeRescaled=rescaleNoise(BpodSystem.Data.Custom.NoiseVolume,BpodSystem.Data.Custom.EmbedSignal);

switch Action
    case 'init'
        
        %% Outcome
        nTrialsToShow = 90; %default number of trials to display
        
        if nargin >=3  %custom number of trials
            nTrialsToShow =varargin{1};
        end
        axes(AxesHandles.HandleOutcome);
        
        %plot in specified axes
        BpodSystem.GUIHandles.OutcomePlot.EarlyWithdrawal = line(-1,0, 'LineStyle','none','Marker','d','MarkerEdge','none','MarkerFace','b', 'MarkerSize',8);
        BpodSystem.GUIHandles.OutcomePlot.SkippedFeedback = line(-1,0, 'LineStyle','none','Marker','h','MarkerFace',[.5 .5 .5],'MarkerEdge','none', 'MarkerSize',11);

        BpodSystem.GUIHandles.OutcomePlot.Aud = line(-1,0, 'LineStyle','none','Marker','o','MarkerEdge',[.5,.5,.5],'MarkerFace',[.7,.7,.7], 'MarkerSize',8);
        %BpodSystem.GUIHandles.OutcomePlot.DV = line(1,0, 'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','b', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCircle = line(1,0, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCross = line(1,0, 'LineStyle','none','Marker','+','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.CumRwd = text(0,0,'0mL','verticalalignment','bottom','horizontalalignment','center');
        BpodSystem.GUIHandles.OutcomePlot.Correct = line(-1,0, 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.Incorrect = line(-1,0, 'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.BrokeFix = line(-1,0, 'LineStyle','none','Marker','d','MarkerEdge','b','MarkerFace','none', 'MarkerSize',8);
        BpodSystem.GUIHandles.OutcomePlot.NoFeedback = line(-1,0, 'LineStyle','none','Marker','o','MarkerEdge','none','MarkerFace','w', 'MarkerSize',5);
        BpodSystem.GUIHandles.OutcomePlot.NoResponse = line(-1,0, 'LineStyle','none','Marker','x','MarkerEdge','b','MarkerFace','none', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.SignalVolume = line(-1,0, 'LineStyle','none','Marker','*','MarkerFace','k','MarkerEdge','k', 'MarkerSize',5);       
        BpodSystem.GUIHandles.OutcomePlot.Catch = line(-1,0, 'LineStyle','none','Marker','o','MarkerEdge',[0,0,0],'MarkerFace',[0,0,0], 'MarkerSize',2);
        
        %set(AxesHandles.HandleOutcome,'TickDir', 'out','XLim',[0, nTrialsToShow], 'YTick', [0:20:60],'YTickLabel', {' 0dB','20dB','40dB','60dB'}, 'FontSize', 13);
        ytick=linspace(-1,1,5);
        ytickLabel=inverseRescaleNoise(ytick);
        ytickLabelStr=cellfun(@num2str,num2cell(ytickLabel),'uni',0);
        set(AxesHandles.HandleOutcome,'TickDir', 'out','XLim',[0, nTrialsToShow],'YLim',[-1.25 1.25],'YTick',ytick,'YTickLabel', ytickLabelStr,'FontSize', 13);
        %xlabel(AxesHandles.HandleOutcome, 'Trial#', 'FontSize', 14);
        hold(AxesHandles.HandleOutcome, 'on');
        
        %% Psyc Auditory
        BpodSystem.GUIHandles.OutcomePlot.PsycAud = line(AxesHandles.HandlePsycAud,[-1 1],[.5 .5], 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',6,'Visible','off');
        BpodSystem.GUIHandles.OutcomePlot.PsycAudFit = line(AxesHandles.HandlePsycAud,[-1. 1.],[.5 .5],'color','k','Visible','off');
        AxesHandles.HandlePsycAud.YLim = [-.05 1.05];
        AxesHandles.HandlePsycAud.XLim = [-1.05 1.05];
        AxesHandles.HandlePsycAud.XTick = [-1:.5:1];
        n=[TaskParameters.GUI.NoiseVolumeTable.NoiseVolume(1:end-1); flipud(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume)];
        s=[zeros(length(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume)-1,1); flipud(TaskParameters.GUI.NoiseVolumeTable.SignalVolume)];
        for k=1:length(n)
           xticklabel{k}=sprintf('%d-%d',n(k),s(k));
        end
        AxesHandles.HandlePsycAud.XTickLabel=xticklabel;
        AxesHandles.HandlePsycAud.XLabel.String = {'signal - noise level (dB)'}; %adapt here if you want to show dB
        AxesHandles.HandlePsycAud.YLabel.String = '% Signal responses';
        AxesHandles.HandlePsycAud.Title.String = 'Psychometric';
        AxesHandles.HandlePsycAud.FontSize=6;
        
        %% Vevaiometric curve
        hold(AxesHandles.HandleVevaiometric,'on')
        BpodSystem.GUIHandles.OutcomePlot.VevaiometricCatch = line(AxesHandles.HandleVevaiometric,-2,-1, 'LineStyle','-','Color','g','Visible','off','LineWidth',2);
        BpodSystem.GUIHandles.OutcomePlot.VevaiometricErr = line(AxesHandles.HandleVevaiometric,-2,-1, 'LineStyle','-','Color','r','Visible','off','LineWidth',2);
        BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsErr = line(AxesHandles.HandleVevaiometric,-2,-1, 'LineStyle','none','Color','r','Marker','o','MarkerFaceColor','r', 'MarkerSize',2,'Visible','off','MarkerEdgeColor','r');
        BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsCatch = line(AxesHandles.HandleVevaiometric,-2,-1, 'LineStyle','none','Color','g','Marker','o','MarkerFaceColor','g', 'MarkerSize',2,'Visible','off','MarkerEdgeColor','g');
        %AxesHandles.HandleVevaiometric.YLim = [-.5 5];
        AxesHandles.HandleVevaiometric.XLim = [-1.05 1.05];
        AxesHandles.HandleVevaiometric.XTick = AxesHandles.HandlePsycAud.XTick;
        AxesHandles.HandleVevaiometric.XTickLabel=AxesHandles.HandlePsycAud.XTickLabel;
        AxesHandles.HandleVevaiometric.XLabel.String = AxesHandles.HandlePsycAud.XLabel.String;
        AxesHandles.HandleVevaiometric.YLabel.String = 'WT (s)';
        AxesHandles.HandleVevaiometric.Title.String = 'Vevaiometric';
                AxesHandles.HandleVevaiometric.FontSize=AxesHandles.HandlePsycAud.FontSize;

        %% Trial rate
        hold(AxesHandles.HandleTrialRate,'on')
        BpodSystem.GUIHandles.OutcomePlot.TrialRate = line(AxesHandles.HandleTrialRate,[0],[0], 'LineStyle','-','Color','k','Visible','off'); %#ok<NBRAK>
        AxesHandles.HandleTrialRate.XLabel.String = 'Time (min)'; % FIGURE OUT UNIT
        AxesHandles.HandleTrialRate.YLabel.String = 'nTrials';
        AxesHandles.HandleTrialRate.Title.String = 'Trial rate';
        
        %% Stimulus delay
        hold(AxesHandles.HandleFix,'on')
        AxesHandles.HandleFix.XLabel.String = 'Time (ms)';
        AxesHandles.HandleFix.YLabel.String = 'trial counts';
        AxesHandles.HandleFix.Title.String = 'Pre-stimulus delay';
        
        %% Sampling duration histogram
        hold(AxesHandles.HandleST,'on')
        AxesHandles.HandleST.XLabel.String = 'Time (ms)';
        AxesHandles.HandleST.YLabel.String = 'trial counts';
        AxesHandles.HandleST.Title.String = 'Stim sampling time';
        
        %% Feedback Delay histogram
        hold(AxesHandles.HandleFeedback,'on')
        AxesHandles.HandleFeedback.XLabel.String = 'Time (ms)';
        AxesHandles.HandleFeedback.YLabel.String = 'trial counts';
        AxesHandles.HandleFeedback.Title.String = 'Feedback delay';
        
        
    case 'update'
        
        %% Reposition and hide/show axes
        ShowPlots = [TaskParameters.GUI.ShowPsycAud,TaskParameters.GUI.ShowVevaiometric,...
            TaskParameters.GUI.ShowTrialRate,TaskParameters.GUI.ShowFix,TaskParameters.GUI.ShowST,TaskParameters.GUI.ShowFeedback];
        PlotNames={'PsycAud','Vevaiometric','TrialRate','Fix','ST','Feedback'};
        
        
        NoPlots = sum(ShowPlots);
        NPlot = cumsum(ShowPlots);
        for n=NPlot
            if ShowPlots(n)
                newPos= ['[' num2str(n*.05+0.005 + (n-1)*1/(1.65*NoPlots)) ',.7,'   num2str(1/(1.65*NoPlots)) ',0.25]'];
                eval(['BpodSystem.GUIHandles.OutcomePlot.Handle' PlotNames{n} '.Position ='  newPos ';'])
                eval(['BpodSystem.GUIHandles.OutcomePlot.Handle' PlotNames{n} '.Visible = ''on'';'])
                eval(['set(get(BpodSystem.GUIHandles.OutcomePlot.Handle' PlotNames{n} ',''Children''),''Visible'',''on'');'])
            else
                eval(['BpodSystem.GUIHandles.OutcomePlot.Handle' PlotNames{n} '.Visible = ''off'';'])
                eval(['set(get(BpodSystem.GUIHandles.OutcomePlot.Handle' PlotNames{n} ',''Children''),''Visible'',''off'');'])
            end
        end
        
        
        %% Outcome main plot
        iTrial = varargin{1};
        [mn, ~] = rescaleX(AxesHandles.HandleOutcome,iTrial,nTrialsToShow); % recompute xlim
        
        %future trial
        set(BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCircle, 'xdata', iTrial+1, 'ydata', BpodSystem.Data.Custom.NoiseVolumeRescaled(iTrial+1));
        set(BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCross, 'xdata', iTrial+1, 'ydata', BpodSystem.Data.Custom.NoiseVolumeRescaled(iTrial+1));
        
        %past trials
        indxToPlot = mn:iTrial;
        
        %reward
        RewardReceivedTotal = sum(BpodSystem.Data.Custom.RewardReceivedTotal);
        set(BpodSystem.GUIHandles.OutcomePlot.CumRwd, 'position', [iTrial+1 -.8], 'string', ...
            [num2str(RewardReceivedTotal/1000) ' mL']);
        
        %write signal volume
        ndxSignalPlayed = BpodSystem.Data.Custom.EmbedSignal(indxToPlot)==1&...
            ~logical(BpodSystem.Data.Custom.BrokeFixation(indxToPlot))&...
            ~logical(BpodSystem.Data.Custom.EarlyWithdrawal(indxToPlot));
        
        Xdata = indxToPlot(ndxSignalPlayed);
        signalBinned=rescaleNoise(BpodSystem.Data.Custom.SignalVolume,BpodSystem.Data.Custom.EmbedSignal);
        Ydata = signalBinned(indxToPlot); Ydata = Ydata(ndxSignalPlayed);
        set(BpodSystem.GUIHandles.OutcomePlot.SignalVolume,'xdata',Xdata, 'ydata',Ydata);
        
            
        %Plot Correct
        ndxCor = BpodSystem.Data.Custom.ResponseCorrect(indxToPlot)==1|(BpodSystem.Data.Custom.InvalidResponseCorrect(indxToPlot)==1&BpodSystem.Data.Custom.ResponseCorrect(indxToPlot)~=0);
        Xdata = indxToPlot(ndxCor);
        Ydata = BpodSystem.Data.Custom.NoiseVolumeRescaled(indxToPlot); Ydata = Ydata(ndxCor);
        set(BpodSystem.GUIHandles.OutcomePlot.Correct, 'xdata', Xdata, 'ydata', Ydata);
        
        %Plot Incorrect
        ndxInc = BpodSystem.Data.Custom.ResponseCorrect(indxToPlot)==0|(BpodSystem.Data.Custom.InvalidResponseCorrect(indxToPlot)==0&BpodSystem.Data.Custom.ResponseCorrect(indxToPlot)~=1);
        Xdata = indxToPlot(ndxInc);
        Ydata = BpodSystem.Data.Custom.NoiseVolumeRescaled(indxToPlot); Ydata = Ydata(ndxInc);
        set(BpodSystem.GUIHandles.OutcomePlot.Incorrect, 'xdata', Xdata, 'ydata', Ydata);
        
        %Plot Broken Fixation
        ndxBroke = logical(BpodSystem.Data.Custom.BrokeFixation(indxToPlot));
        Xdata = indxToPlot(ndxBroke);
        Ydata = BpodSystem.Data.Custom.NoiseVolumeRescaled(indxToPlot);  Ydata=Ydata(ndxBroke);
        set(BpodSystem.GUIHandles.OutcomePlot.BrokeFix, 'xdata', Xdata, 'ydata', Ydata);
        
        %Plot Early Withdrawal
        ndxEarly = logical(BpodSystem.Data.Custom.EarlyWithdrawal(indxToPlot));
        Xdata = indxToPlot(ndxEarly);
        Ydata = BpodSystem.Data.Custom.NoiseVolumeRescaled(indxToPlot);  Ydata=Ydata(ndxEarly);
        set(BpodSystem.GUIHandles.OutcomePlot.EarlyWithdrawal, 'xdata', Xdata, 'ydata', Ydata);
        
        %Plot missed choice trials
        ndxMiss = isnan(BpodSystem.Data.Custom.ResponseCorrect(indxToPlot))&~ndxBroke&~ndxEarly;
        Xdata = indxToPlot(ndxMiss);
        Ydata = BpodSystem.Data.Custom.NoiseVolumeRescaled(indxToPlot); Ydata = Ydata(ndxMiss);
        set(BpodSystem.GUIHandles.OutcomePlot.NoResponse, 'xdata', Xdata, 'ydata', Ydata);
        
        %Plot NoFeedback trials
        ndxNoFeedback = (BpodSystem.Data.Custom.RewardReceivedCorrect(indxToPlot)+BpodSystem.Data.Custom.RewardReceivedError(indxToPlot))==0;
        Xdata = indxToPlot(ndxNoFeedback);
        Ydata = BpodSystem.Data.Custom.NoiseVolumeRescaled(indxToPlot); Ydata = Ydata(ndxNoFeedback);
        set(BpodSystem.GUIHandles.OutcomePlot.NoFeedback, 'xdata', Xdata, 'ydata', Ydata);
        
        %Plot Catch Trials
        ndxCatch = BpodSystem.Data.Custom.CatchTrial(indxToPlot)|(BpodSystem.Data.Custom.FeedbackDelayError(indxToPlot)==60&BpodSystem.Data.Custom.ResponseCorrect(indxToPlot)==0);
        Xdata = indxToPlot(ndxCatch&~ndxMiss&~ndxEarly);
        Ydata = BpodSystem.Data.Custom.NoiseVolumeRescaled(indxToPlot); Ydata = Ydata(ndxCatch&~ndxMiss&~ndxEarly);
        set(BpodSystem.GUIHandles.OutcomePlot.Catch, 'xdata', Xdata, 'ydata', Ydata);

        
        %Plot Skipped
        ndxSkippedCorrect=BpodSystem.Data.Custom.ResponseCorrect(indxToPlot)==1&(BpodSystem.Data.Custom.WaitingTime(indxToPlot)<BpodSystem.Data.Custom.FeedbackDelay(indxToPlot))&~BpodSystem.Data.Custom.CatchTrial(indxToPlot);
        if TaskParameters.GUI.CatchError
            ndxSkippedError=false(1,length(indxToPlot));
        else
            ndxSkippedError=BpodSystem.Data.Custom.ResponseCorrect(indxToPlot)==0&(BpodSystem.Data.Custom.WaitingTime(indxToPlot)<BpodSystem.Data.Custom.FeedbackDelayError((indxToPlot)))&~BpodSystem.Data.Custom.CatchTrial((indxToPlot));
        end
        ndxSkipped=ndxSkippedCorrect|ndxSkippedError;
        Xdata = indxToPlot(ndxSkipped&~ndxMiss&~ndxEarly);
        Ydata = BpodSystem.Data.Custom.NoiseVolumeRescaled(indxToPlot); Ydata = Ydata(ndxSkipped&~ndxMiss&~ndxEarly);
        set(BpodSystem.GUIHandles.OutcomePlot.SkippedFeedback, 'xdata', Xdata, 'ydata', Ydata);


              

        
        %% Psych Aud
        if TaskParameters.GUI.ShowPsycAud
            ndxNan = isnan(BpodSystem.Data.Custom.ResponseLeft);
            if sum(~ndxNan) > 5
                
                %binned according to evidence
                AudDV=BpodSystem.Data.Custom.NoiseVolumeRescaled(1:numel(BpodSystem.Data.Custom.ResponseLeft));
                %AudBins = 6;
                BinIdx = AudDV;%discretize(AudDV,linspace(-1,1,AudBins+1)*1.01);%unelegant! revise!
                PsycY = grpstats(BpodSystem.Data.Custom.ResponseLeft(~ndxNan),(BinIdx(~ndxNan)),'mean');
                PsycX = grpstats(BpodSystem.Data.Custom.NoiseVolumeRescaled(~ndxNan),(BinIdx(~ndxNan)),'mean');
                BpodSystem.GUIHandles.OutcomePlot.PsycAud.YData = PsycY;
                BpodSystem.GUIHandles.OutcomePlot.PsycAud.XData = PsycX;
                
                
                %fit
                BpodSystem.GUIHandles.OutcomePlot.PsycAudFit.XData = linspace(-1,1,100);
                mdl=fitglm(AudDV,BpodSystem.Data.Custom.ResponseLeft,'exclude',ndxNan,'distribution','binomial');
                BpodSystem.GUIHandles.OutcomePlot.PsycAudFit.YData = glmval(mdl.Coefficients.Estimate,BpodSystem.GUIHandles.OutcomePlot.PsycAudFit.XData,'logit');
            end
        end
        %% Vevaiometric
        if TaskParameters.GUI.ShowVevaiometric
            if TaskParameters.GUI.CatchError
                ndxError = BpodSystem.Data.Custom.ResponseCorrect(1:iTrial) == 0 ; %all (completed) error trials if caught
            else
                ndxError = BpodSystem.Data.Custom.CatchTrial(1:iTrial) & BpodSystem.Data.Custom.ResponseCorrect(1:iTrial) == 0;  %all (completed) error trials if caught
            end
            ndxCorrectCatch = BpodSystem.Data.Custom.CatchTrial(1:iTrial) & BpodSystem.Data.Custom.ResponseCorrect(1:iTrial) == 1; %only correct catch trials
            ndxMinWT = BpodSystem.Data.Custom.WaitingTime > 0;
            AudDV=BpodSystem.Data.Custom.NoiseVolumeRescaled(1:length(BpodSystem.Data.Custom.ResponseLeft));
            AudBins = 6;
            BinIdx = discretize(AudDV,linspace(-1,1,AudBins+1)*1.01);%unelegant! revise!
            WTerr = grpstats(BpodSystem.Data.Custom.WaitingTime(ndxError&ndxMinWT),BinIdx(ndxError&ndxMinWT),'mean')';
            WTcatch = grpstats(BpodSystem.Data.Custom.WaitingTime(ndxCorrectCatch&ndxMinWT),BinIdx(ndxCorrectCatch&ndxMinWT),'mean')';
            Xerr = grpstats(BpodSystem.Data.Custom.NoiseVolumeRescaled(ndxError&ndxMinWT),(BinIdx(ndxError&ndxMinWT)),'mean');
            Xcatch = grpstats(BpodSystem.Data.Custom.NoiseVolumeRescaled(ndxCorrectCatch&ndxMinWT),(BinIdx(ndxCorrectCatch&ndxMinWT)),'mean');
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricErr.YData = WTerr;
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricErr.XData = Xerr;
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricCatch.YData = WTcatch;
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricCatch.XData = Xcatch;
            
            %if TaskParameters.GUI.VevaiometricShowPoints          
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsErr.YData = BpodSystem.Data.Custom.WaitingTime(ndxError&ndxMinWT);
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsErr.XData = AudDV(ndxError&ndxMinWT);
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsCatch.YData = BpodSystem.Data.Custom.WaitingTime(ndxCorrectCatch&ndxMinWT);
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsCatch.XData = AudDV(ndxCorrectCatch&ndxMinWT);
            %             else
            %                 BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsErr.YData = -1;
            %                 BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsErr.XData = 0;
            %                 BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsCatch.YData = -1;
            %                 BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsCatch.XData = 0;
            %             end
        end
        %% Trial rate
        if TaskParameters.GUI.ShowTrialRate
            BpodSystem.GUIHandles.OutcomePlot.TrialRate.XData = (BpodSystem.Data.TrialStartTimestamp-min(BpodSystem.Data.TrialStartTimestamp))/60;
            BpodSystem.GUIHandles.OutcomePlot.TrialRate.YData = 1:numel(BpodSystem.Data.Custom.ResponseLeft);
        end
        if TaskParameters.GUI.ShowFix
            %% Stimulus delay
            cla(AxesHandles.HandleFix)
            BpodSystem.GUIHandles.OutcomePlot.HistBroke = histogram(AxesHandles.HandleFix,BpodSystem.Data.Custom.FixDur(BpodSystem.Data.Custom.BrokeFixation==1)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistBroke.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistBroke.EdgeColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistBroke.FaceColor = 'r';
            BpodSystem.GUIHandles.OutcomePlot.HistFix = histogram(AxesHandles.HandleFix,BpodSystem.Data.Custom.FixDur(~BpodSystem.Data.Custom.BrokeFixation==1)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistFix.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistFix.FaceColor = 'b';
            BpodSystem.GUIHandles.OutcomePlot.HistFix.EdgeColor = 'none';
            BreakP = mean(BpodSystem.Data.Custom.BrokeFixation);
            cornertext(AxesHandles.HandleFix,sprintf('P=%1.2f',BreakP))
        end
        %% SamplingTime
        if TaskParameters.GUI.ShowST
            cla(AxesHandles.HandleST)
            BpodSystem.GUIHandles.OutcomePlot.HistSTEarly = histogram(AxesHandles.HandleST,BpodSystem.Data.Custom.ST(BpodSystem.Data.Custom.EarlyWithdrawal==1)*1000);
            BpodSystem.GUIHandles.OutcomePlot.fcoHistSTEarly.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.FaceColor = 'r';
            BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.EdgeColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistST = histogram(AxesHandles.HandleST,BpodSystem.Data.Custom.ST(~BpodSystem.Data.Custom.EarlyWithdrawal==1)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistST.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistST.FaceColor = 'b';
            BpodSystem.GUIHandles.OutcomePlot.HistST.EdgeColor = 'none';
            EarlyP = sum(BpodSystem.Data.Custom.EarlyWithdrawal)/sum(~BpodSystem.Data.Custom.BrokeFixation);
            cornertext(AxesHandles.HandleST,sprintf('P=%1.2f',EarlyP))
        end
        %% Feedback delay (exclude catch trials and error trials, if set on catch)
        if TaskParameters.GUI.ShowFeedback
            cla(AxesHandles.HandleFeedback)
            ndxWaitedCorrect=BpodSystem.Data.Custom.ResponseCorrect==1&(BpodSystem.Data.Custom.WaitingTime>BpodSystem.Data.Custom.FeedbackDelay(1:iTrial))&~BpodSystem.Data.Custom.CatchTrial(1:iTrial);
            ndxSkippedCorrect=BpodSystem.Data.Custom.ResponseCorrect==1&(BpodSystem.Data.Custom.WaitingTime<BpodSystem.Data.Custom.FeedbackDelay(1:iTrial))&~BpodSystem.Data.Custom.CatchTrial(1:iTrial);

            if TaskParameters.GUI.CatchError
               ndxWaitedError=false(1,iTrial);
               ndxSkippedError=false(1,iTrial);
            else
                ndxWaitedError=BpodSystem.Data.Custom.ResponseCorrect==0&(BpodSystem.Data.Custom.WaitingTime>BpodSystem.Data.Custom.FeedbackDelayError(1:iTrial))&~BpodSystem.Data.Custom.CatchTrial(1:iTrial);
                ndxSkippedError=BpodSystem.Data.Custom.ResponseCorrect==0&(BpodSystem.Data.Custom.WaitingTime<BpodSystem.Data.Custom.FeedbackDelayError(1:iTrial))&~BpodSystem.Data.Custom.CatchTrial(1:iTrial);
            end
            ndxSkipped=ndxSkippedCorrect|ndxSkippedError;
            ndxWaited=ndxWaitedCorrect|ndxWaitedError;

            ndxLeft = BpodSystem.Data.Custom.ResponseLeft(1:iTrial)==1;
            ndxRight = BpodSystem.Data.Custom.ResponseLeft(1:iTrial)==0;

            BpodSystem.GUIHandles.OutcomePlot.HistNoFeed = histogram(AxesHandles.HandleFeedback,BpodSystem.Data.Custom.WaitingTime(ndxSkipped)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.EdgeColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.FaceColor = 'r';
            %BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.Normalization = 'probability';
            BpodSystem.GUIHandles.OutcomePlot.HistFeed = histogram(AxesHandles.HandleFeedback,BpodSystem.Data.Custom.WaitingTime(ndxWaited)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistFeed.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistFeed.EdgeColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistFeed.FaceColor = 'b';
            %BpodSystem.GUIHandles.OutcomePlot.HistFeed.Normalization = 'probability';
            LeftSkip = sum(ndxSkippedCorrect&ndxLeft)/sum((ndxSkippedCorrect|ndxWaitedCorrect)&ndxLeft);
            RightSkip = sum(ndxSkippedCorrect&ndxRight)/sum((ndxSkippedCorrect|ndxWaitedCorrect)&ndxRight);
            cornertext(AxesHandles.HandleFeedback,{sprintf('L=%1.2f',LeftSkip),sprintf('R=%1.2f',RightSkip)})
        end
        
        %if TaskParameters.GUI.ShowStaircase
        
        % end
        
end


end



function [mn,mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow)
FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
mn = max(round(CurrentTrial - FractionWindowStickpoint*nTrialsToShow),1);
mx = mn + nTrialsToShow - 1;
set(AxesHandle,'XLim',[mn-1 mx+1]);
end

function cornertext(h,str)
unit = get(h,'Units');
set(h,'Units','char');
pos = get(h,'Position');
if ~iscell(str)
    str = {str};
end
for i = 1:length(str)
    x = pos(1)+1;y = pos(2)+pos(4)-i;
    uicontrol(h.Parent,'Units','char','Position',[x,y,length(str{i})+1,1],'string',str{i},'style','text','background',[1,1,1],'FontSize',8);
end
set(h,'Units',unit);
end

function y=rescaleNoise(x,s)
global TaskParameters
global BpodSystem

signalVec=((s)-.5)*(-2);%1 when signal, -1 when  no signal
noiseMax=max(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);
noiseRange=max(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume)-min(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);

y=(x-noiseMax)./noiseRange.*signalVec;
ndxZero=y==0;
ndxSignal=BpodSystem.Data.Custom.EmbedSignal==1;
y(ndxZero&ndxSignal)=0.1;
y(ndxZero&~ndxSignal)=-0.1;


end

function y=inverseRescaleNoise(x)
global TaskParameters
global BpodSystem

noiseMax=max(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);
noiseRange=max(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume)-min(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);
y=(-abs(x)*noiseRange+noiseMax);

end


