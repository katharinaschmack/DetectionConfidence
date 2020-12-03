function updateLEDData
global nidaq

% nSamples = ceil(nidaq.refreshPeriod * nidaq.sample_rate);
% outputData = zeros(nSamples, (sum(nidaq.channelsOn<=2))); % only channel1 and 2 are photometry channels containing in AND output channels preallocated output data
%     t = (0:nSamples - 1)' / nidaq.sample_rate;
nSamples = floor(nidaq.refreshPeriod * nidaq.session.Rate);
t = (0:nSamples - 1)' / nidaq.session.Rate;%even more exact
for channelIndex = 1:length(nidaq.channelsOn)
    channel = nidaq.channelsOn(channelIndex);
    freq = nidaq.(['LED' num2str(channel) '_f']);
    amp = nidaq.(['LED' num2str(channel) '_amp']);
    outputData(:,channelIndex) = (sin(2*pi*freq*t) + 1) /2 * amp;
end
nidaq.session.queueOutputData(outputData);
nidaq.ao_data=[nidaq.ao_data;outputData];
shift=length(nidaq.ao_timestamps)./nSamples*nidaq.refreshPeriod;
nidaq.ao_timestamps=[nidaq.ao_timestamps; t+shift];
%     % generate output data
%     nidaq.dt = 1/nidaq.session.Rate;    
%     t = (0:nidaq.dt:(nidaq.duration + rem(nidaq.duration, nidaq.updateInterval)))'; % pad output data so that it is an integer multiple of updateInterval so that you can save the last snippet of data
%     nidaq.ao_data = [];
%     ref = struct(...
%         'phaseShift', [],...
%         'freq', [],...
%         'amp', [],...
%         'duration', [],...
%         'sample_rate', []...
%         );
%     for ch = nidaq.channelsOn
%         phaseShift = rand(1) * 2 * pi;
%         freq = nidaq.(['LED' num2str(ch) '_f']);
%         amp = nidaq.(['LED' num2str(ch) '_amp']);
%         if freq % modulation mode
%             channelData = (sin(2*pi*freq*t + phaseShift) + 1) /2 * amp;
%         else % DC mode, if freq = 0;
%             channelData = zeros(size(t)) + amp / 2; % should be same mean amplitude as modulated, assuming that LED driver is linear
%         end
%         channelData(end) = 0;
%         nidaq.ao_data = [nidaq.ao_data channelData];
%         ref.phaseShift(end + 1) = phaseShift;
%         ref.freq(end + 1) = freq;
%         ref.amp(end + 1) = amp;
%         ref.duration(end + 1) = nidaq.duration;
%         ref.sample_rate(end + 1) = nidaq.session.Rate;
%     end
%     ref.channelsOn = nidaq.channelsOn;
%     nidaq.ref = ref;
%     nidaq.session.queueOutputData(nidaq.ao_data);
%     display(['queued LED output data for ' num2str(size(nidaq.ao_data, 1)) ' samples']);