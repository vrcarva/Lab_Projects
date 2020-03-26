clear all
clc

%% Extracting raw LFPs and Events from Open Ephys

% - Load channels and events and performs channels checks
% - Filter channels by John function (based on EEG_lab) - fun_myfilters.m

% Down sampling data:
% Cell Variable "Mouse.data" -> Lines: different substrates / Columns: frequency bands filtered.
%                               wherein the first cell column is the intact signal without filters.


% Flavio Mourao. Nucleo de Neurociencias NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais 11/2019

%% Run each session sequentially

%%
% Load files (*.continuous -> LFP and *.events -> Events)
[FilesLoaded,Mouse.Path] = uigetfile({'*.continuous; *.events'},'MultiSelect', 'on'); % Define file type *.*

% Define a struct with files informations from dir organization'
Mouse.FilesLoaded = repmat(struct('name',[],'folder',[],'date',[],'bytes',[],'isdir',[],'datenum',[]), 1, length(FilesLoaded));

% Filename can be organize as a single char or a group char in a cell depending on the number os files selected
if ischar(FilesLoaded)
   Mouse.FilesLoaded = dir(fullfile(Mouse.Path, FilesLoaded)); % condition for a single file selected       
else    
   for ii = 1:length(FilesLoaded) % loop over multiple files selected
       Mouse.FilesLoaded(ii) = dir(fullfile(Mouse.Path, char(FilesLoaded(ii))));
   end 
end  

% Optional - Uncomment the line below for sort Mouse.Channels based on a specific file properties. 
% Mouse.Channels = nestedSortStruct(Mouse.FilesLoaded,'name',1); % Perform a nested sort of a struct array based on multiple fields. 
                                                                 % >>> https://uk.mathworks.com/matlabcentral/fileexchange/28573-nested-sort-of-structure-arrays?focused=5166120&tab=function

% Choose factor to LFP down sampling
down_sampling = 1; 

% Number of channels recorded
Mouse.nch = 16;

% Loop to extract data

for jj = 1:length(Mouse.FilesLoaded)
    baseFileName = Mouse.FilesLoaded(jj).name;
    fullFileName = fullfile(Mouse.Path,baseFileName);
    
    %Identify the file extension
    [~, ~, fExt] = fileparts(baseFileName);
    
    
    switch lower(fExt)
                
        % Case for load channels
        
        case '.continuous'
    
        % Identify the channel number and print the name on the Command Window:
        % channels   1 to 16 and/or 17 to 32

        channel = split(baseFileName,{'100_CH','.continuous'});
        fprintf(1, '\nExtracting LFP from Channel %s\n', channel{2, 1}); 
        
        
        if      jj == 1 
                % Load datafiles (*.continuous), timestamps e record info.
                % Raw data - Rows: Time  x Columns: Channels
                [Mouse.raw_data, Mouse.timev_raw, info] = load_open_ephys_data(fullFileName);
                Mouse.raw_data = detrend(Mouse.raw_data);                 
                Mouse.header = info.header;   % Data File Header
                 
                % Down_sampling with decimate function
                % data - Rows: Channels x Columns: Time
                Mouse(1,1).data{1,1}  = zeros(Mouse.nch, ceil(length(Mouse.raw_data)/down_sampling));
                Mouse.data{1,1}(jj,:) = decimate(Mouse.raw_data,down_sampling);
                                           
                % Organize parameters according to the downsampling information
                Mouse.srate  = info.header.sampleRate./down_sampling;  % Sampling frequency after downsamplig(Hz)
                Mouse.header.downsampling = down_sampling; 
                
                % Normalizing time vector
                Mouse.timev  = (Mouse.timev_raw(1:down_sampling:end)) - min(Mouse.timev_raw);  % Time stamp (sec)
          
        else 
            
                % Load datafiles (*.continuous).
                % Rows: Channels x Columns: Times
                Mouse.raw_data(:,jj)  = detrend(load_open_ephys_data(fullFileName)); % raw data
                Mouse.data{1,1}(jj,:) = decimate(Mouse.raw_data(:,jj),down_sampling); % Down_sampling with decimate function
      
        end
        
        % Case for load events
         
        case '.events'
                
        % Identify TTL events file and print the name on the Command Window:   
        fprintf(1, '\nExtracting %s\n', 'all_channels.events'); 
        
        % Load datafiles (*.continuous), timestamps e record info.
        [Mouse.events.labels, Mouse.events.ts, Mouse.events.info] = load_open_ephys_data(fullFileName);
        
        % Normalizing time vector
        Mouse.events.ts =  Mouse.events.ts - min(Mouse.events.ts);
    end
