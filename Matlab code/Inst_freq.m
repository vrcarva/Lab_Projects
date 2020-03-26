%% Preparing data and figures from .mat files
%  - Estimated instantaneous frequency based on Hilbert Transform

% Flavio Mourao. Nucleo de Neurociencias NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais 03/2020

%% Estimated instantaneous frequency - Hilbert - by matlab built function instfreq

% Filter the desired frequency band in each trial

%  first dimension (rows) --> substrates
% Row 1:  Sound envelope 
% Row 2:  IC  Left 
% Row 3:  AMY Left 
% Row 4:  AMY Right

% second dimension (columns) --> time
% third dimension (blocks) --> trials

instfrq.filterbands = [50 60]; 

instfrq.data_trials_Filter = zeros(size(data.raw_ALL_trials));

for ii = 1:size(data.raw_ALL_trials,1)
    for jj = 1:size(data.raw_ALL_trials,3)
        temp = data.raw_ALL_trials(ii,1:end,jj);
        temp(isnan(temp))=[];
        instfrq.data_trials_Filter(ii,1:length(temp),jj) = fun_myfilters(temp,parameters.srate,instfrq.filterbands,'iir',0 );
    end
end

clear ('temp', 'ii','jj')

%% Instantaneous frequency for each trial - Matlab build Fuinction

instfrq.instfrqTrials = zeros(size(instfrq.data_trials_Filter));

for ii = 1:size(instfrq.data_trials_Filter,1)
    for jj = 1:size(instfrq.data_trials_Filter,3)
        temp = instfrq.data_trials_Filter(ii,1:end,jj);
        temp(isnan(temp))=[]; %in some cases there are NAN in the end of trials after reshape

        instfrq.instfrqTrials(ii,1:length(temp)-1,jj) = instfreq(temp,parameters.srate,'method','hilbert')';
    end
end 

% By hand
% instfrq = (parameters.srate/(2*pi))*diff(unwrap(hilb.phase_mean_Trials(2,:)));

clear ('temp', 'ii','jj')

%% Sliding window over frequencies with programmable overlap

% cell columns --> substrates
% each cell:
%  - columns: Trials
%  - rowns: time

% Time window
instfrq.time_window     =  1; % sec.
instfrq.time_window_idx = round(instfrq.time_window*parameters.srate);

% Overlap
instfrq.timeoverlap    = .5; % percentage
overlap = round((instfrq.time_window_idx)-(instfrq.timeoverlap*instfrq.time_window_idx));

% Time epochs
instfrq.time2save_idx = (1:overlap:length(instfrq.instfrqTrials)-instfrq.time_window_idx);

for ii = 1:size(instfrq.instfrqTrials,1)
    for jj = 1:length(instfrq.time2save_idx)
        instfrq.instfrq_win_trials{ii}(1,jj,:)   = mean(instfrq.instfrqTrials(ii,instfrq.time2save_idx(jj):(instfrq.time2save_idx(jj) + instfrq.time_window_idx -1),:),2);
    end
        instfrq.instfrq_win_trials{ii} = squeeze(instfrq.instfrq_win_trials{ii});
end 

% stats
% extracting the mean trials, standard deviation and standard error of the mean

% cell columns --> substrates
% cell rowns
% - 1) mean
% - 2) Std
% - 3) SEM

% each cell:
%  - columns: time

for ii = 1:length(instfrq.instfrq_win_trials)

instfrq.stats1{1,ii} = mean(instfrq.instfrq_win_trials{ii},2)';
instfrq.stats1{2,ii} = std(instfrq.instfrq_win_trials{ii},[],2)';
instfrq.stats1{3,ii} = instfrq.stats1{2,ii}./sqrt(size(instfrq.stats1{2,ii},2));

end

clear ('ii','jj','overlap','time2save_idx')

%% Plot to check

% time window
instfrq.time1 = linspace(-parameters.Tpre,parameters.trialperiod+parameters.Tpos,size(instfrq.stats1{1,1},2));

