%% Extract the descriptive stats from Short-time FFT analyses based on Spectrogram

% Flavio Mourao. Nucleo de Neurociencias NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais
% Started in:  02/2020
% Last update: 04/2020

%% Extract the descriptive stats

% Define frequencies cutoff 

steps = diff(short_fft.freq); % frequency steps according to the fft time window

short_fft.freq2plot{1,1}   = 53.4:steps(1):54;    % 1 - modulator
short_fft.freq2plot{1,2}   = 1:steps(1):3;        % 2 - deltacutoff 
short_fft.freq2plot{1,3}   = 4:steps(1):8;        % 3 - thetacutoff1
short_fft.freq2plot{1,4}   = 9:steps(1):12;       % 4 - thetacutoff2
short_fft.freq2plot{1,5}   = 13:steps(1):15;      % 5 - alpha
short_fft.freq2plot{1,6}   = 16:steps(1):31;      % 6 - beta
short_fft.freq2plot{1,7}   = 30:steps(1):50;      % 7 - lowgamma
short_fft.freq2plot{1,8}   = 62:steps(1):100;     % 8 - highgamma
short_fft.freq2plot{1,9}   = 150:steps(1):200;    % 9 - extracutoff1
short_fft.freq2plot{1,10}  = 1:steps(1):100;      % 10 - extracutoff2
%short_fft.freq2plot{1,10} = 300:steps(1):3000;    % 11 - extracutoff3


% Cell Row 1 -> mean over trials (full period considering pre, sound and pos)
% Cell Row 2 -> total mean for each trial (only sound period) normalize from baseline (30s before sound period)
% Cell Row 3 -> total mean session (only sound period) normalize from baseline (30s before sound period)
% Cell Row 4 -> Standart deviation over trials (full period considering pre, sound and pos)
% Cell Row 5 -> Standart error of mean (SEM) over trials (full period considering pre, sound and pos)
%               (SEM is calculated by taking the standard deviation and dividing 
%               it by the square root of the sample size)

% Cell columns --> frequencies cutoff 

% Initialize
short_fft.stats = cell(5, size(short_fft.freq2plot,2));

% loop over frequencies
for ii = 1:size(short_fft.freq2plot,2)
    
closestfreq = dsearchn(short_fft.freq,short_fft.freq2plot{ii}');

% Mean
short_fft.stats{1,ii} = squeeze(mean(mean(abs(short_fft.data_trials(closestfreq,:,:,:)),1),4))';  % full period (pre,sound, pos)
short_fft.stats{2,ii} = squeeze(mean(mean(abs(short_fft.data_trials_sound(closestfreq,:,:,:))./ mean(abs(short_fft.data_trials_pre(closestfreq,:,:,:)),2),1),2));
short_fft.stats{3,ii} = mean(short_fft.stats{2,ii},2);
    
% Standart deviation
short_fft.stats{4,ii} = squeeze(std(mean(abs(short_fft.data_trials(closestfreq,:,:,:)),1),[],4))';
% Standart error of mean
short_fft.stats{5,ii} = short_fft.stats{4,1}./sqrt(size(short_fft.stats{4,ii},2)); 

closestfreq = [];

end

clear('closestfreq','ii','steps')

%% Plot full period considering pre, sound and pos

% Choose channels
ch = 2:17;

figure
suptitle({'Mean Power Spectrum over time via short-window FFT';['(window = ' num2str(short_fft.timewin./1000) 's' ' - ' 'overlap = ' num2str(short_fft.overlap) '%)'];[]}) 
set(gcf,'color','white')

% select the frequency range
fr = 3;

for ii = 1:length(ch)
    subplot (4,4,ii);
    yabove = short_fft.stats{1, fr}(ch(ii),:) + short_fft.stats{5, fr}(ch(ii),:);
    ybelow = short_fft.stats{1, fr}(ch(ii),:) - short_fft.stats{5, fr}(ch(ii),:);
    fill([short_fft.time_trials fliplr(short_fft.time_trials)], [yabove fliplr(ybelow)], [.9 .9 .9], 'linestyle', 'none') %Funcao Filled 2-D polygons
    hold all
    plot(short_fft.time_trials,short_fft.stats{1, fr}(ch(ii),:),'Color','[0.6350, 0.0780, 0.1840]','linew',1)
    plot([0 0],[0 max(short_fft.stats{1, fr}(ch(ii),:))],'k--')
    plot([30 30],[30 max(short_fft.stats{1, fr}(ch(ii),:))],'k--')
    xlabel('Time (s)','FontSize',14), ylabel('Energy','FontSize',14)
    xlim([-30 39])

    axis square
    legend('SEM','Mean','location','northeastoutside')
    legend boxoff
    box off
        
%  if ii < 13
%     ylim([.5 7*10^4])
%  else
%     ylim([.5 14*10^4])
            
%  end
end 

clear('fr','baseline','ii','yabove','ybelow')


%% last update 03/04/2020 - 20:03am
%  listening: Pink Floyd - Dogs