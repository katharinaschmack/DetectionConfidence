function saveLEDData
global nidaq BpodSystem

for channelIndex = 1:length(nidaq.channelsOn)
    channel = nidaq.channelsOn(channelIndex);
    BpodSystem.Data.NidaqParameters.(['LED' num2str(channel) '_f']) = nidaq.(['LED' num2str(channel) '_f']);
    BpodSystem.Data.NidaqParameters.(['LED' num2str(channel) '_amp']) = nidaq.(['LED' num2str(channel) '_amp']);
end
BpodSystem.Data.NidaqParameters.sample_rate