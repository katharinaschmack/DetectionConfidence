%compare two settings files to identify the fields that need to be updated
% clear
% load('C:\Users\Katharina\BpodUser\Data\Dummy Subject\DetectionConfidence\Session Settings\continuous_none.mat')
% NewProtocolSettings=ProtocolSettings;
% load('C:\Users\Katharina\BpodUser\Data\Dummy Subject\DetectionConfidence\Session Settings\K01_confidence.mat')

path=('C:\Users\Katharina\BpodUser\Data\');
files=dir(fullfile(path,'\K*\DetectionConfidence\Session Settings\*.mat'));
for f=1:length(files)
    load(fullfile(files(f).folder,files(f).name))

    ProtocolSettings.GUI=rmfield(ProtocolSettings.GUI,'BiasCorrection');
    ProtocolSettings.GUIMeta=rmfield(ProtocolSettings.GUIMeta,'BiasCorrection');
    ProtocolSettings.GUIPanels.Choice(strcmp(ProtocolSettings.GUIPanels.Choice,'BiasCorrection'))=[];

    ProtocolSettings.GUI.BiasVersion = 3;
    ProtocolSettings.GUIMeta.BiasVersion.Style = 'popupmenu';
    ProtocolSettings.GUIMeta.BiasVersion.String = {'None','Soft','Block'};%Soft: use for bias correction, calculates bias over all trials and presents non-prefered stimulus with p=1-bias.
    ProtocolSettings.GUI.BiasTable.Signal=[.3 .5 .7]';
    ProtocolSettings.GUI.BiasTable.BlockLength=[2000 0 0]';
    ProtocolSettings.GUIMeta.BiasTable.Style = 'table';
    ProtocolSettings.GUIMeta.BiasTable.String = 'Bias blocks';
    ProtocolSettings.GUIMeta.BiasTable.ColumnLabel = {'signal bias','trials'};

    ProtocolSettings.GUIPanels.BiasVersion={'BiasVersion'};
    ProtocolSettings.GUIPanels.BiasTable={'BiasTable'};
    ProtocolSettings.GUITabs.Stimulus = {'Stimulus','NoiseVolumeTable','ContinuousTable','BiasVersion','BiasTable'};

%     ProtocolSettings.GUI.LED1_amp = 5;
%     ProtocolSettings.GUI.LED2_amp = 0;
%     ProtocolSettings.GUI.PhotometryOn = 0;
%     ProtocolSettings.GUI.LED1_f = 531;
%     ProtocolSettings.GUI.LED2_f = 0;%211
%     ProtocolSettings.GUI.PostTrialRecording = 0;%sets Time that will be recorded after trial end
%     ProtocolSettings.GUIPanels.Photometry = {'LED1_amp', 'LED2_amp', 'PhotometryOn', 'LED1_f', 'LED2_f','PostTrialRecording'};
%     ProtocolSettings.GUITabs.General = {'General','Photometry'};

    %BruteForce: presents the same stimulus until a correct choice is made, then resumes stimulus sequence; Soft: calculates bias over all trials and presents non-prefered stimulus with p=1-bias.% ProtocolSettings.GUI.BetaParam=0.1;
    % ProtocolSettings.GUI.ContinuousTable.NoiseLimits=[min(ProtocolSettings.GUI.NoiseVolumeTable.NoiseVolume);max(ProtocolSettings.GUI.NoiseVolumeTable.NoiseVolume)];
    % ProtocolSettings.GUI.ContinuousTable.SignalLimits=[max(ProtocolSettings.GUI.NoiseVolumeTable.SignalVolume);min(ProtocolSettings.GUI.NoiseVolumeTable.SignalVolume)];
    % ProtocolSettings.GUI.DecisionVariable=1;
    % ProtocolSettings.GUIMeta.DecisionVariable.Style='popupmenu';
    % ProtocolSettings.GUIMeta.DecisionVariable.String={'discrete','continuous'};
    % ProtocolSettings.GUIPanels.Stimulus=[];
    % ProtocolSettings.GUIPanels.Stimulus= {'DecisionVariable','BetaParam','EasyTrials','StimDuration'};
    % ProtocolSettings.GUIMeta.ContinuousTable.Style='table';
    % ProtocolSettings.GUIMeta.ContinuousTable.String='Decision variable';
    % ProtocolSettings.GUIMeta.ContinuousTable.ColumnLabel={'noiseLims','signalLims'};
    % ProtocolSettings.GUIPanels.NoiseVolumeTable=[];
    % ProtocolSettings.GUIPanels.NoiseVolumeTable={'NoiseVolumeTable'};
    % ProtocolSettings.GUIPanels.ContinuousTable={'ContinuousTable'};
    % ProtocolSettings.GUIPanels.Sampling=[];
    % ProtocolSettings.GUIPanels.Sampling={'RewardAmountCenter','RewardAmountCenterSelection','RewardAmountCenterEasyTrials','CoutEarlyTimeout'};
    % ProtocolSettings.GUIPanels.FeedbackDelay(end)=[];
    % ProtocolSettings.GUITabs.Stimulation=[];
    % ProtocolSettings.GUITabs=rmfield(ProtocolSettings.GUITabs,'Stimulation');%={'Stimulus','NoiseVolumeTable','ContinuousTable','Timing'};
    % ProtocolSettings.GUI=rmfield(ProtocolSettings.GUI,'AllowBreakFixation');
    % ProtocolSettings.GUI=rmfield(ProtocolSettings.GUI,'VevaiometricMinWT');
    % ProtocolSettings.GUIMeta=rmfield(ProtocolSettings.GUIMeta,'AllowBreakFixation');
    % ProtocolSettings.GUI.BiasCorrection=1;
    % ProtocolSettings.GUITabs.Stimulus = {'Stimulus','NoiseVolumeTable','ContinuousTable'};
    % ProtocolSettings.GUITabs.Timing = {'Timing'};
    
    
    
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
    newfilename=strrep(files(f).name,'.mat','_new.mat');
    save(fullfile(files(f).folder,newfilename),'ProtocolSettings');
    
end

