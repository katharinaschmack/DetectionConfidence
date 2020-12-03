function DetectionConfidence()
% Bpod script for an auditory detection in noise task with
% time-investment-based confidence reports
% Katharina Schmack, Cold Spring Harbor Laboratory, March 2018

global BpodSystem
global TaskParameters

%% prepare TaskParameters
TaskParameters = BpodSystem.ProtocolSettings;%get saved TaskParameters
TaskParameters=syncTaskParameters(TaskParameters);%sync saved TaskParameters with DefaultTaskParameters
BpodParameterGUI('init', TaskParameters);
BpodSystem.Pause = 1;
HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
TaskParameters = BpodParameterGUI('sync', TaskParameters); % Sync parameters with BpodParameterGUI plugin
BpodSystem.ProtocolSettings = TaskParameters; % copy settings back prior to saving
SaveBpodProtocolSettings;


%% define some pathes
[~,BpodSystem.Data.Custom.Rig] = system('hostname');
[~,BpodSystem.Data.Custom.Subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.DataPath))));
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler';
[filepath,filename,~]=fileparts(BpodSystem.DataPath);
BpodSystem.Data.Custom.StimulusPath=fullfile(strrep(filepath,'Session Data','Session Stimuli'),filename);
if ~exist(BpodSystem.Data.Custom.StimulusPath,'dir')
    mkdir(BpodSystem.Data.Custom.StimulusPath)
end
BpodSystem.Data.Custom.recordBaselineTrial=false;


%% User Input for Photometry & Pharmacoloy & Blocks (to do: add option in GUI to switch on and off)
if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
    site = questdlg('Where are you recording from?', ...
        'photometry site', ...
        'left','right','right');
    BpodSystem.Data.Custom.PhotometrySite=site;
    BpodSystem.Data.Custom.PhotometryPath=fullfile(strrep(filepath,'Session Data','Session Photometry'),filename);
    if ~exist(BpodSystem.Data.Custom.PhotometryPath,'dir')
        mkdir(BpodSystem.Data.Custom.PhotometryPath);
    end
end
if TaskParameters.GUI.PharmacologyOn
    drug = questdlg('What did you administer?', ...
        'drug condition', ...
        'ketamine','placebo','ketamine');
    BpodSystem.Data.Custom.Pharmacology=drug;
end
if TaskParameters.GUI.LaserPercentage>0
    PulsePal('COM3');
    load('ParameterMatrix25Hz5ms200ms.mat','ParameterMatrix');
    ParameterMatrix(2:13,4)={0 5 0 0.004 0 0 1/2-0.004 TaskParameters.GUI.LaserBlockLength*30 0 TaskParameters.GUI.LaserBlockLength*30 0 1};
    ParameterMatrix(2:13,5)={0 5 0 0.004 0 0 1/2-0.004 TaskParameters.GUI.LaserBlockLength*30 0 TaskParameters.GUI.LaserBlockLength*30 0 1};
    ParameterMatrix{2,8}=1;
    ProgramPulsePal(ParameterMatrix);
        site = questdlg('Where are you stimulating?', ...
        'photometry site', ...
        'left','right','right');
    BpodSystem.Data.Custom.StimulationSite=site;
end

if TaskParameters.GUI.DetermineFirstBlock
    firstblock = questdlg('Which block do you want to start with?', ...
        'first block', ...
        '30','50','70','50');
    BpodSystem.Data.Custom.firstblock=firstblock;
end
%% Initialize photometry if PhotometryOn
if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
    % BpodSystem.PluginObjects.Photometry.baselinePeriod = [0 1]; % kludge, FS
    BpodSystem.ProtocolSettings = TaskParameters; % copy settings back because syncPhotometrySettings relies upon BpodSystem.ProtocolSettings
%     TaskParameters = initPhotometry(TaskParameters); %DO we need that? The same is done on each trial
    
    %% initialize photometry plot (work this out later)
    %updatePhotometryPlotKatharina('init',[0 0],{'Reward','Stimulus'});
end

%% Initialize trial specific values and save them in BpodSystem.Data.Custom
updateCustomDataFields(0);
BpodSystem.Data.Custom = orderfields(BpodSystem.Data.Custom);

%% Initialize main plot
BpodSystem.ProtocolFigures.SideOutcomePlotFig = figure('Position', [0, 600, 1000, 400],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleOutcome = axes('Position',    [  .05  0.08 0.9 .45]);
BpodSystem.GUIHandles.OutcomePlot.HandlePsycAud = axes('Position',    [2*.05 + 1*.08   .62  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate = axes('Position',  [3*.05 + 2*.08   .62  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleFix = axes('Position',        [4*.05 + 3*.08   .62  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleST = axes('Position',         [5*.05 + 4*.08   .62  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleFeedback = axes('Position',   [6*.05 + 5*.08   .62  .1  .3], 'Visible', 'off');
BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric = axes('Position',   [7*.05 + 6*.08   .62  .1  .3], 'Visible', 'off');
MainPlot(BpodSystem.GUIHandles.OutcomePlot,'init');

%% prepare photometry
if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
    startPhotometryAcq(TaskParameters);
    PhotometryPlot('init');
end

%% Task loop over trials
RunSession = true;
iTrial = 1;
tic;
t=nan(1000,1);
while RunSession
    % update TaskParameters
    TaskParameters = BpodParameterGUI('sync', TaskParameters);
    BpodSystem.ProtocolSettings = TaskParameters; % copy settings back prior to saving
    SaveBpodProtocolSettings;
    
    %% prepare stateMatrix
    sma = stateMatrix(iTrial);
    SendStateMatrix(sma);
    
    %% run state matrix
    RawEvents = RunStateMatrix();
    %% process photometry session
    if ~isempty(fieldnames(RawEvents))
        if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
            processPhotometryAcq(iTrial);
        end
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        SaveBpodSessionData;
    else
        disp(['Trial # ' num2str(iTrial) ':  aborted, data not saved ***']); % happens when you abort early (I think), e.g. when you are halting session
    end
    
    %% check for something (not sure what)
    if BpodSystem.BeingUsed == 0
        return
    end
    
    %% analyze behavior and create new trial-specific parameters for next trial
    updateCustomDataFields(iTrial)%
    
    %% update main plot
    MainPlot(BpodSystem.GUIHandles.OutcomePlot,'update',iTrial);
    
    %% update photometry plot
    if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
        PhotometryPlot('update',iTrial);
    end
    
    %% Go on to next trial
    iTrial = iTrial + 1;
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
end %while loop for trials
%     %% stop photometry session PUT IN KILL SCRIPT
%     if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
%         stopPhotometryAcq;
%     end

end



