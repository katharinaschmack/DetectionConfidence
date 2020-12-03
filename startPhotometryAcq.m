function S = startPhotometryAcq(S)
%% prelude
global nidaq BpodSystem
nidaq = [];
S.nidaq = [];
nidaq.ai_data = []; %flush data buffer
nidaq.ai_timestamps = []; %flush data buffer

nidaq.ao_data = []; %flush data buffer
nidaq.ao_timestamps = []; %flush data buffer

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

% get settings into nidaq and save in BpodSystem.Data.NidaqParameters
nidaq.sample_rate = S.nidaq.sample_rate;
nidaq.updateInterval = S.nidaq.updateInterval;
nidaq.refreshPeriod = S.nidaq.refreshPeriod;

BpodSystem.Data.NidaqParameters=nidaq;

%% Set up session and channels
nidaq.session = daq.createSession('ni');
BpodSystem.Data.NidaqParameters.hardware_sample_rate=nidaq.session.Rate;
% BpodSystem.Data.NidaqData=cell(1200,2);%pre-allocate data
% BpodSystem.Data.LEDData=cell(1200,2);

%% add inputs (photodetectors)
counter = 1;
for ch = nidaq.channelsOn
    nidaq.aiChannels{counter} = addAnalogInputChannel(nidaq.session,S.nidaq.Device,ch - 1,'Voltage'); % - 1 because nidaq channels are zero based
    nidaq.aiChannels{counter}.TerminalConfig = 'SingleEnded';
    counter = counter + 1;
end

%% add extra input (BNC output from Bpod, for perfect synchronizing) 
nidaq.aiChannels{counter} = addAnalogInputChannel(nidaq.session,S.nidaq.Device,counter - 1,'Voltage'); % - 1 because nidaq channels are zero based
nidaq.aiChannels{counter}.TerminalConfig = 'SingleEnded';

%% add outputs (LED modulation)
counter = 1;
for ch = nidaq.channelsOn
    nidaq.aoChannels{counter} = nidaq.session.addAnalogOutputChannel(S.nidaq.Device,ch - 1, 'Voltage'); % - 1 because nidaq channels are zero based
    counter = counter + 1;
end

%% set sampling rate and continuous recording
nidaq.session.Rate = nidaq.sample_rate;
if floor(nidaq.session.Rate) ~= nidaq.sample_rate
    error('*** need to handle case where true sample rate < requested sample rate ***');
end
nidaq.session.IsContinuous = true;

%% callback for queuing data
updateLEDData; %queue first data

%% set up continuous queuing (10% default)
nidaq.session.NotifyWhenScansQueuedBelow = floor(nidaq.sample_rate) * nidaq.refreshPeriod * 0.1; % fire event every second
lh{1} = nidaq.session.addlistener('DataRequired', @queueLEDData);
fprintf(['update LED output data every ' num2str(floor(nidaq.sample_rate) * nidaq.refreshPeriod) ' samples\n']);

%% callback for recording data (update Interval)
nidaq.session.NotifyWhenDataAvailableExceeds = floor(nidaq.session.Rate * nidaq.updateInterval);
lh{2} = nidaq.session.addlistener('DataAvailable',@processNidaqData);
fprintf(['readout photodetector input data every ' num2str(floor(nidaq.session.Rate * nidaq.updateInterval)) ' samples\n']);

%% callback for errors
lh{3} = nidaq.session.addlistener('ErrorOccurred', @(src,event) disp(getReport(event.Error))); 

%% start 
nidaq.session.startBackground(); % takes ~0.1 second to start and release control.