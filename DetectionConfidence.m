function DetectionConfidence()
% Script for training and performing mice a detection in noise task with
% confidence reports

global BpodSystem
global TaskParameters
%global StimulusSettings

%% Task parameters
TaskParameters = BpodSystem.ProtocolSettings;
if isempty(fieldnames(TaskParameters))
    %general
    TaskParameters.GUI.Ports_LMR = '123'; %Port IDs signal center noise
    TaskParameters.GUI.AfterTrialInterval = .5; %DurAfterTrialIntervalon of after trial interval before next trial starts(s)
    TaskParameters.GUI.AfterTrialIntervalJitter = true; %Exponential jitter for after trial interval
    TaskParameters.GUI.AfterTrialIntervalMin = .1;%Minimum for jitter
    TaskParameters.GUI.AfterTrialIntervalMax = 2.5;%Maximum for jitter
    TaskParameters.GUIMeta.AfterTrialIntervalJitter.Style = 'checkbox';
    TaskParameters.GUI.LightGuidance = true;%LED ports indicate active ports, if false LED ports remain on when active
    TaskParameters.GUIMeta.LightGuidance.Style = 'checkbox';
    
    TaskParameters.GUIPanels.General = {'Ports_LMR','AfterTrialInterval','AfterTrialIntervalJitter','AfterTrialIntervalMin','AfterTrialIntervalMax','LightGuidance'};
    
    %sampling period: events, duration and reinforcement for duration
    TaskParameters.GUI.DecisionVariable=2;
    TaskParameters.GUIMeta.DecisionVariable.Style = 'popupmenu';
    TaskParameters.GUIMeta.DecisionVariable.String = {'discrete','continuous'};
    TaskParameters.GUI.BetaParam=0.1;
    
    TaskParameters.GUI.NoiseVolumeTable.NoiseVolume=[20 40 60]';
    TaskParameters.GUI.NoiseVolumeTable.SignalVolume=[50 45 40]';
    TaskParameters.GUI.NoiseVolumeTable.Prob=[1 1 1]';
    
    TaskParameters.GUIMeta.NoiseVolumeTable.Style = 'table';
    TaskParameters.GUIMeta.NoiseVolumeTable.String = 'Noise volumes';
    TaskParameters.GUIMeta.NoiseVolumeTable.ColumnLabel = {'noise','signal','probabilty'};
    
    TaskParameters.GUI.ContinuousTable.NoiseLimits=[35 50]';
    TaskParameters.GUI.ContinuousTable.SignalLimits=[45 30]';
    
    TaskParameters.GUIMeta.ContinuousTable.Style = 'table';
    TaskParameters.GUIMeta.ContinuousTable.String = 'Decision variable';
    TaskParameters.GUIMeta.ContinuousTable.ColumnLabel = {'noiseLims','signalLims'};
    
    
    TaskParameters.GUI.EasyTrials=20;
    TaskParameters.GUI.StimDuration=0.1;
    TaskParameters.GUIPanels.Stimulus = {'DecisionVariable','BetaParam','EasyTrials','StimDuration'};
    TaskParameters.GUIPanels.NoiseVolumeTable ={'NoiseVolumeTable'};
    TaskParameters.GUIPanels.ContinuousTable ={'ContinuousTable'};
    
    TaskParameters.GUI.PreStimDurationSelection = 3;
    TaskParameters.GUIMeta.PreStimDurationSelection.Style = 'popupmenu';
    TaskParameters.GUIMeta.PreStimDurationSelection.String = {'Fix','AutoIncr','TruncExp'};
    TaskParameters.GUI.PreStimDurationTau = 0.2;
    
    TaskParameters.GUI.PreStimDurationMin = 0.05;%minimum sample time required for reward will not decrease further (0.05 in Marion's script)
    TaskParameters.GUI.PreStimDuration = TaskParameters.GUI.PreStimDurationMin;
    TaskParameters.GUIMeta.PreStimDuration.Style = 'text';
    TaskParameters.GUI.PreStimDurationMax = .5; %sample time required for reward will not increase further (0.5)
    TaskParameters.GUI.PreStimDurationRampUp = 0.01;
    TaskParameters.GUI.PreStimDurationRampDown = 0.005;
    TaskParameters.GUI.RewardAmountCenter = 0.5;%reward amount center ports (marion .5)
    
    TaskParameters.GUI.RewardAmountCenterSelection = 2;
    TaskParameters.GUIMeta.RewardAmountCenterSelection.Style = 'text';
    TaskParameters.GUIMeta.RewardAmountCenterSelection.Style = 'popupmenu';
    TaskParameters.GUIMeta.RewardAmountCenterSelection.String = {'Fix','Decrease'};
    TaskParameters.GUI.RewardAmountCenterEasyTrials = 50;
    
    
    TaskParameters.GUI.CoutEarlyTimeout = 0;%time out for early withdrawal (marion 1s)
    TaskParameters.GUIPanels.Timing = {'PreStimDuration',...
        'PreStimDurationSelection','PreStimDurationMin','PreStimDurationMax','PreStimDurationRampUp','PreStimDurationRampDown','PreStimDurationTau'};
    
    TaskParameters.GUIPanels.Sampling = {'RewardAmountCenter',...
        'RewardAmountCenterSelection','RewardAmountCenterEasyTrials','CoutEarlyTimeout'};
    
    %Choice
    TaskParameters.GUI.ChoiceDeadline = 5; %Maximal Interval for choice after stimulus presentAfterTrialIntervalon
    TaskParameters.GUI.BiasCorrection = 4;
    TaskParameters.GUIMeta.BiasCorrection.Style = 'popupmenu';
    TaskParameters.GUIMeta.BiasCorrection.String = {'None','BruteForce','Soft','PerLevel'};%BruteForce: presents the same stimulus until a correct choice is made, then resumes stimulus sequence; Soft: calculates bias over all trials and presents non-prefered stimulus with p=1-bias.
    TaskParameters.GUI.RewardAmountCorrect = 5;%reward amount lateral ports (marion 5)
    TaskParameters.GUI.RewardAmountError = 0;%reward amount lateral ports (marion 5)
    TaskParameters.GUI.ErrorTimeout = 0;%time out for errors
    TaskParameters.GUIPanels.Choice = {'ChoiceDeadline','BiasCorrection','RewardAmountCorrect','RewardAmountError','ErrorTimeout'};%,'Deplete','DepleteRate','Jackpot','JackpotMin','JackpotTime'};
    
    %Feedback delay %UPDATE TO GRAY OUT IRRELEVANT FIELDS
    TaskParameters.GUI.FeedbackDelaySelection = 1;
    TaskParameters.GUIMeta.FeedbackDelaySelection.Style = 'popupmenu';
    TaskParameters.GUIMeta.FeedbackDelaySelection.String = {'Fix','AutoIncr','TruncExp'};
    TaskParameters.GUI.FeedbackDelayMin = 0;
    TaskParameters.GUI.FeedbackDelayMax = 0;
    TaskParameters.GUI.FeedbackDelayIncr = 0.01;
    TaskParameters.GUI.FeedbackDelayDecr = 0.01;
    TaskParameters.GUI.FeedbackDelayTau = 0.05;
    TaskParameters.GUI.FeedbackDelayGrace = 0;
    TaskParameters.GUI.PercentCatch = 0;
    TaskParameters.GUI.CatchError = false;
    TaskParameters.GUIMeta.CatchError.Style = 'checkbox';
    TaskParameters.GUI.FeedbackDelay = TaskParameters.GUI.FeedbackDelayMin;
    TaskParameters.GUIMeta.FeedbackDelay.Style = 'text';
    TaskParameters.GUI.StartNoCatchTrials = 20;
    TaskParameters.GUI.SkippedCorrectCorrection = 1;
    TaskParameters.GUIMeta.SkippedCorrectCorrection.Style = 'popupmenu';
    TaskParameters.GUIMeta.SkippedCorrectCorrection.String = {'None','RepeatSkipped','RepeatSkippedCatch'};%BruteForce: presents the same stimulus until a correct choice is made, then resumes stimulus sequence; Soft: calculates bias over all trials and presents non-prefered stimulus with p=1-bias.
    TaskParameters.GUIPanels.FeedbackDelay = {'FeedbackDelay','FeedbackDelaySelection','FeedbackDelayMin','FeedbackDelayMax','FeedbackDelayIncr','FeedbackDelayDecr','FeedbackDelayTau',...
        'FeedbackDelayGrace','PercentCatch','CatchError','StartNoCatchTrials','SkippedCorrectCorrection'};
    
    %Plot
    TaskParameters.GUI.ShowPsycAud = 1;
    TaskParameters.GUIMeta.ShowPsycAud.Style = 'checkbox';
    TaskParameters.GUI.ShowVevaiometric = 1;
    TaskParameters.GUIMeta.ShowVevaiometric.Style = 'checkbox';
    TaskParameters.GUI.ShowTrialRate = 1;
    TaskParameters.GUIMeta.ShowTrialRate.Style = 'checkbox';
    TaskParameters.GUI.ShowFix = 1;
    TaskParameters.GUIMeta.ShowFix.Style = 'checkbox';
    TaskParameters.GUI.ShowST = 1;
    TaskParameters.GUIMeta.ShowST.Style = 'checkbox';
    TaskParameters.GUI.ShowFix = 1;
    TaskParameters.GUIMeta.ShowFix.Style = 'checkbox';
    TaskParameters.GUI.ShowST = 1;
    TaskParameters.GUIMeta.ShowST.Style = 'checkbox';
    TaskParameters.GUI.ShowFeedback = 1;
    TaskParameters.GUIMeta.ShowFeedback.Style = 'checkbox';
    TaskParameters.GUIPanels.ShowPlots = {'ShowPsycAud','ShowVevaiometric','ShowTrialRate','ShowFix','ShowST','ShowFeedback'};
    
    TaskParameters.GUIPanels.Photometry = {'LED1_amp', 'LED2_amp', 'PhotometryOn', 'LED1_f', 'LED2_f','PostTrialRecording'};
    TaskParameters.GUI.LED1_amp = 2.5;
    TaskParameters.GUI.LED2_amp = 2.5;
    TaskParameters.GUI.PhotometryOn = 0;
    TaskParameters.GUI.LED1_f = 0;%531
    TaskParameters.GUI.LED2_f = 0;%211
    TaskParameters.GUI.PostTrialRecording = 2;%sets Time that will be recorded after trial end
    
    TaskParameters.Figures.OutcomePlot.Position = [0, 600, 1000, 400];
    
    TaskParameters.GUITabs.General = {'General','Photometry'};
    TaskParameters.GUITabs.Stimulus = {'Stimulus','NoiseVolumeTable','ContinuousTable'};
    TaskParameters.GUITabs.Timing = {'Timing'};
    TaskParameters.GUITabs.Feedback = {'Sampling','Choice','FeedbackDelay'};
    TaskParameters.GUITabs.Plots = {'ShowPlots'};
    TaskParameters.GUI = orderfields(TaskParameters.GUI);
    
