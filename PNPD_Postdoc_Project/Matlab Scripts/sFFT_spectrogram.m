
%% Short-time FFT by matlab built function spectrogram

% Flavio Mourao. Nucleo de Neurociencias NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais
% Started in:  07/2019
% Last update: 04/2020

%%

% Time window
short_fft.timewin    = 5200; % in ms

% Convert time window to points
short_fft.timewinpnts  = round(short_fft.timewin/(1000/parameters.srate));

% Number of overlap samples
short_fft.overlap = 90;
short_fft.noverlap = floor(short_fft.overlap*0.01*short_fft.timewinpnts);

% nFFT
short_fft.nFFT = 2^nextpow2(short_fft.timewinpnts);

% Spectrogram
% lines: frequencies / columns: time / third dimension: channels

for ii = 1:size(data.data{1,1},1)
    if ii ==1
       [short_fft.data(:,:,ii),short_fft.freq,short_fft.time] = spectrogram(data.data{1,1}(ii,:),short_fft.timewinpnts,short_fft.noverlap,short_fft.nFFT,parameters.srate);
    else
        short_fft.data(:,:,ii) = spectrogram(data.data{1,1}(ii,:),short_fft.timewinpnts,short_fft.noverlap,short_fft.nFFT,parameters.srate);
    end
end


clear ('ii','jj')



%% Define indexes  from spectrogram

% rows -> trials
% columns 1 -> time before sound epoch 
% columns 2 -> sound start
% columns 3 -> sound stop
% columns 4 -> time after sound epoch

