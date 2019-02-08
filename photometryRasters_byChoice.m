function photometryRasters_byOutcome(Op, varargin)
    global BpodSystem nidaq
        %% optional parameters, first set defaults
    defaults = {...
        'baselinePeriod', [.1 .5];... %KS: is that too short??? in this period nothing should happen...
        'lookupFactor', 4;... %KS ?? 1 - 3 second into recording
        'phRStamp', 6;... %KS?? # pixels to push high or low to indicate alternative reinforcement outcomes
        'decimationFactor', nidaq.online.decimationFactor;...
        'outcomesToPlot', [0 1];...
        'XLim', 0;...
        };
    [ls, ~] = parse_args(defaults, varargin{:}); % combine default and passed (via varargin) parameter settings
    channelsOn = nidaq.channelsOn;
    Op = lower(Op);
    switch Op
        case 'init'
            BpodSystem.PluginObjects.Photometry.blF = []; %[nTrials, nDemodChannels]
            BpodSystem.PluginObjects.Photometry.baselinePeriod = ls.baselinePeriod;
            BpodSystem.PluginObjects.Photometry.trialDFF = {}; % 1 x nDemodChannels cell array, fill with nTrials x nSamples dFF matrix for now to make it easy to pull out raster data
            BpodSystem.ProtocolFigures.phRaster.decimationFactor = ls.decimationFactor;%KS: what does that mean?
            BpodSystem.ProtocolFigures.phRaster.lookupFactor = ls.lookupFactor;%KS: what does that mean?
            BpodSystem.ProtocolFigures.phRaster.phRStamp = ls.phRStamp;%KS: what does that mean?;            
            BpodSystem.ProtocolFigures.phRaster.outcomesToPlot = ls.outcomesToPlot; 
           if sum(channelsOn == 1)
                BpodSystem.ProtocolFigures.phRaster.fig_ch1 = ensureFigure('phRaster_ch1', 1);%KS: to make sure that it plots in the right figure???        
                nAxes = numel(ls.outcomesToPlot);        
                % params.matpos defines position of axesmatrix [LEFT TOP WIDTH HEIGHT].    
                params.cellmargin = [0.02 0.02 0.02 0.02];   
                params.matpos = [0 0 1 1];        
                hAx = axesmatrix(1, nAxes, 1:nAxes, params, gcf);      
                set(hAx, 'NextPlot', 'Add');
                BpodSystem.ProtocolFigures.phRaster.ax_ch1 = hAx;
                set(hAx, 'YDir', 'Reverse');
            else
                BpodSystem.ProtocolFigures.phRaster.fig_ch1 = [];
                BpodSystem.ProtocolFigures.phRaster.ax_ch1 = [];
            end
           if sum(channelsOn == 2)
                BpodSystem.ProtocolFigures.phRaster.fig_ch2 = ensureFigure('phRaster_ch2', 1);        
                nAxes = 4;%numel(ls.outcomesToPlot);        
                % params.matpos defines position of axesmatrix [LEFT TOP WIDTH HEIGHT].    
                params.cellmargin = [0.02 0.02 0.02 0.02];   
                params.matpos = [0 0 1 1];        
                hAx = axesmatrix(1, nAxes, 1:nAxes, params, gcf);      
                set(hAx, 'NextPlot', 'Add');
                BpodSystem.ProtocolFigures.phRaster.ax_ch2 = hAx;
                set(hAx, 'YDir', 'Reverse');
            else
                BpodSystem.ProtocolFigures.phRaster.fig_ch2 = [];
                BpodSystem.ProtocolFigures.phRaster.ax_ch2 = [];
           end         
        case 'update'
            %% update photometry rasters
            displaySampleRate = nidaq.sample_rate / BpodSystem.ProtocolFigures.phRaster.decimationFactor;
            x1 = bpX2pnt(BpodSystem.PluginObjects.Photometry.baselinePeriod(1), displaySampleRate, 0);
            x2 = bpX2pnt(BpodSystem.PluginObjects.Photometry.baselinePeriod(2), displaySampleRate, 0);        
               
            nTrials = length(BpodSystem.Data.Custom.ResponseLeft);
            outcomesToPlot = BpodSystem.ProtocolFigures.phRaster.outcomesToPlot;
            phRStamp = BpodSystem.ProtocolFigures.phRaster.phRStamp;
            lookupFactor = BpodSystem.ProtocolFigures.phRaster.lookupFactor;
            for i = 1:length(outcomesToPlot)
                thisOutcomeIndex = outcomesToPlot(i);
                %thisOutcomeTrials = onlineFilterTrials_v2('OdorValveIndex', thisOdorIndex); % miss or false alarm   
                rewardTrials = onlineFilterTrials_v2('ReinforcementOutcome', 'Reward');
                neutralTrials = onlineFilterTrials_v2('ReinforcementOutcome', 'Neutral');
                punishTrials = onlineFilterTrials_v2('ReinforcementOutcome', {'Punish', 'WNoise'});                
                if sum(channelsOn == 1)
                    channelData = BpodSystem.PluginObjects.Photometry.trialDFF{1};
                    nSamples = size(channelData, 2);
                    
                    phMean = mean(nanmean(channelData(:,x1:x2)));
                    phStd = mean(nanstd(channelData(:,x1:x2)));    
                    ax = BpodSystem.ProtocolFigures.phRaster.ax_ch1(i);
                    
                    CData = NaN(nTrials, nSamples);
                    CData(thisOdorTrials, :) = channelData(thisOdorTrials, :);
                    % add color tags marking trial reinforcment outcome
                    % high color = reward, 0 color = neutral, low color = punish
                    CData(rewardTrials & thisOdorTrials, 1:phRStamp) = 255; % 255 is arbitrary large value that will max out color table
                    CData(neutralTrials & thisOdorTrials, 1:phRStamp) = 0; 
                    CData(punishTrials & thisOdorTrials, 1:phRStamp) = -255; 
                    
                    image('YData', [1 size(CData, 1)], 'XData', ls.XLim,... % XData property is a 1 or 2 element vector
                        'CData', CData, 'CDataMapping', 'Scaled', 'Parent', ax);
                    set(ax, 'CLim', [phMean - lookupFactor * phStd, phMean + lookupFactor * phStd],...
                        'YTickLabel', {});
                    axis(ax, 'tight');
                end
                
                if sum(channelsOn == 2)
                    channelData = BpodSystem.PluginObjects.Photometry.trialDFF{2};
                    nSamples = size(channelData, 2);
                    
                    phMean = mean(nanmean(channelData(:,x1:x2)));
                    phStd = mean(nanstd(channelData(:,x1:x2)));    
                    ax = BpodSystem.ProtocolFigures.phRaster.ax_ch2(i);
                    
                    CData = NaN(nTrials, nSamples);
                    CData(thisOdorTrials, :) = channelData(thisOdorTrials, :);
                    % add color tags marking trial reinforcment outcome
                    % high color = reward, 0 color = neutral, low color = punish
                    CData(rewardTrials & thisOdorTrials, 1:phRStamp) = 255; % 255 is arbitrary large value that will max out color table
                    CData(neutralTrials & thisOdorTrials, 1:phRStamp) = 0; 
                    CData(punishTrials & thisOdorTrials, 1:phRStamp) = -255; 
                    
                    image('YData', [1 size(CData, 1)], 'XData', ls.XLim,... % XData property is a 1 or 2 element vector
                        'CData', CData, 'CDataMapping', 'Scaled', 'Parent', ax);
                    set(ax, 'CLim', [phMean - lookupFactor * phStd, phMean + lookupFactor * phStd],...
                        'YTickLabel', {});
                    axis(ax, 'tight');
                end
                
             
            end
        otherwise
            error('operator not correctly specified');
    end           

