function UserKillScriptKatharina()
global BpodSystem
global TaskParameters

% stop photometryAcquision if necessary
try
if TaskParameters.GUI.PhotometryOn && ~BpodSystem.EmulatorMode
    stopPhotometryAcq;
    fprintf('Photometry acquisition orderly stopped.\n');
end
catch
    fprintf('Problem with stopping photometry acquisition.\n');
end


%save data
try
SessionData=BpodSystem.Data;
SessionData.Settings=TaskParameters;
[localpath,TitleString] = fileparts(BpodSystem.DataPath);
[~,subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.DataPath))));
titstr=strsplit(TitleString,'_');%1 animal %2 protocol %3 date %4 year %5 session
Protocol=titstr{2};
end

%% 
try
AbortPulsePal();
end

%% Stop noise stream
try
    PsychToolboxSoundServerLoop('Stop', 1);
    fprintf('Noise stream successfully stopped.')
catch
    fprintf('Noise stream not stopped.')
end

%% Copy data
try
    remotepath = fullfile('Z:','BpodData',subject,'DetectionConfidence');%CHANGE HERE FOR NEW PROTOCOL!
    if ~isdir(fullfile(remotepath,'Session Data'))
        mkdir(fullfile(remotepath,'Session Data'));
    end
    if ~isdir(fullfile(remotepath,'Session Settings'))
        mkdir(fullfile(remotepath,'Session Settings'));
    end
    if ~isdir(fullfile(remotepath,'Session Stimuli'))
        mkdir(fullfile(remotepath,'Session Stimuli'));
    end
    save(fullfile(remotepath,'Session Data',[TitleString, '.mat']),'SessionData');
    [~,filename,~]=fileparts(BpodSystem.SettingsPath);
    newfilename=[filename '_' datestr(now,'yyyy-mm-dd') '.mat'];
    copyfile(BpodSystem.SettingsPath,fullfile(remotepath,'Session Settings',newfilename));
    copyfile(BpodSystem.Data.Custom.StimulusPath,fullfile(remotepath,'Session Stimuli',TitleString));
    
    if BpodSystem.Data.Custom.PhotometryOn
    if ~isdir(fullfile(remotepath,'Session Photometry'))
        mkdir(fullfile(remotepath,'Session Photometry'));
    end
    photopath=strrep(BpodSystem.Data.Custom.StimulusPath,'Session Stimuli','Session Photometry');
    copyfile(photopath,fullfile(remotepath,'Session Photometry',TitleString));
    end
    fprintf('Files successfully copied to server!\n');    
catch
    fprintf('Error copying data to server. Files not copied!\n');
end

%% analyze data
[trialTab,sessionTab]=retrieveDataOnline(SessionData);
Results=OnlineAnalysis(trialTab,sessionTab);
% Results.Date=datestr(Results.Date,'mm/dd/yy');

%TODO put all this in session Tab via correctErrors and then retrieve it with OnlineAnalysis



%% send email to Evernote
SubjectLine=strcat(titstr{1}, ' @ ', titstr{2}, ' +');
text.Line1=sprintf('%s\t',sessionTab.Day{1},sessionTab.Datestr{1},num2str(sessionTab.SessionNumber),num2str(sessionTab.Trials),sessionTab.Duration,sessionTab.TotalReward);%     body=d{1};
text.Line2=sprintf('beta=%s:\t%s\t%s\t%s\t\t\nFbDelay=%s\tCatch=%d',sessionTab.Evidence,sessionTab.Easy,sessionTab.Intermediate,sessionTab.Difficult,sessionTab.FbDelay,sessionTab.Catch);
text.Line3=sprintf('acc %2.0f\t easyhits %2.0f\t alarms %2.0f\t bias %2.0f',Results.Accuracy,Results.HitsEasy,100-Results.Rejects,Results.Bias);
text.Line4=sprintf('coutEarly %2.0f\t skippedFeedback %2.0f\t',Results.CoutEarly,Results.SkippedFeedback);
Body=sprintf('x\n\n%s\n%s\n%s\n%s',text.Line1,text.Line2,text.Line3,text.Line4);
load('MailSettings.mat');
sent = SendMyMail(MailSettings,MailSettings.MailTo,SubjectLine,Body); % (MailSettings,MailAddress,Subject,Body,Attachment);
if sent
    fprintf('"%s" sent to %s.\n',SubjectLine,MailSettings.MailTo);
else
    fprintf('Error:SendFigureTo:Mail could not be sent to %s.\n',MailSettings.MailTo);
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