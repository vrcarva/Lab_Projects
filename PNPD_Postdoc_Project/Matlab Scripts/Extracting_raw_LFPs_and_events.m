%% Extracting raw LFPs and Events from Open Ephys

% Load channels and events

% Down sampling data:
% Cell Variable "data.data" -> Columns: frequency bands.
%                              First cell column is the decimated raw signal.
%                               - Rows: Channels x Columns: Time

% by Flavio Mourao. Nucleo de Neurociencias - NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais. 
% Started in:  11/2019
% Last update: 03/2020

%%
% Load files (*.continuous -> LFP and *.events -> Events)
[FilesLoaded,data.Path] = uigetfile({'*.continuous; *.events'},'MultiSelect', 'on'); % Define file type *.*

% Define a struct with files informations from dir organization'
% Beware ! This organization changes according to the operating system.
data.FilesLoaded = repmat(struct('name',[],'folder',[],'date',[],'bytes',[],'isdir',[],'datenum',[]), 1, length(FilesLoaded));

% Filename can be organize as a single char or a group char in a cell depending on the number os files selected
if ischar(FilesLoaded)
   data.FilesLoaded = dir(fullfile(data.Path, FilesLoaded)); % condition for a single file selected       
else    
   for ii = 1:length(FilesLoaded) % loop over multiple files selected
       data.FilesLoaded(ii) = dir(fullfile(data.Path, char(FilesLoaded(ii))));
   end 
end  

% Optional - Uncomment the line below for sort data. Channels based on a specific file properties. 
% data.Channels = nestedSortStruct(data.FilesLoaded,'name',1); % Perform a nested sort of a struct array based on multiple fields. 
                                                                 % >>> https://uk.mathworks.com/matlabcentral/fileexchange/28573-nested-sort-of-structure-arrays?focused=5166120&tab=function

%% Choose factor to LFP down sampling and number of channels recorded
% - Manually - 
% parameters.down_sampling = 6; 
% parameters.nch = 16;

% - Request from user -
prompt        = {'Decimation Factor:','Number of channels recorded:'};
dlgtitle      = 'Please enter';
dims          = [1 30];
default_input = {'6', '16'};

input = inputdlg(prompt,dlgtitle,dims,default_input); %gui

parameters.down_sampling = str2double(input{1,1});
parameters.nch = str2double(input{2,1});

clear ('prompt','dlgtitle','dims','default_input','input')

%% Loop to extract data
% Required function: load_open_ephys_data.m
% https://github.com/open-ephys/analysis-tools

for jj = 1:length(data.FilesLoaded)
    baseFileName = data.FilesLoaded(jj).name;
    fullFileName = fullfile(data.Path,baseFileName);
    
    %Identify the file extension
    [~, ~, fExt] = fileparts(baseFileName);
    
    
    switch lower(fExt)
                
        % Case for load channels
        
        case '.continuous'
    
        % Identify the channel number and print the name on the Command Window:
        % channels   1 to 16 and/or 17 to 32

        channel = split(baseFileName,{'100_CH','.continuous'});
        fprintf(1, '\nExtracting LFP from Channel %s\n', channel{2, 1}); 
        
        
        if      jj == 1 
                % Load datafiles (*.continuous), timestamps e record info.
                % Raw data - Rows: Time  x Columns: Channels
                % Remove linear trend (Matlab build function 'detrend'/ Method: 'constant' - subtract the mean from the data)
                [data_temp, data.timev_raw, info] = load_open_ephys_data(fullFileName);
                data.raw = detrend(data_temp, 'constant');  % Raw data           
                parameters.header = info.header;            % Data File Header
                 
                % parameters.down_sampling with decimate function
                % data - Rows: Channels x Columns: Time
                data(1,1).data{1,1}  = zeros(parameters.nch, ceil(length(data.raw)/parameters.down_sampling));
                data.data{1,1}(jj,:) = decimate(data.raw,parameters.down_sampling); % parameters.down_sampling with Matlab decimate function
                                           
                % Organize parameters according to the downsampling information
                parameters.srate  = info.header.sampleRate./parameters.down_sampling;  % Sampling frequency after downsamplig(Hz)
                parameters.header.downsampling = parameters.down_sampling; 
                
                % Normalizing time vector - down sampling data
                data.timev  = (data.timev_raw(1:parameters.down_sampling:end)) - min(data.timev_raw);  % Time stamp (sec)
          
        else 
            
                % Load datafiles (*.continuous).
                % Rows: Channels x Columns: Time
                % Remove linear trend (function 'detrend')
                data.raw(:,jj)  = detrend(load_open_ephys_data(fullFileName),'constant'); % Raw data
                data.data{1,1}(jj,:) = decimate(data.raw(:,jj),parameters.down_sampling);            % parameters.down_sampling with Matlab decimate function
      
        end
        
        % Case for load events
         
        case '.events'
                
        % Identify TTL events file and print the name on the Command Window:   
        fprintf(1, '\nExtracting %s\n', 'all_channels.events'); 
        
        % Load datafiles (*.continuous), timestamps e record info.
        [data.events.labels, data.events.ts, parameters.events.info] = load_open_ephys_data(fullFileName);
        
    end
end                                                   

clear ('baseFileName','channel','parameters.down_sampling','fExt','FilesLoaded','fullFileName','ii','data_temp','info','jj');                                                     

fprintf('\n Done. \n');

%% Sort Events

% Trigger/label 1
label1 = 0;

% Trigger/label 2 
label2 = 1;

% Sort timestamps
% Label 1
data.events.ts_1 = data.events.ts(data.events.labels(:,1)==label1);

% Label 2
data.events.ts_2 = data.events.ts(data.events.labels(:,1)==label2);

clear ('label1', 'label2')

%% Save data (-v7.3 flag to store variables > 2GB with compression)

% save('M','data','-v7.3')

%% last update 30/03/2020 - 20:50am
%  listening: Set Fire To Flames - Fading Lights Are Fading