end
%% SHUJINGS CODE, not sure whether I need this, answer: yes, I do!
BpodParameterGUI('init', TaskParameters);
BpodSystem.Pause = 1;
HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
TaskParameters = BpodParameterGUI('sync', TaskParameters); % Sync parameters with BpodParameterGUI plugin
BpodSystem.ProtocolSettings = TaskParameters; % copy settings back prior to saving
SaveBpodProtocolSettings;

%server data
[~,BpodSystem.Data.Custom.Rig] = system('hostname');
[~,BpodSystem.Data.Custom.Subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.DataPath))));
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler';


%% init photometry raster function handle
%     prfh = str2func(S.GUI.PhotometryRasterFcn); %for being flexible, just
%     choose one for now

%% Initialize NIDAQ
TaskParameters.nidaq.duration = 120;
TaskParameters.nidaq.IsContinuous = true;
TaskParameters.nidaq.updateInterval = 0.1; % save new data every n seconds
BpodSystem.PluginObjects.Photometry.baselinePeriod = [0 1]; % kludge, FS
startX = 0; % 0 defined as time from cue (because reward time can be variable depending upon outcomedelay)
BpodSystem.ProtocolSettings = TaskParameters; % copy settings back because syncPhotometrySettings relies upon BpodSystem.ProtocolSettings
if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
    TaskParameters = initPhotometry(TaskParameters);
