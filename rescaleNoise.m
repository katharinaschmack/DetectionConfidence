function y=rescaleNoise(x,s)
% global TaskParameters
global BpodSystem

signalVec=((s)-.5)*(-2);%1 when signal, -1 when  no signal
noiseMax=60;%max(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);
noiseRange=40;%max(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume)-min(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);

y=(x-noiseMax)./noiseRange.*signalVec;
ndxZero=abs(y)<0.1;
ndxSignal=s==1;
y(ndxZero&ndxSignal)=0.01;
y(ndxZero&~ndxSignal)=-0.01;
end
