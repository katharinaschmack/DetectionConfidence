function SoftCodeHandler(softCode)
%soft code 11-20 reserved for PulsePal sound delivery

global BpodSystem

if softCode > 20 && softCode < 31 %for noise
    %if ~BpodSystem.EmulatorMode
        if softCode == 21 %start Psychtoolbox noise slave  
            if BpodSystem.Data.Custom.PsychtoolboxStartup
                PsychToolboxSoundServer('Play', 1);
            end
            
        elseif softCode == 22  %stop Psychtoolbox noise slave  
            if BpodSystem.Data.Custom.PsychtoolboxStartup
                PsychToolboxSoundServer('Stop', 1);
            end
            
        elseif softCode == 23  %stop Psychtoolbox signal slave
            if BpodSystem.Data.Custom.PsychtoolboxStartup
                PsychToolboxSoundServer('Play', 2);
            end
            
        elseif softCode == 24  %stop Psychtoolbox signal slave
            if BpodSystem.Data.Custom.PsychtoolboxStartup
                PsychToolboxSoundServer('Stop', 2);
            end
            
        end
    %end
end

% if softCode > 20 && softCode < 31 %for auditory freq
%     if softCode == 21 
%     end
%     if softCode == 22
%         if BpodSystem.Data.Custom.PsychtoolboxStartup
%             PsychToolboxSoundServer('Stop', 1);
%         end
%     end    
% end
% 
end

