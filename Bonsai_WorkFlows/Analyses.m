clear
clc

%% Bonsai. Behavioral Analisys. 
% Flavio Mourao. Nucleo de Neurociencias (NNC)
% email: f_agm@yahoo.com.br 
% Universidade Federal de Minas Gerais 2019

% Load datafiles (*.csv)
[FileName,PathName] = uigetfile({'*.csv'},'MultiSelect', 'on'); % Define file type *.*

% Define a struct with files informations for dir organization
Header.FilePattern = repmat(struct('name',[],'date',[],'bytes',[],'isdir',[],'datenum',[]), 1, length(FileName));

% Filename can be organize as a single char or a group char in a cell depending on the number os files selected
if ischar(FileName)
   Header.FilePattern = dir(fullfile(PathName, FileName)); % condition for a single file selected 
   fprintf(1, 'Reading %s\n', FileName);
   data = readtable([PathName '/' FileName],'Delimiter',' ');
   data = table2array(data(:,1:end-1));
   val_name = cell2mat(regexp(FileName,'\w*M\w*','match'));
   assignin('base',val_name, data);
   
else    
   for ii = 1:length(FileName) % loop over multiple files selected
       Header.FilePattern(ii) = dir(fullfile(PathName, char(FileName(ii))));
       fprintf(1, 'Reading %s\n', fullFileName);
       data = readtable([PathName '\'  FileName{1, ii}],'Delimiter',' ');
       data = table2array(data);
       val_name = cell2mat(regexp(FileName{1,ii},'\w*Q\w*','match'));
       assignin('base',val_name, data);
   end 
end 

clear ('data', 'FileName', 'ii', 'val_name','PathName');

% Sort data based on file properties
% BehavFiles = nestedSortStruct(Header.FilePattern,'name',1); % Perform a nested sort of a struct array based on multiple fields.

%% Analysis

% Frame Rate
Header.Num_frames = 30; 

% Total time in sec.
Header.Total_time = round(length(M1)./Header.Num_frames);

% Video Resolution
Header.Video_height = 444;
Header.Video_width  = 456;

% Arena Dimensions
Header.Arena_height = 50; % in cm
Header.Arena_width  = 50; % in cm

% Define conversion factor (cm from pixels)
factor_h = Header.Arena_height/Header.Video_height; % height
factor_w = Header.Arena_width/Header.Video_width;   % width

% Normalize cm from pixels
Arena_Full.vec_y = M1(:,3).* factor_h; % convert y values to cm from pixels
Arena_Full.vec_x = M1(:,2).* factor_w; % convert x values to cm from pixels

Arena_Full.d_vec_y = [0 ; diff(M1(:,3))].* factor_h; % convert y Displacement to cm from pixels
Arena_Full.d_vec_x = [0 ; diff(M1(:,2))].* factor_w; % convert x Displacement to  cm from pixels

Arena_Full.Displacement        = sqrt(Arena_Full.d_vec_x .^2 + Arena_Full.d_vec_y .^2);  % Displacement in cm
Arena_Full.Accumulate_distance = cumsum(Arena_Full.Displacement);                        % Accumulate distance in cm
Arena_Full.Total_distance      = Arena_Full.Accumulate_distance(end);                    % Accumulate distance in cm
Arena_Full.Time_vector         = linspace(0,length(M1)/Header.Num_frames,length(M1));    % Time vector in sec.

% Number of quadrants
n_q = 2;

% Analysis of each quadrant
sq = (M1(:,4:5)); 
z = zeros(1,n_q);
idx = false(size(sq));

% Pre allocate for data analysis for each quadrant
Arena_Quadrants = cell(5,4);

for ii=1:n_q
    z(1,ii) = ii;
    idx = ismember(sq,z,'rows');
    
    Arena_Quadrants{1,ii} = M1(idx,1);                                                                                    % Frames
    Arena_Quadrants{2,ii} = [Arena_Full.vec_x(idx,1) Arena_Full.vec_y(idx,1)];                                            % x y coordinates in cm
    Arena_Quadrants{3,ii} = [Arena_Full.d_vec_x(idx,1) Arena_Full.d_vec_y(idx,1)];                                        % x y Displacement in cm
    Arena_Quadrants{4,ii} = cumsum(Arena_Full.Displacement(idx,1));                                                       % Accumulate distance in cm
    Arena_Quadrants{5,ii} = linspace(0,length(Arena_Quadrants{1,ii})/Header.Num_frames,length(Arena_Quadrants{1,ii}))';   % Time vector
    Arena_Quadrants{6,ii} = Arena_Quadrants{4,ii}./ Arena_Quadrants{5,ii} ;                                               % Velocity 
    Arena_Quadrants{7,ii} = round(length(Arena_Quadrants{1,ii})./Header.Num_frames);                                      % Total time
    Arena_Quadrants{8,ii} = Arena_Quadrants{4,ii}(end);                                                                   % Total distance traveled 
    Arena_Quadrants{9,ii} = sum(diff(Arena_Quadrants{1,ii}) > 1);                                                         % Crossings
    
    z(1,ii) = 0;
end

clear ('factor_h', 'factor_w', 'idx', 'ii', 'n_q', 'sq', 'z')

%% Tracking Map

Track_Fig = figure('position', [0, 0, 600, 400],'resize', 'on');

set(gcf,'color','w');
hold
plot(M1(:,2),M1(:,3),'Color',[0.6, 0.6, 0.6],'linewidth',2)
plot([Header.Arena_width/2 Header.Arena_width/2],[0 Header.Arena_height] ,'k--' ,'linewidth',1)
plot([0 Header.Arena_width],[Header.Arena_height/2 Header.Arena_height/2] ,'k--' ,'linewidth',1)
axis off

%%

Ac_DisT_Fig = figure;
set(gcf,'color','w');
plot(Arena_Full.Time_vector,Arena_Full.Accumulate_distance  ,'Color',[0.6350, 0.0780, 0.1840],'linewidth',1)
xlabel('\fontsize{12}Time'); ylabel('\fontsize{12}Distance (cm)');
box off



clear('A_height','A_width','V_height','V_width','vec_y','vec_x','factor_h','factor_w','Time_vector','Num_frames')

%%
video = VideoReader('Untitled44.avi');
vidFrames = read(video);

while(hasFrame(video))
frames(i+1,:,:,:)=readFrame(video);
i = i+1;
end

whos
size(frames)

x = frames(110,:,:,:);

x(:,:,:) = frames(110,:,:,:);

imagesc(x)


% extract frames to pictures
obj = VideoReader('Untitled44.avi');
numberofframes = get(obj, 'NumberofFrames');

frame = zeros(numberofframes,obj.Height,obj.Width);

for k = 1 : numberofframes  
frame(k+1,:,:,:) = read(obj, k);

end


Track_Fig = figure('position', [0, 0, 600, 400],'resize', 'on');
set(gcf,'color','w');
hold
plot(Arena_Quadrants{2,1}(:,1),Arena_Quadrants{2,1}(:,2),'Color',[0.6, 0.6, 0.6],'linewidth',2)
plot(Arena_Quadrants{2,2}(:,1),Arena_Quadrants{2,2}(:,2),'Color',[0.6, 0.6, 0.6],'linewidth',2)
plot(Arena_Quadrants{2,3}(:,1),Arena_Quadrants{2,3}(:,2),'Color',[0.6, 0.6, 0.6],'linewidth',2)
plot(Arena_Quadrants{2,4}(:,1),Arena_Quadrants{2,4}(:,2),'Color',[0.6, 0.6, 0.6],'linewidth',2)

subplot 221
plot(Arena_Quadrants{5,1},Arena_Quadrants{6,1},'Color',[0.6, 0.6, 0.6],'linewidth',2)
subplot 222
plot(Arena_Quadrants{5,2},Arena_Quadrants{6,2},'Color',[0.6, 0.6, 0.6],'linewidth',2)
subplot 223
plot(Arena_Quadrants{5,3},Arena_Quadrants{6,3},'Color',[0.6, 0.6, 0.6],'linewidth',2)
subplot 224
plot(Arena_Quadrants{5,4},Arena_Quadrants{6,4},'Color',[0.6, 0.6, 0.6],'linewidth',2)