end                                                   

clear ('baseFileName','channel','down_sampling','fExt','FilesLoaded','fullFileName','ii','info','jj');                                                     


fprintf('\n Done. \n');

%% filter bands


cutoff1         = [300 3000];      % 1
cutoff2         = [1 300];   % 2
deltacutoff     = [300 2000];        % 3
% thetacutoff     = [4 12];       % 4
% alphacutoff     = [13 15];      % 5
% betacutoff      = [16 31];      % 6
% lowgammacutoff  = [30 58];      % 7
% highgammacutoff = [62 100];     % 8
% extracutoff     = [150 200];    % 9

for ii = 1:size(Mouse.data,1)
    for jj = 1:size(Mouse.data{ii,1},1)
        Mouse.data{ii,1}(jj,:) = fun_myfilters(Mouse.data{ii,1}(jj,:),Mouse.srate,cutoff1,'iir','1');
        Mouse.data{ii,2}(jj,:) = fun_myfilters(Mouse.data{ii,1}(jj,:),Mouse.srate,cutoff2,'iir','1');
        Mouse.data{ii,3}(jj,:) = fun_myfilters(Mouse.data{ii,1}(jj,:),Mouse.srate,deltacutoff,'iir','1');
%         Mouse.data{ii,4}(jj,:) = fun_myfilters(Mouse.data{ii,1}(jj,:),Mouse.srate,thetacutoff,'iir','1');
%         Mouse.data{ii,5}(jj,:) = fun_myfilters(Mouse.data{ii,1}(jj,:),Mouse.srate,alphacutoff,'iir','1');
%         Mouse.data{ii,6}(jj,:) = fun_myfilters(Mouse.data{ii,1}(jj,:),Mouse.srate,betacutoff,'iir','1');
%         Mouse.data{ii,7}(jj,:) = fun_myfilters(Mouse.data{ii,1}(jj,:),Mouse.srate,lowgammacutoff,'iir','1');
%         Mouse.data{ii,8}(jj,:) = fun_myfilters(Mouse.data{ii,1}(jj,:),Mouse.srate,highgammacutoff,'iir','1');
        % Mouse.data{ii,8}(jj,:) = fun_myfilters(Mouse.data{ii,1}(jj,:),Mouse.srate,extracutoff,'iir','1');   
    end
end

%% Sort Events

% Trigger/label 1 - > video - vid
label1 = 1;

% Trigger/label 2 - > sound modulator - mod
label2 = 2;

% Label 1 - Sort timestamps for independent events (out of trigger 2 time window)
Mouse.events.ts_vid = Mouse.events.ts(Mouse.events.labels(:,1)==label1);

% Label 2 - Sort timestamps for all events
Mouse.events.ts_mod = Mouse.events.ts(Mouse.events.labels(:,1)==label2);

%% plot to check events

% channel to plot
ch = 31

figure

hold all

plot(Mouse.timev,Mouse.data{1,1}(17,:),'Color', '[0.7 0.7 0.7]');
plot(Mouse.events.ts_vid,zeros(1,length(Mouse.events.ts_vid)),'ro');
plot(Mouse.events.ts_mod,zeros(1,length(Mouse.events.ts_mod)),'bo');

%% Organizing channels according to the electrods map

% Channels order - correted channels map to matlab lines
% mPFC 
ch_order1 = [20 18 21 19] - 16 ;

% AMY ->
ch_order2 = [22 17 23 24] - 16 ; 

% CA1 ->
ch_order3 = [25 26 27 28] - 16;

% CI ->
ch_order4 = [29 30 31 32] - 16;

