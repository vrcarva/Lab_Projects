%% Preparing data and figures from .mat files
%  - Extract the descriptive stats from Short-time FFT analyses based on Spectrogram

% Flavio Mourao. Nucleo de Neurociencias NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais 02/2020

%% Extract the descriptive stats

% Define frequencies to plot
steps = diff(short_fft.freq); % frequency steps according to the fft time window

short_fft.freq2plot = 53.67:steps(1):53.78;
closestfreq = dsearchn(short_fft.freq,short_fft.freq2plot');

% Cell Row 1 -> mean over trials (full period considering pre, sound and pos)
% Cell Row 2 -> total mean for each trial (only sound period) normalize from baseline (30s before sound period)
% Cell Row 3 -> total mean session (only sound period) normalize from baseline (30s before sound period)
% Cell Row 4 -> Standart deviation over trials (full period considering pre, sound and pos)
% Cell Row 5 -> Standart error of mean (SEM) over trials (full period considering pre, sound and pos)
%               (SEM is calculated by taking the standard deviation and dividing 
%               it by the square root of the sample size)

% Cell columns --> substrates according to the channels order

short_fft.stats = cell(5, length(short_fft.data_Sound));

for ii=1:length(short_fft.data_Sound)
    
    % Mean
    short_fft.stats{1,ii} = mean(mean(abs(short_fft.data_full_period{ii}(closestfreq,:,:)),1),3); % full period (pre,sound, pos)
    short_fft.stats{2,ii} = mean(squeeze(mean(abs(short_fft.data_Sound{ii}(closestfreq,:,:)),1)),1);
    short_fft.stats{3,ii} = mean(mean(squeeze(mean(abs(short_fft.data_Sound{ii}(closestfreq,:,:)),1)),1));
    
    % Standart deviation
    short_fft.stats{4,ii} = std(mean(abs(short_fft.data_full_period{ii}(closestfreq,:,:)),1),[],3);
    % Standart error of mean
    short_fft.stats{5,ii} = short_fft.stats{4,ii}/sqrt(size(short_fft.stats{4,ii},2)); 

end 

% Baseline normalization
short_fft.stats_basenorm = cell(5, length(short_fft.data_Sound));

for ii=1:length(short_fft.data_Sound)
    
    % Mean    
    baseline(ii,:) = mean(squeeze(mean(abs(short_fft.data_PreSound{ii}(closestfreq,:,:)),1)),1);

    short_fft.stats_basenorm{1,ii} = mean(squeeze(mean(abs(short_fft.data_full_period{ii}(closestfreq,:,:)),1))./baseline(ii,:),2); % full period (pre,sound, pos)
    short_fft.stats_basenorm{2,ii} = mean(squeeze(mean(abs(short_fft.data_Sound{ii}(closestfreq,:,:)),1))./baseline(ii,:),1);
    short_fft.stats_basenorm{3,ii} = mean(mean(squeeze(mean(abs(short_fft.data_Sound{ii}(closestfreq,:,:)),1))./baseline(ii,:),1));
    
    % Standart deviation
    short_fft.stats_basenorm{4,ii} = std(mean(abs(short_fft.data_full_period{ii}(closestfreq,:,:)),1),[],3);
    % Standart error of mean
    short_fft.stats_basenorm{5,ii} = short_fft.stats{4,ii}/sqrt(size(short_fft.stats{4,ii},2)); 

end 

clear('baseline','closestfreq','ii','steps')

%% Plot with baseline normalization

figure
suptitle({'Mean Power Spectrum over time via short-window FFT';['(window = ' num2str(short_fft.timewin./1000) 's' ' - ' 'overlap = ' num2str(short_fft.overlap) '%)'];[]}) 
set(gcf,'color','white')

for ii=1:size(short_fft.stats,2)
    subplot (1,3,ii);
    yabove = short_fft.stats_basenorm{1, ii}' + short_fft.stats_basenorm{5, ii};
    ybelow = short_fft.stats_basenorm{1, ii}' - short_fft.stats_basenorm{5, ii};
    fill([short_fft.time_full_period fliplr(short_fft.time_full_period)], [yabove fliplr(ybelow)], [.9 .9 .9], 'linestyle', 'none') %Funcao Filled 2-D polygons
    hold all
    plot(short_fft.time_full_period,short_fft.stats_basenorm{1, ii},'Color','[0.6350, 0.0780, 0.1840]','linew',1)
    plot([0 0],[0 12],'k--')
    xlabel('Time (s)','FontSize',14), ylabel({'Energy'; '(Change from baseline)'},'FontSize',14)
    xlim([-30 39])
    ylim([.5 12])
    axis square
    legend('SEM','Mean','location','northwest')
    legend boxoff
    box off
end 

clear('baseline','ii','yabove','ybelow')
%% Plot without baseline normalization
% 
% figure
% suptitle({'Mean Power Spectrum over time via short-window FFT';['(window = ' num2str(short_fft.timewin./1000) 's' ' - ' 'overlap = ' num2str(short_fft.overlap) '%)'];[]}) 
% set(gcf,'color','white')
% 
% for ii=1:size(short_fft.stats,2)
%     subplot (1,3,ii);
%     yabove = short_fft.stats{1, ii} + short_fft.stats{5, ii};
%     ybelow = short_fft.stats{1, ii} - short_fft.stats{5, ii};
%     fill([short_fft.time_full_period fliplr(short_fft.time_full_period)], [yabove fliplr(ybelow)], [.9 .9 .9], 'linestyle', 'none') %Funcao Filled 2-D polygons
%     hold all
%     plot(short_fft.time_full_period,short_fft.stats{1, ii},'Color','[0.6350, 0.0780, 0.1840]','linew',1)
%     plot([0 0],[0 max(short_fft.stats{1, 1})],'k--')
%     xlabel('Time (s)','FontSize',14), ylabel('Power ({\mu}m)','FontSize',14)
%     xlim([-30 39])
%     ylim([0 max(short_fft.stats{1, 1})])
%     axis square
%     legend('SEM','Mean','location','northwest')
%     legend boxoff
%     box off
% end 

%% last update 18/02/2020 - 01:05am
%  listening: Set Fire To Flames - Fading Lights Are Fading