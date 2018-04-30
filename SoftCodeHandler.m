function SoftCodeHandler(softCode)
%soft code 11-20 reserved for PulsePal sound delivery

global BpodSystem

if softCode > 20 && softCode < 31
    if softCode == 21 %start Psychtoolbox signal in noise slave
        if BpodSystem.Data.Custom.PsychtoolboxStartup
            PsychToolboxSoundServerLoop('Play', 1);%play in loop
        end
        
    elseif softCode == 22  %stop Psychtoolbox signal in noise slave
        if BpodSystem.Data.Custom.PsychtoolboxStartup
            PsychToolboxSoundServer('Stop', 1);
        end
        
        
        
    elseif softCode == 23 %start Psychtoolbox signal slave
        if BpodSystem.Data.Custom.PsychtoolboxStartup
            PsychToolboxSoundServer('Play', 2);
        end
        
    elseif softCode == 24  %stop Psychtoolbox signal slave
        if BpodSystem.Data.Custom.PsychtoolboxStartup
            PsychToolboxSoundServer('Stop', 2);
        end
        
    end
end
end






