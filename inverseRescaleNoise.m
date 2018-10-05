function y=inverseRescaleNoise(x)
global TaskParameters
global BpodSystem
noiseMax=max(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);
noiseRange=max(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume)-min(TaskParameters.GUI.NoiseVolumeTable.NoiseVolume);
y=(-abs(x)*noiseRange+noiseMax);
end
