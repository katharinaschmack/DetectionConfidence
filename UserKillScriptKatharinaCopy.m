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

%% Stop noise stream
try
    PsychToolboxSoundServerLoop('Stop', 1);
    fprintf('Noise stream successfully stopped.')
catch
    fprintf('Noise stream not stopped.')
end

%% save figures
FigureFolder = fullfile(fileparts(fileparts(BpodSystem.DataPath)),'Session Figures');
[~, FigureName] = fileparts(BpodSystem.DataPath);
if ~isdir(FigureFolder)
    mkdir(FigureFolder);
end

% Export Online Figure
try
    saveas(BpodSystem.ProtocolFigures.SideOutcomePlotFig,fullfile(FigureFolder,FigureName),'png')
end

% Create Analysis Figure and Data
[~,TitleString] = fileparts(BpodSystem.DataPath);
if BpodSystem.Data.nTrials>10
    [AnalyzedData, FigureHandle]=CheckBehaviorOnline(SessionData,TitleString);
    [trialTab sessionTab]=retrieveDataOnline(SessionData);
    %try
    %    plotPsychometricOnline(trialTab,sessionTab,TitleString);
    %catch
    %    figure;
    %    title('Something went wrong during plotting')
    %end
    expression = '\w\w\w\d\d_2018*';
    matchStr = regexp(FigureName,expression,'match');
    [y,m,d]=datevec(matchStr{1});
    dateNumStr=sprintf('%4.0f-%02.0f-%02.0f',y,m,d);
    
    
    % Export Analysis Figure
    FigureName02=['Analysis_' dateNumStr '_' FigureName];
    saveas(FigureHandle,fullfile(FigureFolder,FigureName02),'png')
    
    
    % Send Analysis Summary to Evernote
    if evernote
        load('MailSettings.mat')
        MailAddress = MailSettings.MailTo; % 'bosc274.b4f75e1@m.evernote.com';
        
        % Note informations:
        infostrings=strsplit(TitleString,'_');
        note = sprintf('%s %s %s:\n',infostrings{3},infostrings{4},infostrings{5});%date year session
        note = sprintf('%sTrials (completed) %d (%d)\tTrainTime %d min\tReward %2.3fml\t',note,AnalyzedData.nTrials,AnalyzedData.nComTrials,AnalyzedData.TrainTime,AnalyzedData.TotalRew);
        note = sprintf('%sAccuracy %2.0f%s\t Bias %2.0f%s CoutEarly %2.0f%s\n\n',note,AnalyzedData.Acc,'%',AnalyzedData.Bias,'%',AnalyzedData.CoutEarly,'%');
        
        Subject = strcat(infostrings{1}, ' @ ', infostrings{2}, ' +');%subject protocol
        Body = note;
        
        sent = SendMyMail(MailSettings,MailSettings.MailTo,Subject,Body); % (MailSettings,MailAddress,Subject,Body,Attachment);
        if sent
            fprintf('"%s" sent to %s.\n',Subject,MailAddress);
        else
            fprintf('Error:SendFigureTo:Mail could not be sent to %s.\n',MailAddress);
        end
    end
    
    %% copy data to server
    if copydata
        try
            %CHANGE THIS TO 'homes\YOUR-ACCOUNT-NAME' OR to 'SHARED-FOLDER-NAME'
            %examples: user = 'homes\torben'; % user name on server
            %          user = 'confidence';   % shared folder
            [~,subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.DataPath))));
            remotepath = fullfile('Z:','BpodData',subject,BpodSystem.CurrentProtocolName);
            
            if ~isdir(fullfile(remotepath,'Session Data'))
                mkdir(fullfile(remotepath,'Session Data'));
            end
            if ~isdir(fullfile(remotepath,'Session Settings'))
                mkdir(fullfile(remotepath,'Session Settings'));
            end
            if ~isdir(fullfile(remotepath,'Session Figures'))
                mkdir(fullfile(remotepath,'Session Figures'));
            end
            if ~isdir(fullfile(remotepath,'Session Stimuli'))
                mkdir(fullfile(remotepath,'Session Stimuli'));
            end

            save(fullfile(remotepath,'Session Data',[TitleString, '.mat']),'SessionData');
            [~,filename,~]=fileparts(BpodSystem.SettingsPath);
            newfilename=[filename '_' datestr(now,'yyyy-mm-dd') '.mat'];
            copyfile(BpodSystem.SettingsPath,fullfile(remotepath,'Session Settings',newfilename));
            copyfile(fullfile(FigureFolder,[FigureName '.png']),fullfile(remotepath,'Session Figures',[FigureName '.png']));
            copyfile(fullfile(FigureFolder,[FigureName02 '.png']),fullfile(remotepath,'Session Figures',[FigureName02 '.png']));
            copyfile(BpodSystem.Data.Custom.StimulusPath,fullfile(remotepath,'Session Stimuli',FigureName));
        catch
            fprintf('Error copying data to server. Files not copied!\n');
        end
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