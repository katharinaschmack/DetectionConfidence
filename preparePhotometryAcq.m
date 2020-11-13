function S = preparePhotometryAcq(S)
%% prelude
global nidaq BpodSystem
% daq.reset %maybe necessary
% daq.HardwareInfo.getInstance('DisableReferenceClockSynchronization',true); % necessary for some Nidaq

%% settings
% retrieve machine-specifice settints (e.g. which channels)
try
    addpath(genpath(fullfile(BpodSystem.BpodUserPath, 'Settings Files'))); % Settings path is assumed to be shielded by gitignore file
    phSettings = machineSpecific_Photometry;
    rmpath(genpath(fullfile(BpodSystem.BpodUserPath, 'Settings Files'))); % remove it just in case there would somehow be a name conflict
catch
    addpath(genpath(fullfile(BpodSystem.BpodPath, 'Settings Files'))); % Settings path is assumed to be shielded by gitignore file
    phSettings = machineSpecific_Photometry;
    rmpath(genpath(fullfile(BpodSystem.BpodPath, 'Settings Files'))); % remove it just in case there would somehow be a name conflict
end
phDefaults = phSettings.phDefaults;
phGUIDefaults = phSettings.phGUIDefaults;

%set defaults
for counter = 1:size(phDefaults, 1)
    if ~isfield(S.nidaq, phDefaults{counter, 1})
        S.nidaq.(phDefaults{counter, 1}) = phDefaults{counter, 2};
    end
end
for counter = 1:size(phGUIDefaults, 1)
    if ~isfield(S.GUI, phGUIDefaults{counter, 1})
        S.GUI.(phGUIDefaults{counter, 1}) = phGUIDefaults{counter, 2};
    end
end

% synchronize settings between maching-specific defaults,
% settings hard coded in protocol S.nidaq.(exampleField)   and
% settings selected in GUI  S.GUI.(exampleField)
syncPhotometrySettings;

% get settings into nidaq
nidaq.ai_channelNames          = S.nidaq.ai_channelNames;
nidaq.ai_data = [];
nidaq.ao_channelNames          = S.nidaq.ao_channelNames;
nidaq.ao_data = [];
nidaq.aiChannels = {};
nidaq.aoChannels = {};

%% fields for online analysis (do I want this?)
nidaq.online.currentDemodData = cell(1, maxDemodChannels);
nidaq.online.currentXData = []; % x data starts from 0 (thus independent of protocol), add/subtract offset to redefine zero in protocol-specific funtions
%     nidaq.online.trialXData = {};
%     nidaq.online.trialDemodData = cell(1, maxDemodChannels);
nidaq.online.decimationFactor = 100;


%% Set up session and channels
nidaq.session = daq.createSession('ni');

%% add inputs
counter = 1;
for ch = nidaq.channelsOn
    nidaq.aiChannels{counter} = addAnalogInputChannel(nidaq.session,S.nidaq.Device,ch - 1,'Voltage'); % - 1 because nidaq channels are zero based
    nidaq.aiChannels{counter}.TerminalConfig = 'SingleEnded';
    counter = counter + 1;
end

%% add outputs
counter = 1;
for ch = nidaq.channelsOn
    nidaq.aoChannels{counter} = nidaq.session.addAnalogOutputChannel(S.nidaq.Device,ch - 1, 'Voltage'); % - 1 because nidaq channels are zero based
    counter = counter + 1;
end

%% add trigger external trigger, if specified
if S.nidaq.TriggerConnection
    addTriggerConnection(nidaq.session, 'external', [S.nidaq.Device '/' S.nidaq.TriggerSource], 'StartTrigger');
    nidaq.session.ExternalTriggerTimeout = 900; % something really long (15min), might be necessary during freely moving behavior when animal doesn't re-initiate trial for a while
end

%% Sampling rate and continuous updating (important for queue-ing ao data)
nidaq.session.Rate = nidaq.sample_rate;
if floor(nidaq.session.Rate) ~= nidaq.sample_rate
    error('*** need to handle case where true sample rate < requested sample rate ***');
end

if nidaq.IsContinuous
    nidaq.session.IsContinuous = true;
else
    nidaq.session.IsContinuous = false; % would work with this set to true as well since setting the samples acquired callback to be equal to acq duration effectively makes it non-continous
end

%% create and cue data for output, add callback function
updateLEDData;
% data available notify must be set after queueing data
if nidaq.IsContinuous
    nidaq.session.NotifyWhenDataAvailableExceeds = floor(nidaq.session.Rate * nidaq.updateInterval);
else
    nidaq.session.NotifyWhenDataAvailableExceeds = floor(nidaq.session.Rate * nidaq.duration); % fire only at the end of acquisition
end
lh{1} = nidaq.session.addlistener('DataAvailable',@processNidaqData);
display(['data availableexceeds set at ' num2str(floor(nidaq.session.Rate * nidaq.duration))]);






%%
nidaq.ai_data = [];
nidaq.session.prepare(); %Saves 50ms on startup time, perhaps more for repeats.
nidaq.session.startBackground(); % takes ~0.1 second to start and release control.