end
%% photometry plots
if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
    updatePhotometryPlot('init');
    %         prfh('init', 'baselinePeriod', [1 S.PreCsRecording])
end
%% lick rasters for cs1 and cs2 ADD LATER
PhotometryRasterFcnList = {'lickNoLick_Sound_PhotometryRasters', 'LNL_Sound_pRasters_3Sounds', 'LNL_pRasters_bySound'};
BpodSystem.ProtocolFigures.lickRaster.fig = ensureFigure('lick_raster', 1);
BpodSystem.ProtocolFigures.lickRaster.AxSound1 = subplot(1, 3, 1); title('Sound 1');
BpodSystem.ProtocolFigures.lickRaster.AxSound2 = subplot(1, 3, 2); title('Sound 2');
BpodSystem.ProtocolFigures.lickRaster.AxSound3 = subplot(1, 3, 3); title('Sound 3');


[filepath,filename,~]=fileparts(BpodSystem.DataPath);
BpodSystem.Data.Custom.StimulusPath=fullfile(strrep(filepath,'Session Data','Session Stimuli'),filename);
if ~exist(BpodSystem.Data.Custom.StimulusPath,'dir')
    mkdir(BpodSystem.Data.Custom.StimulusPath)
end

%initialize values and put into BpodSystem.Data.Custom
updateCustomDataFields(0)


