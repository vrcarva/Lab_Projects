%% Granger prediction parameters

% Granger prediction parameters
Granger.timewin = 2000; % in ms

% Temporal down-sample results (but not data!)
Granger.times2save = -10:0.2:32; % in seconds

% Convert parameters to indices
Granger.timewin_points = round(Granger.timewin/(1000/params.srate));

% Convert requested times to indices. Considering all trials with the same time window
Granger.times2saveidx = dsearchn(params.time_trials{1,1}',Granger.times2save');

%% Test Bayes info criteria(BIC) for optimal model order at each time point

% initialize
Granger.bic = zeros(length(Granger.times2save),30); % Bayes info criteria (hard-coded to order=15)

% for ii = 1:numel(data.raw_trials)
    for timei=1:length(Granger.times2save)
    
    % data from all trials in this time window
    % Line 1 = LFP
    Granger.tempdata(1,:) = data.raw_trials{ii}(Granger.times2saveidx(timei)-floor(Granger.timewin_points/2):Granger.times2saveidx(timei)+floor(Granger.timewin_points/2)-mod(Granger.timewin_points+1,2));
    % Line 2 = Sound envelope
    Granger.tempdata(2,:) = data.envelope_trials{ii}(Granger.times2saveidx(timei)-floor(Granger.timewin_points/2):Granger.times2saveidx(timei)+floor(Granger.timewin_points/2)-mod(Granger.timewin_points+1,2));

    % detrend and zscore all data   
    Granger.tempdata(1,:) = zscore(detrend(squeeze(Granger.tempdata(1,:))));
    Granger.tempdata(2,:) = zscore(detrend(squeeze(Granger.tempdata(2,:))));
   
        for bici=1:size(Granger.bic,2)
            % run model
            [Axy,E] = armorf(Granger.tempdata,1,Granger.timewin_points,bici);
            % compute Bayes Information Criteria
            Granger.bic(timei,bici) = log(det(E)) + (log(length(Granger.tempdata))*bici*2^2)/length(Granger.tempdata);

        end
    end
% end

figure

subplot(121)
plot((1:size(Granger.bic,2))*(1000/params.srate),mean(Granger.bic,1),'--.')
xlabel('Order (converted to ms)')
ylabel('Mean BIC over all time points')

[Granger.bestbicVal,Granger.bestbicIdx]=min(mean(Granger.bic,1));
hold on
plot(Granger.bestbicIdx*(1000/params.srate),Granger.bestbicVal,'mo','markersize',15)

title([ 'Optimal order is ' num2str(Granger.bestbicIdx) ' (' num2str(Granger.bestbicIdx*(1000/params.srate)) ' ms)' ])

subplot(122)
[junk,Granger.bic_per_timepoint] = min(Granger.bic,[],2);
plot(Granger.times2save,Granger.bic_per_timepoint*(1000/params.srate),'--.')
xlabel('Time (ms)')
ylabel('Optimal order (converted to ms)')
title('Optimal order (in ms) at each time point')

%% Test Bayes info criteria(BIC) for optimal model order at whole session

% initialize
Granger.bic = zeros(length(Granger.times2save),50); % Bayes info criteria (hard-coded to order=15)

for timei=1:length(Granger.times2save)
    
    % data from all trials in this time window
    
    % Line 1 = LFP 53.71/ Line 2 = LFP 92.77
    Granger.tempdata = squeeze(data.raw_ALL_trials(:,Granger.times2saveidx(timei)-floor(Granger.timewin_points/2):Granger.times2saveidx(timei)+floor(Granger.timewin_points/2)-mod(Granger.timewin_points+1,2),:));

    % Line 1 = LFP 53.71/ Line 2 = LFP 92.77
    Granger.tempenvelop = squeeze(data.envelope_ALL_trials(:,Granger.times2saveidx(timei)-floor(Granger.timewin_points/2):Granger.times2saveidx(timei)+floor(Granger.timewin_points/2)-mod(Granger.timewin_points+1,2),:));

    % detrend and zscore all data
    for triali=1:size(Granger.tempenvelop,3)
        Granger.tempdata(1,:,triali)    = zscore(detrend(squeeze(Granger.tempdata(1,:,triali))));
        Granger.tempdata(2,:,triali)    = zscore(detrend(squeeze(Granger.tempdata(2,:,triali))));
        Granger.tempenvelop(1,:,triali) = zscore(detrend(squeeze(Granger.tempenvelop(1,:,triali))));
        Granger.tempenvelop(2,:,triali) = zscore(detrend(squeeze(Granger.tempenvelop(2,:,triali))));
        
        % At this point with real data, you should check for stationarity
        % and possibly discard or mark data epochs that are extreme stationary violations.
    end
    
    % reshape tempdata for armorf
    Granger.tempdata    = reshape(Granger.tempdata,2,Granger.timewin_points*(params.NTrials./2));
    Granger.tempenvelop = reshape(Granger.tempenvelop,2,Granger.timewin_points*(params.NTrials./2));
    

    for bici=1:size(Granger.bic,2)
        % run model
        temp_2      = [Granger.tempdata(2,:);Granger.tempenvelop(2,:)];
        [Axy,E] = armorf(temp_2          ,params.NTrials./2,Granger.timewin_points,bici);

        % compute Bayes Information Criteria
        Granger.bic(timei,bici) = log(det(E)) + (log(length(Granger.tempdata))*bici*2^2)/length(Granger.tempdata);
    end
