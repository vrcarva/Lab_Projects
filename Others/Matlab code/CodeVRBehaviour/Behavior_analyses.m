clear all
clc
%% VR. Behavioral Analisys. 
% Flavio Mourao. Centre for Systems Neuroscience (CSN)
% email: f_agm@yahoo.com.br / fagm1@leicester.ac.uk
% University of Leicester 2018

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
trials = 40; 


% Sort sessions according to the imposed conditions
BehavData_all = repmat(struct('data_in',[],'data_out1',[],'data_out2',[]), 1, length(BehavFiles)); % all sessions. field: data_in have sessions with number of trials >= condition / data_in have sessions with number of trials <= condition. 

for jj = 1:length(BehavFiles)
    baseFileName = BehavFiles(jj).name;
    fullFileName = fullfile(PathName, baseFileName);
    fprintf(1, 'Reading %s\n', fullFileName);
    data = load(fullFileName);
    
    if     mean(strcmp(locked_manual,baseFileName))~=0
           BehavData_all(jj).data_out2 = data; % excluded data condition 1
           
    elseif data.blend_data.num_trials <= trials
           BehavData_all(jj).data_out1 = data; % excluded data condition 2
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

clear ('PathName','filePattern','baseFileName','fullFileName','ii','jj','empty','data','trials');

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

%% Sorting data based on Behavior (piece of Michael code to sort)

% Struct named 'Permut' contain behavioral and reward positions for all sessions and trials

% Struct named 'ChiSquare' contain variables for chi-square associative test. 
% Matrix in the form of a contingency table (Behavioural responses matrix )

%                  reward-L reward-R
%   behav resp-L      A        B
%   behav resp-R      C        D

% Struct named 'Trajectories' contain x and y coordinates for all sessions and trials
% Struct named 'EventTimes' contain time in seconds and Timestamps all sessions and trials



% Initialized cells variables
Permut.behavResp = cell(1,length(BehavData));                       % Behavioral responses. Sessions = columns . 0 wrong choice and 1 correct choices
Permut.stimPos = cell(1,length(BehavData));                         % Reward position. Sessions = columns . 0 wrong choice and 1 correct choices
[ChiSquare.observed_1{1, 1:length(BehavData)}] = deal(zeros(2));    % Contigency tables according to the behavioral response and reward position
Trajectories = repmat(struct('all_trials',[],'correct_choices',[],'wrong_choices',[] ), length(BehavData),1); % Trajectories over sessions (x and y - 2D environment coordinates).  3 fields = all trials over sessions(lines) / correct trials / wrong trials. Each field: column 1 = 'x coordinate'; colunm 2 = 'y coordinate'; lines = trials
EventTimes   = repmat(struct('all_trials',[],'correct_choices',[],'wrong_choices',[] ), length(BehavData),1); % Event Time in seconds and the correspondent Event index for each trial  =  3 fields = all trials over sessions(lines) / correct trials / wrong trials. Each field: first line 1 = 'Events Time in seconds for each trial'; line 2 = 'Events indexes for each time event for each trial

for ii = 1:length(BehavData) % Loop over sessions
    for jj = 2:numel(BehavData(ii).data_in.blend_data.event_times)-1 % Loop over time events. First and last trials are not considered
               
        [~, jjimePos] = min(abs(BehavData(ii).data_in.blend_data.time - BehavData(ii).data_in.blend_data.event_times(jj))); % the time (in blend_data timeframe) of the event
        jjimePos = jjimePos-2;
        assert(BehavData(ii).data_in.blend_data.time(jjimePos) < BehavData(ii).data_in.blend_data.event_times(jj));
               
        if     mean(timeouts{1,ii} == jj) ~= 0 % Find timeouts indexes and delete from trial elements
               continue;
        
        elseif BehavData(ii).data_in.blend_data.path(1,jjimePos) <= 0 && BehavData(ii).data_in.blend_data.reward_position_mat(jj) == 1 % mouse went L, reward L
               ChiSquare.observed_1{1,ii}(1, 1) = ChiSquare.observed_1{1,ii}(1, 1) + 1;
               Permut.behavResp{1,ii}(end+1,:) = 0; % mouse went L
               Permut.stimPos{1,ii}(end+1,:) = 1;   % reward L
        elseif BehavData(ii).data_in.blend_data.path(1,jjimePos) >= 0 && BehavData(ii).data_in.blend_data.reward_position_mat(jj) == 1 % mouse went R, reward L
               ChiSquare.observed_1{1,ii}(2, 1) = ChiSquare.observed_1{1,ii}(2, 1) + 1;
               Permut.behavResp{1,ii}(end+1,:) = 1; % mouse went R
               Permut.stimPos{1,ii}(end+1,:) = 1;   % reward L
        elseif BehavData(ii).data_in.blend_data.path(1,jjimePos) <= 0 && BehavData(ii).data_in.blend_data.reward_position_mat(jj) == 0 % mouse went L, reward R
               ChiSquare.observed_1{1,ii}(1, 2) = ChiSquare.observed_1{1,ii}(1, 2) + 1;
               Permut.behavResp{1,ii}(end+1,:) = 0; % mouse went L
               Permut.stimPos{1,ii}(end+1,:) = 0;   % reward R
        elseif BehavData(ii).data_in.blend_data.path(1,jjimePos) >= 0 && BehavData(ii).data_in.blend_data.reward_position_mat(jj) == 0 % mouse went R, reward R
               ChiSquare.observed_1{1,ii}(2, 2) = ChiSquare.observed_1{1,ii}(2, 2) + 1;
               Permut.behavResp{1,ii}(end+1,:) = 1; % mouse went R
               Permut.stimPos{1,ii}(end+1,:) = 0;   % reward R
        else
               error('something wrong')
        end
        
        
        if     mean(timeouts{1,ii} == jj) ~= 0 % Find timeouts indexes and delete from trial elements
               continue;
        
               % Trajectories = First: extract all trials in all sessions       
        elseif jj==1
               Trajectories(ii).all_trials{jj,1} = BehavData(ii).data_in.blend_data.path(1,BehavData(ii).data_in.blend_data.time<BehavData(ii).data_in.blend_data.event_times(jj));
               Trajectories(ii).all_trials{jj,2} = BehavData(ii).data_in.blend_data.path(2,BehavData(ii).data_in.blend_data.time<BehavData(ii).data_in.blend_data.event_times(jj));
              
        else
               Trajectories(ii).all_trials{jj,1} = BehavData(ii).data_in.blend_data.path(1,BehavData(ii).data_in.blend_data.time>BehavData(ii).data_in.blend_data.event_times(jj-1) & BehavData(ii).data_in.blend_data.time<BehavData(ii).data_in.blend_data.event_times(jj));
               Trajectories(ii).all_trials{jj,2} = BehavData(ii).data_in.blend_data.path(2,BehavData(ii).data_in.blend_data.time>BehavData(ii).data_in.blend_data.event_times(jj-1) & BehavData(ii).data_in.blend_data.time<BehavData(ii).data_in.blend_data.event_times(jj));
       
        end
        
        
        if     mean(timeouts{1,ii} == jj) ~= 0 % Find timeouts indexes and delete from trial elements
               continue;
                             
        else
            
              % Time in seconds and Events indexes for each time event  = First: extract all trials in all sessions 
              EventTimes(ii).all_trials(1,jj) = BehavData(ii).data_in.blend_data.event_times(1,jj);
              EventTimes(ii).all_trials(2,jj) = jjimePos;             

        end 
    end
