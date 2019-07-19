function DetectionConfidence()
% Script for training and performing mice a detection in noise task with
% confidence reports

global BpodSystem
global TaskParameters
%global StimulusSettings

%% Task parameters
TaskParameters = BpodSystem.ProtocolSettings;
if isempty(fieldnames(TaskParameters))
    TaskParameters=defaultTaskParameters(TaskParameters);
end
BpodParameterGUI('init', TaskParameters);
BpodSystem.Pause = 1;
HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
TaskParameters = BpodParameterGUI('sync', TaskParameters); % Sync parameters with BpodParameterGUI plugin
BpodSystem.ProtocolSettings = TaskParameters; % copy settings back prior to saving
SaveBpodProtocolSettings;

%host data
[~,BpodSystem.Data.Custom.Rig] = system('hostname');
[~,BpodSystem.Data.Custom.Subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.DataPath))));
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler';

%% Initialize NIDAQ
TaskParameters.nidaq.duration = 120;
TaskParameters.nidaq.IsContinuous = true;
TaskParameters.nidaq.updateInterval = 0.1; % save new data every n seconds
BpodSystem.PluginObjects.Photometry.baselinePeriod = [0 1]; % kludge, FS
BpodSystem.ProtocolSettings = TaskParameters; % copy settings back because syncPhotometrySettings relies upon BpodSystem.ProtocolSettings
if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
    TaskParameters = initPhotometry(TaskParameters);
end
%% photometry plot
if TaskParameters.GUI.PhotometryOn 
    updatePhotometryPlotKatharina('init',[0 0],{'Reward','Stimulus'});
end

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
TaskParameters = BpodParameterGUI('sync', TaskParameters);
if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
    site = questdlg('Where are you recording from?', ...
        'photometry site', ...
        'right','left','right');
    BpodSystem.Data.Custom.PhotometrySite=site;
end

% %if TaskParameters.GUI.PharmacologyOn 
%     drug = questdlg('What did you administer?', ...
%         'drug condition', ...
%         'ketamine','placebo','ketamine');
%     BpodSystem.Data.Custom.Pharmacology=drug;
% %end
% firstblock = questdlg('Which block do you want to start with?', ...
%     'first block', ...
%     '30','50','70','50');
% BpodSystem.Data.Custom.firstblock=firstblock;



%% alternate LED modulation mode
if TaskParameters.GUI.PhotometryOn==2
    % store initial LED settings
    storedLED1_amp = TaskParameters.GUI.LED1_amp;
    storedLED2_amp = TaskParameters.GUI.LED2_amp;
end

while RunSession

   if TaskParameters.GUI.PhotometryOn==2
       LEDmode = rem(iTrial, 3);
       switch LEDmode
           case 1
               TaskParameters.GUI.LED1_amp = storedLED1_amp;
               TaskParameters.GUI.LED2_amp = storedLED2_amp;
           case 2
               TaskParameters.GUI.LED1_amp = storedLED1_amp;
               TaskParameters.GUI.LED2_amp = 0;
           case 0
               TaskParameters.GUI.LED1_amp = 0;
               TaskParameters.GUI.LED2_amp = storedLED2_amp;
       end
   end    
    TaskParameters = BpodParameterGUI('sync', TaskParameters);
    BpodSystem.ProtocolSettings = TaskParameters; % copy settings back prior to saving
    SaveBpodProtocolSettings;

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
        processPhotometryOnline(iTrial);
        if BpodSystem.Data.Custom.RewardReceivedCorrect(iTrial)>0
            rewtime=BpodSystem.Data.Custom.RewardStartTime(iTrial);
        else
            rewtime=nan;
        end
        if (BpodSystem.Data.Custom.CoutEarly(iTrial))~=1
            stimtime=BpodSystem.Data.Custom.StimulusStartTime(iTrial);
        else
            stimtime=nan;
        end
        updatePhotometryPlotKatharina('update', [rewtime stimtime],{'reward','stimulus'});        
    end   

    iTrial = iTrial + 1;
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.

end


end



