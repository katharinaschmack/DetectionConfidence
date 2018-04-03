function MainPlot(AxesHandles, Action, varargin)
global nTrialsToShow %this is for convenience
global BpodSystem
global TaskParameters

switch Action
    case 'init'
        
        %% Outcome
        %initialize pokes plot
        nTrialsToShow = 90; %default number of trials to display
        
        if nargin >=3  %custom number of trials
            nTrialsToShow =varargin{1};
        end
        axes(AxesHandles.HandleOutcome);
        %plot in specified axes
        BpodSystem.GUIHandles.OutcomePlot.Aud = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge',[.5,.5,.5],'MarkerFace',[.7,.7,.7], 'MarkerSize',8);
        BpodSystem.GUIHandles.OutcomePlot.DV = line(1:numel(BpodSystem.Data.Custom.SignalVolume),BpodSystem.Data.Custom.SignalVolume, 'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','b', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCircle = line(1,0, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCross = line(1,0, 'LineStyle','none','Marker','+','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.CumRwd = text(1,1,'0mL','verticalalignment','bottom','horizontalalignment','center');
        BpodSystem.GUIHandles.OutcomePlot.Correct = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.Incorrect = line(-1,1, 'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.BrokeFix = line(-1,0, 'LineStyle','none','Marker','d','MarkerEdge','b','MarkerFace','none', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.EarlyWithdrawal = line(-1,0, 'LineStyle','none','Marker','d','MarkerEdge','none','MarkerFace','b', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.NoFeedback = line(-1,0, 'LineStyle','none','Marker','o','MarkerEdge','none','MarkerFace','w', 'MarkerSize',5);
        BpodSystem.GUIHandles.OutcomePlot.NoResponse = line(-1,[0 1], 'LineStyle','none','Marker','x','MarkerEdge','w','MarkerFace','none', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.LightOff = line(-1,[0 1], 'LineStyle','none','Marker','p','MarkerEdge','m','MarkerFace','none', 'MarkerSize',20);
                
        %BpodSystem.GUIHandles.OutcomePlot.Catch = line(-1,[0 1], 'LineStyle','none','Marker','o','MarkerEdge',[0,0,0],'MarkerFace',[0,0,0], 'MarkerSize',4);
         set(AxesHandles.HandleOutcome,'TickDir', 'out','XLim',[0, nTrialsToShow],'YLim', [-5, 65], 'YTick', [0:20:60],'YTickLabel', {' 0dB','20dB','40dB','60dB'}, 'FontSize', 13);
        %set(BpodSystem.GUIHandles.OutcomePlot.Aud,'xdata',find(BpodSystem.Data.Custom.AuditoryTrial),'ydata',BpodSystem.Data.Custom.SignalVolume(BpodSystem.Data.Custom.AuditoryTrial));
        xlabel(AxesHandles.HandleOutcome, 'Trial#', 'FontSize', 14);
        hold(AxesHandles.HandleOutcome, 'on');
        %% Psyc Auditory
        BpodSystem.GUIHandles.OutcomePlot.PsycAud = line(AxesHandles.HandlePsycAud,[-1 1],[.5 .5], 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',6,'Visible','off');
        BpodSystem.GUIHandles.OutcomePlot.PsycAudFit = line(AxesHandles.HandlePsycAud,[-1. 1.],[.5 .5],'color','k','Visible','off');
        AxesHandles.HandlePsycAud.YLim = [-.05 1.05];
        AxesHandles.HandlePsycAud.XLim = [0, 60];
        AxesHandles.HandlePsycAud.XLabel.String = 'Signal intensity (dB)'; % FIGURE OUT UNIT
        AxesHandles.HandlePsycAud.YLabel.String = '% left';
        AxesHandles.HandlePsycAud.Title.String = 'Psychometric Aud';
        %% Vevaiometric curve
        hold(AxesHandles.HandleVevaiometric,'on')
        BpodSystem.GUIHandles.OutcomePlot.VevaiometricCatch = line(AxesHandles.HandleVevaiometric,-2,-1, 'LineStyle','-','Color','g','Visible','off','LineWidth',2);
        BpodSystem.GUIHandles.OutcomePlot.VevaiometricErr = line(AxesHandles.HandleVevaiometric,-2,-1, 'LineStyle','-','Color','r','Visible','off','LineWidth',2);
        BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsErr = line(AxesHandles.HandleVevaiometric,-2,-1, 'LineStyle','none','Color','r','Marker','o','MarkerFaceColor','r', 'MarkerSize',2,'Visible','off','MarkerEdgeColor','r');
        BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsCatch = line(AxesHandles.HandleVevaiometric,-2,-1, 'LineStyle','none','Color','g','Marker','o','MarkerFaceColor','g', 'MarkerSize',2,'Visible','off','MarkerEdgeColor','g');
        AxesHandles.HandleVevaiometric.YLim = [0 10];
        AxesHandles.HandleVevaiometric.XLim = [0, 60];
        AxesHandles.HandleVevaiometric.XLabel.String = 'Signal intensity (dB)';
        AxesHandles.HandleVevaiometric.YLabel.String = 'WT (s)';
        AxesHandles.HandleVevaiometric.Title.String = 'Vevaiometric';
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
        %% ST histogram
        hold(AxesHandles.HandleST,'on')
        AxesHandles.HandleST.XLabel.String = 'Time (ms)';
        AxesHandles.HandleST.YLabel.String = 'trial counts';
        AxesHandles.HandleST.Title.String = 'Stim sampling time';
        %% Feedback Delay histogram
        hold(AxesHandles.HandleFeedback,'on')
        AxesHandles.HandleFeedback.XLabel.String = 'Time (ms)';
        AxesHandles.HandleFeedback.YLabel.String = 'trial counts';
        AxesHandles.HandleFeedback.Title.String = 'Feedback delay';
        %% Light Guidance rate
        hold(AxesHandles.HandleLightGuidance,'on')
        BpodSystem.GUIHandles.OutcomePlot.LightGuidance = line(AxesHandles.HandleLightGuidance,[0],[0], 'LineStyle','-','Color','k','Visible','off'); %#ok<NBRAK>
        AxesHandles.HandleLightGuidance.XLabel.String = 'trials'; % FIGURE OUT UNIT
        AxesHandles.HandleLightGuidance.YLabel.String = 'light guidance (%)';
        AxesHandles.HandleLightGuidance.Title.String = 'Light Guidance';
        %% Stimulus Time
        hold(AxesHandles.HandleStimDuration,'on')
        BpodSystem.GUIHandles.OutcomePlot.StimDuration = line(AxesHandles.HandleStimDuration,[0],[0], 'LineStyle','-','Color','k','Visible','off'); %#ok<NBRAK>
        AxesHandles.HandleStimDuration.XLabel.String = 'trials'; % FIGURE OUT UNIT
        AxesHandles.HandleStimDuration.YLabel.String = 'stimulus time (ms)';
        AxesHandles.HandleStimDuration.Title.String = 'Stimulus Time';

        
    case 'update'
        %% Reposition and hide/show axes
        ShowPlots = [TaskParameters.GUI.ShowPsycAud,TaskParameters.GUI.ShowVevaiometric,...
            TaskParameters.GUI.ShowTrialRate,TaskParameters.GUI.ShowFix,TaskParameters.GUI.ShowST,TaskParameters.GUI.ShowFeedback,TaskParameters.GUI.ShowLightGuidance,TaskParameters.GUI.ShowStimDuration];
        NoPlots = sum(ShowPlots);
        NPlot = cumsum(ShowPlots);
        if ShowPlots(1)
            BpodSystem.GUIHandles.OutcomePlot.HandlePsycAud.Position =      [NPlot(1)*.05+0.005 + (NPlot(1)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            BpodSystem.GUIHandles.OutcomePlot.HandlePsycAud.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandlePsycAud,'Children'),'Visible','on');
        else
            BpodSystem.GUIHandles.OutcomePlot.HandlePsycAud.Visible = 'off';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandlePsycAud,'Children'),'Visible','off');
        end
        if ShowPlots(2)
            BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric.Position = [NPlot(2)*.05+0.005 + (NPlot(2)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric,'Children'),'Visible','on');
        else
            BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric.Visible = 'off';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric,'Children'),'Visible','off');
        end
        if ShowPlots(3)
            BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate.Position =    [NPlot(3)*.05+0.005 + (NPlot(3)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate,'Children'),'Visible','on');
        else
            BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate.Visible = 'off';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate,'Children'),'Visible','off');
        end
        if ShowPlots(4)
            BpodSystem.GUIHandles.OutcomePlot.HandleFix.Position =          [NPlot(4)*.05+0.005 + (NPlot(4)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            BpodSystem.GUIHandles.OutcomePlot.HandleFix.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleFix,'Children'),'Visible','on');
        else
            BpodSystem.GUIHandles.OutcomePlot.HandleFix.Visible = 'off';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleFix,'Children'),'Visible','off');
        end
        if ShowPlots(5)
            BpodSystem.GUIHandles.OutcomePlot.HandleST.Position =           [NPlot(5)*.05+0.005 + (NPlot(5)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            BpodSystem.GUIHandles.OutcomePlot.HandleST.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleST,'Children'),'Visible','on');
        else
            BpodSystem.GUIHandles.OutcomePlot.HandleST.Visible = 'off';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleST,'Children'),'Visible','off');
        end
        if ShowPlots(6)
            BpodSystem.GUIHandles.OutcomePlot.HandleFeedback.Position =     [NPlot(6)*.05+0.005 + (NPlot(6)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            BpodSystem.GUIHandles.OutcomePlot.HandleFeedback.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleFeedback,'Children'),'Visible','on');
        else
            BpodSystem.GUIHandles.OutcomePlot.HandleFeedback.Visible = 'off';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleFeedback,'Children'),'Visible','off');
        end
        if ShowPlots(7)
            BpodSystem.GUIHandles.OutcomePlot.HandleLightGuidance.Position =     [NPlot(7)*.05+0.005 + (NPlot(7)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            BpodSystem.GUIHandles.OutcomePlot.HandleLightGuidance.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleLightGuidance,'Children'),'Visible','on');
        else
            BpodSystem.GUIHandles.OutcomePlot.HandleLightGuidance.Visible = 'off';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleLightGuidance,'Children'),'Visible','off');
        end
        
        if ShowPlots(8)
            BpodSystem.GUIHandles.OutcomePlot.HandleStimDuration.Position =     [NPlot(8)*.05+0.005 + (NPlot(8)-1)*1/(1.65*NoPlots)    .6   1/(1.65*NoPlots) 0.3];
            BpodSystem.GUIHandles.OutcomePlot.HandleStimDuration.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleStimDuration,'Children'),'Visible','on');
        else
            BpodSystem.GUIHandles.OutcomePlot.HandleStimDuration.Visible = 'off';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleStimDuration,'Children'),'Visible','off');
        end

        
        %% Outcome
        iTrial = varargin{1};
        [mn, ~] = rescaleX(AxesHandles.HandleOutcome,iTrial,nTrialsToShow); % recompute xlim
        
        set(BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCircle, 'xdata', iTrial+1, 'ydata', 0);
        set(BpodSystem.GUIHandles.OutcomePlot.CurrentTrialCross, 'xdata', iTrial+1, 'ydata', 0);
        
        %plot modality background
        %         set(BpodSystem.GUIHandles.OutcomePlot.Aud,'xdata',find(BpodSystem.Data.Custom.AuditoryTrial),'ydata',BpodSystem.Data.Custom.SignalVolume(BpodSystem.Data.Custom.AuditoryTrial));
        %plot past&future trials
        set(BpodSystem.GUIHandles.OutcomePlot.DV, 'xdata', mn:numel(BpodSystem.Data.Custom.SignalVolume), 'ydata',BpodSystem.Data.Custom.SignalVolume(mn:end));
        
        %Plot past trial outcomes
        indxToPlot = mn:iTrial;
        RewardReceivedTotal = sum(BpodSystem.Data.Custom.RewardReceivedCenter +...
                    BpodSystem.Data.Custom.RewardReceivedError  + ...
                    BpodSystem.Data.Custom.RewardReceivedCorrect);

        set(BpodSystem.GUIHandles.OutcomePlot.CumRwd, 'position', [iTrial+1 1], 'string', ...
            [num2str(RewardReceivedTotal/1000) ' mL']);

        %Plot Correct
        ndxCor = BpodSystem.Data.Custom.ResponseCorrect(indxToPlot)==1;
        Xdata = indxToPlot(ndxCor);
        Ydata = BpodSystem.Data.Custom.SignalVolume(indxToPlot); Ydata = Ydata(ndxCor);
        set(BpodSystem.GUIHandles.OutcomePlot.Correct, 'xdata', Xdata, 'ydata', Ydata);
        %Plot Incorrect
        ndxInc = BpodSystem.Data.Custom.ResponseCorrect(indxToPlot)==0;
        Xdata = indxToPlot(ndxInc);
        Ydata = BpodSystem.Data.Custom.SignalVolume(indxToPlot); Ydata = Ydata(ndxInc);
        set(BpodSystem.GUIHandles.OutcomePlot.Incorrect, 'xdata', Xdata, 'ydata', Ydata);
        %Plot Broken Fixation
        ndxBroke = BpodSystem.Data.Custom.BrokeFixation(indxToPlot);
        Xdata = indxToPlot(ndxBroke); Ydata = zeros(1,sum(ndxBroke))+60;
        set(BpodSystem.GUIHandles.OutcomePlot.BrokeFix, 'xdata', Xdata, 'ydata', Ydata);
        %Plot Early Withdrawal
        ndxEarly = BpodSystem.Data.Custom.EarlyWithdrawal(indxToPlot);
        Xdata = indxToPlot(ndxEarly);
        Ydata = zeros(1,sum(ndxEarly))+60;
        set(BpodSystem.GUIHandles.OutcomePlot.EarlyWithdrawal, 'xdata', Xdata, 'ydata', Ydata);
        %Plot missed choice trials
        ndxMiss = isnan(BpodSystem.Data.Custom.ResponseCorrect(indxToPlot))&~ndxBroke&~ndxEarly;
        Xdata = indxToPlot(ndxMiss);
        Ydata = BpodSystem.Data.Custom.SignalVolume(indxToPlot); Ydata = Ydata(ndxMiss);
        set(BpodSystem.GUIHandles.OutcomePlot.NoResponse, 'xdata', Xdata, 'ydata', Ydata);
        %Plot NoFeedback trials
        ndxNoFeedback = (BpodSystem.Data.Custom.RewardReceivedCorrect(indxToPlot)+BpodSystem.Data.Custom.RewardReceivedError(indxToPlot))==0;
        Xdata = indxToPlot(ndxNoFeedback&~ndxMiss);
        Ydata = BpodSystem.Data.Custom.SignalVolume(indxToPlot); Ydata = Ydata(ndxNoFeedback&~ndxMiss);
        set(BpodSystem.GUIHandles.OutcomePlot.NoFeedback, 'xdata', Xdata, 'ydata', Ydata);
        %Plot light guidance trials
        ndxLightGuidance = BpodSystem.Data.Custom.ErrorPortLightIntensity(indxToPlot)==0&~ndxBroke&~ndxEarly;
        Xdata = indxToPlot(ndxLightGuidance);
        Ydata = BpodSystem.Data.Custom.SignalVolume(indxToPlot); Ydata = Ydata(ndxLightGuidance);
        set(BpodSystem.GUIHandles.OutcomePlot.LightOff, 'xdata', Xdata, 'ydata', Ydata);

