function updatePhotometryPlotKatharina(Op, startX, titles)
% startX: time point in seconds from beginning of photometry
% acquisition to be defined as 0
if nargin<3
    titles={'start recording'};
    if nargin < 2
        startX = 0;
    end
end
channelColors=[0 .9 0; .9 0 0];
window=[-200 200];

global BpodSystem nidaq
    
%% for simulation (reverse when finished)
% if ~BpodSystem.EmulatorMode    
    syncPhotometrySettings;
% else
%     titles={'reward','stimulus'};
%     samples=round(rand*1000);
%     startX=sort(randsample(samples,2));
%     
%     nidaq.online.currentXData=1:samples;
%     nidaq.online.currentDemodData{1}=rand(1,samples);
%     nidaq.online.currentDemodData{1}(startX(1))=10;
%     nidaq.online.currentDemodData{1}(startX(2))=20;
%     
%     nidaq.online.currentDemodData{1}=smoothdata(nidaq.online.currentDemodData{1},'gaussian',10);
%     nidaq.online.currentDemodData{2}=rand(1,samples);    
% end
    Op = lower(Op);

    switch Op
        case 'init'
            scrsz = get(groot,'ScreenSize'); 

            BpodSystem.ProtocolFigures.NIDAQFig       = figure(...
                'Position', [25 25 min(scrsz(3)*.4*length(startX),scrsz(3)-25) min(scrsz(4)*.2*2)],...
                'Name','NIDAQ plot','numbertitle','off');
            %if all(channelsOn)
            k=1;
            for ch=1:2
                for condition=1:length(startX)
                    BpodSystem.ProtocolFigures.NIDAQPanel(ch,condition)=subplot(2,length(startX),k);
                    hold on;
                    %%update here for samples
                    windowSample=bpX2pnt(window, nidaq.sample_rate/nidaq.online.decimationFactor);
                    BpodSystem.ProtocolFigures.NIDAQMean(ch,condition)=plot(BpodSystem.ProtocolFigures.NIDAQPanel(ch,condition),...
                        windowSample(1):windowSample(2),zeros(length(windowSample(1):windowSample(2)),1),'Color',channelColors(ch,:),'LineWidth',2);                    
                    if ch==1
                        BpodSystem.ProtocolFigures.NIDAQPanel(ch,condition).Title.String=titles{condition};
                    end
                    k=k+1;
                end
            end
     
        case 'update'
            for ch=1:2
                for condition=1:length(startX)
                    
                    %single trace
                    alignedXData=nidaq.online.currentXData-startX(condition);
                    idx = alignedXData>=window(1)&alignedXData<=window(2);
                    xData = alignedXData(idx);
                    yData = nidaq.online.currentDemodData{ch}(idx);
                    plot(BpodSystem.ProtocolFigures.NIDAQPanel(ch,condition),xData, yData,'Color','k','LineWidth',.5);

                    %update mean
                    if all(BpodSystem.ProtocolFigures.NIDAQMean(ch,condition).YData==0)
                        %pad data to the right and left to make sure that
                        %future 
                        BpodSystem.ProtocolFigures.NIDAQMean(ch,condition).XData=xData;
                        BpodSystem.ProtocolFigures.NIDAQMean(ch,condition).YData=yData;
                    else
                        weight=length(findall(BpodSystem.ProtocolFigures.NIDAQPanel(ch,condition),'Type','Line'))-1;
                        meanYData=BpodSystem.ProtocolFigures.NIDAQMean(ch,condition).YData;
                        meanXData=BpodSystem.ProtocolFigures.NIDAQMean(ch,condition).XData;
                        updateIdx=ismember(meanXData,xData);
                        oldIdx=ismember(xData,meanXData);
                        %update timepoints that are in mean and in new
                        %trial
                        meanYData(updateIdx)=(meanYData(updateIdx).*weight+yData(oldIdx))./(weight+1);
                        %add new timepoints that are not yet in mean but in
                        %new trial
                        meanXData=[meanXData xData(~oldIdx)];
                        [meanXData sortIdx]=sort(meanXData);
                        meanYData=[meanYData yData(~oldIdx)];
                        meanYData=meanYData(sortIdx);
                        BpodSystem.ProtocolFigures.NIDAQMean(ch,condition).XData=meanXData;
                        BpodSystem.ProtocolFigures.NIDAQMean(ch,condition).YData=meanYData;
                        uistack(BpodSystem.ProtocolFigures.NIDAQMean(ch,condition),'top');
                    end
                end
            end
%             drawnow;
        %     legend(nidaq.ai_channels,'Location','East')
    end