end


% Sort trajectories over trials and over sessions according with mice choices and delete empty structs for analysis

for ii = 1:length(Trajectories)
    a = Trajectories(ii).all_trials;
    Trajectories(ii).all_trials = reshape(a(~cellfun(@isempty,a)),[],2);
    
    for jj = 1: length(Trajectories(ii).all_trials)
        if Permut.behavResp{1,ii}(jj) == 1 && Permut.stimPos{1,ii}(jj) == 0 || Permut.behavResp{1,ii}(jj) == 0 && Permut.stimPos{1,ii}(jj) == 1; % correct choices
           Trajectories(ii).correct_choices{jj,1} = (Trajectories(ii).all_trials{jj,1})';
           Trajectories(ii).correct_choices{jj,2} = (Trajectories(ii).all_trials{jj,2})';
           b = Trajectories(ii).correct_choices;
           Trajectories(ii).correct_choices = reshape(b(~cellfun(@isempty,b)),[],2);
        else
           Trajectories(ii).wrong_choices{jj,1} = (Trajectories(ii).all_trials{jj,1})';
           Trajectories(ii).wrong_choices{jj,2} = (Trajectories(ii).all_trials{jj,2})';
           c = Trajectories(ii).wrong_choices;
           Trajectories(ii).wrong_choices = reshape(c(~cellfun(@isempty,c)),[],2);
        end
    end
end


% Sort Events over trials and over sessions according with mice choices and delete empty structs for analysis

for ii = 1:length(EventTimes)
    
    EventTimes(ii).all_trials( :, ~any(EventTimes(ii).all_trials,1) ) = [];  % delete zeros columns
    
    for jj = 1: length(EventTimes(ii).all_trials)
        if Permut.behavResp{1,ii}(jj) == 1 && Permut.stimPos{1,ii}(jj) == 0 || Permut.behavResp{1,ii}(jj) == 0 && Permut.stimPos{1,ii}(jj) == 1; % correct choices
           EventTimes(ii).correct_choices(:,jj) = (EventTimes(ii).all_trials(:,jj));
           EventTimes(ii).correct_choices( :, ~any(EventTimes(ii).correct_choices,1)) = [];  % delete zeros columns
        else
           EventTimes(ii).wrong_choices(:,jj) = (EventTimes(ii).all_trials(:,jj));
           EventTimes(ii).wrong_choices( :, ~any(EventTimes(ii).wrong_choices,1)) = [];  % delete zeros columns           
        end
    end
end


%%%% Velocity & Distance

Velocity     = repmat(struct('all_trials',[],'correct_choices',[],'wrong_choices',[] ), length(BehavData),1); % Velocity over sessions (Forward and turn).  3 fields = all trials over sessions(lines) / correct trials / wrong trials. 
                                                                                                                % Each field: column 1 = 'Velocity forward'; colunm 2 = 'Velocity - Ball turn'; colunm 3 = 'Time'; lines = trials/ 
                                                                                                                % collunm 4-6 = Same as 1-3 but each line is just a repetition for the role session period.
Distances    = repmat(struct('all_trials',[],'correct_choices',[],'wrong_choices',[] ), length(BehavData),1); % Distances over sessions.  3 fields = all trials over sessions(lines) / correct trials / wrong trials. 
                                                                                                                % Each field: column 1 = 'total distance over trial'; colunm 2 = 'comulative distance over time'; lines = trials 
    
for ii = 1:length(BehavData) % Loop over sessions
    
    a = [1 EventTimes(ii).all_trials(2,:)]; % plus 1 to start (first colunm) just to calcule time differences
    TimeTrials = diff(a);                   % Diferences between time events (in blender timestamps). (Number of frames for each trial)
    idx = EventTimes(ii).all_trials(2,:);   % Time events indexes (in blender timestamps)
    
    for jj = 1:length(idx)                  % Loop over time events.
       
    % Velocity = First: extract all trials in all sessions

    Velocity(ii).all_trials{jj,1} = BehavData(ii).data_in.blend_data.raw_velocity(1,idx(jj)-TimeTrials(jj):idx(jj));      % Forward velocity in trial epochs
    Velocity(ii).all_trials{jj,2} = BehavData(ii).data_in.blend_data.raw_velocity(2,idx(jj)-TimeTrials(jj):idx(jj));      % Turn the ball - velocity in trial epochs
    Velocity(ii).all_trials{jj,3} = BehavData(ii).data_in.blend_data.raw_velocity_time(1,idx(jj)-TimeTrials(jj):idx(jj)); % Time Velocity in trial epochs
    Velocity(ii).all_trials{jj,4} = BehavData(ii).data_in.blend_data.raw_velocity(1,:);                                   % Forward velocity full session
    Velocity(ii).all_trials{jj,5} = BehavData(ii).data_in.blend_data.raw_velocity(2,:);                                   % Turn the ball - velocity full session
    Velocity(ii).all_trials{jj,6} = BehavData(ii).data_in.blend_data.raw_velocity_time(1,:);                              % Time Velocity full session

    end
end

