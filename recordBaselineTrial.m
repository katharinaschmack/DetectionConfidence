function iTrial=recordBaselineTrial(iTrial)
global BpodSystem TaskParameters
%% records baseline for photometry
%% record end baseline
if TaskParameters.GUI.PhotometryOn~=0&&TaskParameters.GUI.BaselineRecording>0
    BpodSystem.Data.Custom.recordBaselineTrial=true;
    sma = stateMatrix(iTrial);
    SendStateMatrix(sma);
    
    %% prepare photometry
    if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
        preparePhotometryAcq(TaskParameters);
    end
    
    %% RUN!!!
    RawEvents = RunStateMatrix();
    
    %% stop photometry session
    if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
        stopPhotometryAcq;
    end
    
    %% process photometry session
    if ~isempty(fieldnames(RawEvents))
        if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
            processPhotometryAcq(iTrial);
        end
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        SaveBpodSessionData;
    else
        disp([' *** Trial # ' num2str(iTrial) ':  aborted, data not saved ***']); % happens when you abort early (I think), e.g. when you are halting session
    end
    
        %% analyze behavior and create new trial-specific parameters for next trial
    updateCustomDataFields(iTrial)%
    
    %% update main plot
    MainPlot(BpodSystem.GUIHandles.OutcomePlot,'update',iTrial);
    
    %% update photometry plot
    if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode 
        processPhotometryOnline(iTrial);
        if BpodSystem.Data.Custom.RewardReceivedCorrect(iTrial)>0
            rewtime=BpodSystem.Data.Custom.RewardStartTime(iTrial);
        else
            rewtime=nan;
        end
        if (BpodSystem.Data.Custom.CoutEarly(iTrial))~=1
            stimtime=BpodSystem.Data.Custom.StimulusStartTime(iTrial);
        else
            stimtime=nan;
        end
        try %kludge, problem with plotting baseline
        updatePhotometryPlotKatharina('update', [rewtime stimtime],{'reward','stimulus'});
        catch
            fprintf('Trial %d: Error in updatePhotometryPlotKatharina.m during baseline Recording\n',iTrial)
        end
    end
    
    %% Go on to next trial
    iTrial = iTrial + 1;
        BpodSystem.Data.Custom.recordBaselineTrial=false;
end