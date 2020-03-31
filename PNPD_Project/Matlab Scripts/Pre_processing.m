%% Pre processing
% (First extract the data using the "Extracting raw LFPs and Events" script)

%   - Define sound epochs
%   - Organize channels according to the electrodes map
%   - Estimate the CS modulating signal
%   - Concatenate the modulator signal as channel 1
%   - Organize trial Data

%                               - CHANNELS MAP - 

% CS modulating signal
% .Row 1

% mPFC 
% .Row 2,3 -> pre limbic
% .Row 4,5 -> infra limbic

% Hippocampus
% .Row 6   -> CA1
% .Row 7   -> MOL layer
% .Row 8,9 -> GD

% Amygdala
% .Row 10,11 -> lateral
% .Row 12,13 -> basolateral

% Inferior colliculus
% .Row 14,15,16,17 -> Dorsol -> ventral, respectively

% by Flavio Mourao. Nucleo de Neurociencias - NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais. 
% Started in:  02/2020
% Last update: 03/2020

%% Set the parameters for each epoch

parameters.trialperiod = 30; % trial period in seconds
parameters.Tpre        = 30; % pre trial in seconds
parameters.Tpos        = 10; % pos trial in seconds
parameters.NTrials     =  5; % number of trials

%% Organizing channels according to the channels map

% obs.
% During my experiment I set channels 17 to 32 to record but here I corrected the numbers to 1 to 16

% Channels order - correted channels map
% mPFC -> ch/lines: 1 2 3 4
ch_order1 = [20 18 21 19] - 16;

% Hippocampus -> ch/lines: 5 6 7 8
ch_order2 = [22 17 23 24] - 16; 

% Amygdala -> ch/lines: 9 10 11 12
ch_order3 = [25 26 27 28] - 16;

% Inferior colliculus -> ch/lines: 13 14 15 16
ch_order4 = [29 30 31 32] - 16;

% Rearrange  channels
data.raw        = data.raw(:,[ch_order1 ch_order2 ch_order3 ch_order4]);       % Raw data - All channels  
data.data{1,1}  = data.data{1,1}([ch_order1 ch_order2 ch_order3 ch_order4],:); % Downsampled data - All channels 

% Clear trash
clear ('ch_order1','ch_order2','ch_order3','ch_order4'); 

%% Define sound epochs. Index and time (sec.)

% lines       : trials
% odd columns : trial start
% even columns: trial stop

% data.events.ts_1 --> Video Frames
% Video frames were counted by Bonsai software then I send a sequence of numbers were sent to an Arduino via serial port.
% So,Arduino created packages at every 10 frames and each package sent a digital signal that was recorded by openephys.
data.events.ts_vid = data.events.ts_1; % in seconds 

% data.events.ts_1 --> CS modulating frequency
% Timestamps locked to the peaks and valleys of the CS modulating frequency 
data.events.ts_mod = data.events.ts_2; % in seconds

% Time in seconds
data.events.idx_t(:,1) = data.events.ts_mod(abs(diff([0; data.events.ts_mod]))>1);
data.events.idx_t(:,2) = data.events.ts_mod(abs(diff([data.events.ts_mod; 0]))>1);

% Index
data.events.idx(:,1) = dsearchn(data.timev,data.events.idx_t(:,1));
data.events.idx(:,2) = dsearchn(data.timev,data.events.idx_t(:,2));

clear ('data.events.ts_1','data.events.ts_2')

%% Estimating the CS modulating signal

% The timestamps locked to the peaks and valleys of the CS modulating frequency
% were generated in parallel through one of the Arduino Digital I/O pins and then recorded
% by a digital input port of the Open-ephys. Through linear interpolation, these
% time values were used to obtain an instantaneous phase time series, which in turn were
% used to reconstruct/estimate the CS modulating signal itself. In this sense the time-
% frequency analysis could keep engaged with the stimulus presentation.

% Define index for peaks and valleys (these two lines take time ...)
picosTSidxs = dsearchn(data.timev,data.events.ts_mod(1:2:end));
valesTSidxs = dsearchn(data.timev,data.events.ts_mod(2:2:end));

% Interpolated instantaneous phase time series
phiRec = nan(length(data.timev),1);      % initialize the vector
phiRec(picosTSidxs) = 0;                 % peak phase   = 0
phiRec(valesTSidxs) = pi;                % valley phase = pi

xphi = find(~isnan(phiRec)); % Sample points
yphi = phiRec(xphi);         % Sample values    
qp   = 1:length(phiRec);     % Query points

% 1-D data linear interpolation
yphi = interp1(xphi,yphi,(qp)');

% Extrated values from Euler representation of angles
yrec = real(exp(1i.*yphi));

% Reconstructed signal with modulator
data.mod = zeros(length(data.timev),1);  

for ii = 1:size(data.events.idx,1)
    data.mod(data.events.idx(ii,1):data.events.idx(ii,2),1) = yrec(data.events.idx(ii,1):data.events.idx(ii,2),1);
end

clear ('picosTSidxs', 'valesTSidxs', 'phiRec', 'xphi', 'yphi', 'qp', 'yrec','ii')                                                 

% Concatenate the modulator signal as channel 1 in the decimated data variable
data.data{1,1} = [data.mod';data.data{1, 1}];

%% Organizing Trial Data

% Initializing trial periods
data.data_trials     = cell(parameters.NTrials,length(data.data));

% Cutting time windows...
for ii = 1:size(data.data,2)
    for jj = 1:size(data.events.idx,1)       
         data.data_trials{jj,ii} = data.data{1,ii}(:,data.events.idx(jj,1) - parameters.Tpre * parameters.srate : data.events.idx (jj,2) + parameters.Tpos * parameters.srate);  
    end   
end

% Normalizing total samples with "not a numbers (nan)" in each trial 
% to the exact time period according to the sample rate.

totalsamples  = max(max(cellfun(@length,data.data_trials)));

for ii = 1:size(data.data_trials,2)
    for jj = 1:size(data.data_trials,1)        
        if length(data.data_trials{jj,ii}) < totalsamples
           data.data_trials{jj,ii}(:,end:totalsamples) = nan;
        else
           continue
        end
    end
end

clear ('totalsamples')

% Concatenate trials in 3 dimentions

for ii = 1:size(data.data,2)
    data.data_trials{1,ii} = cat(3,data.data_trials{:,ii});
end

data.data_trials(2:end,:) = [];

% Setting Time

% Initializing time trial vectors
data.time_trials = linspace(-parameters.Tpre,parameters.trialperiod+parameters.Tpos,length(data.data_trials{1,1}));


clear ('totalsamples','ii', 'jj')

%% last update 30/03/2020 - 20:48am
%  listening: Set Fire To Flames - Fading Lights Are Fading