% Sound epochs
short_fft.time_idx_t = (data.events.idx_t(:));
short_fft.time_idx(:,2:3) = reshape(dsearchn(short_fft.time',short_fft.time_idx_t),5,2);
short_fft.time_idx_t = reshape(short_fft.time_idx_t,5,2);  % just to keep the same format m x n

% Pre sound
short_fft.time_idx(:,1) = dsearchn(short_fft.time',(short_fft.time_idx_t(:,1) - parameters.Tpre));

% Pos sound
short_fft.time_idx(:,4) = dsearchn(short_fft.time',(short_fft.time_idx_t(:,2) + parameters.Tpos));

%% Organizing trials data from spectrogram 

% Concatenate trial epochs (pre sound, sound, pos sound) in fourth dimensions
% lines: frequencies / columns: time / third dimension: channels / fourth dimension: trials

short_fft.data_trials = complex(zeros(length(short_fft.freq),max(short_fft.time_idx(:,4)-short_fft.time_idx(:,1)) + 1,parameters.nch+1,parameters.NTrials));

for jj = 1:parameters.NTrials
    temp = short_fft.data(:,short_fft.time_idx(jj,1):short_fft.time_idx(jj,4),:);
    short_fft.data_trials(:,1:size(temp,2),:,jj) = temp;
    temp = [];
end

% Time vector to plot
short_fft.time_trials = (linspace(-parameters.Tpre,parameters.trialperiod+parameters.Tpos,size(short_fft.data_trials,2)));

% Concatenate trial epochs (pre sound) in fourth dimensions
% lines: frequencies / columns: time / third dimension: channels / fourth dimension: trials

short_fft.data_trials_pre = complex(zeros(length(short_fft.freq),max(short_fft.time_idx(:,2)-short_fft.time_idx(:,1)) + 1,parameters.nch+1,parameters.NTrials));

for jj = 1:parameters.NTrials
    temp = short_fft.data(:,short_fft.time_idx(jj,1):short_fft.time_idx(jj,2)-1,:);
    short_fft.data_trials_pre(:,1:size(temp,2),:,jj) = temp;
    temp = [];
end

% Time vector to plot
short_fft.time_trials_pre = (linspace(-parameters.Tpre,parameters.trialperiod,size(short_fft.data_trials_pre,2)));


% Concatenate trial epochs (sound period) in fourth dimensions
% lines: frequencies / columns: time / third dimension: channels / fourth dimension: trials

short_fft.data_trials_sound = complex(zeros(length(short_fft.freq),max(short_fft.time_idx(:,3)-short_fft.time_idx(:,2)) + 1,parameters.nch+1,parameters.NTrials));

for jj = 1:parameters.NTrials
    temp = short_fft.data(:,short_fft.time_idx(jj,2):short_fft.time_idx(jj,3),:);
    short_fft.data_trials_sound (:,1:size(temp,2),:,jj) = temp;
    temp = [];
end

% Time vector to plot
short_fft.time_trials_sound = (linspace(0,parameters.trialperiod,size(short_fft.data_trials_sound,2)));


clear ('temp','ii','jj')

%% Plot to check full session. Channels per substrate 

% Choose channel
ch = 14:17;

%Define frequencies to plot in each subplot
steps = diff(short_fft.freq); % according to the fft time window

short_fft.freq2plot = 40:steps(1):70;
closestfreq = dsearchn(short_fft.freq,short_fft.freq2plot');

figure

for ii = 1:length(ch)
    subplot(length(ch),1,ii)
    %suptitle({'Amplitude Spectrum via short-window FFT';['(window = ' num2str(short_fft.timewin./1000) 's' ' - ' 'overlap = ' num2str(short_fft.overlap) '%)']}) 
    set(gcf,'color','white')

    contourf(short_fft.time,short_fft.freq(closestfreq),abs(short_fft.data(closestfreq,:,ch(ii))),80,'linecolor','none');
    xlabel('Time (s)','FontSize',14), ylabel('Frequency (Hz)','FontSize',14)
    xlim([short_fft.time(1) 600])
    colorbar
    caxis([0 1.5*10^5])
end 

%% Plot to check - Pre sound and Sound period

% Choose channel
ch = 16;

%Define frequencies to plot in each subplot
steps = diff(short_fft.freq); % according to the fft time window

short_fft.freq2plot = 40:steps(1):70;
closestfreq = dsearchn(short_fft.freq,short_fft.freq2plot');

%Define time to plot in each subplot
time2plot1 = [ short_fft.time_idx(:,1),short_fft.time_idx(:,2) ]; % pre sound
time2plot2 = [ short_fft.time_idx(:,2),short_fft.time_idx(:,3) ]; % sound period

figure

subplot(3,5,[1 5])
suptitle({'Amplitude Spectrum via short-window FFT';['(window = ' num2str(short_fft.timewin./1000) 's' ' - ' 'overlap = ' num2str(short_fft.overlap) '%)']}) 
set(gcf,'color','white')

contourf(short_fft.time,short_fft.freq(closestfreq),abs(short_fft.data(closestfreq,:,ch)),80,'linecolor','none');
xlabel('Time (s)','FontSize',14), ylabel('Frequency (Hz)','FontSize',14)
xlim([short_fft.time(1) 600])
colorbar
caxis([0 1.5*10^5])

%colorbar('Location','eastoutside','YTick',[]);

for ii = 1:parameters.NTrials
    subplot(3,5,ii+5)
    plot(short_fft.freq, mean(abs(short_fft.data(:,time2plot1(ii,1):time2plot1(ii,2)-1,ch)),2),'k')
    xlim([0 100])
    ylim([0 15*10^4])
    box off
    title(['Trial: ',num2str(ii)]) 
end 

for ii = 1:parameters.NTrials
    subplot(3,5,ii+10)
    plot(short_fft.freq, mean(abs(short_fft.data(:,time2plot2(ii,1):time2plot2(ii,2),ch)),2),'k')
    xlim([0 100])
    ylim([0 15*10^4])
    xlabel('Frequencies (Hz)')
    ylabel('Energy')
    box off
    title(['Trial: ',num2str(ii)]) 
end 

clear ('ch','steps','closestfreq','time2plot1','time2plot2')

%% Plot to check - change from baseline

% Choose channel
ch = 16;

%Define frequencies to plot in each subplot
steps = diff(short_fft.freq); % according to the fft time window

short_fft.freq2plot = 40:steps(1):70;
closestfreq = dsearchn(short_fft.freq,short_fft.freq2plot');

%Define time to plot in each subplot
time2plot1 = [ short_fft.time_idx(:,1),short_fft.time_idx(:,2) ]; % pre sound
time2plot2 = [ short_fft.time_idx(:,2),short_fft.time_idx(:,3) ]; % sound period


figure

subplot(2,5,[1 5])
suptitle({'Amplitude Spectrum via short-window FFT';['(window = ' num2str(short_fft.timewin./1000) 's' ' - ' 'overlap = ' num2str(short_fft.overlap) '%)']}) 
set(gcf,'color','white')

contourf(short_fft.time,short_fft.freq(closestfreq),abs(short_fft.data(closestfreq,:,ch)),80,'linecolor','none');
xlabel('Time (s)','FontSize',14), ylabel('Frequency (Hz)','FontSize',14)
xlim([short_fft.time(1) 600])
colorbar
caxis([0 1.5*10^5])

%colorbar('Location','eastoutside','YTick',[]);

for ii = 1:parameters.NTrials
    subplot(2,5,ii+5)
    plot(short_fft.freq, mean(abs(short_fft.data(:,time2plot2(ii,1):time2plot2(ii,2),ch))./ mean(abs(short_fft.data(:,time2plot1(ii,1):time2plot1(ii,2)-1,ch)),2),2),'k');
    xlim([0 100])
    ylim([0 15])
    xlabel('Frequencies (Hz)')
    ylabel('Change from baseline')
    box off
    title(['Trial: ',num2str(ii)]) 
end 

clear ('ch','steps','closestfreq','time2plot1','time2plot2')
%% Plot to check - decibel normalization

% Choose channel
ch = 16;

%Define frequencies to plot in each subplot
steps = diff(short_fft.freq); % according to the fft time window

short_fft.freq2plot = 40:steps(1):70;
closestfreq = dsearchn(short_fft.freq,short_fft.freq2plot');

%Define time to plot in each subplot
time2plot1 = [ short_fft.time_idx(:,1),short_fft.time_idx(:,2) ]; % pre sound
time2plot2 = [ short_fft.time_idx(:,2),short_fft.time_idx(:,3) ]; % sound period


figure

subplot(2,5,[1 5])
suptitle({'Amplitude Spectrum via short-window FFT';['(window = ' num2str(short_fft.timewin./1000) 's' ' - ' 'overlap = ' num2str(short_fft.overlap) '%)']}) 
set(gcf,'color','white')

contourf(short_fft.time,short_fft.freq(closestfreq),abs(short_fft.data(closestfreq,:,ch)),80,'linecolor','none');
xlabel('Time (s)','FontSize',14), ylabel('Frequency (Hz)','FontSize',14)
xlim([short_fft.time(1) 600])
colorbar
caxis([0 1.5*10^5])

%colorbar('Location','eastoutside','YTick',[]);

for ii = 1:parameters.NTrials
    subplot(2,5,ii+5)
    plot(short_fft.freq, mean(10*log10(abs(short_fft.data(:,time2plot2(ii,1):time2plot2(ii,2),ch))./ mean(abs(short_fft.data(:,time2plot1(ii,1):time2plot1(ii,2)-1,ch)),2)),2),'k');
    xlim([0 100])
    ylim([-5 15])
    xlabel('Frequencies (Hz)')
    ylabel('Log Power (DB)')
    box off
    title(['Trial: ',num2str(ii)]) 
end 

clear ('ch','steps','closestfreq','time2plot1','time2plot2')

%% Plot all trials and mean trials to check

% Choose channel
ch = 16;

%Define frequencies to plot
steps = diff(short_fft.freq); % frequency steps according to the fft time window

short_fft.freq2plot = 50.7:steps(1):56.7;
closestfreq = dsearchn(short_fft.freq,short_fft.freq2plot');

figure
suptitle(['Amplitude Spectrum via short-window FFT (window = ' num2str(short_fft.timewin./1000) 's' ' - ' 'overlap = ' num2str(short_fft.overlap) '%)']) 
set(gcf,'color','white')

for ii=1:parameters.NTrials
    subplot (2,3,ii);
    contourf(short_fft.time_trials,short_fft.freq(closestfreq),(abs(short_fft.data_trials(closestfreq,:,ch, ii))),80,'linecolor','none');
    xlabel('Time (s)','FontSize',14), ylabel('Frequency (Hz)','FontSize',14)
    title(['Trial ', num2str(ii)]);
    colormap jet
    colorbar('Location','eastoutside','YTick',[]);
    caxis([0 1.5*10^5])

end 

subplot (2,3,6);
contourf(short_fft.time_trials,short_fft.freq(closestfreq),mean(abs(short_fft.data_trials(closestfreq,:,ch,:)),4),80,'linecolor','none');
xlabel('Time (s)','FontSize',14), ylabel('Frequency (Hz)','FontSize',14)
title('Mean Trials');
colormap jet
colorbar('Location','eastoutside','YTick',[]);
caxis([0 1.5*10^5])

clear ('steps','closestfreq','ii','s','jj');

%% last update 01/04/2020 - 18:00
%  listening: Mogwai - Every Country`s Sun

