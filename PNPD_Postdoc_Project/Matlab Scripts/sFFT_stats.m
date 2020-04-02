%% Extract the descriptive stats from Short-time FFT analyses based on Spectrogram

% Flavio Mourao. Nucleo de Neurociencias NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais 02/2020

%% Extract the descriptive stats

% Define frequencies to plot
steps = diff(short_fft.freq); % frequency steps according to the fft time window

short_fft.freq2plot = 4:steps(1):8;
closestfreq = dsearchn(short_fft.freq,short_fft.freq2plot');

% Cell Row 1 -> mean over trials (full period considering pre, sound and pos)
% Cell Row 2 -> total mean for each trial (only sound period) normalize from baseline (30s before sound period)
% Cell Row 3 -> total mean session (only sound period) normalize from baseline (30s before sound period)
% Cell Row 4 -> Standart deviation over trials (full period considering pre, sound and pos)
% Cell Row 5 -> Standart error of mean (SEM) over trials (full period considering pre, sound and pos)
%               (SEM is calculated by taking the standard deviation and dividing 
%               it by the square root of the sample size)

% Cell columns --> Band pass (for now working only with the modulating
%                  frequency)

short_fft.stats = cell(5, size(short_fft.freq2plot,1));

% Mean
short_fft.stats{1,1} = squeeze(mean(mean(abs(short_fft.data_trials(closestfreq,:,:,:)),1),4))';          % full period (pre,sound, pos)
short_fft.stats{2,1} = squeeze(mean(mean(abs(short_fft.data_trials_sound(closestfreq,:,:,:))./ mean(abs(short_fft.data_trials_pre(closestfreq,:,:,:)),2),1),2));
short_fft.stats{3,1} = mean(short_fft.stats{2,1},2);
    
% Standart deviation
short_fft.stats{4,1} = squeeze(std(mean(abs(short_fft.data_trials(closestfreq,:,:,:)),1),[],4))';
% Standart error of mean
short_fft.stats{5,1} = short_fft.stats{4,1}./sqrt(size(short_fft.stats{4,1},2)); 

clear('closestfreq','ii','steps')

%% Plot full period considering pre, sound and pos

% Choose channels
ch = 2:17;

figure
suptitle({'Mean Power Spectrum over time via short-window FFT';['(window = ' num2str(short_fft.timewin./1000) 's' ' - ' 'overlap = ' num2str(short_fft.overlap) '%)'];[]}) 
set(gcf,'color','white')

for jj = 1:size(short_fft.stats,2) 
    for ii = 1:length(ch)
        subplot (4,4,ii);
        yabove = short_fft.stats{1, jj}(ch(ii),:) + short_fft.stats{5, jj}(ch(ii),:);
        ybelow = short_fft.stats{1, jj}(ch(ii),:) - short_fft.stats{5, jj}(ch(ii),:);
        fill([short_fft.time_trials fliplr(short_fft.time_trials)], [yabove fliplr(ybelow)], [.9 .9 .9], 'linestyle', 'none') %Funcao Filled 2-D polygons
        hold all
        plot(short_fft.time_trials,short_fft.stats{1, jj}(ch(ii),:),'Color','[0.6350, 0.0780, 0.1840]','linew',1)
        plot([0 0],[0 12],'k--')
        xlabel('Time (s)','FontSize',14), ylabel('Energy','FontSize',14)
        xlim([-30 39])

        axis square
        legend('SEM','Mean','location','northeastoutside')
        legend boxoff
        box off
        
%         if ii < 13
            ylim([.5 7*10^4])
%         else
%            ylim([.5 14*10^4])
%            
%         end
    end 
end 

clear('baseline','ii','yabove','ybelow')


%% last update 02/04/2020 - 01:05am
%  listening: Set Fire To Flames - Fading Lights Are Fading