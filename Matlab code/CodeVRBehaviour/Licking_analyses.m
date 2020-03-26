clear all
clc
%% Lick analysis
% Flavio Mourao. Centre for Systems Neuroscience (CSN)
% email: f_agm@yahoo.com.br / fagm1@leicester.ac.uk
% University of Leicester 2018

% Load Behavior datafile (*.mat)
% For now just 1 session per time but with small changes I'll be able to load more than one session.

% Load datafiles (*.mat)
[FileName,PathName] = uigetfile('/Volumes/Elements/PDE/3_University/Project/resultados/Flavio_Brendan - From_Jan2018/Behavior/climb/all/*.mat','MultiSelect', 'on'); % Define file type *.*

% Define a struct with files informations for dir organization
filePattern = repmat(struct('name',[],'date',[],'bytes',[],'isdir',[],'datenum',[]), 1, length(FileName));

% Filename can be organize as a single char or a group char in a cell depending on the number os files selected
if ischar(FileName)
   filePattern = dir(fullfile(PathName, FileName)); % condition for a single file selected       
else    
   for ii = 1:length(FileName) % loop over multiple files selected
       filePattern(ii) = dir(fullfile(PathName, char(FileName(ii))));
   end 
end 

% Sort data based on file properties
BehavFiles = nestedSortStruct(filePattern,'name',1); % Perform a nested sort of a struct array based on multiple fields. 
                                                     % >>> https://uk.mathworks.com/matlabcentral/fileexchange/28573-nested-sort-of-structure-arrays?focused=5166120&tab=function


% Condition 1 to delete sessions: sessions with reward locked to one side or manual control by the experimenter
locked_manual = [{'2017_11_23_14.mat'},{'2017_11_30_13.mat'},{'2017_12_01_14.mat'},{'2018_01_16_15.mat'},...
    {'2018_01_18_15.mat'},{'2018_03_21_15.mat'},{'2018_03_22_15.mat'},{'2018_03_23_15.mat'}];                                                   
                                                   
% Condition 2 to delete sessions:  minimum number of trials to be considered
trials = 30; 


% Sort sessions according to the imposed conditions
BehavData_all = repmat(struct('data_in',[],'data_out1',[],'data_out2',[]), 1, length(BehavFiles)); % all sessions. field: data_in have sessions with number of trials >= condition / data_in have sessions with number of trials <= condition. 

for jj = 1:length(BehavFiles)
    baseFileName = BehavFiles(jj).name;
    fullFileName = fullfile(PathName, baseFileName);
    fprintf(1, 'Reading %s\n', fullFileName);
    data = load(fullFileName);
    
    if     mean(strcmp(locked_manual,baseFileName))~=0
           BehavData_all(jj).data_out2 = data; % excluded data condition 2
           
    elseif data.blend_data.num_trials <= trials
           BehavData_all(jj).data_out1 = data; % excluded data condition 1
    else
           BehavData_all(jj).data_in = data;   % data for analysis
    end
end

% Error messagem in case of a bad session be selected
if isempty (cell2mat({BehavData_all(~cellfun(@isempty,{BehavData_all.data_in})).data_in})) == 1;
   errordlg ('The selected file did not satisfy the experimental conditions imposed. Check the variables in lines 24 and 28');
else
end

% Delete empty structs for analysis in BehavData_all.data_in, considering only the minimum number of trials and free exploration (without locked reward or manual control).
empty = {BehavData_all(~cellfun(@isempty,{BehavData_all.data_in})).data_in};
BehavData = cell2struct(empty,{'data_in'},1); % data considered for analysis

clear ('FileName','PathName','filePattern','baseFileName','fullFileName','ii','jj','empty','data','trials');

% Find time outs trials indexes in each session from BehavData_all.data_in.
% This indexes will be use in the next Sorting loops
timeouts = cell(1,length(BehavData));
for jj = 1:length(BehavData)
    timeouts{1,jj} = find(BehavData(jj).data_in.blend_data.timeOutFail_mat);
    if isempty(timeouts{1,jj})
       timeouts{1,jj}=0; % Timeouts Trials indexes for each session
    end
end

clear ('jj');

%% load ThorSync files *.H5 - licks/Time (LoadSyncEpisode_m) 
LoadSyncEpisode_m % Thor labs function - this funcion and function LoadSyncXML.m needs to be in the folder

% Generate H5 summary (piece of Michael code). The original function load all data files from Thornsinc.  
% Check original function ---> GenerateH5summary.m. But for licks I just need this part :

