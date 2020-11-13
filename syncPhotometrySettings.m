function syncPhotometrySettings
% function attempts to sync nidaq settings (part of
% BpodSystem.Settings) with nidaq structure (containing nidaq session)
% Note conventions below (somewhat historical):
% convention is to have GUI-linked nidaq settings stored as
% S.GUI.nidaqSetting and non-GUI-linked nidaq settings stored as
% S.nidaq.nidaqSetting
% function first attempts to find a GUI-linked version setting to sync, then
% tries non-GUI-linked setting
global nidaq BpodSystem
S = BpodSystem.ProtocolSettings;

% these fields will either be specified in
syncFields = {'LED1_f', 'LED2_f', 'duration', 'sample_rate', 'LED1_amp', 'LED2_amp', 'IsContinuous', 'updateInterval'};

for counter = 1:length(syncFields)
    sf = syncFields{counter};
    
    try
        nidaq.(sf) = S.GUI.(sf);
    catch
        try
            nidaq.(sf) = S.nidaq.(sf);
        catch
        end
    end
end

%% determine which channels are being acquired
nidaq.channelsOn = [];
ch1on = 0; ch2on = 0;
try
    if S.GUI.ch1
        ch1on = 1;
    end
catch
    if S.GUI.LED1_amp > 0
        ch1on = 1;
    end
end

try
    if S.GUI.ch2
        ch2on = 1;
    end
catch
    if S.GUI.LED2_amp > 0
        ch2on = 1;
    end
end

if ch1on
    nidaq.channelsOn = [nidaq.channelsOn 1];
end
if ch2on
    nidaq.channelsOn = [nidaq.channelsOn 2];
end

if isempty(nidaq.channelsOn)
    error('you need at least one acquisition channel turned on');
end

