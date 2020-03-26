%% Preparing data and figures from .mat files
%  - Phase analyses based on Hilbert Transform

% Flavio Mourao. Nucleo de Neurociencias NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais 02/2020

%% Run each session sequentially

%%
% Hilbert Transform

%loop over channels and make hilbert transform

hilb.coefficients = zeros(size(data.envelope_ALL_trials));

for ii = 1:size(data.envelope_ALL_trials,1)
    for jj = 1:size(data.envelope_ALL_trials,3)
        temp = data.envelope_ALL_trials(ii,1:end,jj);
        temp(isnan(temp))=[]; %in some cases there are NAN in the end of trials after reshape
        hilb.coefficients(ii,1:length(temp),jj) = hilbert(temp);
    end
end 

% Extract phase
hilb.phase_trials = angle(hilb.coefficients); % Trials

clear('ii','jj','temp')

%% Delta phase from Euler representation of angles
  
% Difference between channels

% column 1 --> IC   - modulator
% column 2 --> AMYL - modulator
% column 3 --> AMYR - modulator
% column 4 --> AMYL - IC
% column 5 --> AMYR - IC
% column 6 --> AMYR - AMYL

% all possible channels combinations
parameters.combinations = nchoosek(1:size(hilb.phase_trials,1),2);

% Delta phase for each trial
for ii = 1:length(parameters.combinations)
    hilb.phase_delta_trials{1,ii} = squeeze(exp(1i*(hilb.phase_trials(parameters.combinations(ii,2),:,:) - hilb.phase_trials(parameters.combinations(ii,1),:,:))))';
end

clear('parameters.combinations','ii')

%% Extracted relative phase and length of circular variance (PLV) 
%  Measure of phase synchronization

% Time window
hilb.time_window     =  3; % sec.
hilb.time_window_idx = round(hilb.time_window*parameters.srate);

% Overlap
hilb.timeoverlap    = .9; % percentage
overlap = round((hilb.time_window_idx)-(hilb.timeoverlap*hilb.time_window_idx));

% Time epochs
time2save_idx = (1:overlap:length(hilb.phase_delta_trials{1,1})-hilb.time_window_idx);

hilb.phase_win_trials      = cell(1,length(hilb.phase_delta_trials));
hilb.PLV_win_trials        = cell(1,length(hilb.phase_delta_trials));
hilb.phase_win_mean_trials = cell(1,length(hilb.phase_delta_trials));
hilb.PLV_win_mean_trials   = cell(1,length(hilb.phase_delta_trials));

for ii = 1:length(hilb.phase_delta_trials)
    for jj = 1:length(time2save_idx)
        temp1   = mean(hilb.phase_delta_trials{1,ii}(:,time2save_idx(jj):(time2save_idx(jj) + hilb.time_window_idx -1)),2);
        
        hilb.phase_win_trials{ii}(:,jj) = angle(temp1); % time epoch for all trials over time
        hilb.PLV_win_trials{ii}(:,jj)   = abs(temp1);   % time epoch for all trials over time
        
        hilb.phase_win_mean_trials{ii}(:,jj) = angle(mean(temp1,1)); % one value for each time epoch. Average trials
        hilb.PLV_win_mean_trials{ii}(:,jj)   = mean(abs(temp1),1);   % one value for each time epoch. Average trials

    end
end

% Time vector
hilb.time_trials = (linspace(-parameters.Tpre,parameters.trialperiod+parameters.Tpos,size(hilb.phase_win_trials{1, 1},2)));

clear ('overlap','time2save_idx','ii','jj','temp1')

%% Plot to check average angles in the sliding window

figure

% choose comparison
c = 1;

% 1 --> IC   - modulator
% 2 --> AMYL - modulator
% 3 --> AMYR - modulator
% 4 --> AMYL - IC
% 5 --> AMYR - IC
% 6 --> AMYR - AMYL

titles = {'IC and modulator', 'AMYL and modulator','AMYR and modulator'...
           'AMYL and IC', 'AMYR and IC', 'AMYR and AMYL'};
       
suptitle({[' \Delta Phase between: ' titles{c}] ;['Time window = ' num2str(hilb.time_window) 's ' '- ' 'Overlap = ' num2str(hilb.timeoverlap*100) '%'];[]}) 
set(gcf,'color','white')


for ii = 1:parameters.NTrials
    subplot(3,2,ii)
    plot(hilb.time_trials,rad2deg(hilb.phase_win_trials{1, c}(ii,:)),'k','linew',1)
    set(gca,'xlim',[hilb.time_trials(1) hilb.time_trials(end)],'ylim',[-180 180])
    title (['Trial ' num2str(ii)])
    xlabel('Time (s)')
    ylabel('\Delta Phase (^{o})')
