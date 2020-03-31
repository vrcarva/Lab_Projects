%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Program for extracting raw LFP data and downsampling %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% 2014.02.11, HS. Kim / Modified by Cleiton 2018%%

clc; close all;

fn={'CSC13.ncs'}
%fn={'CSC11.ncs'};

for i=1:size(fn(:,1)); % Number of files
    
%%%%%%%%%%%%%%%%%
%%% Load data %%%
%%%%%%%%%%%%%%%%%
cd /Users/Flavio/Documents/Arquivos/Academico/Projetos/PNPD_Neurociencias/Karolinska/Acute12/2013-11-21_18-24-59 %% Put your directory which have recording data.
fn_lfp = fn{i,1}; %% LFP file name from Cheetah
%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%
%%% Extract LFP %%%
%%%%%%%%%%%%%%%%%%%
down_sampling = 32; %% Down sampling parameter
data = read_cheetah_data(fn_lfp, down_sampling); %% Function 'read_cheetah_data'

FS = data.sample_Hz; %% Sampling frequency (Hz)
LFP = data.samples; %% LFP samples
TS = data.tsI;%*1000; %% Time stamp (msec)
BitV=data.bit_volts;
LFP = LFP.*BitV.*1000; % Amplitude in mV

if i==1;
LFP_all=zeros(length(LFP(:,1)),length(fn));

else

end;
%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%
%%% Plotting %%%
%%%%%%%%%%%%%%%%
% subplot(4,4,i);
% plot(TS,LFP);
% % xlabel('time')
% % ylabel('amplitude')
% axis off
% title(num2str(i));
% ylim([-1 1]);
% xlim([TS(1) TS(end)]);
% set(gcf,'color',[1 1 1]);
% %%%%%%%%%%%%%%%%
% 
% 
% S1=num2str(i);
% S2='CS';
% S3=strcat(S2,S1);
% 
% LFP_all(:,i)=detrend(LFP);
% 
% % eval([S3 ' = LFP_all(:,i);']);
% 
% clear LFP CS*

% pause(0.05);
    
end;