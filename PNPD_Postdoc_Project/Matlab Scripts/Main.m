
%% Main - Analysis and Plots

% by Flavio Mourao. Nucleo de Neurociencias - NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais. 

% Started in:  03/2020
% Last update: 04/2020

%% Follow the scripts below sequentially

% 1)
Extracting_raw_LFPs_and_events
% 2)
Pre_processing

%% Check frequency band based on data cursor/cursor info

% f = 1/(cursor_info(1,1).Position(1,1)-cursor_info(1,2).Position(1,1));

%% Filters - Plot to check

% Choose filter band
ff = 10;

% choose a channel to plot
ch = 3;

figure
set(gcf,'color','white')
box 'off'

hold all

plot(data.timev,data.data{1,ff}(ch,:),'Color', '[0.7 0.7 0.7]','linew',1);

% Set the transparency of lines for the Light events
% In newer versions of MATLAB you can do that easily using the Color property of the line.
% By default it is RGB array (1 x 3). Yet if you set it to RGBA (1 x 4) the last value is the alpha of the color.
plot(data.events.ts_vid,zeros(1,length(data.events.ts_vid)),'ko');
plot(data.timev,data.data{1,1}(1,:).* (max(data.data{1,ff}(ch,:)/2)),'Color','[0.6350, 0.0780, 0.1840,0.2000]','linew',2);

a = gca; % Get axis

% Set Axis
a.XLim = ([0 data.timev(end)]);
xlabel('Time (s)'), ylabel('Voltage (\muV)')

title('Sound Envelope and video track events over Data')
legend('Raw data','Rising edges of video frame blocks','Sound Envelope')

zoom on

clear('a','ch')
%% Plot to check all channels

% Choose filter band
ff = 10;

% Choose channels to plot
channels = 1:4;

% factor
factor = (channels)'*500;

% Set Figure
figure
set(gcf,'color','white')
box 'off'
hold on

% Select fields with data
r = plot(data.timev, bsxfun(@plus, data.data{1, ff}(channels,:), factor))%,'Color','[0.7, 0.7, 0.7]');
a = gca; % Get axis

% Plot sound epochs
%I = plot([data.events.idx_t(:)';data.events.idx_t(:)'], [zeros(1,length(data.events.idx_t(:)));a.YLim(2)*(ones(1,length(data.events.idx_t(:))))],'Color',[0.6350, 0.0780, 0.1840]','linew',2);

% Set Axis
a.YColor = 'w';
a.YTick = [];
a.XLim = [10 180];
xlabel('Time (s)')

% Clear trash
clear ('factor','channels','filter','substrate','session','str','sub','r','a','I','lh','lh_pos');

%% Plot to check all channels separately

figure

% Choose filter band
ff = 10;

% Choose channels to plot
channels = 1:4;


for ii = 1:length(channels)
    subplot(4,5,ii)
    plot(data.timev,data.data{1,ff}(ii,:),'k')
    
    %ylim([min(data.data{1,ff}(ii,:)) max(data.data{1,ff}(ii,:))])
    ylim([-500 500])
    xlim([0 round(max(data.timev))]);
    xlim([0 20]);

    %yticklabels({'-1','0','1'})
    title(['channel ',num2str(ii)])
    xlabel('Time (s)')
    ylabel('mV')
    box off
end

set(gcf,'color','w');
  
clear ('ii','filter','substrate','channels')

%% Pre Processing - Plot to check Trials

% Choose filter band
ff = 1;

% Choose channel to plot
ch = 16;

% Set Figure
figure
set(gcf,'color','white')


for ii = 1:parameters.NTrials
    subplot(1,5,ii)
    hold on
    plot(data.time_trials,data.data_trials{1,ff}(ch,:,ii),'Color', '[0.7 0.7 0.7]','linew',2)
    plot(data.time_trials,data.data_trials{1,ff}(1,:,ii).* 200,'Color','[0.6350, 0.0780, 0.1840, 0.2]','linew',2)
    
    ylim([-500 500]);
    xlim([-parameters.Tpre parameters.trialperiod + parameters.Tpos]);
    title(['Trial ',num2str(ii)])
    xlabel('Time (s)')
    ylabel('mV')
    box off

end
  
clear ('ii','ff','ch')

%%
