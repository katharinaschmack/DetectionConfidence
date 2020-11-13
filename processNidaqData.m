function processNidaqData(src,event)

global nidaq
nidaq.ai_data = [nidaq.ai_data; event.Data]; % for non-continuous acquisition