end
    
figure

titles = {'IC  - modulator', 'AMYL - modulator','AMYR - modulator'...
           'AMYL - IC', 'AMYR - IC', 'AMYR - AMYL'};
       
suptitle({'\Delta Phase average between trials';['Time window = ' num2str(hilb.time_window) 's ' '- ' 'Overlap = ' num2str(hilb.timeoverlap*100) '%'];[]}) 
set(gcf,'color','white')

for ii = 1:length(hilb.phase_win_trials)
    subplot(3,2,ii)
    plot(hilb.time_trials,-1*(rad2deg(hilb.phase_win_mean_trials{1, ii})),'k','linew',1)
    set(gca,'xlim',[hilb.time_trials(1) hilb.time_trials(end)],'ylim',[-180 180])
    title (titles{ii})
    xlabel('Time (s)')
    ylabel('\Delta Phase (^{o})')
end

clear('c','ii','titles')

%% Plot to check PLV in the sliding window

figure

% choose comparison
c = 1;

% 1 --> IC   - modulator
% 2 --> AMYL - modulator
% 3 --> AMYR - modulator
% 4 --> AMYL - IC
% 5 --> AMYR - IC
% 6 --> AMYR - AMYL

titles = {'IC and modulator', 'AMYL and modulator','AMYR and modulator'...
           'AMYL and IC', 'AMYR and IC', 'AMYR and AMYL'};
       
suptitle({[' PLV between: ' titles{c}] ;['Time window = ' num2str(hilb.time_window) 's ' '- ' 'Overlap = ' num2str(hilb.timeoverlap*100) '%'];[]}) 
set(gcf,'color','white')


for ii = 1:parameters.NTrials
    subplot(3,2,ii)
    plot(hilb.time_trials, hilb.PLV_win_trials{1, c}(ii,:),'k','linew',1)
    set(gca,'xlim',[hilb.time_trials(1) hilb.time_trials(end)],'ylim',[0 1])
    title (['Trial ' num2str(ii)])
    xlabel('Time (s)')
    ylabel('Phase Synchronization')
end
    

figure

titles = {'IC  - modulator', 'AMYL - modulator','AMYR - modulator'...
           'AMYL - IC', 'AMYR - IC', 'AMYR - AMYL'};
       
suptitle({'PLV average between trials';['Time window = ' num2str(hilb.time_window) 's ' '- ' 'Overlap = ' num2str(hilb.timeoverlap*100) '%'];[]}) 
set(gcf,'color','white')

for ii = 1:length(hilb.phase_win_trials)
    subplot(3,2,ii)
    plot(hilb.time_trials,hilb.PLV_win_mean_trials{1, ii},'k','linew',1)
    set(gca,'xlim',[hilb.time_trials(1) hilb.time_trials(end)],'ylim',[0 1])
    title (titles{ii})
    xlabel('Time (s)')
    ylabel('Phase Synchronization')
end

clear('c','ii','titles')

%% Time vectors to cut and STATS

% Attention. The time values were corrected by visual inspection. 
% Fs from TDT with odd number and decimal values fuck with my life

% Time index --> 0s: sound sound begins / 30s: sound ends
hilb.time_zero_idx = dsearchn(hilb.time_trials',-2.38'); % time zero index. Sound Start. Time corrected by visual inspection 
hilb.time_end_idx = dsearchn(hilb.time_trials',32.47'); % time  30s index. Sound Ends. Time corrected by visual inspection 

hilb.phase_mean_trials = cell(2,length(hilb.phase_delta_trials));
hilb.PLV_mean_trials   = cell(2,length(hilb.phase_delta_trials));


% Mean values for all trials and channels comparisons

% row 1 --> pre sound period
% row 2 --> sound period

% column 1 --> IC   - modulator
% column 2 --> AMYL - modulator
% column 3 --> AMYR - modulator
% column 4 --> AMYL - IC
% column 5 --> AMYR - IC
% column 6 --> AMYR - AMYL

for ii = 1:length(hilb.phase_delta_trials)
        hilb.phase_mean_trials{1,ii}  = circ_mean(hilb.phase_win_trials{ii}(:,1:hilb.time_zero_idx-1),[],2);;              % one value for each trial. Average time during pre sound period
        hilb.phase_mean_trials{2,ii}  = circ_mean(hilb.phase_win_trials{ii}(:,hilb.time_zero_idx:hilb.time_end_idx),[],2); % one value for each trial. Average time during sound period

        hilb.PLV_mean_trials{1,ii}    = mean(hilb.PLV_win_trials{ii}(:,1:hilb.time_zero_idx-1),2);               % one value for each trial. Average time during pre sound period
        hilb.PLV_mean_trials{2,ii}    = mean(hilb.PLV_win_trials{ii}(:,hilb.time_zero_idx:hilb.time_end_idx),2); % one value for each trial. Average time during sound period