% Sort velocity over trials and over sessions according with mice choices and delete empty structs for analysis

for ii = 1:length(Velocity)
    a = Velocity(ii).all_trials;
    Velocity(ii).all_trials = reshape(a(~cellfun(@isempty,a)),[],6);
    
    for jj = 1: length(Velocity(ii).all_trials)
        if Permut.behavResp{1,ii}(jj) == 1 && Permut.stimPos{1,ii}(jj) == 0 || Permut.behavResp{1,ii}(jj) == 0 && Permut.stimPos{1,ii}(jj) == 1; % correct choices
           Velocity(ii).correct_choices{jj,1} = (Velocity(ii).all_trials{jj,1})';
           Velocity(ii).correct_choices{jj,2} = (Velocity(ii).all_trials{jj,2})';
           Velocity(ii).correct_choices{jj,3} = (Velocity(ii).all_trials{jj,3})';
           Velocity(ii).correct_choices{jj,4} = (Velocity(ii).all_trials{jj,4})';
           Velocity(ii).correct_choices{jj,5} = (Velocity(ii).all_trials{jj,5})';
           Velocity(ii).correct_choices{jj,6} = (Velocity(ii).all_trials{jj,6})';
           b = Velocity(ii).correct_choices;
           Velocity(ii).correct_choices = reshape(b(~cellfun(@isempty,b)),[],6);
        else
           Velocity(ii).wrong_choices{jj,1} = (Velocity(ii).all_trials{jj,1})';
           Velocity(ii).wrong_choices{jj,2} = (Velocity(ii).all_trials{jj,2})';
           Velocity(ii).wrong_choices{jj,3} = (Velocity(ii).all_trials{jj,3})';
           Velocity(ii).wrong_choices{jj,4} = (Velocity(ii).all_trials{jj,4})';
           Velocity(ii).wrong_choices{jj,5} = (Velocity(ii).all_trials{jj,5})';
           Velocity(ii).wrong_choices{jj,6} = (Velocity(ii).all_trials{jj,6})';
           c = Velocity(ii).wrong_choices;
           Velocity(ii).wrong_choices = reshape(c(~cellfun(@isempty,c)),[],6);
        end
    end
end


% Distances covered over trials and over sessions according with mice choices and delete empty structs for analysis

% >> Trapz Function performs discrete integration by using the data points to create trapezoids, 
% so it is well suited to handling data sets with discontinuities. This method assumes linear behavior 
% between the data points, and accuracy may be reduced when the behavior between data points is nonlinear. 

% >> Cumtrapz Function is closely related to trapz. While trapz returns only the final integration value, cumtrapz also 
%returns intermediate values in a vector (Cumulative distance traveled).

for ii = 1:length(Velocity)
    for jj = 1: length(Velocity(ii).all_trials)              % all trials
        idx1 = find(~isnan(Velocity(ii).all_trials{jj, 3})); % delete nan
        x = Velocity(ii).all_trials{jj, 3}(idx1);            % time vector
        y = Velocity(ii).all_trials{jj, 1}(idx1);            % velocity vector
        Distances(ii).all_trials{jj,1} = trapz(x,y);         % Total distance
        Distances(ii).all_trials{jj,2} = cumtrapz(x,y);      % Cumulative distance
    end
end
for ii = 1:length(Velocity)
    for jj = 1: length(Velocity(ii).correct_choices)              % correct trials
        idx2 = find(~isnan(Velocity(ii).correct_choices{jj, 3})); % delete nan
        x = Velocity(ii).correct_choices{jj, 3}(idx2);            % time vector
        y = Velocity(ii).correct_choices{jj, 1}(idx2);            % velocity vector
        Distances(ii).correct_choices{jj,1} = trapz(x,y);         % Total distance
        Distances(ii).correct_choices{jj,2} = cumtrapz(x,y);      % Cumulative distance
    end
end
for ii = 1:length(Velocity)
    for jj = 1: length(Velocity(ii).wrong_choices)              % Wrong trials
        idx3 = find(~isnan(Velocity(ii).wrong_choices{jj, 3})); % delete nan
        x = Velocity(ii).wrong_choices{jj, 3}(idx3);            % time vector
        y = Velocity(ii).wrong_choices{jj, 1}(idx3);            % velocity vector
        Distances(ii).wrong_choices{jj,1} = trapz(x,y);         % Total distance
        Distances(ii).wrong_choices{jj,2} = cumtrapz(x,y);      % Cumulative distance
    end
end

clear ('jj','jjimePos','ii','a','b','c','idx1','idx2','idx3','x','y','idx','TimeTrials');

%% Permutation test and Descriptive Statistics

% Initialized cells variables
Permut.behavResp_aux = Permut.behavResp;                  % Auxiliary variable for normalization. Behavioral responses
Permut.stimPos_aux = Permut.stimPos;                      % Auxiliary variable for normalization. Reward positions

Permut.random_performance = cell(1,length(BehavData));    % Permutation of behavioral responses. 10000 times ( 0 wrong choices and 1 correct choices)
Permut.real_performance = cell(1,length(BehavData));      % Mouse performance during session ( 0 wrong choices  and 1 correct choices)
Permut.real_performance_mean = cell(1,length(BehavData)); % Mean Performance (%)
Permut.real_performance_std = cell(1,length(BehavData));  % Standart deviation
Permut.real_performance_sem = cell(1,length(BehavData));  % Standart error of mean

Permut.z_random_performance = cell(1,length(BehavData));  % z scores permuted values
Permut.z_observed = cell(1,length(BehavData));            % z scores observed values
Permut.p_values = cell(1,length(BehavData));              % p values

Permut.real_performance_movaverage = cell(1,length(BehavData)); % Trailing Moving Average over correct trials

