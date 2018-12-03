function UserKillScriptGoogle(updatesheet,copydata)
if nargin<2
    copydata=true;
    if nargin<1
        updatesheet=true;
    end
end
global BpodSystem
global TaskParameters


SessionData=BpodSystem.Data;
SessionData.Settings=TaskParameters;
[localpath,TitleString] = fileparts(BpodSystem.DataPath);
[~,subject] = fileparts(fileparts(fileparts(fileparts(BpodSystem.DataPath))));
titstr=strsplit(TitleString,'_');%1 animal %2 protocol %3 date %4 year %5 session
Protocol=titstr{2};

%% Stop noise stream
try
    PsychToolboxSoundServerLoop('Stop', 1);
    fprintf('Noise stream successfully stopped.')
catch
    fprintf('Noise stream not stopped.')
end

%% Copy data
if copydata
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
        fprintf('Files successfully copied to server!\n');
        
    catch
        fprintf('Error copying data to server. Files not copied!\n');
    end
end

%% analyze data
[trialTab,sessionTab]=retrieveDataOnline(SessionData);

%TODO put all this in session Tab via correctErrors and then retrieve it with OnlineAnalysis
[~,dayName]=weekday(datestr(titstr{3},'mm/dd/yyyy'));
Results.Day=dayName;
Results.Date=string(datestr(titstr{3},'mm/dd/yyyy'));
Results.Session=titstr{5};
Results.Trials=sprintf('n=%d',length(SessionData.Custom.ResponseCorrect));%Trials
Results.Duration=sprintf('%d min',round((max(SessionData.TrialStartTimestamp)-min(SessionData.TrialStartTimestamp))/60));
Results.Reward=sprintf('%2.1fml',sum(SessionData.Custom.RewardReceivedTotal)/1000);%Reward

%Print used difficulty
switch SessionData.Settings.GUIMeta.DecisionVariable.String{SessionData.Settings.GUI.DecisionVariable}
    case 'continuous'
        Results.Evidence=sprintf('%2.0f',SessionData.Settings.GUI.BetaParam);
        Results.Easy=sprintf('%d-%d',min(SessionData.Settings.GUI.ContinuousTable.NoiseLimits),max(SessionData.Settings.GUI.ContinuousTable.SignalLimits));
        Results.Intermediate='';
        Results.Difficult=sprintf('%d-%d',max(SessionData.Settings.GUI.ContinuousTable.NoiseLimits),min(SessionData.Settings.GUI.ContinuousTable.SignalLimits));
    case 'discrete'
        Results.Evidence='discrete';
        Results.Easy=sprintf('%d-%d',SessionData.Settings.GUI.NoiseVolumeTable.NoiseVolume(1),SessionData.Settings.GUI.NoiseVolumeTable.SignalVolume(1));
        Results.Intermediate=sprintf('%d-%d',SessionData.Settings.GUI.NoiseVolumeTable.NoiseVolume(2),SessionData.Settings.GUI.NoiseVolumeTable.SignalVolume(2));
        Results.Difficult=sprintf('%d-%d',SessionData.Settings.GUI.NoiseVolumeTable.NoiseVolume(3),SessionData.Settings.GUI.NoiseVolumeTable.SignalVolume(3));
end
switch SessionData.Settings.GUIMeta.FeedbackDelaySelection.String{SessionData.Settings.GUI.FeedbackDelaySelection}
    case 'Fix'
        Results.FbDelay=sprintf('%2.0f',SessionData.Settings.GUI.FeedbackDelayMax);
    case 'AutoIncr'
        Results.FbDelay=sprintf('AutoIncr');
    case 'TruncExp'
        Results.FbDelay=sprintf('%2.1f (%2.1f-%2.1f)',SessionData.Settings.GUI.FeedbackDelayTau,SessionData.Settings.GUI.FeedbackDelayMin,SessionData.Settings.GUI.FeedbackDelayMax);
end
Results=OnlineAnalysis(trialTab,sessionTab,Results);
newResultsTable=struct2table(Results,'AsArray',true);
newResultsCell=struct2cell(Results);


%% send email to Evernote
try
    SubjectLine=strcat(titstr{1}, ' @ ', titstr{2}, ' +');
    text.Line1=sprintf('%s\t',Results.Day,Results.Date,Results.Session,Results.Trials,Results.Duration,Results.Reward);%     body=d{1};
    text.Line2=sprintf('beta=%s:\t%s\t%s\t%s\t\t\nFbDelay=%ss\tCatch=%d%s',Results.Evidence,Results.Easy,Results.Intermediate,Results.Difficult,Results.FbDelay,Results.Catch,'%');
    text.Line3=sprintf('acc %2.0f\t easyhits %2.0f\t alarms %2.0f\t bias %2.0f',Results.Accuracy,Results.HitsEasy,100-Results.Rejects,Results.Bias);
    text.Line4=sprintf('coutEarly %2.0f\t skippedFeedback %2.0f\t',Results.CoutEarly,Results.SkippedFeedback);
    Body=sprintf('x\n\n%s\n%s\n%s\n%s\n\n',text.Line1,text.Line2,text.Line3,text.Line4);
    load('MailSettings.mat');
    sent = SendMyMail(MailSettings,MailSettings.MailTo,SubjectLine,Body); % (MailSettings,MailAddress,Subject,Body,Attachment);
    if sent
        fprintf('"%s" sent to %s.\n',SubjectLine,MailSettings.MailTo);
    else
        fprintf('Error:SendFigureTo:Mail could not be sent to %s.\n',MailSettings.MailTo);
    end
end

%% Send Analysis to xls sheet
if updatesheet
    
    
    %copy to remote summary path
    try
    summarypath=fullfile('Z:','TrainingSummary');
    if ~exist(summarypath)
        mkdir(summarypath);
    end
    xlsName=fullfile(summarypath,sprintf('%s_%s.xlsx',Protocol,subject));
    catch
        %set up excel sheet on local computer
        summarylocalpath=fullfile(fileparts(localpath),'TrainingSummary');
        if ~exist(summarylocalpath)
            mkdir(summarylocalpath);
        end
        xlsName=fullfile(summarylocalpath,sprintf('%s_%s.xlsx',Protocol,subject));
        fprintf('Saving Summary locally!...')
    end

    
    %close excel if running
    try
        system('taskkill /F /IM EXCEL.EXE >nul 2>&1');
    end
    
    %write in xls
    if exist(xlsName,'file')
        oldResultsTable=readtable(xlsName);
        h=height(oldResultsTable)+2;
        w=width(newResultsTable);
        alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        insertRange=sprintf('%s%d:%s%d',alphabet(1),h,alphabet(w),h);
        xlswrite(xlsName,struct2array(Results),insertRange);
    else
        writetable(newResultsTable,xlsName);
    end
    
    %start xls
     cmd=sprintf('start excel /r %s',xlsName);
     system(cmd);
    
   
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