end

figure

subplot(121)
plot((1:size(Granger.bic,2))*(1000/params.srate),mean(Granger.bic,1),'--.')
xlabel('Order (converted to ms)')
ylabel('Mean BIC over all time points')

[Granger.bestbicVal,Granger.bestbicIdx]=min(mean(Granger.bic,1));
hold on
plot(Granger.bestbicIdx*(1000/params.srate),Granger.bestbicVal,'mo','markersize',15)

title([ 'Optimal order is ' num2str(Granger.bestbicIdx) ' (' num2str(Granger.bestbicIdx*(1000/params.srate)) ' ms)' ])

subplot(122)
[junk,Granger.bic_per_timepoint] = min(Granger.bic,[],2);
plot(Granger.times2save,Granger.bic_per_timepoint*(1000/params.srate),'--.')
xlabel('Time (ms)')
ylabel('Optimal order (converted to ms)')
title('Optimal order (in ms) at each time point')

%% Define model order

Granger.order   =  30; % in ms

% convert parameters to indices
Granger.order_points   = round(Granger.order/(1000/params.srate));

%% Model for each trial

% initialize
[x2y,y2x] = deal(zeros(1,length(Granger.times2save))); % the function deal assigns inputs to all outputs
    
for ii = 1:numel(data.raw_trials)
    for timei=1:length(Granger.times2save)
        
    % Line 1 = LFP
    Granger.tempdata_trial(1,:) = data.raw_trials{ii}(Granger.times2saveidx(timei)-floor(Granger.timewin_points/2):Granger.times2saveidx(timei)+floor(Granger.timewin_points/2)-mod(Granger.timewin_points+1,2));
    % Line 2 = Sound envelope
    Granger.tempdata_trial(2,:) = data.envelope_trials{ii}(Granger.times2saveidx(timei)-floor(Granger.timewin_points/2):Granger.times2saveidx(timei)+floor(Granger.timewin_points/2)-mod(Granger.timewin_points+1,2));

    % detrend and zscore all data   
    Granger.tempdata_trial(1,:) = zscore(detrend(squeeze(Granger.tempdata_trial(1,:))));
    Granger.tempdata_trial(2,:) = zscore(detrend(squeeze(Granger.tempdata_trial(2,:))));
     
    % At this point with real data, you should check for stationarity
    % and possibly discard or mark data epochs that are extreme stationary violations.
    
    % fit AR models (model estimation from bsmart toolbox)
    
    % i.e = [Ax,Ex] = armorf(data,trials,timewin_points,order_points);
    % Ax = polynomial coefficients A corresponding to the AR model estimate of matrix X using Morf's method
    % Ex = prediction error E (the covariance matrix of the white noise of the AR model).
    
    [Ax,Ex] = armorf(Granger.tempdata_trial(1,:),1,Granger.timewin_points,Granger.order_points);
    [Ay,Ey] = armorf(Granger.tempdata_trial(2,:),1,Granger.timewin_points,Granger.order_points);
    [Axy,E] = armorf(Granger.tempdata_trial     ,1,Granger.timewin_points,Granger.order_points);
    
    % time-domain causal estimate. odd row = 53.71/ even row = 92.77
    % causal estimate reorganized in another variable as well
    y2x(ii,timei)=log(Ex/E(1,1));
    y2x_53 = y2x(1:2:end,:);
    y2x_92 = y2x(2:2:end,:);
    x2y(ii,timei)=log(Ey/E(2,2));
    
    end
end

%% Model for whole session