figure
titles = {'Inferior colliculus', 'AMY Left', 'AMY Right'};
suptitle ('Estimated instantaneous frequency - Hilbert')

for ii = 2:length(instfrq.stats1)
    
    if ii == 2
       subplot(2,2,[ii-1,ii])

       yabove = instfrq.stats1{1,ii}+instfrq.stats1{3,ii};
       ybelow = instfrq.stats1{1,ii}-instfrq.stats1{3,ii};
       fill([instfrq.time1 fliplr(instfrq.time1)], [yabove fliplr(ybelow)], [.8 .8 .8], 'linestyle', 'none') % Funcao Filled 2-D polygons
       hold all
       plot(instfrq.time1,instfrq.stats1{1,ii},'k')

       plot([0 0],instfrq.filterbands,'r--','linew',2)
       plot([30 30],instfrq.filterbands,'r--','linew',2)
       xlabel('Time (s)'), ylabel('Frequency (Hz)')
       ylim(instfrq.filterbands)
       xlim([-29 40])
       title (titles{ii-1})
       
    else
       subplot(2,2,ii) 
       yabove = instfrq.stats1{1,ii}+instfrq.stats1{3,ii};
       ybelow = instfrq.stats1{1,ii}-instfrq.stats1{3,ii};
       fill([instfrq.time1 fliplr(instfrq.time1)], [yabove fliplr(ybelow)], [.8 .8 .8], 'linestyle', 'none') % Funcao Filled 2-D polygons
       hold all
       plot(instfrq.time1,instfrq.stats1{1,ii},'k')

       plot([0 0],instfrq.filterbands,'r--','linew',2)
       plot([30 30],instfrq.filterbands,'r--','linew',2)
       xlabel('Time (s)'), ylabel('Frequency (Hz)')
       ylim(instfrq.filterbands)
       xlim([-29 40])
       title (titles{ii-1})
       
    end

end

clear ('ii','titles','yabove','ybelow')

%% stats in a full window - without a slinding smooth
% extracting the mean trials, standard deviation and standard error of the mean

% cell columns --> substrates
% cell rowns
% - 1) mean
% - 2) Std
% - 3) SEM

% each cell:
%  - columns: time

for ii = 1:size(instfrq.instfrqTrials,1)

instfrq.stats2{1,ii} = mean(instfrq.instfrqTrials(ii,:,:),3);
instfrq.stats2{2,ii} = std(instfrq.instfrqTrials(ii,:,:),[],3);
instfrq.stats2{3,ii} = instfrq.stats2{2,ii}./sqrt(size(instfrq.stats2{2,ii},2));

end

clear ('ii')

%% Plot to check - This one take time...

% Time window
instfrq.time2 = linspace(-parameters.Tpre,parameters.trialperiod+parameters.Tpos,size(instfrq.stats2{1,1},2));


figure
titles = {'Inferior colliculus', 'AMY Left', 'AMY Right'};
suptitle ('Estimated instantaneous frequency - Hilbert')

for ii = 2:length(instfrq.stats2)
    
    if ii == 2
       subplot(2,2,[ii-1,ii])

       yabove = instfrq.stats2{1,ii}+instfrq.stats2{3,ii};
       ybelow = instfrq.stats2{1,ii}-instfrq.stats2{3,ii};
       fill([instfrq.time2 fliplr(instfrq.time2)], [yabove fliplr(ybelow)], [.8 .8 .8], 'linestyle', 'none') % Funcao Filled 2-D polygons
       hold all
       plot(instfrq.time2,instfrq.stats2{1,ii},'k')

       plot([0 0],instfrq.filterbands,'r--','linew',2)
       plot([30 30],instfrq.filterbands,'r--','linew',2)
       xlabel('Time (s)'), ylabel('Frequency (Hz)')
       ylim(instfrq.filterbands)
       xlim([-29 40])
       title (titles{ii-1})
       
    else
       subplot(2,2,ii) 
       yabove = instfrq.stats2{1,ii}+instfrq.stats2{3,ii};
       ybelow = instfrq.stats2{1,ii}-instfrq.stats2{3,ii};
       fill([instfrq.time2 fliplr(instfrq.time2)], [yabove fliplr(ybelow)], [.8 .8 .8], 'linestyle', 'none') % Funcao Filled 2-D polygons
       hold all
       plot(instfrq.time2,instfrq.stats2{1,ii},'k')

       plot([0 0],instfrq.filterbands,'r--','linew',2)
       plot([30 30],instfrq.filterbands,'r--','linew',2)
       xlabel('Time (s)'), ylabel('Frequency (Hz)')
       ylim(instfrq.filterbands)
       xlim([-29 40])
       title (titles{ii-1})
       
    end

