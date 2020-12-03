function processNidaqData(src,event)

global nidaq
nidaq.ai_data = [nidaq.ai_data; event.Data]; % for non-continuous acquisition
nidaq.ai_timestamps = [nidaq.ai_timestamps; event.TimeStamps];

if size(nidaq.ai_data,1)~=size(nidaq.ai_timestamps,1)
   fprintf('What''s wrong?\n'); 
end

% global BpodSystem iTrial
%    BpodSystem.Data.NidaqData{iTrial, 1} = [BpodSystem.Data.NidaqData{iTrial, 1}; event.Data]; %input data
%    BpodSystem.Data.NidaqData{iTrial, 2} = [BpodSystem.Data.NidaqData{iTrial, 2}; event.TimeStamps]; %input data

