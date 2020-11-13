function processPhotometryAcq(currentTrial)
    global BpodSystem nidaq
    
    while ~nidaq.session.IsDone
        pause(0.05);
    end

    %% Save data in BpodSystem format.   
    BpodSystem.Data.NidaqData{currentTrial, 1} = nidaq.ai_data; %input data
    BpodSystem.Data.NidaqData{currentTrial, 2} = nidaq.ref; % parameters
        