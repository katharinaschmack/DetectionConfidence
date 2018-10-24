function UserKillScriptKatharina(evernote,copydata)
if nargin<2
    copydata=true;
    if nargin<1
        evernote=true;
    end
end
global BpodSystem
global TaskParameters


SessionData=BpodSystem.Data;
SessionData.Settings=TaskParameters;
[~,TitleString] = fileparts(BpodSystem.DataPath);
[~,subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.DataPath))));

%% Stop noise stream
try
    PsychToolboxSoundServerLoop('Stop', 1);
    fprintf('Noise stream successfully stopped.')
catch
    fprintf('Noise stream not stopped.')
end


if copydata
    try
        remotepath = fullfile('Z:','BpodData',subject,'DetectionConfidence');%CHANGE HERE FOR NEW PROTOCOL!
        
        if ~isdir(fullfile(remotepath,'Session Data'))
            mkdir(fullfile(remotepath,'Session Data'));
        end
        if ~isdir(fullfile(remotepath,'Session Settings'))
            mkdir(fullfile(remotepath,'Session Settings'));
        end
        %         if ~isdir(fullfile(remotepath,'Session Figures'))
        %             mkdir(fullfile(remotepath,'Session Figures'));
        %         end
        if ~isdir(fullfile(remotepath,'Session Stimuli'))
            mkdir(fullfile(remotepath,'Session Stimuli'));
        end
        
        save(fullfile(remotepath,'Session Data',[TitleString, '.mat']),'SessionData');
        [~,filename,~]=fileparts(BpodSystem.SettingsPath);
        newfilename=[filename '_' datestr(now,'yyyy-mm-dd') '.mat'];
        copyfile(BpodSystem.SettingsPath,fullfile(remotepath,'Session Settings',newfilename));
        %copyfile(fullfile(FigureFolder,[FigureName '.png']),fullfile(remotepath,'Session Figures',[FigureName '.png']));
        %         copyfile(fullfile(FigureFolder,[FigureName02 '.png']),fullfile(remotepath,'Session Figures',[FigureName02 '.png']));
        copyfile(BpodSystem.Data.Custom.StimulusPath,fullfile(remotepath,'Session Stimuli',TitleString));
        fprintf('Files successfully copied to server!\n');
        
    catch
        fprintf('Error copying data to server. Files not copied!\n');
    end
end


% Export Online Figure
% try
%     saveas(BpodSystem.ProtocolFigures.SideOutcomePlotFig,fullfile(FigureFolder,FigureName),'png')
% end

% Create Analysis Figure and Data
try
    %% save figures
    if ~isdir(FigureFolder)
        mkdir(FigureFolder);
    end
    
    [trialTab,sessionTab]=retrieveDataOnline(SessionData);
    metadata=defineMetadata();
    %     metadata.binning.noise=[-20 prctile(trialTab.NoiseVolume,[33 66 100])];
    metadata.titlestring=TitleString;
    metadata.pooled=true;
    [dayTab]=retrieveDaydata(sessionTab,trialTab,metadata);
    [FigureHandle,infostring]=AnalysisFigure(trialTab,sessionTab,dayTab,metadata);
    
    expression = '\w\w\w\d\d_2018*';
    matchStr = regexp(FigureName,expression,'match');
    [y,m,d]=datevec(matchStr{1});
    dateNumStr=sprintf('%4.0f-%02.0f-%02.0f',y,m,d);
    
    % Export Analysis Figure
    FigureName=['Analysis_' dateNumStr '_' FigureName];
    saveas(FigureHandle,fullfile(FigureFolder,TitleString),'png')
end

% Send Analysis Summary to Evernote
if evernote
    ResultData=OnlineAnalysis(SessionData);
    load('MailSettings.mat')
    MailAddress = MailSettings.MailTo; % 'bosc274.b4f75e1@m.evernote.com';
    
    % Note informations:
    titstr=strsplit(TitleString,'_');
    note = sprintf('%s %s %s:\n',titstr{3},titstr{4},titstr{5});%date year session
%     for k=1:length(infostring)
%         note = sprintf('%s\n%s',note,infostring{k});
%     end
    note = sprintf('%sacc=%2.0f (S%2.0f-N%2.0f) lapse=%2.0f (S%2.0f-N%2.0f)\n',note,ResultData.acc.both,ResultData.acc.signal,ResultData.acc.noise,ResultData.lapse.both,ResultData.lapse.signal,ResultData.lapse.noise);
    note = sprintf('%scoutEarly=%2.0f skippedFeedback=%2.0f(S%2.0f-N%2.0f)\n',note,ResultData.coutEarly.both,ResultData.skipped.signal,ResultData.skipped.noise,ResultData.skipped.both);
    note = sprintf('%sn=%d (%d min) reward=%2.1fml\n',note,ResultData.nTrials,ResultData.Duration,ResultData.Reward);

    Subject = strcat(titstr{1}, ' @ ', titstr{2}, ' +');%subject protocol
    Body = note;
    
    sent = SendMyMail(MailSettings,MailSettings.MailTo,Subject,Body); % (MailSettings,MailAddress,Subject,Body,Attachment);
    if sent
        fprintf('"%s" sent to %s.\n',Subject,MailAddress);
    else
        fprintf('Error:SendFigureTo:Mail could not be sent to %s.\n',MailAddress);
    end
    
end

end






function sent = SendMyMail(varargin)
% sends mail from gmail account
% 3 or  4 inputs: address,subject,message,cell with attachment paths
% (each as string)

sent = false;
MailSettings = varargin{1};
setpref('Internet','E_mail',MailSettings.MailFrom)
setpref('Internet','SMTP_Server','smtp.gmail.com')
setpref('Internet','SMTP_Username',MailSettings.MailFrom)
setpref('Internet','SMTP_Password',MailSettings.MailFromPassword)
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

if length(varargin)==4
    try
        sendmail(varargin{2},varargin{3},varargin{4})
        sent=true;
    catch
        display('Error:SendMyMail:E-Mail could not be sent.')
    end
elseif length(varargin)==5
    try
        %attachments need to be in full path (not ~) for linux systems
        for k =1:length(varargin{5})
            if strcmp(varargin{5}{k}(1),'~')
                varargin{5}{k} = fullfile('/home/marion',varargin{5}{k}(2:end));
            end
        end
        
        sendmail(varargin{2},varargin{3},varargin{4},varargin{5})
        sent=true;
    catch
        display('Error:SendMyMail:E-Mail could not be sent.')
    end
else
    display('Error:SendMyMail:Number of input arguments wrong.')
end
end