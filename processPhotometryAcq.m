function processPhotometryAcq(currentTrial)
    global BpodSystem nidaq
    
    %% Save data in BpodSystem format & flush
    if isempty(nidaq.ai_data)
        error('Check this!')
    end
    BpodSystem.Data.CurrentNidaqData = [nidaq.ai_timestamps,nidaq.ai_data]; %input data
    nidaq.ai_data=[];
    nidaq.ai_timestamps=[];
    
    
    % I only want to save this for debugging purposes (or maybe for
    % demodulation?)
    BpodSystem.Data.CurrentLEDData=[nidaq.ao_timestamps nidaq.ao_data]; %input data
    nidaq.ao_data=[];
    nidaq.ao_timestamps=[];

    % store away
    NidaqData=BpodSystem.Data.CurrentNidaqData;
    NidaqParameters=BpodSystem.Data.NidaqParameters;
    LEDData=BpodSystem.Data.CurrentLEDData;
    filename=fullfile(BpodSystem.Data.Custom.PhotometryPath,sprintf('trial%04.0f.mat',currentTrial));
    save(filename,'NidaqData','NidaqParameters','LEDData','currentTrial');
    %     % in continuous acquisition no more continous saving is necessary
%     BpodSystem.Data.NidaqData{currentTrial, 2} = nidaq.ref; % parameters
        