for timei=1:length(Granger.times2save)
    
    % data from all trials in this time window
    
    % Line 1 = LFP 53.71/ Line 2 = LFP 92.77
    Granger.tempdata = squeeze(data.raw_ALL_trials(:,Granger.times2saveidx(timei)-floor(Granger.timewin_points/2):Granger.times2saveidx(timei)+floor(Granger.timewin_points/2)-mod(Granger.timewin_points+1,2),:));

    % Line 1 = LFP 53.71/ Line 2 = LFP 92.77
    Granger.tempenvelop = squeeze(data.envelope_ALL_trials(:,Granger.times2saveidx(timei)-floor(Granger.timewin_points/2):Granger.times2saveidx(timei)+floor(Granger.timewin_points/2)-mod(Granger.timewin_points+1,2),:));

    % detrend and zscore all data
    for triali=1:size(Granger.tempenvelop,3)
        Granger.tempdata(1,:,triali)    = zscore(detrend(squeeze(Granger.tempdata(1,:,triali))));
        Granger.tempdata(2,:,triali)    = zscore(detrend(squeeze(Granger.tempdata(2,:,triali))));
        Granger.tempenvelop(1,:,triali) = zscore(detrend(squeeze(Granger.tempenvelop(1,:,triali))));
        Granger.tempenvelop(2,:,triali) = zscore(detrend(squeeze(Granger.tempenvelop(2,:,triali))));
        
        % At this point with real data, you should check for stationarity
        % and possibly discard or mark data epochs that are extreme stationary violations.
    end
    
    % reshape tempdata for armorf
    Granger.tempdata    = reshape(Granger.tempdata,2,Granger.timewin_points*(params.NTrials./2));
    Granger.tempenvelop = reshape(Granger.tempenvelop,2,Granger.timewin_points*(params.NTrials./2));

    % fit AR models for 53.71 (model estimation from bsmart toolbox)
    [Ax_1,Ex_1] = armorf(Granger.tempdata(1,:),params.NTrials./2,Granger.timewin_points,Granger.order_points);
    [Ay_1,Ey_1] = armorf(Granger.tempenvelop(1,:),params.NTrials./2,Granger.timewin_points,Granger.order_points);
    temp_1      = [Granger.tempdata(1,:);Granger.tempenvelop(1,:)];
    [Axy_1,E_1] = armorf(temp_1     ,params.NTrials./2,Granger.timewin_points,Granger.order_points);
    
    % fit AR models for 92.77 (model estimation from bsmart toolbox)
    [Ax_2,Ex_2] = armorf(Granger.tempdata(2,:),params.NTrials./2,Granger.timewin_points,Granger.order_points);
    [Ay_2,Ey_2] = armorf(Granger.tempenvelop(2,:),params.NTrials./2,Granger.timewin_points,Granger.order_points);
    temp_2      = [Granger.tempdata(2,:);Granger.tempenvelop(2,:)];
    [Axy_2,E_2] = armorf(temp_2     ,params.NTrials./2,Granger.timewin_points,Granger.order_points);
    
    % time-domain causal estimate for 53.71
    y2x_53_all(timei)=log(Ex_1/E_1(1,1));
    x2y_53_all(timei)=log(Ey_1/E_1(2,2));
    
    % time-domain causal estimate for 92.77
    y2x_92_all(timei)=log(Ex_2/E_2(1,1));
    x2y_92_all(timei)=log(Ey_2/E_2(2,2));
end

%% Plot Predictions

figure(5)
for ii = 1:size(y2x)
    if ii<=3
       subplot(3,3,ii)
       plot(Granger.times2save,y2x_53(ii,:),'Color','[0.6350, 0.0780, 0.1840]','linew',1)
       legend('GP:sound -> LFP')
       title([ 'Window length: ' num2str(Granger.timewin) ' ms, order: ' num2str(Granger.order) ' ms' ])
       xlabel('Time (s)')
       ylabel('Granger prediction estimate')
       xlim ([-10 32])
       ylim ([-0.1 0.6])
    else
       subplot(3,3,ii)
       plot(Granger.times2save,y2x_92(ii-3,:),'r','linew',1)
       legend('GP:sound -> LFP')
       title([ 'Window length: ' num2str(Granger.timewin) ' ms, order: ' num2str(Granger.order) ' ms' ])
       xlabel('Time (s)')
       ylabel('Granger prediction estimate')
       xlim ([-10 32])
       ylim ([-0.1 0.6])
    end
end

subplot(3,3,[7 9])
plot(Granger.times2save,y2x_53_all,'Color','[0.6350, 0.0780, 0.1840]','linew',1)
hold
plot(Granger.times2save,y2x_92_all,'r','linew',1)
legend('GP:sound -> LFP')
title([ 'Window length: ' num2str(Granger.timewin) ' ms, order: ' num2str(Granger.order) ' ms' ])
xlabel('Time (s)')
ylabel('Granger prediction estimate')
