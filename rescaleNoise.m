function y=rescaleNoise(x,s)
global TaskParameters
global BpodSystem

signalVec=((s)-.5)*(-2);%1 when signal, -1 when  no signal
noiseMax=max(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);
noiseRange=max(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume)-min(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);

y=(x-noiseMax)./noiseRange.*signalVec;
ndxZero=y<0.1;
ndxSignal=BpodSystem.Data.Custom.EmbedSignal==1;
y(ndxZero&ndxSignal)=0.1;
y(ndxZero&~ndxSignal)=-0.1;
end