%         %Plot Catch Trials
%         ndxCatch = BpodSystem.Data.Custom.CatchTrial(indxToPlot);
%         Xdata = indxToPlot(ndxCatch&~ndxMiss);
%         Ydata = BpodSystem.Data.Custom.SignalVolume(indxToPlot); Ydata = Ydata(ndxCatch&~ndxMiss);
%         set(BpodSystem.GUIHandles.OutcomePlot.Catch, 'xdata', Xdata, 'ydata', Ydata);        
       % Psych Aud
        if TaskParameters.GUI.ShowPsycAud
            AudDV = BpodSystem.Data.Custom.SignalVolume(1:numel(BpodSystem.Data.Custom.ResponseLeft));
            %ndxAud = BpodSystem.Data.Custom.AuditoryTrial(1:numel(BpodSystem.Data.Custom.ResponseLeft));
            ndxNan = isnan(BpodSystem.Data.Custom.ResponseLeft);
            AudBin = 6;
            BinIdx = discretize(AudDV,linspace(0,60,AudBin+1));
            PsycY = grpstats(BpodSystem.Data.Custom.ResponseLeft(~ndxNan),BinIdx(~ndxNan),'mean');
            PsycX = (unique(BinIdx(~ndxNan))/AudBin*60);
            BpodSystem.GUIHandles.OutcomePlot.PsycAud.YData = PsycY;
            BpodSystem.GUIHandles.OutcomePlot.PsycAud.XData = PsycX;
            if sum(~ndxNan) > 1
                BpodSystem.GUIHandles.OutcomePlot.PsycAudFit.XData = linspace(min(AudDV(~ndxNan)),max(AudDV(~ndxNan)),100);
                BpodSystem.GUIHandles.OutcomePlot.PsycAudFit.YData = glmval(glmfit(AudDV(~ndxNan),...
                    BpodSystem.Data.Custom.ResponseLeft(~ndxNan)','binomial'),linspace(min(AudDV(~ndxNan)),max(AudDV(~ndxNan)),100),'logit');
            end
        end
        %% Vevaiometric
        if TaskParameters.GUI.ShowVevaiometric
            ndxError = BpodSystem.Data.Custom.ResponseCorrect(1:iTrial) == 0 ; %all (completed) error trials (including catch errors)
            ndxCorrectCatch = BpodSystem.Data.Custom.CatchTrial(1:iTrial) & BpodSystem.Data.Custom.ResponseCorrect(1:iTrial) == 1; %only correct catch trials
            ndxMinWT = BpodSystem.Data.Custom.WaitingTime > 2;%TaskParameters.GUI.VevaiometricMinWT;
            DV = BpodSystem.Data.Custom.SignalVolume(1:iTrial);
            DVNBin = 6;%TaskParameters.GUI.VevaiometricNBin;
            BinIdx = discretize(DV,linspace(0,60,DVNBin+1));
            WTerr = grpstats(BpodSystem.Data.Custom.WaitingTime(ndxError&ndxMinWT),BinIdx(ndxError&ndxMinWT),'mean')';
            WTcatch = grpstats(BpodSystem.Data.Custom.WaitingTime(ndxCorrectCatch&ndxMinWT),BinIdx(ndxCorrectCatch&ndxMinWT),'mean')';
            Xerr = unique(BinIdx(ndxError&ndxMinWT))/DVNBin*60;
            Xcatch = unique(BinIdx(ndxCorrectCatch&ndxMinWT))/DVNBin*60;
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricErr.YData = WTerr;
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricErr.XData = Xerr;
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricCatch.YData = WTcatch;
            BpodSystem.GUIHandles.OutcomePlot.VevaiometricCatch.XData = Xcatch;
            %if TaskParameters.GUI.VevaiometricShowPoints
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsErr.YData = BpodSystem.Data.Custom.WaitingTime(ndxError&ndxMinWT);
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsErr.XData = DV(ndxError&ndxMinWT);
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsCatch.YData = BpodSystem.Data.Custom.WaitingTime(ndxCorrectCatch&ndxMinWT);
                BpodSystem.GUIHandles.OutcomePlot.VevaiometricPointsCatch.XData = DV(ndxCorrectCatch&ndxMinWT);
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
            BpodSystem.GUIHandles.OutcomePlot.HistBroke = histogram(AxesHandles.HandleFix,BpodSystem.Data.Custom.FixDur(BpodSystem.Data.Custom.BrokeFixation)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistBroke.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistBroke.EdgeColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistBroke.FaceColor = 'r';
            BpodSystem.GUIHandles.OutcomePlot.HistFix = histogram(AxesHandles.HandleFix,BpodSystem.Data.Custom.FixDur(~BpodSystem.Data.Custom.BrokeFixation)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistFix.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistFix.FaceColor = 'b';
            BpodSystem.GUIHandles.OutcomePlot.HistFix.EdgeColor = 'none';
            BreakP = mean(BpodSystem.Data.Custom.BrokeFixation);
            cornertext(AxesHandles.HandleFix,sprintf('P=%1.2f',BreakP))
        end
        %% SamplingTime
        if TaskParameters.GUI.ShowST
            cla(AxesHandles.HandleST)
            BpodSystem.GUIHandles.OutcomePlot.HistSTEarly = histogram(AxesHandles.HandleST,BpodSystem.Data.Custom.ST(BpodSystem.Data.Custom.EarlyWithdrawal)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.FaceColor = 'r';
            BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.EdgeColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistST = histogram(AxesHandles.HandleST,BpodSystem.Data.Custom.ST(~BpodSystem.Data.Custom.EarlyWithdrawal)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistST.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistST.FaceColor = 'b';
            BpodSystem.GUIHandles.OutcomePlot.HistST.EdgeColor = 'none';
            EarlyP = sum(BpodSystem.Data.Custom.EarlyWithdrawal)/sum(~BpodSystem.Data.Custom.BrokeFixation);
            cornertext(AxesHandles.HandleST,sprintf('P=%1.2f',EarlyP))
        end
        %% Feedback delay (exclude catch trials and error trials, if set on catch)
        if TaskParameters.GUI.ShowFeedback
            cla(AxesHandles.HandleFeedback)
%             if TaskParameters.GUI.CatchError
%                 ndxExclude = BpodSystem.Data.Custom.ResponseCorrect(1:iTrial) == 0; %exclude error trials if they are set on catch
%             else
%                 ndxExclude = false(1,iTrial);
%             end
            ndxReward = BpodSystem.Data.Custom.RewardReceivedCorrect(1:iTrial)>0|BpodSystem.Data.Custom.RewardReceivedError(1:iTrial)>0;
            ndxCatch = BpodSystem.Data.Custom.CatchTrial(1:iTrial);
            ndxLeft = BpodSystem.Data.Custom.ResponseLeft(1:iTrial)==1;
            ndxNan = isnan(BpodSystem.Data.Custom.ResponseLeft);
            BpodSystem.GUIHandles.OutcomePlot.HistNoFeed = histogram(AxesHandles.HandleFeedback,BpodSystem.Data.Custom.WaitingTime(~ndxReward&~ndxCatch&~ndxNan)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.EdgeColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.FaceColor = 'r';
            %BpodSystem.GUIHandles.OutcomePlot.HistNoFeed.Normalization = 'probability';
            BpodSystem.GUIHandles.OutcomePlot.HistFeed = histogram(AxesHandles.HandleFeedback,BpodSystem.Data.Custom.WaitingTime(ndxReward&~ndxCatch&~ndxNan)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistFeed.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistFeed.EdgeColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistFeed.FaceColor = 'b';
            %BpodSystem.GUIHandles.OutcomePlot.HistFeed.Normalization = 'probability';
            LeftSkip = sum(~ndxReward&~ndxCatch&ndxLeft&~ndxNan)/sum(~ndxCatch&ndxLeft&~ndxNan);
            RightSkip = sum(~ndxReward&~ndxCatch&ndxLeft&~ndxNan)/sum(~ndxCatch&~ndxLeft&~ndxNan);
            cornertext(AxesHandles.HandleFeedback,{sprintf('L=%1.2f',LeftSkip),sprintf('R=%1.2f',RightSkip)})
        end
        
        if TaskParameters.GUI.ShowLightGuidance
            ndxCoutEarly=BpodSystem.Data.Custom.CoutEarly;
            BpodSystem.GUIHandles.OutcomePlot.LightGuidance.XData = 1:numel(BpodSystem.Data.Custom.LightGuidance(~ndxCoutEarly));
            BpodSystem.GUIHandles.OutcomePlot.LightGuidance.YData = BpodSystem.Data.Custom.LightGuidance(~ndxCoutEarly);
        end
        
        if TaskParameters.GUI.ShowStimDuration
            BpodSystem.GUIHandles.OutcomePlot.StimDuration.XData = 1:numel(BpodSystem.Data.Custom.StimDuration);
            BpodSystem.GUIHandles.OutcomePlot.StimDuration.YData = BpodSystem.Data.Custom.StimDuration;
        end


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

