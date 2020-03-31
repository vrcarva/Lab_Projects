%% Correlation and Covariance Matrices betwwen channels

% by Flavio Mourao. Nucleo de Neurociencias - NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais.
% Started in:  07/2019
% Last update: 03/2020

%%

% Choose filter band
ff = 3;

% Choose channels
ch = 2:17;

% Correlation

figure (1)

% Pre sound period

for ii = 1:size(data.events.idx,1)
    all_channels_pre = (data.data{1, ff}(ch,data.events.idx(ii,1) - parameters.Tpre * parameters.srate : data.events.idx(ii,1))');

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

%% last update 30/03/2020 - 21:01
%  listening: Mogwai - Every Country`s Sun