%% order fields
BpodSystem.Data.Custom = orderfields(BpodSystem.Data.Custom);

%% Initialize plots
BpodSystem.ProtocolFigures.SideOutcomePlotFig = figure('Position', TaskParameters.Figures.OutcomePlot.Position,'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleOutcome = axes('Position',    [  .05  0.08 0.9 .45]);
BpodSystem.GUIHandles.OutcomePlot.HandlePsycAud = axes('Position',    [2*.05 + 1*.08   .62  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate = axes('Position',  [3*.05 + 2*.08   .62  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleFix = axes('Position',        [4*.05 + 3*.08   .62  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleST = axes('Position',         [5*.05 + 4*.08   .62  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleFeedback = axes('Position',   [6*.05 + 5*.08   .62  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric = axes('Position',   [7*.05 + 6*.08   .62  .1  .3], 'Visible', 'off');

MainPlot(BpodSystem.GUIHandles.OutcomePlot,'init');
%BpodSystem.ProtocolFigures.ParameterGUI.Position = TaskParameters.Figures.ParameterGUI.Position;



%% Main loop
RunSession = true;
iTrial = 1;

while RunSession
    TaskParameters = BpodParameterGUI('sync', TaskParameters);
    
    % SHUJINGs CODE, not sure whether I want this
    %     BpodSystem.ProtocolSettings = S; % copy settings back prior to saving
    %     SaveBpodProtocolSettings;
    
    sma = stateMatrix(iTrial);
    SendStateMatrix(sma);
    %% prep data acquisition
    if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
        preparePhotometryAcq(TaskParameters);
    end
    
    RawEvents = RunStateMatrix();
    
    %% Stop Photometry session
    if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
        stopPhotometryAcq;
    end
    
    if ~isempty(fieldnames(RawEvents))
        %% Process NIDAQ session
        if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
            try
                processPhotometryAcq(iTrial);
            catch
                disp('*** Data not saved, issue with processPhotometryAcq ***');
            end
            
        end
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        SaveBpodSessionData;
    else
        disp([' *** Trial # ' num2str(iTrial) ':  aborted, data not saved ***']); % happens when you abort early (I think), e.g. when you are halting session
    end
    
    if BpodSystem.BeingUsed == 0
        return
    end
    updateCustomDataFields(iTrial)%get data and create new stimuli here
    
    %% update plots
    %behavior
    MainPlot(BpodSystem.GUIHandles.OutcomePlot,'update',iTrial);
    
    if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
%         try % in case photometry hicupped
            % saving data
            processPhotometryOnline(iTrial);
            startX=0;%BpodSystem.Data.Custom.RewardStartTime(iTrial);
            %startX=BpodSystem.Data.Custom.StimulusStartTime(iTrial);
            if ~isnan(startX)
                updatePhotometryPlot('update', startX);
                xlabel('Time from reward start (s)');
            else
                disp('No reward delivered, no photometry plotted.');
            end
%         catch
%             disp('*** Problem with online photometry processing ***');
%         end
    end
    
    %     %% update photometry rasters WORK ON THIS LATER
    %     try % in case photometry hicupped
    %         if S.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
    %             % Note that switchParameterCriterion not used for
    %             % LNL_pRasters_bySound, but doesn't matter when
    %             % supplied via varargin
    %             prfh('Update', 'switchParameterCriterion', switchParameterCriterion, 'XLim', [-S.nidaq.duration, S.nidaq.duration]);
    %             if any(blockTransitions) % block transition lines
    %                 if ~isempty(BpodSystem.ProtocolFigures.phRaster.ax_ch1)
    %                     for ah = BpodSystem.ProtocolFigures.phRaster.ax_ch1(2:end)
    %                         plot(btx2, bty, '-r', 'Parent', ah);
    %                     end
    %                 end
    %                 if ~isempty(BpodSystem.ProtocolFigures.phRaster.ax_ch2)
    %                     for ah = BpodSystem.ProtocolFigures.phRaster.ax_ch2(2:end)
    %                         plot(btx2, bty, '-r', 'Parent', ah);
    %                     end
    %                 end
    %             end
    %         end
    %     end
    %
    %     %% lick rasters by sound
    %     %             bpLickRaster2(SessionData, filtArg, zeroField, figName, ax)
    %     bpLickRaster2({'SoundValveIndex', 1}, 'Cue', 'lick_raster', BpodSystem.ProtocolFigures.lickRaster.AxSound1, 'session'); hold on;
    %     bpLickRaster2({'SoundValveIndex', 2}, 'Cue', 'lick_raster', BpodSystem.ProtocolFigures.lickRaster.AxSound2, 'session'); hold on; % make both rasters regardless of number of Sounds, it'll just be blank if you don't have that Sound
    %     bpLickRaster2({'SoundValveIndex', 3}, 'Cue', 'lick_raster', BpodSystem.ProtocolFigures.lickRaster.AxSound3, 'session'); hold on;
    %     if any(blockTransitions)
    %         plot(btx, bty, '-r', 'Parent', BpodSystem.ProtocolFigures.lickRaster.AxSound1);
    %         plot(btx, bty, '-r', 'Parent', BpodSystem.ProtocolFigures.lickRaster.AxSound2);
    %         plot(btx, bty, '-r', 'Parent', BpodSystem.ProtocolFigures.lickRaster.AxSound3);
    %         drawnow;
    %     end
    %     set([BpodSystem.ProtocolFigures.lickRaster.AxSound1 BpodSystem.ProtocolFigures.lickRaster.AxSound2 BpodSystem.ProtocolFigures.lickRaster.AxSound3], 'XLim', [startX, startX + S.nidaq.duration]);
    %     xlabel(BpodSystem.ProtocolFigures.lickRaster.AxSound1, 'Time from cue (s)');
    %     xlabel(BpodSystem.ProtocolFigures.lickRaster.AxSound2, 'Time from cue (s)');
    %             xlabel(BpodSystem.ProtocolFigures.lickRaster.AxSound3, 'Time from cue (s)');
    iTrial = iTrial + 1;
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.

end


end



