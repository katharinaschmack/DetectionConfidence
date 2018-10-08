function y=inverseRescaleNoise(x)
% global TaskParameters
global BpodSystem
noiseMax=60;%max(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);
noiseRange=40;%max(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume)-min(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);
y=(-abs(x)*noiseRange+noiseMax);
end
