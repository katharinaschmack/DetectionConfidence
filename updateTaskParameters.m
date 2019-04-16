%compare two settings files to identify the fields that need to be updated
% clear
% load('C:\Users\Katharina\BpodUser\Data\Dummy Subject\DetectionConfidence\Session Settings\continuous_none.mat')
% NewProtocolSettings=ProtocolSettings;
% load('C:\Users\Katharina\BpodUser\Data\Dummy Subject\DetectionConfidence\Session Settings\K01_confidence.mat')

<<<<<<< HEAD
path=('C:\Users\Katharina\BpodUser\Data\');
files=dir(fullfile(path,'\K*\DetectionConfidence\Session Settings\*.mat'));
=======
path=('C:\Users\root\BpodUser\Data\');
files=dir(fullfile(path,'\*\DetectionConfidence\Session Settings\*.mat'));
>>>>>>> ff9f1be89b791eefeb7728b79f885d719b94941f
for f=1:length(files)
    load(fullfile(files(f).folder,files(f).name))
    ProtocolSettings.GUIMeta.BiasVersion.String = {'None','Soft','Block','Noise'};%Soft: use for bias correction, calculates bias over all trials and presents non-prefered stimulus with p=1-bias.
    ProtocolSettings.GUIMeta.BiasTable.ColumnLabel = {'signal bias','noise','trials'};

    %save new Settings
    newfilename=strrep(files(f).name,'.mat','_new.mat');
    save(fullfile(files(f).folder,newfilename),'ProtocolSettings');
    
end

