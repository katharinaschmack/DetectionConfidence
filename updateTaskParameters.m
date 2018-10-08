%compare two settings files to identify the fields that need to be updated
% clear
% load('C:\Users\Katharina\BpodUser\Data\Dummy Subject\DetectionConfidence\Session Settings\continuous_none.mat')
% NewProtocolSettings=ProtocolSettings;
% load('C:\Users\Katharina\BpodUser\Data\Dummy Subject\DetectionConfidence\Session Settings\K01_confidence.mat')

[files,path] = uigetfile('Z:\BpodData\','MultiSelect','off');
load(fullfile(path,files))
ProtocolSettings.GUI.BetaParam=0.1;
ProtocolSettings.GUI.ContinuousTable.NoiseLimits=[min(ProtocolSettings.GUI.NoiseVolumeTable.NoiseVolume);max(ProtocolSettings.GUI.NoiseVolumeTable.NoiseVolume)];
ProtocolSettings.GUI.ContinuousTable.SignalLimits=[max(ProtocolSettings.GUI.NoiseVolumeTable.SignalVolume);min(ProtocolSettings.GUI.NoiseVolumeTable.SignalVolume)];
ProtocolSettings.GUI.DecisionVariable=1;
ProtocolSettings.GUIMeta.DecisionVariable.Style='popupmenu';
ProtocolSettings.GUIMeta.DecisionVariable.String={'discrete','continuous'};
ProtocolSettings.GUIPanels.Stimulus=[];
ProtocolSettings.GUIPanels.Stimulus= {'DecisionVariable','BetaParam','EasyTrials','StimDuration'};
ProtocolSettings.GUIMeta.ContinuousTable.Style='table';
ProtocolSettings.GUIMeta.ContinuousTable.String='Decision variable';
ProtocolSettings.GUIMeta.ContinuousTable.ColumnLabel={'noiseLims','signalLims'};
ProtocolSettings.GUIPanels.NoiseVolumeTable=[];
ProtocolSettings.GUIPanels.NoiseVolumeTable={'NoiseVolumeTable'};
ProtocolSettings.GUIPanels.ContinuousTable={'ContinuousTable'};
ProtocolSettings.GUIPanels.Sampling=[];
ProtocolSettings.GUIPanels.Sampling={'RewardAmountCenter','RewardAmountCenterSelection','RewardAmountCenterEasyTrials','CoutEarlyTimeout'};
ProtocolSettings.GUIPanels.FeedbackDelay(end)=[];
ProtocolSettings.GUITabs.Stimulation=[];
ProtocolSettings.GUITabs=rmfield(ProtocolSettings.GUITabs,'Stimulation');%={'Stimulus','NoiseVolumeTable','ContinuousTable','Timing'};
ProtocolSettings.GUI=rmfield(ProtocolSettings.GUI,'AllowBreakFixation');
ProtocolSettings.GUI=rmfield(ProtocolSettings.GUI,'VevaiometricMinWT');
ProtocolSettings.GUIMeta=rmfield(ProtocolSettings.GUIMeta,'AllowBreakFixation');
ProtocolSettings.GUI.BiasCorrection=1;
ProtocolSettings.GUITabs.Stimulus = {'Stimulus','NoiseVolumeTable','ContinuousTable'};
ProtocolSettings.GUITabs.Timing = {'Timing'};



% %compare two settings files to identify the fields that need to be updated
% OldProtocolSettings=ProtocolSettings;
% 
% fnames=fields(NewProtocolSettings)';
% for f=fnames
%     gnames=fields(NewProtocolSettings.(f{1}))';
%     for g=gnames
%         if ~isfield(OldProtocolSettings.(f{1}),g{1})
%             fprintf('Add ProtocolSettings.%s.%s\n',f{1},g{1})
%         elseif ~isequal(NewProtocolSettings.(f{1}).(g{1}),OldProtocolSettings.(f{1}).(g{1}))&&...
%                 iscell(NewProtocolSettings.(f{1}).(g{1}))
%             fprintf('Update ProtocolSettings.%s.%s\n',f{1},g{1})
%         end
%     end
% end
% 
% fnames=fields(OldProtocolSettings)';
% for f=fnames
%     gnames=fields(OldProtocolSettings.(f{1}))';
%     for g=gnames
%         if ~isfield(NewProtocolSettings.(f{1}),g{1})
%             fprintf('Remove ProtocolSettings.%s.%s\n',f{1},g{1})
%         end
%     end
% end
% 
%save new Settings
newfilename=strrep(files,'.mat','_new.mat');
save(fullfile(path,newfilename),'ProtocolSettings');