% Sort Channels
Mouse.raw_data   = Mouse.raw_data(:,[ch_order1 ch_order2 ch_order3 ch_order4]);  % All channels in raw data
Mouse.data{1,1}  = Mouse.data{1,1}([ch_order1 ch_order2 ch_order3 ch_order4],:); % All channels in downsampled data

% Clear trash
clear ('ch_order1','ch_order2','ch_order3','ch_order4');                                                     

%% Plot to check all channels

% Choose substrate
substrate = 1;

% Choose filter
filter = 1;

% Choose channels to plot
channels = 1:16;

% Set Figure
figure
set(gcf,'color','white')
box 'off'
hold on

% Select fields with data
r = plot(Mouse.timev, bsxfun(@plus, Mouse.data{1, 1}(channels,:), (channels)'*500));%,'Color',[0.7, 0.7, 0.7]);
a = gca; % Get axis

% Set Axis
a.YColor = 'w';
a.YTick = [];
a.XLim = [0 40];
xlabel('Time (s)')

% Clear trash
clear ('channels','filter','substrate','session','str','sub','r','a','I','lh','lh_pos');

%% Plot to check all channels separately

figure

% Choose channels to plot
channels = 1:16;

% Choose substrate
substrate = 1;

% Choose filter
filter = 1;

for ii = 1:length(channels)
    subplot(4,4,ii)
    plot(Mouse.timev,Mouse.data{substrate,filter}(ii,:),'k')
    
    ylim([-1000 1000])
    xlim([0 round(max(Mouse.timev))]);
    yticklabels({'-1','0','1'})
    title(['channel ',num2str(ii)])
    xlabel('Time (s)')
    ylabel('mV')
    box off
end

set(gcf,'color','w');
  
clear ('ii','filter','substrate','channels')

%% Overlap two channels
figure

% Choose substrate
substrate = 1;

% Choose filter
filter1 = 1;
%filter2 = 8;

% Choose channel
ch1 = 1;
%ch2 = 2;

plot(Mouse.timev,Mouse.data{substrate,filter1}(ch1,:),'k')
hold
%plot(Mouse.timev,Mouse.data{substrate,filter2}(ch2,:),'Color','[0.6350, 0.0780, 0.1840]')

ylim([-1500 1500])
xlim([0 round(max(Mouse.timev))])
yticks([-1500 0 1500])
yticklabels({'-1.5','0','1.5'})
xlabel('Time (s)')
ylabel('mV')

set(gcf,'color','w');

box off

clear ('substrate','filter','ch1','ch2')

%% Check frequency based on data cursor/cursor info

f = 1/(cursor_info(1,1).Position(1,1)-cursor_info(1,2).Position(1,1));


%% Correlation Matrices

% Choose substrate
substrate = 1;

% Choose filter
filter = 1;

% Choose channels
ch = 1:16;
% Time to plot
correlation.time2plot = 5; % min

all_channels = (Mouse.data{substrate, filter}(ch,:)');

%Spearman Correlation
[correlation.cormat1,correlation.PVAL] = corr(all_channels,all_channels,'Type','s');

figure

subplot (1,2,1)
imagesc(correlation.cormat1);
xlabel ('channels')
ylabel ('channels')
title ('Spearman Correlation')

% Define bad channels
% correlation.badchannels = [3 4];

% Exclude bad channels
% goodchannels = all_channels;
% goodchannels(:,correlation.badchannels) = [];
% 
% correlation.cormat2 = corr(goodchannels,goodchannels,'Type','s');
% 
% subplot (1,2,2)
% imagesc(correlation.cormat2);
% xlabel ('channels')
% ylabel ('channels')
% title ('Spearman Correlation only Good Channels')
% 
% clear ('ch','substrate','filter','goodchannels','all_channels')






%%

deltacutoff = [ 200 400 ];
GH = fun_myfilters(Mouse.data{1,1}(1,:),Mouse.srate,deltacutoff,'iir','1');

%% 
% Save data (-v7.3 flag to store variables > 2GB with compression)
save('S1_1h_data','Mouse','-v7.3')
save('S1_1h_pw','pw')
save('S1_1h_fft','short_fft','-v7.3')
