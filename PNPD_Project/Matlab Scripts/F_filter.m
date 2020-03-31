%% Filter Data
% filtering by hand (especially the modulated envelope) and/or
% by the Johnzinho's function (based on EEG_lab): 'fun_myparameters.filters.m' 


% by Flavio Mourao. Nucleo de Neurociencias - NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais. 
% Started in:  07/2019
% Last update: 03/2020

%% parameters.filter modulated envelope (parameters defined by hand)
%  Building the parameters.filter by hand avoided deformations to 53.71 modulated frequency. 
%  Furthermore, it guarantees smooth edges in the CS modulating transitions.

% Obs. this parameters.filter will only be used for comparisons within the band of 51.71Hz - 55.71Hz

% Specify nyquist frequency
parameters.nyquistS = parameters.srate/2;

% parameters.filter frequency band
parameters.filter.filtbound(1,:) = [51.71 55.71]; % Hz

% transition width
parameters.filter.trans_width(1,:) = 0.20; % fraction of 1, thus 20%

% parameters.filter order
parameters.filter.filt_order(1,:) = round(3*(parameters.srate/parameters.filter.filtbound(1,1)));

% frequency vector (as fraction of nyquist)
parameters.filter.ffrequencies(1,:)  = [ 0 (1-parameters.filter.trans_width(1,:))*parameters.filter.filtbound(1,1) parameters.filter.filtbound(1,:) (1+parameters.filter.trans_width(1,:))*parameters.filter.filtbound(1,2) parameters.nyquistS ]/parameters.nyquistS;

% shape of parameters.filter (must be the same number of elements as frequency vector
parameters.filter.idealresponse = [ 0 0 1 1 0 0 ];

% get parameters.filter weights
parameters.filter.parameters.filterweights = cell(size(parameters.filter.filtbound,1),1);
parameters.filter.parameters.filterweights{1} = firls(parameters.filter.filt_order(1,:),parameters.filter.ffrequencies(1,:),parameters.filter.idealresponse);

%% Plot parameters.filter parameters for visual inspection

figure, clf
set(gcf,'color','white')

subplot(1,2,1)
plot(parameters.filter.ffrequencies(1,:)*parameters.nyquistS,parameters.filter.idealresponse,'k--o','markerface','[0.6350, 0.0780, 0.1840]')
set(gca,'ylim',[-.1 1.1],'xlim',[-2 parameters.nyquistS+2])
xlabel('Frequencies (Hz)'), ylabel('Response amplitude')
legend({['Bandcuts',' ',num2str(parameters.filter.filtbound(1,1)),'-',num2str(parameters.filter.filtbound(1,2))]},'Location','northeast')
legend('boxoff')

subplot(1,2,2)
plot((0:parameters.filter.filt_order(1,:))*(1000/parameters.srate),parameters.filter.parameters.filterweights{1},'Color','[0.6350, 0.0780, 0.1840]','linew',2)
xlabel('Time (ms)'), ylabel('Amplitude')
legend({['parameters.filter Weights',' ',num2str(parameters.filter.filtbound(1,1)),'-',num2str(parameters.filter.filtbound(1,2))]},'Location','northeast')
legend('boxoff')

%% Apply parameters.filter to the data

for jj = 2:size(data.data{1,1},1)
    data.data{1,2}(jj,:) = filtfilt(parameters.filter.parameters.filterweights{1},1,double(data.data{1,1}(jj,:)));
end

clear('jj')

%% parameters.filter bands

parameters.parameters.filter.deltacutoff     = [1 3];         % 3
parameters.parameters.filter.thetacutoff     = [4 12];        % 4
parameters.parameters.filter.alphacutoff     = [13 15];       % 5
parameters.parameters.filter.betacutoff      = [16 31];       % 6
parameters.parameters.filter.lowgammacutoff  = [30 58];       % 7
parameters.parameters.filter.highgammacutoff = [62 100];      % 8
parameters.parameters.filter.extracutoff1    = [150 200];     % 9
parameters.parameters.filter.extracutoff2    = [1 100];       % 10
parameters.parameters.filter.extracutoff3    = [300 3000];    % 11
parameters.parameters.filter.modulator       = [51.71 55.71]; % 12

% each cell --> columns: parameters.filters according to the above order 

for jj = 1:size(data.data{1,1},1)

    data.data{1,3}(jj,:)  = fun_myparameters.filters(data.data{1,1}(jj,:),parameters.srate,parameters.parameters.filter.deltacutoff,'iir','1');
    data.data{1,4}(jj,:)  = fun_myparameters.filters(data.data{1,1}(jj,:),parameters.srate,parameters.parameters.filter.thetacutoff,'iir','1');
    data.data{1,5}(jj,:)  = fun_myparameters.filters(data.data{1,1}(jj,:),parameters.srate,parameters.parameters.filter.alphacutoff,'iir','1');
    data.data{1,6}(jj,:)  = fun_myparameters.filters(data.data{1,1}(jj,:),parameters.srate,parameters.parameters.filter.betacutoff,'iir','1');
    data.data{1,7}(jj,:)  = fun_myparameters.filters(data.data{1,1}(jj,:),parameters.srate,parameters.parameters.filter.lowgammacutoff,'iir','1');
    data.data{1,8}(jj,:)  = fun_myparameters.filters(data.data{1,1}(jj,:),parameters.srate,parameters.parameters.filter.highgammacutoff,'iir','1');
    data.data{1,9}(jj,:)  = fun_myparameters.filters(data.data{1,1}(jj,:),parameters.srate,parameters.parameters.filter.extracutoff1,'iir','1');
    data.data{1,10}(jj,:) = fun_myparameters.filters(data.data{1,1}(jj,:),parameters.srate,parameters.parameters.filter.extracutoff2,'iir','1');
    data.data{1,11}(jj,:) = fun_myparameters.filters(data.data{1,1}(jj,:),parameters.srate,parameters.parameters.filter.extracutoff3,'iir','1');   
    data.data{1,12}(jj,:) = fun_myparameters.filters(data.data{1,1}(jj,:),parameters.srate,parameters.parameters.filter.modulator,'iir','1');   

end

clear('jj')

%% last update 30/03/2020 - 21:22
%  listening: Grouper - Heavy Water/I'd Rather Be Sleeping
