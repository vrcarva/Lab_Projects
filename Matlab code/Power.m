
%% Mouse.short-time FFT by matlab built function spectrogram

% Flavio Mourao. Nucleo de Neurociencias NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais 11/2019


%%
% Choose substrate
substrate = 1;

% Choose filter
filter = 1;

% Time window
Mouse.short_fft.timewin    = 5200; % in ms

% Convert time window to points
Mouse.short_fft.timewinpnts  = round(Mouse.short_fft.timewin/(1000/Mouse.srate));

% Number of overlap samples
Mouse.short_fft.overlap = 90;
Mouse.short_fft.noverlap = floor(Mouse.short_fft.overlap*0.01*Mouse.short_fft.timewinpnts);

% nFFT
Mouse.short_fft.nFFT = 2^nextpow2(Mouse.short_fft.timewinpnts);

% Spectrogram
% lines: frequencies / columns: time / third dimension: channels
for ii = 1:size(Mouse.data{1,filter},1)
    if ii ==1
       [Mouse.short_fft.data(:,:,ii),Mouse.short_fft.freq,Mouse.short_fft.time] = spectrogram(Mouse.data{substrate,filter}(ii,:),Mouse.short_fft.timewinpnts,Mouse.short_fft.noverlap,Mouse.short_fft.nFFT,Mouse.srate);
    else
        Mouse.short_fft.data(:,:,ii) = spectrogram(Mouse.data{substrate,filter}(ii,:),Mouse.short_fft.timewinpnts,Mouse.short_fft.noverlap,Mouse.short_fft.nFFT,Mouse.srate);
    end
end

clear ('ii','filter')

%% Plot to check

% Choose channel
ch = 16;

%Define frequencies to plot in each subplot
steps = diff(Mouse.short_fft.freq); % according to the fft time window

