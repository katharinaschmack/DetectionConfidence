function S = initPhotometry(S)
    %% prepare variables etc.
    global nidaq BpodSystem
    %daq.reset
    %% set settings
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
    
    % define parameters for analog inputs.
    nidaq.ai_channelNames=S.nidaq.ai_channelNames; 
    nidaq.ai_data = [];
    
    % define parameters for analog outputs.
    nidaq.ao_channelNames=S.nidaq.ao_channelNames;
    nidaq.ao_data = [];
    nidaq.aiChannels = {};
    nidaq.aoChannels = {};
    nidaq.sample_rate = S.nidaq.sample_rate;
    
    %% fields for online analysis (do I want this?)
    nidaq.online.currentDemodData = cell(1, nDemodChannels);
    nidaq.online.currentXData = []; % x data starts from 0 (thus independent of protocol), add/subtract offset to redefine zero in protocol-specific funtions
    nidaq.online.trialXData = {};
    nidaq.online.trialDemodData = cell(1, nDemodChannels);
    nidaq.online.decimationFactor = 1000;
    BpodSystem.PluginObjects.Photometry.trialDFF = cell(1, nDemodChannels);

