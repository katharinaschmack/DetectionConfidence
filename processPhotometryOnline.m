function processPhotometryOnline(currentTrial)
    global nidaq
    % calculate baseline F and dF/F, this function is seperate from
    % phDemodOnline because you need a baseline period which is specific to
    % a given behavioral protocol

    phDemodOnline(currentTrial);

    
    global BpodSystem nidaq    
    baselinePeriod = BpodSystem.PluginObjects.Photometry.baselinePeriod;
    blStartP = bpX2pnt(baselinePeriod(1), nidaq.sample_rate/nidaq.online.decimationFactor);
    blEndP = bpX2pnt(baselinePeriod(2), nidaq.sample_rate/nidaq.online.decimationFactor);
    
    trialBaselines = zeros(1,2);
    channelsOn = nidaq.channelsOn;
    for ch = channelsOn % 2 channels are hard coded
        chData = nidaq.online.currentDemodData{ch};
        bl = nanmean(chData(blStartP:blEndP));
        dFF = (chData - bl) ./ bl;
%         if nidaq.IsContinuous
            % not finished, need to create system for storing uneven length
            % trial data downsampled for rasters I guesss
            BpodSystem.PluginObjects.Photometry.currentTrialDFF{ch} = dFF;
%         else
%             BpodSystem.PluginObjects.Photometry.trialDFF{ch}(currentTrial, :) = dFF;
%         end
        trialBaselines(ch) = bl;
    end
    BpodSystem.PluginObjects.Photometry.currentblF{ch}  = trialBaselines;
    