end

clear('ii','jj','overlap','temp','time2save_idx','yabove','ybelow','titles')

%% Filter the desired frequency band in full session record

%  first dimension (rows) --> substrates
% Row 1:  Sound envelope 
% Row 2:  IC  Left 
% Row 3:  AMY Left 
% Row 4:  AMY Right

% second dimension (columns) --> time
% third dimension (blocks) --> trials

instfrq.filterbands = [50 60]; 

instfrq.data_Filter = zeros(size(data.raw));

for ii = 1:size(data.raw,1)
        instfrq.data_Filter(ii,:) = fun_myfilters(data.raw(ii,:),parameters.srate,instfrq.filterbands,'iir',0 );
end

clear('ii')

%% Instantaneous frequency in full session record - Matlab build Fuinction

instfrq.instfrq_full = zeros(size(instfrq.data_Filter,1),(size(instfrq.data_Filter,2)-1));

for ii = 1:size(instfrq.data_Filter,1)
instfrq.instfrq_full(ii,:) = instfreq(instfrq.data_Filter(ii,:),parameters.srate,'method','hilbert');
end

clear('ii')

%% Plot to check the Filtered record and the Instantaneous frequency

% organize all data to plot

% even rows --> data_filter
% odd  rows --> instfrq_full

temp2plot = zeros(size(instfrq.data_Filter,1)*2,size(instfrq.data_Filter,2));
temp2plot(1:2:end,:) = instfrq.data_Filter(:,:);
temp2plot(2:2:end,1:length(instfrq.instfrq_full)) = instfrq.instfrq_full(:,:);

% Time windows
instfrq.time_data_Filter = (linspace(1,size(instfrq.data_Filter,2)./parameters.srate,size(instfrq.data_Filter,2)));
instfrq.time_instfreq_full = (linspace(1,size(instfrq.instfrq_full,2)./parameters.srate,size(instfrq.instfrq_full,2)));

figure
titles = {'Inferior colliculus', 'AMY Left', 'AMY Right'};
suptitle ('Estimated instantaneous frequency - Hilbert')


for ii = 1:size(temp2plot,1)

    if mod(ii,2)>0
       subplot(size(temp2plot,1),1,ii)
       plot(instfrq.time_data_Filter,temp2plot(ii,:),'k')
       xlabel('Time (s)'), ylabel('Frequency (Hz)')
       xlim([1 instfrq.time_data_Filter(end)])
       %title (titles{ii})         
   
    elseif ii == 2 % ignore instfrq_full for the modulator
        continue
        
       else 
       subplot(size(temp2plot,1),1,ii)
       plot(instfrq.time_data_Filter,temp2plot(ii,:),'k')
       xlabel('Time (s)'), ylabel('Frequency (Hz)')
       xlim([1 instfrq.time_instfreq_full(end)])
       ylim(instfrq.filterbands)
       
    end
end

clear('ii','temp2plot','titles')
%% data to analised

% Extracted Index (trial begin/end - only sound period)
% Extrated index from instfrq.time1 for smooth window (with overlap)
% Extrated index from instfrq.time2 for full window (without overlap)

instfrq.trial_idx(1,1) = dsearchn(instfrq.time2',0);
instfrq.trial_idx(1,2) = dsearchn(instfrq.time2',30);


    
%( i will finish later .... )

%% last update 03/03/2020 - 10:40am
%  listening: Godspeed You! Black Emperor - Bosses Hang, Pt. I
