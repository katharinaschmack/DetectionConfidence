function PhotometryPlot(Op,iTrial)
% startX: time point in seconds from beginning of photometry
% acquisition to be defined as 0
channelColors=[0 .9 0; .9 0 0];
window=[-1 2];
decimationFactor=10;
titles={'stimulus','reward'};
global BpodSystem nidaq
Op = lower(Op);

switch Op
    case 'init'
        scrsz = get(groot,'ScreenSize');
        heightScr=scrsz(4);
        widthFig=min(scrsz(3)*.2*2,scrsz(3)-25);
        heightFig=min(scrsz(4)*.2*2);
        marg=100;
        %% start with raw signal figure
        BpodSystem.ProtocolFigures.photoFig = figure(...
            'Position', [marg+widthFig heightScr-heightFig/2-marg widthFig heightFig/2],...
            'Name','Photometry plot','numbertitle','off');
        p=1;
        for ch=1:2
            for con=1:2
                BpodSystem.ProtocolFigures.photoPanel(con,ch)=subplot(2,2,p);
                hold off;
                p=p+1;
            end
        end
        
        
        
    case 'update'
        try
            
            mod_freq = [BpodSystem.Data.NidaqParameters.LED1_f BpodSystem.Data.NidaqParameters.LED2_f];
            hardware_sample_rate = BpodSystem.Data.NidaqParameters.hardware_sample_rate;
            sample_rate = BpodSystem.Data.NidaqParameters.sample_rate;
            %         triggerX=BpodSystem.Data.NidaqData{iTrial,2}(find(BpodSystem.Data.NidaqData{iTrial,1}(:,3)>2,1,'first'));
            %         rawXData=BpodSystem.Data.NidaqData{iTrial,2}(:);
            %         XData=BpodSystem.Data.NidaqData{iTrial,2}-triggerX;
            %             trialIdx=BpodSystem.Data.NidaqData(:,1)==iTrial;
            %             rawXData=BpodSystem.Data.NidaqData(trialIdx,2);
            %             triggerX=rawXData(find(BpodSystem.Data.NidaqData(trialIdx,5)>2,1,'first'));
            %             XData=BpodSystem.Data.NidaqData{iTrial,2}-triggerX;
            rawXData=BpodSystem.Data.CurrentNidaqData(:,1);
            triggerX=rawXData(find(BpodSystem.Data.CurrentNidaqData(:,4)>2,1,'first'));
            XData=rawXData-triggerX;
            for ch=1:2
                rawYData=BpodSystem.Data.CurrentNidaqData(:,ch+1);
                YData=demodulateTrial(rawYData, mod_freq(ch), hardware_sample_rate);
                
                % plot raw data
                plot(BpodSystem.ProtocolFigures.photoPanel(1,ch),rawXData,rawYData,'Color',channelColors(ch,:),'LineWidth',.5);
                line(BpodSystem.ProtocolFigures.photoPanel(1,ch),[triggerX,triggerX],BpodSystem.ProtocolFigures.photoPanel(1,ch).YLim,'Color','k','LineWidth',2)
                
                % plot demodulated data
                plotIdx=find(XData>-2&XData<10);
                artifactIdx=(max(plotIdx)-ceil(0.1*sample_rate)):max(plotIdx);
                plotIdx(ismember(plotIdx,artifactIdx))=[];
                plot(BpodSystem.ProtocolFigures.photoPanel(2,ch),XData(plotIdx),YData(plotIdx),'Color',channelColors(ch,:));
                
                rewX=BpodSystem.Data.RawEvents.Trial{iTrial}.States.LinCorrect_CueFb(1)-BpodSystem.Data.RawEvents.Trial{iTrial}.States.Cin_GraceStart(1);
                stiX=BpodSystem.Data.RawEvents.Trial{iTrial}.States.Cin_Stim(1)-BpodSystem.Data.RawEvents.Trial{iTrial}.States.Cin_GraceStart(1);
                line(BpodSystem.ProtocolFigures.photoPanel(2,ch),[stiX,stiX],BpodSystem.ProtocolFigures.photoPanel(2,ch).YLim,'Color','k','LineWidth',1,'LineStyle','--');
                line(BpodSystem.ProtocolFigures.photoPanel(2,ch),[rewX,rewX],BpodSystem.ProtocolFigures.photoPanel(2,ch).YLim,'Color','b','LineWidth',1,'LineStyle','--');
            end
            
        catch
            fprintf('No trigger recorded on Trial %d\n',iTrial);
        end
        
end
%             drawnow;
%     legend(nidaq.ai_channels,'Location','East')
end