end


% PLV - Total mean session

% Difference between channels

% row 1 --> IC   - modulator
% row 2 --> AMYL - modulator
% row 3 --> AMYR - modulator
% row 4 --> AMYL - IC
% row 5 --> AMYR - IC
% row 6 --> AMYR - AMYL

% column 1 --> pre sound
% column 2 --> sound period


for ii = 1:length(hilb.phase_delta_trials)
        hilb.PLV_Total_mean(ii,1)   = mean(hilb.PLV_mean_trials{1, ii},1); % one value for each session. Average during pre sound period
        hilb.PLV_Total_mean(ii,2)   = mean(hilb.PLV_mean_trials{2, ii},1); % one value for each session. Average during sound period
end

% --> circular-statistics-toolbox
% https://www.mathworks.com/matlabcentral/fileexchange/10676-circular-statistics-toolbox-directional-statistics

clear('ii')

%% Plot polar plots

figure
suptitle({'\Delta Phase average over trials. Sound period';['Time window = ' num2str(hilb.time_window) 's ' '- ' 'Overlap = ' num2str(hilb.timeoverlap*100) '%'];[]}) 
set(gcf,'color','white')

titles = {'IC   - modulator', 'AMYL - modulator','AMYR - modulator'...
           'AMYL - IC', 'AMYR - IC', 'AMYR - AMYL'};

sub_ind = 1;

while sub_ind <= parameters.NTrials * size(parameters.combinations,1)

for jj = 1:length(hilb.phase_win_trials)
    for ii = 1:parameters.NTrials * size(parameters.combinations,1)
        
    subplot(6,5,sub_ind)
    polarplot([zeros(size(hilb.phase_win_trials{jj}(ii,hilb.time_zero_idx:hilb.time_end_idx))), hilb.phase_win_trials{jj}(ii,hilb.time_zero_idx:hilb.time_end_idx)]',repmat([0 1],1,length(hilb.phase_win_trials{jj}(ii,hilb.time_zero_idx:hilb.time_end_idx)))','k');
    hold all
    polarplot([0,hilb.phase_mean_trials{2,jj}(ii,1)]',[0 1]','Color','[0.6350, 0.0780, 0.1840]','linew',2);
    title(['Trial ', num2str(ii)]);
    
        if mod(sub_ind,parameters.NTrials) == 0  
           break
      
        end 
        
    sub_ind = sub_ind+1; 
    
    end
    sub_ind = sub_ind+1; 
end
end


figure
suptitle({'\Delta Phase average over trials. Pre Sound';['Time window = ' num2str(hilb.time_window) 's ' '- ' 'Overlap = ' num2str(hilb.timeoverlap*100) '%'];[]}) 
set(gcf,'color','white')

titles = {'IC   - modulator', 'AMYL - modulator','AMYR - modulator'...
           'AMYL - IC', 'AMYR - IC', 'AMYR - AMYL'};

sub_ind = 1;

while sub_ind <= parameters.NTrials * size(parameters.combinations,1)

for jj = 1:length(hilb.phase_win_trials)
    for ii = 1:parameters.NTrials * size(parameters.combinations,1)
        
    subplot(6,5,sub_ind)
    polarplot([zeros(size(hilb.phase_win_trials{jj}(ii,1:hilb.time_zero_idx-1))), hilb.phase_win_trials{jj}(ii,1:hilb.time_zero_idx-1)]',repmat([0 1],1,length(hilb.phase_win_trials{jj}(ii,1:hilb.time_zero_idx-1)))','k');
    hold all
    polarplot([0,hilb.phase_mean_trials{1,jj}(ii,1)]',[0 1]','Color','[0.6350, 0.0780, 0.1840]','linew',2);
    title(['Trial ', num2str(ii)]);
    
        if mod(sub_ind,parameters.NTrials) == 0  
           break
      
        end 
        
    sub_ind = sub_ind+1; 
    
    end
    sub_ind = sub_ind+1; 
end
end

clear ('ii','jj','sub_ind','titles')
%%
 save('G7-R7_pre_MUS','data','filter','hilb','parameters','short_fft')

%% last update 18/02/2020 - 01:05am
%  listening: Set Fire To Flames - Fading Lights Are Fading