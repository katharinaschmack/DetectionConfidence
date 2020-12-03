function stopPhotometryAcq
    global nidaq   
%     %% hack for switching off LED
%     % set amplitude to zero
%     for channelIndex = 1:length(nidaq.channelsOn)
%         channel = nidaq.channelsOn(channelIndex);
%         nidaq.(['LED' num2str(channel) '_amp'])=0;
%     end
%     
%     %wait for a little longer than refresh period to make sure that zero data is read 
%     %(I could use this time for data copying if I wanted to be super
%     %efficient)
%     pause(1.1*nidaq.refreshPeriod);
    
    %% start session
    nidaq.session.stop(); %  ~0.002 seconds after state matrix is done.
    wait(nidaq.session);
    nidaq.session.outputSingleScan(zeros(1, length(nidaq.channelsOn))); % make sure LEDs are turned off
    
