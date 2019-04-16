%compare two settings files to identify the fields that need to be updated
% clear
% load('C:\Users\Katharina\BpodUser\Data\Dummy Subject\DetectionConfidence\Session Settings\continuous_none.mat')
% NewProt% load('C:\Users\Katharina\BpodUser\Data\Dummy Subject\DetectionConfidence\Session Settings\K01_confidence.mat')

path=('C:\Users\Katharina\BpodUser\Data\');
files=dir(fullfile(path,'\K*\DetectionConfidence\Session Settings\*.mat'));
for f=1:length(files)
    load(fullfile(files(f).folder,files(f).name))
    ProtocolSettings.GUIMeta.BiasVersion.String = {'None','Soft','Block','Noise'};%Soft: use for bias correction, calculates bias over all trials and presents non-prefered stimulus with p=1-bias.
    ProtocolSettings.GUIMeta.BiasTable.ColumnLabel = {'signal bias','noise','trials'};

    ProtocolSettings.GUI.BiasTable.Noise=[35 40 45]';


    
    
    ProtocolSettings.GUI.ch1=1;
    ProtocolSettings.GUIPanels.Photometry = {'PhotometryOn','LED1_amp', 'LED2_amp','ch1','ch2','LED1_f', 'LED2_f','PostTrialRecording'};
    ProtocolSettings.GUI.LED1_amp = 2.5;
    ProtocolSettings.GUI.LED2_amp = 2.5;
    ProtocolSettings.GUI.PhotometryOn = 0;%2
    ProtocolSettings.GUI.LED1_f = 0;%531
    ProtocolSettings.GUI.LED2_f = 0;%211
    ProtocolSettings.GUI.PostTrialRecording = 2;%sets Time that will be recorded after trial end
    ProtocolSettings.GUI.ch1 = 1;
    ProtocolSettings.GUIMeta.ch1.Style = 'checkbox';
    ProtocolSettings.GUI.ch2 = 1;
    ProtocolSettings.GUIMeta.ch2.Style = 'checkbox';
    %save new Settings
    newfilename=strrep(files(f).name,'.mat','_correct.mat');
    save(fullfile(files(f).folder,newfilename),'ProtocolSettings');
    
end