for ii = 1:length(BehavData)
    Permut.behavResp_aux{1,ii}(Permut.behavResp_aux{1,ii}==0)= -1; 
    Permut.stimPos_aux{1,ii}(Permut.stimPos_aux{1,ii}==1) = -1;
    Permut.stimPos_aux{1,ii}(Permut.stimPos_aux{1,ii}==0) = 1;
    
    Permut.real_performance{1,ii} = abs(Permut.behavResp_aux{1,ii}+Permut.stimPos_aux{1,ii})==2;
    Permut.real_performance_mean{1,ii} = mean(abs(Permut.behavResp_aux{1,ii}+Permut.stimPos_aux{1,ii})==2);
    Permut.real_performance_std{1,ii} = std(abs(Permut.behavResp_aux{1,ii}+Permut.stimPos_aux{1,ii})==2);
    Permut.real_performance_sem{1,ii} = Permut.real_performance_std{1,ii}/sqrt(length(Permut.real_performance{1,ii}));
    
    for r=1:10000 % Randomization
        Permut.performance_mat_rd{1,ii} = Permut.behavResp_aux{1,ii}(randperm(numel(Permut.behavResp_aux{1,ii})));
        Permut.random_performance{1,ii}(1,r) = mean(abs(Permut.performance_mat_rd{1,ii}+Permut.stimPos_aux{1,ii})==2);
    end
    
    % Normalize by Z score
    Permut.z_random_performance{1,ii} = zscore(Permut.random_performance{1,ii}); % z permuted values
    Permut.z_observed{1,ii} = (mean(Permut.real_performance{1,ii})-mean(Permut.random_performance{1,ii}))/(std(Permut.random_performance{1,ii}));% z real(observed) value
    Permut.p_values{1,ii} = 0.5 * erfc(Permut.z_observed{1,ii} ./ sqrt(2)); % p value. Similar to Matlab function: normcdf(-z) two-tailed
    % zval = norminv(1-(.05/length(sessions))); % z-value threshold at p=0.05, correcting for multiple comparisons
    
    % Moving average over trials
    Permut.real_performance_movaverage{1,ii} = 100*(movmean(Permut.real_performance{1,ii},[length(Permut.real_performance{1,ii}) 0])); % Trailing Moving Average over correct trials
    Permut.real_performance_movaverage{2,ii} = 100 - Permut.real_performance_movaverage{1,ii}; % Trailing Moving Average over wrong trials

end

clear ('ii','j','l','r');

%% Chi-square - Associated Behavior with the reward --> H1
% (Behavioural responses matrix );

%                  reward-L reward-R
%   behav resp-L      A        B
%   behav resp-R      C        D

% Initialize cells for total rows and total columns for the chi-square test
ChiSquare.total_col_1 = cell(1,length(BehavData));
ChiSquare.total_row_1 = cell(1,length(BehavData));
ChiSquare.total_all_1 = cell(1,length(BehavData));

for ii = 1:length(BehavData)
    ChiSquare.total_col_1{1, ii} = sum(ChiSquare.observed_1{1, ii});
    ChiSquare.total_row_1{1, ii} = sum(ChiSquare.observed_1{1, ii},2);
    ChiSquare.total_all_1{1, ii} = sum(ChiSquare.total_col_1{1, ii});
end

% Expected counts under H0 (null hypothesis)
[ChiSquare.expected_1{1, 1:length(BehavData)}] = deal(zeros(2)); % Initialize cells for contigency tables according to the expected behavioral response and reward position
ChiSquare.chi2stat_1 = cell(1,length(BehavData));                % Initialize cells for chi values
ChiSquare.p_1 = cell(1,length(BehavData));                       % Initialize cells for p values

for ii = 1:length(BehavData)
    for l = 1:2
        for j = 1:2
            a = (ChiSquare.total_col_1{1, ii}(l)./ChiSquare.total_all_1{1,ii})*ChiSquare.total_row_1{1, ii}(j);
            ChiSquare.expected_1{1,ii}(l,j) = a; % Expected values
        end
    end
    
