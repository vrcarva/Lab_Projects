clear all
clc

%% Extracting raw LFPs and Events from Neuralynx. Wrote to Cleiton`s Project


% By Flavio Mourao. Nucleo de Neurociencias NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais 01/2019

%% Run each session sequentially

%%
% Load files (*.ncs -> LFP and *.nev -> Events)
[FilesLoaded,Acute.Path] = uigetfile({'*.ncs; *.nev'},'MultiSelect', 'on'); % Define file type *.*

% Define a struct with files informations from dir organization'
Acute.FilesLoaded = repmat(struct('name',[],'date',[],'bytes',[],'isdir',[],'datenum',[]), 1, length(FilesLoaded));

% Filename can be organize as a single char or a group char in a cell depending on the number os files selected
if ischar(FilesLoaded)
   Acute.FilesLoaded = dir(fullfile(Acute.Path, FilesLoaded)); % condition for a single file selected       
else    
   for ii = 1:length(FilesLoaded) % loop over multiple files selected
       Acute.FilesLoaded(ii) = dir(fullfile(Acute.Path, char(FilesLoaded(ii))));
   end 
end 

% Optional - Uncomment the line below for sort Acute.Channels based on a specific file properties. 
% Acute.Channels = nestedSortStruct(Acute.FilesLoaded,'name',1); % Perform a nested sort of a struct array based on multiple fields. 
                                                                 % >>> https://uk.mathworks.com/matlabcentral/fileexchange/28573-nested-sort-of-structure-arrays?focused=5166120&tab=function

% Down sampling factor accordingly to the main Function: 'read_cheetah_fata.m' (Neuralynx)

%           Down-sample factor     Sample Hz (approx.)
%                   1                  30303
%                   2                  15152
%                   4                   7576
%                   8                   3788
%                   16                  1894
%                   32                   947
%                   64                   473


% Choose factor to LFP down sampling
down_sampling = 32; 

% Loop to extract data

for jj = 1:length(Acute.FilesLoaded)
    baseFileName = Acute.FilesLoaded(jj).name;
    fullFileName = fullfile(Acute.Path,baseFileName);
    
    %Identify the file extension
    [~, ~, fExt] = fileparts(baseFileName);
    
    
    switch lower(fExt)
                
        % Case for load channels
        
        case '.ncs'
    
        % Identify the channel number and print the name on the Command Window:
        % channels   1 to 32 --> Prefrontal Cortex
        % channels  33 to 64 --> V1    
        channel = str2double(strtok(baseFileName,'CSC.ncs')); 
        fprintf(1, '\nExtracting LFP from Channel %s\n', num2str(channel)); 
    
        % Load datafiles (*.ncs).
        % Columns: Channels x Rows: Time
        data = read_cheetah_data(fullFileName,down_sampling);
     
        if       jj == 1 ;
             
                % Record Parameters
                Acute.header = data.header;    % Neuralynx Data File Header
                Acute.srate = data.sample_Hz;  % Sampling frequency (Hz)
                Acute.ts = data.tsI;           % *1000; Time stamp (msec)
                
                % Number of channels per substrate
                Acute.nch = 32;
                
                % Initialize LPF variables
                Acute.LFP_PFC.All = zeros(length(FilesLoaded),length(data.samples));
                Acute.LFP_V1.All  = zeros(length(FilesLoaded),length(data.samples));
        end
    
        % Sort channels   
        if      channel <= Acute.nch;
                Acute.LFP_PFC.All(jj,:) = data.samples.*data.bit_volts.*1000;  % LFP data - Amplitude in mV

        elseif  channel > Acute.nch;
                Acute.LFP_V1.All(jj,:) = data.samples.*data.bit_volts.*1000;  % LFP data - Amplitude in mV
         
        else
                fprintf('\nSomething Wrong.\n');
        end
        
        
        % Case for load events
         
        case '.nev'
                
        % Identify TTL events file and print the name on the Command Window:   
        fprintf(1, '\nExtracting %s\n', 'Events.nev'); 
        
        % Load events file (*.nev).
        
        % --> 2 options to load: 
        
        % 1) 'read_cheetah_data': output with the same time scale magnitude for events 
        %     but for some reason, for some animals, the events appear distributed asymmetrically over time       
        %     compared to the record timestamps.
        % 2) 'getRawTTLs': for some reason the output appear with the events magnitude 
        %     10^6 times greater compared to the record timestamps magnitude but the events appear 
        %     distributed symmetrically over time compared to the record timestamps.
        
        % Acute.events = read_cheetah_data('/Users/Flavio/Documents/Arquivos/Academico/Projetos/PNPD_Neurociencias/Karolinska/Acute12/2013-11-21_18-24-59/Events.nev');
        Acute.events.ts = getRawTTLs(fullFileName);
        
        % Find 'Light On' events throughout the events timesamples.
        % In Neuralynx each event is signaled by the digit '2'       
        % Acute.events.TTLTime_idx(:,1) = Acute.events.ts(Acute.events.TTLval==2);
        Acute.events.TTLTime_idx = Acute.events.ts(Acute.events.ts(:,2)==2)./1000000;

        % Find 'Light On' indexes throughout the data.
        % To avoid floating point issues the accuracy of the numbers was
        % set to three. So, three decimals remain and more decimals are set to 0.
        ts = round(Acute.ts * 1000)/1000; 
        tsTTLTime = round(Acute.events.TTLTime_idx * 1000)/1000;
        
        % Return indexes where events are in the data
        [~,Acute.events.TTLTime_idx(:,2)] = ismember(tsTTLTime,ts);

        
        otherwise
        % Identify events throughout the record
        error('Unexpected file extension: %s', fExt);
        
    end
end                                                   


% After channels sorting delete blank (zeros) rows 
Acute.LFP_PFC.All(~any(Acute.LFP_PFC.All,2),:) = [];
Acute.LFP_V1.All(~any(Acute.LFP_V1.All,2),:) = [];

% Clear Variable Field if no channel was selected
if     isempty(Acute.LFP_PFC.All);
       Acute = rmfield(Acute,'LFP_PFC');
elseif isempty(Acute.LFP_V1.All);
       Acute = rmfield(Acute,'LFP_V1');
end


% Clear trash
clear ('FilesLoaded','baseFileName','fullFileName','channel','jj','ii','data','down_sampling','fExt','ts','tsTTLTime' );                                                     

fprintf('\n Done. \n');

%% Define sessions periods

% Find the indexes according to the timestamps
idx = diff(Acute.ts);

% Plot to check sessions periods
figure
yyaxis left
plot(Acute.ts',Acute.LFP_PFC.All(3,:),'Color',[0.8, 0.8, 0.8]);
ylim ([-max(Acute.LFP_PFC.All(3,:)) max(Acute.LFP_PFC.All(3,:))]);
yyaxis right
plot(Acute.ts',[1 (abs(diff(idx'))) 1],'Color','r', 'LineWidth', 1);
ylim ([-max(idx) max(idx)]);

%%
% According to the figure above define the threshold value to set the sessions periods 
% Threshold: minimum time between different sessions (values on the right y-axis)
% BEWARE of very small periods. Possibly small packet losses that generated TTL values

thresh = 25;

% Find the indexes according to the timestamps 
idx = ((diff(Acute.ts))>thresh)'; % Differences between adjacent elements considering only the values above the threshold

% Session beginnings and ends separately
% Normalizes the vector length  with '1' to identify the begin and end
% Time periods and Indexes - First column: Time Periods / Second column: Index values
Acute.idx_start(:,1) = Acute.ts(logical([1 idx])); % Find time periods with logical indexing.
Acute.idx_start(:,2) = find([1 idx]);              % Find indexes
Acute.idx_end  (:,1) = Acute.ts(logical([idx 1])); % Find time periods with logical indexing.
Acute.idx_end  (:,2) = find([idx 1]);              % Find indexes

% Clear trash
clear ('idx','thresh','input')

%% Plot to check events and sessions marks 

% choose substrate (LFP_PFC or LFP_V1) and choose one channel
sub = 'LFP_PFC';
channel = 3;

% Set Figure
figure
set(gcf,'color','white')
box 'off'
hold on

% Select fields with data
sub = getfield(Acute,sub,'All'); 

% Data
plot(Acute.ts,sub(channel,:),'Color',[0.8, 0.8, 0.8]);
ylim ([-max(sub(channel,:)) max(sub(channel,:))]);

% Light
plot(Acute.events.TTLTime_idx(:,1),zeros(length(Acute.events.TTLTime_idx),1),'Color',[0, 0.7000, 0.9000],'Marker','o','LineStyle','none');
% Session Start
plot(Acute.idx_start(:,1),zeros(length(Acute.idx_start),1),'r*');
% Session end
plot(Acute.idx_end(:,1),zeros(length(Acute.idx_start),1),'k*');
% Scale Bar
plot([Acute.ts(end-1800000) Acute.ts(end)],[-0.3 -0.3], 'k', 'linew',1);
text(Acute.ts(end),-0.35, ' 30 min', 'HorizontalAlignment','right')

% Set Axis
a = gca;
a.XColor = 'w';
a.YTickLabel = a.YTick*1000;
ylabel('\muV')

% Legend
lh = legend('raw data','Light','Session Start','Session End','location','best');
legend('boxoff')

% This lines below just organize conveniently the legend
% 'PlotChildren' property to manipulate the order of the legend entries without requiring a new legend call
neworder = [1, 3, 4, 2];
lh.PlotChildren = lh.PlotChildren(neworder);

% Clear trash
clear ('sub','channel','a','lh','neworder');

%% Cutting entire sessions and defining Time vectors and Light ON events/indexes

% CELL ORGANIZATION
% - First  cell column: Entire Sessions - rows = channels / columns = time
% - Second cell column: Entire Time vector for each session
% - Third  cell column: Time events and Indexes for entire light ON periods  - First row: Time events / Second row: Index values
% - Fourth cell column: Time events and Indexes for light ON beginnings and ends marks (odd columns - Start Light ON period/ even columns - end Light ON period)
%                                                                                                   - First row: Time events / Second row: Index values

Acute.LFP_PFC.All_sessions  = cell(length(Acute.idx_start),4);
Acute.LFP_V1.All_sessions   = cell(length(Acute.idx_start),4);

% Sessions
for ii = 1:Acute.nch
    for jj = 1:size(Acute.idx_start,1)
        Acute.LFP_PFC.All_sessions{jj,1}(ii,:) = Acute.LFP_PFC.All(ii,Acute.idx_start(jj,2):Acute.idx_end(jj,2));
        Acute.LFP_V1.All_sessions{jj,1}(ii,:)  = Acute.LFP_V1.All(ii,Acute.idx_start(jj,2):Acute.idx_end(jj,2));   
    end   
end 

% Time Vectors and Light events
for ll = 1:size(Acute.idx_start,1)
    
    % Time Vector
    Acute.LFP_PFC.All_sessions{ll,2} = Acute.ts(Acute.idx_start(ll,2):Acute.idx_end(ll,2))';
    Acute.LFP_V1.All_sessions{ll,2}  = Acute.ts(Acute.idx_start(ll,2):Acute.idx_end(ll,2))';

    % All Light events - Time and Indexes
    idx = Acute.events.TTLTime_idx(:,2) >= Acute.idx_start(ll,2) & Acute.events.TTLTime_idx(:,2) <= Acute.idx_end(ll,2);
    Acute.LFP_PFC.All_sessions{ll,3} = Acute.events.TTLTime_idx(idx,:)';
    Acute.LFP_V1.All_sessions{ll,3}  = Acute.events.TTLTime_idx(idx,:)';
    
    % Light events - Time and Indexes / Beginnings and Ends
    idx1 = logical([ 1 abs(diff(diff(Acute.LFP_PFC.All_sessions{ll, 3}(2,:))))>1 1 ]);
    Acute.LFP_PFC.All_sessions{ll,4} = Acute.LFP_PFC.All_sessions{ll, 3}(:,idx1);
    Acute.LFP_V1.All_sessions{ll,4}  = Acute.LFP_V1.All_sessions{ll, 3}(:,idx1);

end

% Normalize time vectors and indexes
for tt = 1:size(Acute.idx_start,1)
    
    % Time events
    dif_time_PFC  = Acute.LFP_PFC.All_sessions{tt,2}(1,1);
    dif_time_V1   = Acute.LFP_V1.All_sessions{tt,2}(1,1);
        
    Acute.LFP_PFC.All_sessions{tt,2}      = Acute.LFP_PFC.All_sessions{tt,2} - dif_time_PFC;
    Acute.LFP_PFC.All_sessions{tt,3}(1,:) = Acute.LFP_PFC.All_sessions{tt,3}(1,:) - dif_time_PFC;
    Acute.LFP_PFC.All_sessions{tt,4}(1,:) = Acute.LFP_PFC.All_sessions{tt,4}(1,:) - dif_time_PFC;

    Acute.LFP_V1.All_sessions{tt,2}       = Acute.LFP_V1.All_sessions{tt,2} - dif_time_V1;
    Acute.LFP_V1.All_sessions{tt,3}(1,:)  = Acute.LFP_V1.All_sessions{tt,3}(1,:) - dif_time_V1;
    Acute.LFP_V1.All_sessions{tt,4}(1,:)  = Acute.LFP_V1.All_sessions{tt,4}(1,:) - dif_time_V1;

    if ll == 1;
        continue
    
    % Indexes
    else
       dif_lenth_PFC = sum(cellfun(@length, Acute.LFP_PFC.All_sessions(1:tt-1,2))); 
       dif_lenth_V1  = sum(cellfun(@length, Acute.LFP_V1.All_sessions(1:tt-1,2)));
       
       Acute.LFP_PFC.All_sessions{tt,3}(2,:) = Acute.LFP_PFC.All_sessions{tt,3}(2,:) - dif_lenth_PFC;
       Acute.LFP_PFC.All_sessions{tt,4}(2,:) = Acute.LFP_PFC.All_sessions{tt,4}(2,:) - dif_lenth_PFC;

       Acute.LFP_V1.All_sessions{tt,3}(2,:) = Acute.LFP_V1.All_sessions{tt,3}(2,:) - dif_lenth_V1;
       Acute.LFP_V1.All_sessions{tt,4}(2,:) = Acute.LFP_V1.All_sessions{tt,4}(2,:) - dif_lenth_V1;

    end
end

% Clear trash   
clear ('ii','jj','ll','idx','idx1','dif_lenth_PFC','dif_lenth_V1','dif_time_PFC','dif_time_V1','tt');

%% Plot to check marks on individual Channels

% choose substrate (LFP_PFC or LFP_V1), channel and session
sub = 'LFP_PFC';
channel = 3;
session = 1;

% Set Figure
figure
set(gcf,'color','white')
box 'off'
hold on

% Select field with data
sub = getfield(Acute,sub,'All_sessions'); 

% Data
plot(sub{session,2}(1,:),sub{session,1}(channel,:),'Color',[0.8, 0.8, 0.8]);

% Light period
plot(sub{session,3}(1,:), zeros(size(sub{session,3}(1,:),1)),'Color',[0, 0.7000, 0.9000],'Marker','o','LineStyle','none');

% Light period - Beginnings and Ends
plot(sub{session,4}(1,:), 0,'Color','r','Marker','o','LineStyle','none');

% Clear trash
clear ('channel','session','sub');

%% Plot to check all channels

% choose substrate (LFP_PFC or LFP_V1), channels and session
sub = 'LFP_PFC';
channels = Acute.nch;
session = 1;

% Set Figure
figure
set(gcf,'color','white')
box 'off'
hold on
str = ['LFP ', sub(5:end), ' - ',num2str(channels),' channels - ','Session ',num2str(session)];
title(str,'position',[1100 51])

% Select fields with data
sub = getfield(Acute,sub,'All_sessions'); 

r = plot(sub{session,2}(1,:), bsxfun(@plus, sub{session,1}(1:channels,:), (1:channels)'*1.5),'Color',[0.7, 0.7, 0.7]);
a = gca; % Get axis

% Set the transparency of lines for the Light events
% In newer versions of MATLAB you can do that easily using the Color property of the line.
% By default it is RGB array (1 x 3). Yet if you set it to RGBA (1 x 4) the last value is the alpha of the color.

I = plot([sub{session,3}(1,:);sub{session,3}(1,:)], [zeros(1,size(sub{session,3}(1,:),2));a.YLim(2)*(ones(1,size(sub{session,3}(1,:),2)))],'Color',[0, 0.7000, 0.9000, 0.3000]);

% Set Axis
a.YColor = 'w';
a.YTick = [];
a.XLim = [0 max(sub{session,2}(1,:))];
xlabel('Time (s)')

% Legend
lh = legend([r(1),I(1)],{'raw data','Light ON'});
lh_pos = get(lh,'position');
set(lh, 'position',[0.74 0.92 lh_pos(3:4)])

legend('boxoff')

% Clear trash
clear ('channels','session','str','sub','r','a','I','lh','lh_pos');

%% Cutting entire Light ON and Light OFF periods separately

% CELL ORGANIZATION
% Cell lines: sessions
% - odd cell columns : Light OFF periods - rows = channels / columns = time
% - even cell columns: Light ON  periods - rows = channels / columns = time

Acute.LFP_PFC.Sessions_LightON_OFF  = cell(length(Acute.idx_start),1);
Acute.LFP_V1.Sessions_LightON_OFF   = cell(length(Acute.idx_start),1);

for jj = 1:size(Acute.idx_start,1)
    for ll = 1:size(Acute.LFP_PFC.All_sessions{jj,4},2)
    
    % First Light OFF period (baseline) 
    if     ll == 1;
           Acute.LFP_PFC.Sessions_LightON_OFF{jj,ll} = Acute.LFP_PFC.All_sessions{jj,1}(:,1:(Acute.LFP_PFC.All_sessions{jj,4}(2,ll))-1);
           Acute.LFP_V1.Sessions_LightON_OFF{jj,ll}  = Acute.LFP_V1.All_sessions{jj,1}(:,1:(Acute.LFP_V1.All_sessions{jj,4}(2,ll))-1);

    % Light OFF periods - odd cell columns       
    elseif mod(ll,2)~= 0  &&  ll ~= 1;
           Acute.LFP_PFC.Sessions_LightON_OFF{jj,ll} = Acute.LFP_PFC.All_sessions{jj,1}(:,(Acute.LFP_PFC.All_sessions{jj,4}(2,ll-1))+1:(Acute.LFP_PFC.All_sessions{jj,4}(2,ll))-1);
           Acute.LFP_V1.Sessions_LightON_OFF{jj,ll}  = Acute.LFP_V1.All_sessions{jj,1}(:,(Acute.LFP_V1.All_sessions{jj,4}(2,ll-1))+1:(Acute.LFP_V1.All_sessions{jj,4}(2,ll))-1);

    % Light ON periods - even cell columns       
    elseif mod(ll,2) == 0 &&  ll ~= 1;
           Acute.LFP_PFC.Sessions_LightON_OFF{jj,ll} = Acute.LFP_PFC.All_sessions{jj,1}(:,Acute.LFP_PFC.All_sessions{jj,4}(2,ll-1):Acute.LFP_PFC.All_sessions{jj,4}(2,ll));
           Acute.LFP_V1.Sessions_LightON_OFF{jj,ll}  = Acute.LFP_V1.All_sessions{jj,1}(:,Acute.LFP_V1.All_sessions{jj,4}(2,ll-1):Acute.LFP_V1.All_sessions{jj,4}(2,ll));

    end    
    end
end

% Clear trash
clear ('jj','ll');

%% Normalizing time - light OFF period according to the light ON period

% session = 1; % choose session 
% 
% s1_lengths = cellfun(@length, Acute.LFP_PFC.Sessions_LightON_OFF(session,:));
% s1_lengths(~any(s1_lengths,1)) = [];
% 
% Acute.LFP_PFC.Sessions_LightON_OFF_TimeNorm  = cell(length(s1_lengths)/2,2);
% Acute.LFP_V1.Sessions_LightON_OFF_TimeNorm  = cell(length(s1_lengths)/2,2);
% 
% 
% for ii = 1:length(s1_lengths)
%     
%     % First Light OFF period (baseline)
%     if     ii == 1;
%            Acute.LFP_PFC.Sessions_LightON_OFF_TimeNorm{ii,1} = Acute.LFP_PFC.Sessions_LightON_OFF{session,ii};
%            Acute.LFP_V1.Sessions_LightON_OFF_TimeNorm{ii,1}  = Acute.LFP_V1.Sessions_LightON_OFF{session,ii};
% 
%     % Light OFF periods       
%     elseif mod(ii,2)~= 0  &&  ii ~= 1;
%            Acute.LFP_PFC.Sessions_LightON_OFF_TimeNorm{ii-1,2} = Acute.LFP_PFC.Sessions_LightON_OFF{session,ii}(:,1:s1_lengths(ii-1));
%            Acute.LFP_V1.Sessions_LightON_OFF_TimeNorm{ii-1,2}  = Acute.LFP_V1.Sessions_LightON_OFF{session,ii}(:,1:s1_lengths(ii-1));
% 
%     % Light ON periods       
%     elseif mod(ii,2) == 0 &&  ii ~= 1;
%            Acute.LFP_PFC.Sessions_LightON_OFF_TimeNorm{ii,1} = Acute.LFP_PFC.Sessions_LightON_OFF{session,ii};
%            Acute.LFP_V1.Sessions_LightON_OFF_TimeNorm{ii,1}  = Acute.LFP_V1.Sessions_LightON_OFF{session,ii};
%    
%     end
% end
% 
% % Delete empty row inside cell
% Acute.LFP_PFC.Sessions_LightON_OFF_TimeNorm(3:2:9,:)=[]
% Acute.LFP_V1.Sessions_LightON_OFF_TimeNorm(3:2:9,:) =[]
% 
% % Clear trash
% clear ('session','ii','s1_lengths')

%%
% Optinal - Uncomment the lines below to define main variables name according to
% the experiment number
val_name = cell2mat(regexp(Acute.Path,'\w*Acute\w*','match'));
assignin('base',val_name, Acute);

% Clear trash
clear ('Acute',)

%%
% Save data (-v7.3 flag to store variables > 2GB with compression)
save(val_name,val_name,'-v7.3')


