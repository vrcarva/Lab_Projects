%% Correlation and Covariance Matrices betwwen channels

% by Flavio Mourao. Nucleo de Neurociencias - NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais.
% Started in:  07/2019
% Last update: 04/2020

%%

% Choose filter band
ff = 1;

% Choose channels
ch = 1:16;

% Correlation

figure (1)

% Pre sound period

for ii = 1:size(data.events.idx,1)
    all_channels_pre = (data.data{1, ff}(ch,data.events.idx(ii,1) - parameters.Tpre * parameters.srate : data.events.idx(ii,1)-1)');

    % Spearman Correlation
    [correlation.cormat_pre,correlation.PVAL_pre] = corr(all_channels_pre,all_channels_pre,'Type','s');

    subplot (2,5,ii)
    imagesc(correlation.cormat_pre);
    xlabel ('channels')
    ylabel ('channels')
    %suptitle(['Spearman Correlation'])
    title(['Trial: ',num2str(ii)])
    colorbar
    caxis([-.5 1])
end


% Sound period

for ii = 1:size(data.events.idx,1)
    all_channels_sound = (data.data{1, ff}(ch,data.events.idx(ii,1) : data.events.idx(ii,2))');

    % Spearman Correlation
    [correlation.cormat_sound,correlation.PVAL_sound] = corr(all_channels_sound,all_channels_sound,'Type','s');

    subplot (2,5,ii+5)
    imagesc(correlation.cormat_sound);
    xlabel ('channels')
    ylabel ('channels')
    title(['Trial: ',num2str(ii)])
    colorbar
    caxis([-.5 1])
end

%% Covariance

figure (2)

% Pre sound period

for ii = 1:size(data.events.idx,1)
    all_channels_pre = (data.data{1, ff}(ch,data.events.idx(ii,1) - parameters.Tpre * parameters.srate : data.events.idx(ii,1))');

    %Covariance
    covariance.covmat_pre = cov(all_channels_pre);

    subplot (2,5,ii)
    imagesc(covariance.covmat_pre);
    xlabel ('channels')
    ylabel ('channels')
    title(['Covariance Pre sound - Trial: ',num2str(ii)])
    colorbar
    caxis([0 20000])
end

% Sound period

for ii = 1:size(data.events.idx,1)
    all_channels_sound = (data.data{1, ff}(ch,data.events.idx(ii,1):data.events.idx(ii,2))');

    %Covariance
    covariance.covmat_sound = cov(all_channels_sound);

    subplot (2,5,ii+5)
    imagesc(covariance.covmat_sound);
    xlabel ('channels')
    ylabel ('channels')
    title(['Covariance Sound - Trial: ',num2str(ii)])
    colorbar
    caxis([0 20000])
end

%% Exclude bad channels

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

%% Power Spearman's correlation over channels - Pre sound and Sound

% Choose channels
ch = 2:17;

%Define frequencies to plot in each subplot
steps = diff(short_fft.freq); % according to the fft time window

short_fft.freq2plot = 52.71:steps(1):54.71;
closestfreq = dsearchn(short_fft.freq,short_fft.freq2plot');

% Correlation

figure (1)

% Pre sound period

for ii = 1:size(data.events.idx,1)
    all_channels_pre = squeeze(mean(abs(short_fft.data_trials_pre(closestfreq,:,ch,ii)),2));

    % Spearman Correlation
    [correlation.cormat_pre,correlation.PVAL_pre] = corr(all_channels_pre,all_channels_pre,'Type','s');

    subplot (2,5,ii)
    imagesc(correlation.cormat_pre);
    xlabel ('channels')
    ylabel ('channels')
    %suptitle(['Spearman Correlation'])
    title(['Trial: ',num2str(ii)])
    colorbar
    caxis([-.5 1])
end


% Sound period

for ii = 1:size(data.events.idx,1)
    all_channels_sound = squeeze(mean(abs(short_fft.data_trials_sound(closestfreq,:,ch,ii)),2));

    % Spearman Correlation
    [correlation.cormat_sound,correlation.PVAL_sound] = corr(all_channels_sound,all_channels_sound,'Type','s');

    subplot (2,5,ii+5)
    imagesc(correlation.cormat_sound);
    xlabel ('channels')
    ylabel ('channels')
    title(['Trial: ',num2str(ii)])
    colorbar
    caxis([-.5 1])
end

%% Power Spearman's correlation over channels - change from baseline

% Choose channel
ch = 2:17;

%Define frequencies to plot in each subplot
steps = diff(short_fft.freq); % according to the fft time window

short_fft.freq2plot = 51.71:steps(1):55.71;
closestfreq = dsearchn(short_fft.freq,short_fft.freq2plot');

%Define time to plot in each subplot
time2plot1 = [ short_fft.time_idx(:,1),short_fft.time_idx(:,2) ]; % pre sound
time2plot2 = [ short_fft.time_idx(:,2),short_fft.time_idx(:,3) ]; % sound period

% Correlation

figure (1)

% Pre sound period

for ii = 1:size(data.events.idx,1)
    all_channels = squeeze(mean(abs(short_fft.data(closestfreq,time2plot2(ii,1):time2plot2(ii,2),ch))./ mean(abs(short_fft.data(closestfreq,time2plot1(ii,1):time2plot1(ii,2)-1,ch)),2),2));

    % Spearman Correlation
    [correlation.cormat,correlation.PVAL] = corr(all_channels,all_channels,'Type','s');

    subplot (1,5,ii)
    imagesc(correlation.cormat);
    xlabel ('channels')
    ylabel ('channels')
    %suptitle(['Spearman Correlation'])
    title(['Trial: ',num2str(ii)])
    colorbar
    caxis([-.5 1])
end

%% last update 01/04/2020 - 21:59
%  listening: Mogwai - D to E