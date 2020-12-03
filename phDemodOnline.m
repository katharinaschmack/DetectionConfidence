function phDemodOnline(currentTrial)
global BpodSystem nidaq

% decimationFactor = 10;
% lowCutoff = 15;
mod_freq = [nidaq.LED1_f nidaq.LED2_f];
for counter = 1:length(nidaq.channelsOn)
    ch = nidaq.channelsOn(counter);
    nidaq.online.currentDemodData{ch}=demodulateTrial(BpodSystem.Data.NidaqData{currentTrial}(:,counter), mod_freq(ch), nidaq.sample_rate);
end
% %% generate x data, scale from 0 initially (you can add/subtract offsets to x data within downstream funtions)
% dT = 1/nidaq.sample_rate;
% nidaq.online.currentXData = 0:dT:nidaq.duration - dT;
% nidaq.online.currentXData = nidaq.online.currentXData(:); % make column vector
% nidaq.online.currentXData = nidaq.online.currentXData(1:size(nidaq.online.currentDemodData{1}, 1));
% triggerIdx=find(BpodSystem.Data.NidaqData{currentTrial}(:,3)>2,1,'first');
% 
% %% pad or truncate if acquisition stopped short or long
% for ch = nidaq.channelsOn
%     nidaq.online.currentDemodData{ch}=decimate(nidaq.online.currentDemodData{ch}, decimationFactor);
% end
% nidaq.online.currentXData = decimate(nidaq.online.currentXData, decimationFactor);
