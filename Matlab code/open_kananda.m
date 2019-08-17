clc
clear all

% Load record
WAR02_INSTRUCTIONS

% Raw Data
% Row 1: sound envelope / Row 2: LFP
%%
% Decimate fator
params.df = 20;
Canais = Canais(:,1:params.df:end);
data.raw = Canais;

% Parameters
params.CH_param = CH_param;

% sample rate
params.srate  = (params.CH_param(1).Famos)/params.df; 

% specify nyquist frequency
params.nyquistS = params.srate/2;

clear ('Canais','CH_param');