Mouse.short_fft.freq2plot1 = 1:steps(1):100;
closestfreq1 = dsearchn(Mouse.short_fft.freq,Mouse.short_fft.freq2plot1');

figure

subplot(2,1,1)
suptitle({'Amplitude Spectrum via Mouse.short-window FFT';['(window = ' num2str(Mouse.short_fft.timewin./1000) 's' ' - ' 'overlap = ' num2str(Mouse.short_fft.overlap) '%)']}) 
set(gcf,'color','white')

contourf(Mouse.short_fft.time,Mouse.short_fft.freq(closestfreq1),abs(Mouse.short_fft.data(closestfreq1,:,ch)),80,'linecolor','none');
xlabel('Time (s)','FontSize',14), ylabel('Frequency (Hz)','FontSize',14)
%colorbar('Location','eastoutside','YTick',[]);

subplot(2,1,2)
plot(Mouse.short_fft.freq, mean(abs(Mouse.short_fft.data(:,:,ch)),2))
xlim([0 100])

clear ('ch','substrate','steps', 'closestfreq1','closestfreq2','closestfreq3', 'c1', 'c2', 'c3')

%% Plot to check all channels

%Define frequencies to plot in each subplot
steps = diff(Mouse.short_fft.freq); % according to the fft time window

Mouse.short_fft.freq2plot1 = 40:steps(1):70;
closestfreq1 = dsearchn(Mouse.short_fft.freq,Mouse.short_fft.freq2plot1');

figure
for ii = 1:size(Mouse.short_fft.data,3)

    subplot(4,4,ii)
    suptitle({'Amplitude Spectrum via Mouse.short-window FFT';['(window = ' num2str(Mouse.short_fft.timewin./1000) 's' ' - ' 'overlap = ' num2str(Mouse.short_fft.overlap) '%)']}) 
    set(gcf,'color','white')

    contourf(Mouse.short_fft.time,Mouse.short_fft.freq(closestfreq1),abs(Mouse.short_fft.data(closestfreq1,:,ii)),80,'linecolor','none');
    xlabel('Time (s)','FontSize',14), ylabel('Frequency (Hz)','FontSize',14)
    %colorbar('Location','eastoutside','YTick',[]);
end

figure
for ii = 1:size(Mouse.short_fft.data,3)
    subplot(4,4,ii)
    plot(Mouse.short_fft.freq, mean(abs(Mouse.short_fft.data(:,:,ii)),2))
    xlim([0 100])

    clear ('ch','substrate','steps', 'closestfreq1','closestfreq2','closestfreq3', 'c1', 'c2', 'c3')
end

%% Analyses Power Frequencies --- > need to fix to my expeirment

% Define time win
time_win = [300:300:3600]; 
time_idx = [0;dsearchn(Mouse.short_fft.time',time_win')];

% Define frequencies
steps = diff(Mouse.short_fft.freq); % according to the fft time window

% Theta
Mouse.short_fft.theta = 5:steps(1):8;
closest_theta = dsearchn(Mouse.short_fft.freq,Mouse.short_fft.theta');

% Gama1
Mouse.short_fft.gama1 = 30:steps(1):58;
closest_gama1 = dsearchn(Mouse.short_fft.freq,Mouse.short_fft.gama1');

% Gama2
Mouse.short_fft.gama2 = 62:steps(1):100;
closest_gama2 = dsearchn(Mouse.short_fft.freq,Mouse.short_fft.gama2');

% Define channels
ch = [ 1 2 8 9];

% first mean = average frequencies
% second mean = average the 5-min block

% Lines: 5-min block  / Colunms: channels

Mouse.short_fft.analyse_theta = zeros(length(time_idx)-1,length(ch));

for jj = 1:length(time_idx)-1
    Mouse.short_fft.analyse_theta(jj,:) = log10(mean(mean(abs(Mouse.short_fft.data(closest_theta,time_idx(jj)+1:time_idx(jj+1),ch)),1),2));
end
Mouse.short_fft.analyse_theta_meanGD  = mean(Mouse.short_fft.analyse_theta(:,1:2),2);
Mouse.short_fft.analyse_theta_meanCA1 = mean(Mouse.short_fft.analyse_theta(:,3:4),2);


Mouse.short_fft.analyse_gama1 = zeros(length(time_idx)-1,length(ch));

for jj = 1:length(time_idx)-1
    Mouse.short_fft.analyse_gama1(jj,:) = log10(mean(mean(abs(Mouse.short_fft.data(closest_gama1,time_idx(jj)+1:time_idx(jj+1),ch)),1),2));
end

Mouse.short_fft.analyse_gama1_meanGD  = mean(Mouse.short_fft.analyse_gama1(:,1:2),2);
Mouse.short_fft.analyse_gama1_meanCA1 = mean(Mouse.short_fft.analyse_gama1(:,3:4),2);

Mouse.short_fft.analyse_gama2 = zeros(length(time_idx)-1,length(ch));

for jj = 1:length(time_idx)-1
    Mouse.short_fft.analyse_gama2(jj,:) = log10(mean(mean(abs(Mouse.short_fft.data(closest_gama2,time_idx(jj)+1:time_idx(jj+1),ch)),1),2));
end

Mouse.short_fft.analyse_gama2_meanGD  = mean(Mouse.short_fft.analyse_gama2(:,1:2),2);
Mouse.short_fft.analyse_gama2_meanCA1 = mean(Mouse.short_fft.analyse_gama2(:,3:4),2);

clear ('time_win','time_idx','steps','closest_theta','closest_gama1','closest_gama2','ch','jj')

%% Plot Analyses Power Frequencies

subplot(1,2,1)
plot(mean(Mouse.short_fft.analyse_theta(:,3:4),2),'o-')
title ('CA1')
ylim([4 5])
yticks([4:.5:5])
ylabel('Log Power')
xticks([1:1:6])
xticklabels({'5','10','15','20','25','30'})
xlabel('Time (min)')

subplot(1,2,2)
plot(mean(Mouse.short_fft.analyse_theta(:,1:2),2),'o-')
title ('DG')
ylim([5 6])
yticks([5:.5:6])
ylabel('Log Power')
xticks([1:1:6])
xticklabels({'5','10','15','20','25','30'})
xlabel('Time (min)')

% analyse Mouse.short_fft

Mouse.short_fft.baseline_Mouse_b  = mean(abs(Mouse.short_fft_Mouse_b.data(:,:,:)),2);
Mouse.short_fft.baseline_s1_b  = mean(abs(Mouse.short_fft_s1_b.data(:,:,:)),2);


Mouse.short_fft.data_Mouse_1h = abs(Mouse.short_fft_Mouse_1h.data(:,:,:));
Mouse.short_fft.data_s1_1h = abs(Mouse.short_fft_s1_1h.data(:,:,:));

Mouse.short_fft.normalize_data_Mouse = (Mouse.short_fft.data_Mouse_1h./Mouse.short_fft.baseline_Mouse_b);
Mouse.short_fft.normalize_data_s1 = (Mouse.short_fft.data_s1_1h./Mouse.short_fft.baseline_s1_b);

Mouse.short_fft.time = Mouse.short_fft_Mouse_1h.time;
Mouse.short_fft.freq = Mouse.short_fft_Mouse_1h.freq;

%% Choose channel
ch = 1;

%Define frequencies to plot in each subplot
steps = diff(Mouse.short_fft.freq); % according to the fft time window

Mouse.short_fft.freq2plot1 = 1:steps(1):100;
closestfreq1 = dsearchn(Mouse.short_fft.freq,Mouse.short_fft.freq2plot1');

figure(2), clf
suptitle('Amplitude Spectrum via Mouse.short-window FFT - memantine 1h') 
set(gcf,'color','white')

contourf(Mouse.short_fft.time,Mouse.short_fft.freq(closestfreq1),Mouse.short_fft.normalize_data_Mouse(closestfreq1,:,ch),10,'linecolor','none');
xlabel('Time (s)','FontSize',14), ylabel('Frequency (Hz)','FontSize',14)
colormap jet

figure(3), clf
suptitle('Amplitude Spectrum via Mouse.short-window FFT - saline 1h') 
set(gcf,'color','white')

contourf(Mouse.short_fft.time,Mouse.short_fft.freq(closestfreq1),Mouse.short_fft.normalize_data_s1(closestfreq1,1:1155,ch),10,'linecolor','none');
xlabel('Time (s)','FontSize',14), ylabel('Frequency (Hz)','FontSize',14)
colormap jet


%% pwelch

% Choose substrate
substrate = 1;

% Choose filter
filter = 1;


Mouse.pw.timewin    = 5200; % in ms

% Convert time window to points
Mouse.pw.timewinpnts  = round(Mouse.pw.timewin/(1000/Mouse.srate));

% nFFT
Mouse.pw.nFFT = 2^nextpow2(Mouse.pw.timewinpnts);

%[pxx,f] = pwelch(x,window,noverlap,f,fs)

for ii = 1:size(Mouse.data{substrate,filter},1)
    if ii ==1
       [Mouse.pw.Pxx(ii,:),Mouse.pw.f] = pwelch(Mouse.data{substrate,filter}(ii,:),Mouse.pw.nFFT,Mouse.pw.nFFT*.5,Mouse.pw.nFFT,Mouse.srate);
    else
       Mouse.pw.Pxx(ii,:) = pwelch(Mouse.data{substrate,filter}(ii,:),Mouse.pw.nFFT,Mouse.pw.nFFT*.5,Mouse.pw.nFFT,Mouse.srate);
    end
end

clear ('substrate','filter','ii')

%% plot PSD

% choose channel
ch = 2

subplot(1,2,1)
plot(Mouse.pw.f,abs(Mouse.pw.Pxx(ch,:)),'k','linewidth',1)
xlim([0 150])
ylim([0 500])
xlabel('frequencies')
ylabel('PSD')
box off

subplot(1,2,2)
plot(Mouse.pw.f,10*log10(abs(Mouse.pw.Pxx(ch,:))),'k','linewidth',1)
xlim([0 150])
%title ('pwelch')
xlabel('frequencies')
ylabel('PSD (dB/Hz)')

suptitle('Welch power spectral density estimate')
set(gcf,'color','w');
box off

clear ('ch','filter','substrate')

%% Analyses PSD

% Define channels
ch = [ 1 2 8 9];

pw.analyse = log10(abs(pw.Pxx(ch,:)));
pw.analyse_meanGD  = mean(pw.analyse(1:2,:),1);
pw.analyse_meanCA1 = mean(pw.analyse(3:4,:),1);

subplot(1,2,1)
plot(pw.f,pw.analyse_meanGD,'k','linewidth',1)
xlim([0 100])
title ('GD')
xlabel('frequencies')
ylabel('PSD Log power')
box off

subplot(1,2,2)
plot(pw.f,pw.analyse_meanCA1,'k','linewidth',1)
xlim([0 100])
title ('CA1')
xlabel('frequencies')
ylabel('PSD Log power')
box off

suptitle('Welch power spectral density estimate')
set(gcf,'color','w');


clear ('ch')
%%
figure
plot(pw_Mouseh.f,pw_Mouseh.analyse_meanCA1,'Color','[0.6350, 0.0780, 0.1840]','linewidth',1)
xlim([0 100])
hold
plot(pw_s1h.f,pw_s1h.analyse_meanCA1,'k','linewidth',1)
xlim([0 100])
suptitle('1h')

figure
plot(log10(pw_mb.f),pw_mb.analyse_meanCA1,'Color','[0.6350, 0.0780, 0.1840]','linewidth',1)
xlim([0 100])
hold
plot(log10(pw_sb.f),pw_sb.analyse_meanCA1,'k','linewidth',1)
xlim([0 100])
suptitle('basal')