Frame_In_on_i = find(Frame_In(2:numel(Frame_In)) - Frame_In(1:numel(Frame_In)-1) > 0.9);
Frame_In_on = time(Frame_In_on_i);
clear *i
  
if exist('liking_', 'var')  && numel(liking_) ~= numel(time) 
   warning('liking_ variable exists but is of wrong size?!')
   LickingTimes = [];
elseif exist('liking_', 'var')   
   liking_ = medfilt1(liking_, 17);
   liking_ = abs(liking_);
   l_th = sort(liking_);
   l_th = l_th(round(numel(l_th)*0.95)); % 95% threshold to determine where licking happens
   LickingTimes = time(liking_(1:numel(liking_)-1)<= l_th & liking_(2:numel(liking_)) > l_th);
   LickingTimes = LickingTimes([true; diff(LickingTimes) > 0.020]); % points less than 20ms apart are considered to be part of the same lick    
else
   LickingTimes = [];
end

% Pairing ThorSinc Time with Blender Time (piece of Michael code).
% The original function: get2pTimes_blendereferenced.m. But for licks I just need this two lines :

timeDiff = median(BehavData.data_in.blend_data.event_times(BehavData.data_in.blend_data.performance_mat == 0) - Frame_In_on');
licksDiscrete = LickingTimes + timeDiff;

clear ('Frame*','l_th','timeDiff','liking_');

%% Organize licks according Trials. correct and Wrongs
fs = 1/mean(diff(BehavData.data_in.blend_data.time));
timew = 3;         % define time in seconds 
window = timew*fs; % time window 

lick_idx = dsearchn(BehavData.data_in.blend_data.time',licksDiscrete);
lick_session = zeros(1,length(BehavData.data_in.blend_data.time));
lick_session(lick_idx) = true;

lick_window_all = []; % over all trials
lick_window_c = [];   % correted trials
lick_window_w = [];   % wrong trial

for jj = 1:length(BehavData) % for now....just one session. 
    for ii = 2:BehavData(jj).data_in.blend_data.num_trials-1 % Loop over trials. First and last trials are not considered
               
        all_events_time = BehavData(jj).data_in.blend_data.event_times(ii);
        idx = find(BehavData(jj).data_in.blend_data.time==all_events_time);
        %lick_window_all(ii,:) = lick_session(idx(1)-window:idx(1)+window); % all trials
        
        if BehavData(jj).data_in.blend_data.performance_mat(ii) == 1
           correct_events_time = BehavData(jj).data_in.blend_data.event_times(ii);
           idx1 = find(BehavData(jj).data_in.blend_data.time==correct_events_time);
           lick_window_c(ii,:) = lick_session(idx1(1)-window:idx1(1)+window); % correct trials

        elseif BehavData(jj).data_in.blend_data.performance_mat(ii) == 0
           wrong_events_time = BehavData(jj).data_in.blend_data.event_times(ii);
           idx2 = find(BehavData(jj).data_in.blend_data.time==wrong_events_time);
           lick_window_w(ii,:) = lick_session(idx2(1)-window:idx2(1)+window); % wrong trials
        end
    end
end

% Delete first empty row and time out trials
if mean(timeouts{1,1} == jj) ~= 0
   lick_window_c([1, timeouts{1, 1}  ], :) = []; 
   lick_window_w([1, timeouts{1, 1}  ], :) = [];
end

% Sum
lick_window_sum_c = sum(lick_window_c);
lick_window_sum_w = sum(lick_window_w);

clear ('all_events_time','idx*','*events_time','lick_idx','lick_session','ii','jj');


%% Figures

f1 = figure('position', [4, 4, 1200, 700]);

% Raster plot over trials. correct and wrong
subplot (2,3,[1,4]) 
hold on
Time = -timew:1/fs:timew; % Time to plot

% Correct trials
for ii = 1:size(lick_window_c,1)
    lick = Time(lick_window_c(ii,:)==1);
    for jj = 1:length(lick)
        plot([lick(jj) lick(jj)],[ii-0.4 ii+0.4],'color',[0.3 0.3 0.3], 'MarkerSize', 10)
    end
end

title({'\fontsize{12}Licks over'; 'Entire Session'});
xlabel('\fontsize{12}Time (s)');
ylabel('\fontsize{12}Trials ');
ylim([0 size(lick_window_c, 1)+1]); 

y1 = get(gca,'ylim');
plot([0 0],y1,'color','k','LineStyle',':','LineWidth',1)

% Wrong trials
for ii = 1:size(lick_window_w,1)
    lick = Time(lick_window_w(ii,:)==1);
    for jj = 1:length(lick)
        plot([lick(jj) lick(jj)],[ii-0.4 ii+0.4],'color',[0.6350, 0.0780, 0.1840],'MarkerSize', 10)
    end
end

y1 = get(gca,'ylim');
plot([0 0],y1,'color','k','LineStyle',':','LineWidth',1)
plot([3 3],y1,'color','k','LineStyle',':','LineWidth',1)


% Raster plot licks over correct trials
subplot(2,3,2) 
hold on
Time = -timew:1/fs:timew;

for ii = 1:size(lick_window_c,1)
    lick = Time(lick_window_c(ii,:)==1);
    for jj = 1:length(lick)
        plot([lick(jj) lick(jj)],[ii-0.4 ii+0.4],'color',[0.3 0.3 0.3], 'MarkerSize', 10)
    end
end

title({'\fontsize{12}Licks over'; 'Correct Trials'})
xlabel('\fontsize{11}Time (s)');
ylabel('\fontsize{11}Trials ');
ylim([0 size(lick_window_c, 1)+1]); 

y1 = get(gca,'ylim');
plot([0 0],y1,'color','k','LineStyle',':','LineWidth',1)
plot([1.7 1.7],y1,'color','k','LineStyle',':','LineWidth',1)


% Raster plot licks over wrong trials
subplot(2,3,3) 
hold on
Time = -timew:1/fs:timew;

for ii = 1:size(lick_window_w,1)
    lick = Time(lick_window_w(ii,:)==1);
    for jj = 1:length(lick)
        plot([lick(jj) lick(jj)],[ii-0.4 ii+0.4],'color',[0.6350, 0.0780, 0.1840],'MarkerSize', 10)
    end
end

title({'\fontsize{12}Licks over'; 'Wrong Trials'})
xlabel('\fontsize{11}Time (s)');
ylabel('\fontsize{11}Trials');
ylim([0 size(lick_window_c, 1)+1]); 

y1 = get(gca,'ylim');
plot([0 0],y1,'color','k','LineStyle',':','LineWidth',1)
plot([3 3],y1,'color','k','LineStyle',':','LineWidth',1)


% Peri event time histogram - over correct trials
subplot(2,3,5) 
hold on

edges = linspace(-3,3,50);
time_bin = diff(edges);
lick_c = zeros(1,length(edges));

for ii = 1:size(lick_window_c,1)
    lick_c = lick_c + histc(Time(lick_window_c(ii,:)==1),edges);
end

b1 = bar(edges,lick_c);
b1(1).FaceColor = 'w';
b1(1).LineWidth = .5;

xlim([-3.06 3.06])
ylim([0 100])
xlabel('\fontsize{11}Time (s)');
ylabel('\fontsize{11}Frequency');
y1 = get(gca,'ylim');
plot([0 0],y1,'color','k','LineStyle',':','LineWidth',1)
plot([1.7 1.7],y1,'color','k','LineStyle',':','LineWidth',1)
title({'\fontsize{12}Peri event time histogram'; '~120 ms time bins.'})

filter_lick = smooth(edges,lick_c,0.25,'rloess');
plot(edges,filter_lick,'LineWidth', 3, 'color', [0.6350, 0.0780, 0.1840]);


% Peri event time histogram - over wrong trials
subplot(2,3,6) 
hold on

lick_w = zeros(1,length(edges));
for ii = 1:size(lick_window_w,1)
    lick_w = lick_w + histc(Time(lick_window_w(ii,:)==1),edges);
end

b2 = bar(edges,lick_w);
b2(1).FaceColor = 'w';
b2(1).LineWidth = .5;

xlim([-3.06 3.06])
ylim([0 100])
xlabel('\fontsize{11}Time (s)');
ylabel('\fontsize{11}Frequency');
y1 = get(gca,'ylim');
plot([0 0],y1,'color','k','LineStyle',':','LineWidth',1)
plot([3.06 3.06],y1,'color','k','LineStyle',':','LineWidth',1)
title({'\fontsize{12}Peri event time histogram'; '~120 ms time bins.'})

filter_lick = smooth(edges,lick_w,0.25,'rloess');
plot(edges,filter_lick,'LineWidth',3,'color', [0.6350, 0.0780, 0.1840]);

%% 
% Flavio Mourao. Last update 23/04/18. 16.10am. David Wilson Library. Leicester Uk
% listening: Mogwai - May nothing but hapiness come through your door 
















