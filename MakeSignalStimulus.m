<<<<<<< HEAD
function [signal]=MakeSignalStimulus(SignalSettings)
%makes auditory signal sweep or beep the following properties 
%SignalSettings.Duration - Duration of signal in seconds
%SignalSettings.Form - 'LinearUpsweep','LinearDownweep','QuadraticConvex'
%SignalSettings.MinFreq - Minimal Frequency in Hz
%SignalSettings.MaxFreq - Maximal Frequency in Hz
%for beep set 'LinearUpweep' abd MinFreq=MaxFreq


%Abreviate Variable Names for easier handling
SamplingRate=SignalSettings.SamplingRate;
Duration=SignalSettings.Duration;
Form=SignalSettings.Form;
MinFreq=SignalSettings.MinFreq;
MaxFreq=SignalSettings.MaxFreq;
Volume=SignalSettings.Volume;%


global BpodSystem %we need this for volume adjustment
% Make chirp and fill into buffer

%generate noise vector
t=linspace(0,Duration,[SamplingRate*Duration]); %time vector for chirp
switch Form
    case 'LinearUpsweep'
        signal=chirp(t,MinFreq,Duration,MaxFreq);
        freqvec=MinFreq+(MaxFreq-MinFreq)*t;
    case 'LinearDownsweep' %gaussian noise from mean 0 std .25
        signal=chirp(t,MaxFreq,Duration,MinFreq);
        freqvec=MaxFreq+(MinFreq-MaxFreq)*t;
    case 'QuadraticConvex'
        tnew=t-mean(t);
        signal=chirp(tnew,MinFreq,Duration./2,MaxFreq,'quadratic',[],'convex'); %make chirp
        freqvec=MinFreq+(MaxFreq-MinFreq)./tnew(1)*tnew.^2;
end

%adjust volume of noise
SoundCal = BpodSystem.CalibrationTables.SoundCal;
if(isempty(SoundCal))
    disp('Error: no sound calibration file specified');
    return
end
toneAtt = polyval(SoundCal(1,1).Coefficient,freqvec);%Frequency dependent attenuation factor with less attenuation for higher frequency (based on calibration polynomial)
%toneAtt = [polyval(SoundCal(1,1).Coefficient,toneFreq)' polyval(SoundCal(1,2).Coefficient,toneFreq)']; in Torben's script
diffSPL = Volume - [SoundCal.TargetSPL];
attFactor = sqrt(10.^(diffSPL./10)); %sqrt(10.^(diffSPL./10)) in Torben's script WHY sqrt?
att = toneAtt.*attFactor;%this is the value for multiplying signal scaled/clipped to [-1 to 1]
signal=signal.*att;
end
=======
function [signal]=MakeSignalStimulus(SignalSettings)
%makes auditory signal sweep or beep the following properties 
%SignalSettings.Duration - Duration of signal in seconds
%SignalSettings.Form - 'LinearUpsweep','LinearDownweep','QuadraticConvex'
%SignalSettings.MinFreq - Minimal Frequency in Hz
%SignalSettings.MaxFreq - Maximal Frequency in Hz
%for beep set 'LinearUpweep' abd MinFreq=MaxFreq


%Abreviate Variable Names for easier handling
SamplingRate=SignalSettings.SamplingRate;
Duration=SignalSettings.Duration;
Form=SignalSettings.Form;
MinFreq=SignalSettings.MinFreq;
MaxFreq=SignalSettings.MaxFreq;
Volume=SignalSettings.Volume;%


global BpodSystem %we need this for volume adjustment
% Make chirp and fill into buffer

%generate noise vector
t=linspace(0,Duration,[SamplingRate*Duration+1]); %time vector for chirp
switch Form
    case 'LinearUpsweep'
        signal=chirp(t,MinFreq,Duration,MaxFreq);
        freqvec=MinFreq+(MaxFreq-MinFreq)*t;
    case 'LinearDownsweep' %gaussian noise from mean 0 std .25
        signal=chirp(t,MaxFreq,Duration,MinFreq);
        freqvec=MaxFreq+(MinFreq-MaxFreq)*t;
    case 'QuadraticConvex'
        tnew=t-mean(t);
        signal=chirp(tnew,MinFreq,Duration./2,MaxFreq,'quadratic',[],'convex'); %make chirp
        freqvec=MinFreq+(MaxFreq-MinFreq)./tnew(1)*tnew.^2;
end

%adjust volume of noise
SoundCal = BpodSystem.CalibrationTables.SoundCal;
if(isempty(SoundCal))
    disp('Error: no sound calibration file specified');
    return
end
toneAtt = polyval(SoundCal(1,1).Coefficient,freqvec);%Frequency dependent attenuation factor with less attenuation for higher frequency (based on calibration polynomial)
%toneAtt = [polyval(SoundCal(1,1).Coefficient,toneFreq)' polyval(SoundCal(1,2).Coefficient,toneFreq)']; in Torben's script
diffSPL = Volume - [SoundCal.TargetSPL];
attFactor = sqrt(10.^(diffSPL./10)); %sqrt(10.^(diffSPL./10)) in Torben's script WHY sqrt?
att = toneAtt.*attFactor;%this is the value for multiplying signal scaled/clipped to [-1 to 1]
signal=signal.*att;
end
>>>>>>> 1fe83add81c01a12fb42009e40612eae4da582b4