% Chi-square test
ChiSquare.chi2stat_1{1,ii} = sum(sum((ChiSquare.observed_1{1, ii}-ChiSquare.expected_1{1, ii}').^2 ./ ChiSquare.expected_1{1, ii})); % chi square
ChiSquare.p_1{1,ii} = 1 - chi2cdf(ChiSquare.chi2stat_1{1,ii},1); % p values 

end

clear ('ii','PathName','j','l','a');

%% Chi-square - Another point of view - Preference(Bias)for one side -> H1
%  (considering that the rewards are evenly distributed)

%          Rewards     Behavioral Responses  
%   Left      z                 w
%   Right     x                 y

% Expected counts under H0 (null hypothesis)

% Observed data
[ChiSquare.observed_2{1, 1:length(BehavData)}] = deal(zeros(2)); % contigency tables according to the behavioral response and reward position

for ii = 1:length(BehavData)
    ChiSquare.observed_2{1,ii}(1, 1) = sum(Permut.stimPos{1, ii}~=0);     % Reward presented to the Left
    ChiSquare.observed_2{1,ii}(2, 1) = sum(Permut.stimPos{1, ii}==0);     % Reward presented to the Right
    ChiSquare.observed_2{1,ii}(1, 2) = ChiSquare.total_row_1{1, ii}(1,1); % Behavioral Responses to the left
    ChiSquare.observed_2{1,ii}(2, 2) = ChiSquare.total_row_1{1, ii}(2,1); % Behavioral Responses to the right
end

% Initialize cells for total rows and total columns for the chi-square test
ChiSquare.total_col_2 = cell(1,length(BehavData));
ChiSquare.total_row_2 = cell(1,length(BehavData));
ChiSquare.total_all_2 = cell(1,length(BehavData));

for ii = 1:length(BehavData)
    ChiSquare.total_col_2{1, ii} = sum(ChiSquare.observed_2{1, ii});
    ChiSquare.total_row_2{1, ii} = sum(ChiSquare.observed_2{1, ii},2);
    ChiSquare.total_all_2{1, ii} = sum(ChiSquare.total_col_2{1, ii});
end

% Expected counts under H0 (null hypothesis)
[ChiSquare.expected_2{1, 1:length(BehavData)}] = deal(zeros(2)); % Initialize cells for contigency tables according to the expected behavioral response and reward position
ChiSquare.chi2stat_2 = cell(1,length(BehavData));                % Initialize cells for chi values
ChiSquare.p_2 = cell(1,length(BehavData));                       % Initialize cells for p values

for ii = 1:length(BehavData)
    for l = 1:2
        for j = 1:2
            a = (ChiSquare.total_col_2{1, ii}(l)./ChiSquare.total_all_2{1,ii})*ChiSquare.total_row_2{1, ii}(j);
            ChiSquare.expected_2{1,ii}(l,j) = a; % Expected values
        end
    end
    
% Chi-square test
ChiSquare.chi2stat_2{1,ii} = sum(sum((ChiSquare.observed_2{1, ii}-ChiSquare.expected_2{1, ii}').^2 ./ ChiSquare.expected_2{1, ii})); % chi square
ChiSquare.p_2{1,ii} = 1 - chi2cdf(ChiSquare.chi2stat_2{1,ii},1); % p values 

end

clear ('ii','ind_rd','j','l','a');

%% Figures

f1 = figure('position', [2, 2, 900, 750]);
set(gcf,'color','w');

%%%%
% Mean Performance over sessions

subplot(2,3,1) % Mean values for all considered sessions with respective statistical significance 
                   % and without significant bias (according to the chi square test)
hold all
sessions = 1:length(BehavData);
plot(sessions,100*cell2mat(Permut.real_performance_mean),'-k','linewidth',.25);
plot(sessions,50*ones(length(BehavData)),'--k','linewidth',.25)
axis([.9 length(BehavData)+.1 0 100])
for jj = 1:length(BehavData) 
    if Permut.p_values{1,jj} <=.05 %&& ChiSquare.p_2{1,jj} >=.05
       p = plot(sessions(jj),100*Permut.real_performance_mean{1,jj},...
           'o','linewidth',1, 'MarkerEdgeColor','k','MarkerFaceColor','k');
    else
       q = plot(sessions(jj),100*Permut.real_performance_mean{1,jj},...
           'o','linewidth',1, 'MarkerEdgeColor','k','MarkerFaceColor','w');
    end
end

xlabel('\fontsize{12}Sessions'), ylabel('\fontsize{12}Performance (%)')
title({'\fontsize{12}Mouse performance over';[num2str(length(BehavData)),' sessions']})

if     exist ('p') == 1 && exist ('q') == 0;
       legend([p], {'\fontsize{8}Significant'}, 'box','off','location','southwest');
elseif exist ('p') == 0 && exist ('q') == 1;
       legend([q], {'\fontsize{8}Non-Significant'}, 'box','off','location','southwest');
elseif exist ('p') == 1 && exist ('q') == 1;
       legend([p q], {'\fontsize{8}Significant';'\fontsize{8}Non - Significant';'\fontsize{8}Significant'}, 'box','off','location','southwest');
else
       error ('empty data');
end


%%%% Request session to show analysis
input = inputdlg('Please enter Session number:'); % Gui
s = str2num(input{1,1});                          % Define session to plot

q1 = plot(sessions(s),100*Permut.real_performance_mean{1,s},...
           'o','linewidth',1, 'MarkerEdgeColor','[0.6350, 0.0780, 0.1840]','MarkerFaceColor','[0.6350, 0.0780, 0.1840]');
% legend([p q q1],{'\fontsize{8}Significant';'\fontsize{8}Non - Significant';'\fontsize{8}Selected session'}, 'box','off','location','southwest');


%%%% Moving Average
subplot(2,3,[2,3])
hold all
plot(1:length(Permut.real_performance_movaverage{1, s}),Permut.real_performance_movaverage{1, s},'-k','linewidth',2);
plot(1:length(Permut.real_performance_movaverage{2, s}),Permut.real_performance_movaverage{2, s},'-r','linewidth',2);
xlabel('\fontsize{12}Trials'); ylabel('\fontsize{12}Performance (%)');
title({'\fontsize{12}Moving average over';[num2str(length(Permut.real_performance_movaverage{1, s})),' trials (Full session running window)']});
legend({'\fontsize{8}correct choices';'\fontsize{8}Wrong choices'},'box','off');
axis ([0 length(Permut.real_performance_movaverage{1, s}) 0 100 ])

%%%% Permutation test
subplot(2,3,4)
h = histogram(Permut.z_random_performance{1,s},18);
h.FaceColor = 'w';
hold on
plot([Permut.z_observed{1,s} Permut.z_observed{1,s}],[0 800],'Color', '[0.6350, 0.0780, 0.1840]','linewidth',1);

[figx,figy] = dsxy2figxy([Permut.z_observed{1,s} Permut.z_observed{1,s}],[800 0]); % Transform point or position from data space 
                                                                                   % coordinates into normalized figure coordinates . 
                                                                                   % >>> https://uk.mathworks.com/matlabcentral/fileexchange/30347-sigplot?focused=5178148&tab=function
annotation('textarrow',figx,figy,'Color', '[0.6350, 0.0780, 0.1840]','linewidth',4);
xlabel('\fontsize{12}z values'), ylabel('\fontsize{12}Frequency')
title({'\fontsize{12}Mouse choice vs Random choices';['\rm\fontsize{10}p_v_a_l_u_e = ' num2str(Permut.p_values{1,s})]})
legend({'\fontsize{8}Random';'\fontsize{8}Observed'},'box','off');

clear ('jj','figx','figy','sessions');


%%%% Chi square - Associated behavior with the reward
subplot(2,3,5) 
b1 = bar(ChiSquare.observed_1{1,s}');
b1(1).FaceColor = 'w'; b1(2).FaceColor = [0.8, 0.8, 0.8];
title({'\fontsize{12}Associated Behavior';'with the Reward Side'})
labels={'Reward-L'; 'Reward-R'};
set(gca,'xticklabel',labels(1:2));
ylabel('Total');
xlabel(['chi2stat = ',num2str(ChiSquare.chi2stat_1{1,s}),'   ','p_v_a_l_u_e = ',num2str(ChiSquare.p_1{1,s})])
legend({'Behavioral Response to Left';
    'Behavioral Response to Right'},'Box','off','location','southoutside');
axis square


%%%% Chi square - Bias. Considering rewards evenly distributed
subplot(2,3,6)  

b2 = bar(ChiSquare.observed_2{1,s}'); % Chi square - Bias. Considering rewards evenly distributed
b2(1).FaceColor = 'w'; b2(2).FaceColor = [0.8, 0.8, 0.8];
title({'\fontsize{12}Preference (Bias) for one side.';'\fontsize{8}(rewards are evenly distributed)'})
labels={'Left';'Right'};
set(gca,'xticklabel',labels(1:2));
ylabel('Total');
xlabel(['chi2stat = ',num2str(ChiSquare.chi2stat_2{1,s}),'   ','p_v_a_l_u_e = ',num2str(ChiSquare.p_2{1,s})])
legend({'Rewards';'Behavioral Responses'},'Box','off','location', 'southoutside');
axis square

%%
f2 = figure('position', [4, 4, 1000, 450]);
set(gcf,'color','w');

%%%% Trajectories
subplot(2,3,[1,4])

% Environment coordinates
size_e = [77 146]; % VR Environment size_e in cm
hold all

% Environment
length_e = BehavData(s).data_in.blend_data.front_wall_pos(2) - BehavData(s).data_in.blend_data.back_wall_pos(1);               % Environment length in blender units
begin_length = (BehavData(s).data_in.blend_data.back_wall_pos(2) * size_e(2))/BehavData(s).data_in.blend_data.front_wall_pos(2); % Environment length normalized in cm
y = linspace(begin_length,size_e(2),length_e); % Reference line scale in cm

width = BehavData(s).data_in.blend_data.wallRight_pos(1) - BehavData(s).data_in.blend_data.wallLeft_pos(1);                    % Environment width in blender units
begin_width = (BehavData(s).data_in.blend_data.wallRight_pos(1) * size_e(1))/BehavData(s).data_in.blend_data.wallLeft_pos(1);    % Environment width normalized in cm
x = (linspace(begin_width,size_e(1),width)); % Reference line scale in cm

% Reward zone 2D References - normalized in cm
ai = (BehavData(s).data_in.blend_data.ths_y*size_e(2))/(length_e);
bi = (BehavData(s).data_in.blend_data.ths_y*size_e(2))/(length_e);
ci = (BehavData(s).data_in.blend_data.ths_x(1)*size_e(1))/(width);
di = (BehavData(s).data_in.blend_data.ths_x(2)*size_e(1))/(width);

% Draw Environment
plot(x(end)/2*ones(1,2), [y(1) y(end)],'k','linewidth',.2)               % Right wall
plot(x(1)/2*ones(1,2), [y(1) y(end)],'k','linewidth',.2)                 % Left wall
plot(ci*ones(1,2), [ai size_e(2)],'Color',[0.8, 0.8, 0.8],'linewidth',1) % Reward zone - Corridor line Left
plot(di*ones(1,2), [ai size_e(2)],'Color',[0.8, 0.8, 0.8],'linewidth',1) % Reward zone - Corridor line Right
plot([x(1) ci], ai*ones(1,2),'Color',[0.8, 0.8, 0.8],'linewidth',1)      % Reward zone - Front Left
plot([di x(end)], ai*ones(1,2),'Color',[0.8, 0.8, 0.8],'linewidth',1)    % Reward zone - Front Right
plot([x(1) x(end)], (92*y(end)/100)*ones(1,2),'k','linewidth',2)         % Front wall
plot([x(1) x(end)], y(1)*ones(1,2),'k','linewidth',.2)                   % Back wall

ylabel('Length (cm)','Fontsize',12)
xlabel('Width (cm)','Fontsize',12)
%set(gca, 'Fontsize_e', 10)
axis([x(1)/2+1 x(end)/2-1 y(1) (92*y(end)/100)]) % axis normalized to correct errors sampling
title ({'\fontsize{12}Trajectories map';'over session'});

% Plot wrong choices over selected session 
for ii = 1:length(Trajectories(s).wrong_choices)
    a = (Trajectories(s).wrong_choices{ii, 1}.* size_e(1))./(width);    % Directions normalized in cm
    b = (Trajectories(s).wrong_choices{ii, 2}.* size_e(2))./(length_e); % Directions normalized in cm
    w = plot(a,b,'r.','Markersize',5);
end

% Plot correct choices over selected session  
for ii = 1:length(Trajectories(s).correct_choices)
    a = (Trajectories(s).correct_choices{ii, 1}).* size_e(1)./(width);    % Directions normalized in cm
    b = (Trajectories(s).correct_choices{ii, 2}).* size_e(2)./(length_e); % Directions normalized in cm
    c = plot(a,b,'LineStyle','none','Marker','.','Markersize',5,'color',[0.3, 0.3, 0.3]);
end

%legend([c w],{'\fontsize{10}correct Choices';'\fontsize{10}Wrong Choices'},'Box','off', 'position',[0.202982487922705 0.115477706539509 0.139444444444444 0.0446666666666666]);
x1 = [12.3123574879227];   
y1 = [-2.33151933508312];
str1 = {'\fontsize{10}\bf| Correct'};
t1 = text(x1,y1,str1);

x2 = [12.2548527065395];   
y2 = [-10.4569293963255];
str2 = {'\fontsize{10}\bf| Wrong'};
t2 = text(x2,y2,str2);
t2(1).Color = 'r';


%%%% Velocity
fs = 1/mean(diff(BehavData(s).data_in.blend_data.raw_velocity_time(~isnan(BehavData(s).data_in.blend_data.raw_velocity_time))));
timew = 3; % define time in seconds
time_win = timew*fs; %time window 

VelocityAnalysis.velocity_window_c = zeros(length(EventTimes(s).correct_choices),ceil(time_win*2));
VelocityAnalysis.velocity_window_w = zeros(length(EventTimes(s).wrong_choices),ceil(time_win*2));
VelocityAnalysis.turn_window_c = zeros(length(EventTimes(s).correct_choices),ceil(time_win*2));
VelocityAnalysis.turn_window_w = zeros(length(EventTimes(s).wrong_choices),ceil(time_win*2));

for ii = 1:length(Velocity(s).correct_choices)
    for jjc = 1:length(EventTimes(s).correct_choices)
        idx1 = EventTimes(s).correct_choices(2,jjc);
        VelocityAnalysis.velocity_window_c(jjc,:) = Velocity(s).correct_choices{ii,4}(idx1-time_win:idx1+time_win);
        VelocityAnalysis.turn_window_c(jjc,:) = Velocity(s).correct_choices{ii,6}(idx1-time_win:idx1+time_win);
    end
end

for ii = 1:length(Velocity(s).wrong_choices)
    for jjw = 1:length(EventTimes(s).wrong_choices)
        idx2 = EventTimes(s).wrong_choices(2,jjw);
        VelocityAnalysis.velocity_window_w(jjw,:) = Velocity(s).wrong_choices{ii,4}(idx2-time_win:idx2+time_win);
        VelocityAnalysis.turn_window_w(jjw,:) = Velocity(s).wrong_choices{ii,6}(idx2-time_win:idx2+time_win);
    end
end

% Descriptive statistics for selected session- mean, SD, SEM
VelocityAnalysis.velocity_window_mean_c = (mean(VelocityAnalysis.velocity_window_c))/1000; 
VelocityAnalysis.sd_velocity_window_c = (std(VelocityAnalysis.velocity_window_c))/1000; 
VelocityAnalysis.sem_velocity_window_c = (std(VelocityAnalysis.velocity_window_c)/sqrt(length(VelocityAnalysis.velocity_window_c))/1000);

VelocityAnalysis.turn_window_mean_c = mean(VelocityAnalysis.turn_window_c); 
VelocityAnalysis.sd_turn_window_c = std(VelocityAnalysis.turn_window_c); 
VelocityAnalysis.sem_turn_window_c = std(VelocityAnalysis.turn_window_c)/sqrt(length(VelocityAnalysis.turn_window_c));

VelocityAnalysis.velocity_window_mean_w = (mean(VelocityAnalysis.velocity_window_w))/1000; 
VelocityAnalysis.sd_velocity_window_w = (std(VelocityAnalysis.velocity_window_w))/1000; 
VelocityAnalysis.sem_velocity_window_w = (std(VelocityAnalysis.velocity_window_w)/sqrt(length(VelocityAnalysis.velocity_window_w))/1000);

VelocityAnalysis.turn_window_mean_w = mean(VelocityAnalysis.turn_window_w); 
VelocityAnalysis.sd_turn_window_w = std(VelocityAnalysis.turn_window_w); 
VelocityAnalysis.sem_turn_window_w = std(VelocityAnalysis.turn_window_w)/sqrt(length(VelocityAnalysis.turn_window_w));

subplot(2,3,2)
hold all
VelocityAnalysis.Time = -timew:1/fs:timew;

yabove = VelocityAnalysis.velocity_window_mean_c+VelocityAnalysis.sem_velocity_window_c;
ybelow = VelocityAnalysis.velocity_window_mean_c-VelocityAnalysis.sem_velocity_window_c;
f = fill([VelocityAnalysis.Time fliplr(VelocityAnalysis.Time)], [yabove fliplr(ybelow)], [.9 .9 .9], 'linestyle', 'none'); % Filled 2-D polygons
yabove = VelocityAnalysis.velocity_window_mean_c+VelocityAnalysis.sem_velocity_window_c;
ybelow = VelocityAnalysis.velocity_window_mean_c-VelocityAnalysis.sem_velocity_window_c;
f = fill([VelocityAnalysis.Time fliplr(VelocityAnalysis.Time)], [yabove fliplr(ybelow)], [.9 .9 .9], 'linestyle', 'none'); % Filled 2-D polygons
v = plot(VelocityAnalysis.Time,VelocityAnalysis.velocity_window_mean_c);
v(1).LineWidth = 1;v(1).Color = 'k';

VelocityAnalysis.filter_vc = smooth(VelocityAnalysis.Time,VelocityAnalysis.velocity_window_mean_c,0.25,'rloess');
g1 = plot(VelocityAnalysis.Time,VelocityAnalysis.filter_vc,'LineWidth',3,'color', [0.6350, 0.0780, 0.1840]);

ylim([-15 30])
y1 = get(gca,'ylim');
plot([0 0],y1,'color','k','LineStyle',':')
plot([1.7 1.7],y1,'color','k','LineStyle',':')
%axis square

title({'\fontsize{12}Velocity over'; 'Correct Trials'})
ylabel('Velocity (cm/s)');
xlabel('Time')
legend([v g1 f],{'Mean','Fit','SEM'},'Box','off','location','southwest' )

x1 = [0.827272484116559];
y1 = [17.1711449633183];
str1 = {'\fontsize{10}\bf Reward';'\fontsize{10}\bf Zone'};
t1 = text(x1,y1,str1,'HorizontalAlignment','center');

subplot(2,3,3)
hold all

yabove = VelocityAnalysis.velocity_window_mean_w+VelocityAnalysis.sem_velocity_window_w;
ybelow = VelocityAnalysis.velocity_window_mean_w-VelocityAnalysis.sem_velocity_window_w;
f=fill([VelocityAnalysis.Time fliplr(VelocityAnalysis.Time)], [yabove fliplr(ybelow)], [.9 .9 .9], 'linestyle', 'none'); % Filled 2-D polygons
yabove = VelocityAnalysis.velocity_window_mean_w+VelocityAnalysis.sem_velocity_window_w;
ybelow = VelocityAnalysis.velocity_window_mean_w-VelocityAnalysis.sem_velocity_window_w;
f=fill([VelocityAnalysis.Time fliplr(VelocityAnalysis.Time)], [yabove fliplr(ybelow)], [.9 .9 .9], 'linestyle', 'none'); % Filled 2-D polygons
v = plot(VelocityAnalysis.Time,VelocityAnalysis.velocity_window_mean_w);
v(1).LineWidth = 1;v(1).Color = 'k';

VelocityAnalysis.filter_vw = smooth(VelocityAnalysis.Time,VelocityAnalysis.velocity_window_mean_w,0.25,'rloess');
plot(VelocityAnalysis.Time,VelocityAnalysis.filter_vw,'LineWidth',3,'color', [0.6350, 0.0780, 0.1840]);

ylim([-15 30])
y1 = get(gca,'ylim');
plot([0 0],y1,'color','k','LineStyle',':')
plot([2.999 2.999],y1,'color','k','LineStyle',':')
%axis square

title({'\fontsize{12}Velocity over';'Wrong Trials'})
ylabel('Velocity (cm/s)');
xlabel('Time')
legend([v g1 f],{'Mean','Fit','SEM'},'Box','off','location','southwest' )

x1 = [1.51298676983084];
y1 = [17.1711449633183];
str1 = {'\fontsize{10}\bf Punishment';'\fontsize{10}\bf Zone'};
t1 = text(x1,y1,str1,'HorizontalAlignment','center');

% Distance

% Descriptive statistics for selected session- mean, SD, SEM

DistanceAnalysis.integral_c = zeros(1,length(EventTimes(s).correct_choices));
DistanceAnalysis.cumulative_c = zeros(size(VelocityAnalysis.velocity_window_c));

DistanceAnalysis.integral_w = zeros(1,length(EventTimes(s).wrong_choices));
DistanceAnalysis.cumulative_w = zeros(size(VelocityAnalysis.velocity_window_w));

for ii = 1:length(Distances(s).correct_choices)
    DistanceAnalysis.integral_c(ii) = Distances(s).correct_choices{ii, 1};
    DistanceAnalysis.cumulative_c(ii,:) = cumtrapz(VelocityAnalysis.velocity_window_c(ii, :));
end

for ii = 1:length(Distances(s).wrong_choices)
    DistanceAnalysis.integral_w(ii) = Distances(s).wrong_choices{ii, 1};
    DistanceAnalysis.cumulative_w(ii,:) = cumtrapz(VelocityAnalysis.velocity_window_w(ii, :));
end

DistanceAnalysis.mean_cumulative_c = (mean(DistanceAnalysis.cumulative_c))/1000; 
DistanceAnalysis.sd_cumulative_c = (std(DistanceAnalysis.cumulative_c))/1000; 
DistanceAnalysis.sem_cumulative_c = (std(DistanceAnalysis.cumulative_c)/sqrt(length(DistanceAnalysis.cumulative_c))/1000);

DistanceAnalysis.mean_cumulative_w = (mean(DistanceAnalysis.cumulative_w))/1000; 
DistanceAnalysis.sd_cumulative_w = (std(DistanceAnalysis.cumulative_w))/1000; 
DistanceAnalysis.sem_cumulative_w = (std(DistanceAnalysis.cumulative_w)/sqrt(length(DistanceAnalysis.cumulative_w))/1000);

% Figure

subplot(2,3,5)
hold all
DistanceAnalysis.Time = -timew:1/fs:timew;

yabove = DistanceAnalysis.mean_cumulative_c+DistanceAnalysis.sem_cumulative_c;
ybelow = DistanceAnalysis.mean_cumulative_c-DistanceAnalysis.sem_cumulative_c;
f = fill([DistanceAnalysis.Time fliplr(DistanceAnalysis.Time)], [yabove fliplr(ybelow)], [.9 .9 .9], 'linestyle', 'none'); % Filled 2-D polygons
yabove = DistanceAnalysis.mean_cumulative_c+DistanceAnalysis.sem_cumulative_c;
ybelow = DistanceAnalysis.mean_cumulative_c-DistanceAnalysis.sem_cumulative_c;
f = fill([DistanceAnalysis.Time fliplr(DistanceAnalysis.Time)], [yabove fliplr(ybelow)], [.9 .9 .9], 'linestyle', 'none'); % Filled 2-D polygons
v = plot(DistanceAnalysis.Time,DistanceAnalysis.mean_cumulative_c);
v(1).LineWidth = 1;v(1).Color = 'k';

DistanceAnalysis.filter_vc = smooth(VelocityAnalysis.Time,DistanceAnalysis.mean_cumulative_c,0.25,'rloess');
g1 = plot(DistanceAnalysis.Time,DistanceAnalysis.filter_vc,'LineWidth',3,'color', [0.6350, 0.0780, 0.1840]);

ylim([-5 3000])
y1 = get(gca,'ylim');
plot([0 0],y1,'color','k','LineStyle',':')
plot([1.7 1.7],y1,'color','k','LineStyle',':')
%axis square

title({'\fontsize{12}Cumulative Distance over'; 'Correct Trials'})
ylabel('Distance (cm)');
xlabel('Time')
legend([v g1 f],{'Mean','Fit','SEM'},'Box','off','location','northwest' )

x1 = [0.855441498201065];
y1 = [350.5725534140225];
str1 = {'\fontsize{10}\bf Reward';'\fontsize{10}\bf Zone'};
t1 = text(x1,y1,str1,'HorizontalAlignment','center');

subplot(2,3,6)
hold all

yabove = DistanceAnalysis.mean_cumulative_w+DistanceAnalysis.sem_cumulative_w;
ybelow = DistanceAnalysis.mean_cumulative_w-DistanceAnalysis.sem_cumulative_w;
f = fill([DistanceAnalysis.Time fliplr(DistanceAnalysis.Time)], [yabove fliplr(ybelow)], [.9 .9 .9], 'linestyle', 'none'); % Filled 2-D polygons
yabove = DistanceAnalysis.mean_cumulative_w+DistanceAnalysis.sem_cumulative_w;
ybelow = DistanceAnalysis.mean_cumulative_w-DistanceAnalysis.sem_cumulative_w;
f = fill([DistanceAnalysis.Time fliplr(DistanceAnalysis.Time)], [yabove fliplr(ybelow)], [.9 .9 .9], 'linestyle', 'none'); % Filled 2-D polygons
v = plot(DistanceAnalysis.Time,DistanceAnalysis.mean_cumulative_w);
v(1).LineWidth = 1;v(1).Color = 'k';

DistanceAnalysis.filter_vc = smooth(VelocityAnalysis.Time,DistanceAnalysis.mean_cumulative_w,0.25,'rloess');
g1 = plot(DistanceAnalysis.Time,DistanceAnalysis.filter_vc,'LineWidth',3,'color', [0.6350, 0.0780, 0.1840]);

ylim([-5 3000])
y1 = get(gca,'ylim');
plot([0 0],y1,'color','k','LineStyle',':')
plot([2.999 2.999],y1,'color','k','LineStyle',':')
%axis square

title({'\fontsize{12}Cumulative Distance over'; 'Wrong Trials'})
ylabel('Distance (cm)');
xlabel('Time')
legend([v g1 f],{'Mean','Fit','SEM'},'Box','off','location','northwest' )

x1 = [1.48488372533435];
y1 = [350.5725534140225];
str1 = {'\fontsize{10}\bf Punishment';'\fontsize{10}\bf Zone'};
t1 = text(x1,y1,str1,'HorizontalAlignment','center');

clear ('f1','jj','q','sessions','input')
%% 
% Flavio Mourao. Last update 23/04/18. 16.13am. David Wilson Library. Leicester Uk
% listening: Mogwai - May nothing but hapiness come through your door 

