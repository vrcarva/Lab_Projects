function datos_VR_batch_170311()

[filename, pathname] = uigetfile('/Volumes/Elements/PDE/3_University/Project/resultados/*.txt','Select files','multiselect','on');
if ischar(filename)
    filename = {filename};
end
                
hit_percentages = zeros(1,numel(filename));
wrongChoice_percentages = zeros(1,numel(filename));
for ind_file=1:numel(filename)
    [aux1,aux2] = datos_VR(pathname,filename{ind_file});
        hit_percentages(ind_file) =aux1;
        wrongChoice_percentages(ind_file) =aux2;
end

figure
bar([mean(hit_percentages);mean(wrongChoice_percentages)]')
% keyboard


end


function [hit_percentages,wrongChoice_percentages] = datos_VR(pathname,filename)
close all
clearvars -global blend_data
%this function load and save the data txt into different matrix
global blend_data
scrsz = get(0,'ScreenSize');
blend_data.file = [pathname '\'  filename];
blend_data.name =  filename(1:end-7);
blend_data.name =  filename(1:end-7);
display(['loading: ' filename])
h1 = figure('name',blend_data.file,'Position',[20 scrsz(4)/30 scrsz(3)/1.1 scrsz(4)/1.1]);
if filename==0
    return;
end

if ~exist([blend_data.file(1:end-11) '.mat'],'file') || 1
    blend_data.file = fullfile(pathname, filename);
    fid = fopen(blend_data.file);   
    data_summary = textscan(fid,'%s');
    fclose(fid);
    data_summary = data_summary{1};
    
    fid = fopen([blend_data.file(1:end-11) '.txt']);
    position = textscan(fid,'%s');
    fclose(fid);
    %start position
    position = position{1};
    start_position = position{1};
    start_position = start_position(2:strfind(start_position,'t')-1);
    x =str2double(start_position(1:strfind(start_position,'y')-1));
    y = str2double(start_position(strfind(start_position,'y')+1:end));
    blend_data.start_position = [x,y];
    
    %get the info from the trials (time, performance, position of reward)
    index = ~cellfun(@isempty,strfind(data_summary,'front_wall'));
    blend_data.front_wall_pos = [str2double(data_summary{index}(strfind(data_summary{index},'/')+1:end)),str2double(data_summary{index}(11:strfind(data_summary{index},'/')-1))]-blend_data.start_position;
    index = ~cellfun(@isempty,strfind(data_summary,'back_wall'));
    blend_data.back_wall_pos = [str2double(data_summary{index}(strfind(data_summary{index},'/')+1:end)),str2double(data_summary{index}(10:strfind(data_summary{index},'/')-1))]-blend_data.start_position;
    index = ~cellfun(@isempty,strfind(data_summary,'wall1'));
    index2 = ~cellfun(@isempty,strfind(data_summary,'wall2'));
    aux = [str2double(data_summary{index}(strfind(data_summary{index},'/')+1:end)),str2double(data_summary{index}(7:strfind(data_summary{index},'/')-1));...
        str2double(data_summary{index2}(strfind(data_summary{index2},'/')+1:end)),str2double(data_summary{index2}(7:strfind(data_summary{index2},'/')-1))]-repmat(blend_data.start_position,2,1);
    blend_data.wallLeft_pos = aux(aux(:,1)==min(aux(:,1)),:);
    blend_data.wallRight_pos = aux(aux(:,1)==max(aux(:,1)),:);
    index = ~cellfun(@isempty,strfind(data_summary,'theshold_x'));
    aux = str2double(data_summary{index}(11:end));
    blend_data.ths_x = [blend_data.wallLeft_pos(1)+aux,blend_data.wallRight_pos(1)-aux];
    index = ~cellfun(@isempty,strfind(data_summary,'theshold_y'));
    aux = str2double(data_summary{index}(11:end));
    blend_data.ths_y = aux-blend_data.start_position(2);
    
    trials = find(~cellfun(@isempty,strfind(data_summary,'oooooooooooooooooooooooooooooooooo')));
    blend_data.reward_position_mat = nan(1,numel(trials)-1);
    blend_data.performance_mat = nan(1,numel(trials)-1);
    blend_data.trial_start_end =  nan(2,numel(trials)-1);
    blend_data.exp_trial = nan(2,numel(trials)-1);
    blend_data.final_position_mat = nan(2,numel(trials)-1);
    blend_data.manual_control_mat = nan(1,numel(trials)-1);
    blend_data.turningFail_mat = nan(1,numel(trials)-1);
    blend_data.timeOutFail_mat = nan(1,numel(trials)-1);
    blend_data.wrongChoiceFail_mat = nan(1,numel(trials)-1);
    blend_data.event_times =  nan(1,numel(trials)-1);
    blend_data.mean_performance_mat = nan(1,numel(trials)-1);
    blend_data.frontWall = cell(1,numel(trials)-1);
    blend_data.background = nan(1,numel(trials)-1);
    for ind_trials=1:numel(trials)-1
        info_trial = data_summary(trials(ind_trials)+1:trials(ind_trials+1)-1);
        index_flip = ~cellfun(@isempty,strfind(info_trial,'flip'));
        index2 = ~cellfun(@isempty,strfind(info_trial,'start'));
        if nnz(index2==1)==1 && nnz(index_flip==1)==1
            trial_times = info_trial{index2};
            start_trial =str2double(trial_times(strfind(trial_times,'start')+5:strfind(trial_times,'end')-1));
            end_trial = str2double(trial_times(strfind(trial_times,'end')+3:end));
            blend_data.trial_start_end(:,ind_trials) = [start_trial;end_trial];
            blend_data.event_times(ind_trials) = end_trial;
            blend_data.reward_position_mat(ind_trials) = str2double(info_trial{index_flip}(5:end));
            index2 = ~cellfun(@isempty,strfind(info_trial,'hit'));
            blend_data.performance_mat(ind_trials) = nnz(index2==1);
            index2 = ~cellfun(@isempty,strfind(info_trial,'x'));
            coord = info_trial{index2};
            x =str2double(coord(strfind(coord,'x')+1:strfind(coord,'y')-1));
            y = str2double(coord(strfind(coord,'y')+1:end));
            blend_data.final_position_mat(:,ind_trials) = [x;y];
            index2 = ~cellfun(@isempty,strfind(info_trial,'manualControl'));
            blend_data.manual_control_mat(ind_trials) = str2double(info_trial{index2}(14:end));
            index2 = ~cellfun(@isempty,strfind(info_trial,'mean_performance'));
            blend_data.mean_performance_mat(ind_trials) = str2double(info_trial{index2}(17:end));
            index2 = ~cellfun(@isempty,strfind(info_trial,'obj'));
            blend_data.frontWall{ind_trials} = info_trial{index2}(4:end);
            index2 = ~cellfun(@isempty,strfind(info_trial,'bg'));
            aux = info_trial{index2}(3:end);
            if isequal(aux,'backgroundObject')
                 blend_data.background(ind_trials) = 0;
            elseif isequal(aux,'backgroundObject_dots')
                 blend_data.background(ind_trials) = 1;
            elseif isequal(aux,'backgroundObject_stripes')
                 blend_data.background(ind_trials) = 2;
            else 
                keyboard
            end
           
            
            
            index2 = ~cellfun(@isempty,strfind(info_trial,'wrongChoice'));
            if nnz(index2~=0)>0
                blend_data.wrongChoiceFail_mat(ind_trials) = str2double(info_trial{index2}(12:end));
            else
                blend_data.wrongChoiceFail_mat(ind_trials) = 0;
            end
            
            index2 = ~cellfun(@isempty,strfind(info_trial,'turning'));
            if nnz(index2~=0)>0
                blend_data.turningFail_mat(ind_trials) = str2double(info_trial{index2}(8:end));
            else
                blend_data.turningFail_mat(ind_trials) = 0;
            end
            
            index2 = ~cellfun(@isempty,strfind(info_trial,'timeout'));
            if nnz(index2~=0)>0
                blend_data.timeOutFail_mat(ind_trials) = str2double(info_trial{index2}(8:end));
            else
                blend_data.timeOutFail_mat(ind_trials) = 0;
            end
            
        elseif nnz(~cellfun(@isempty,strfind(info_trial,'exp_trial'))==1)~=0
            index2 = ~cellfun(@isempty,strfind(info_trial,'exp_trial_start'));
            index3 = ~cellfun(@isempty,strfind(info_trial,'exp_trial_end'));
            blend_data.exp_trial(:,ind_trials) = [str2double(info_trial{index2}(16:end)) str2double(info_trial{index3}(14:end))];
        else
            %keyboard
        end
    end
    blend_data.frontWall(isnan(blend_data.reward_position_mat)) = [];
    blend_data.background(isnan(blend_data.reward_position_mat)) = [];
    blend_data.reward_position_mat(isnan(blend_data.reward_position_mat)) = [];
    blend_data.performance_mat(isnan(blend_data.performance_mat)) = [];
    blend_data.trial_start_end(:,isnan(blend_data.trial_start_end(1,:))) = [];
    blend_data.final_position_mat(:,isnan(blend_data.final_position_mat(1,:))) = [];
    blend_data.manual_control_mat(isnan(blend_data.manual_control_mat)) = [];
    blend_data.wrongChoiceFail_mat(isnan(blend_data.wrongChoiceFail_mat)) = [];
    blend_data.timeOutFail_mat(isnan(blend_data.timeOutFail_mat)) = [];
    blend_data.event_times(isnan(blend_data.event_times)) = [];
    blend_data.mean_performance_mat(isnan(blend_data.mean_performance_mat)) = [];
    blend_data.turningFail_mat(isnan(blend_data.turningFail_mat)) = [];
    blend_data.timeOutFail_mat(isnan(blend_data.timeOutFail_mat)) = [];
    blend_data.exp_trial(:,isnan(blend_data.exp_trial(1,:))) = [];
   
    blend_data.num_trials = numel(blend_data.reward_position_mat);
    blend_data.exp_num_trials = size(blend_data.exp_trial,2);
    
    %get trials duration
    aux = [0 blend_data.event_times];
    blend_data.trial_durations = diff(aux);
    
    
    %%%%%%%%%%%%%%%%%%%%
    subplot(4,2,[1,3])
    hold on
    mat_mean_hits = zeros(1,blend_data.num_trials);
    mat_mean_wrongChoice = zeros(1,blend_data.num_trials);
    for ind_ph=1:blend_data.num_trials
        mat_mean_hits(ind_ph) = 100*mean(blend_data.performance_mat(1:ind_ph));
        mat_mean_wrongChoice(ind_ph) = 100*mean(blend_data.wrongChoiceFail_mat(1:ind_ph));
    end
    
    plot(mat_mean_hits,'color',[0 0 1],'linewidth',2)
    plot(mat_mean_wrongChoice,'color',[1 0 0],'linewidth',2)
    title('Mean performance')
    xlabel('trials')
    ylabel('percentage of hits')
    axis([1 blend_data.num_trials 0 100])
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %get the info about the mouse position/orientation
    contador_path = 0;
    blend_data.time = zeros(1,numel(position));
    blend_data.path = zeros(2,numel(position));
    blend_data.orientation = zeros(2,numel(position));
    for ind_position=1:numel(position)-1
        if isequal(position{ind_position}(1),'x')
            coord = position{ind_position};
            time_aux = str2double(coord(strfind(coord,'t')+1:end));
            indices = find(blend_data.event_times>time_aux, 1);
            if ~isempty(indices)
                contador_path = contador_path + 1;
                blend_data.time(contador_path) = time_aux;
                coord = coord(2:strfind(coord,'t')-1);
                x =str2double(coord(1:strfind(coord,'y')-1));
                y = str2double(coord(strfind(coord,'y')+1:end));
                blend_data.path(:,contador_path) = [x,y]-blend_data.start_position;
                ori = position{ind_position+1};
                ori = ori(7:end);
                blend_data.orientation(:,contador_path) = [str2double(ori(1:strfind(ori,'sin')-1))/100,str2double(ori(strfind(ori,'sin')+3:end))/100];
            else
                break
            end
        end
    end
    
    blend_data.time = blend_data.time(1:contador_path);
    blend_data.path = blend_data.path(:,1:contador_path);
    blend_data.orientation = blend_data.orientation(:,1:contador_path);

    subplot(4,2,[5,7])
    hold on
    for ind_tr=1:numel(blend_data.event_times)
        if ind_tr==1
            plot(blend_data.path(1,blend_data.time<blend_data.event_times(ind_tr)),blend_data.path(2,blend_data.time<blend_data.event_times(ind_tr)),'.',...
                'color',[1-blend_data.performance_mat(ind_tr) 0 blend_data.performance_mat(ind_tr)])
        else
            plot(blend_data.path(1,blend_data.time>blend_data.event_times(ind_tr-1)&blend_data.time<blend_data.event_times(ind_tr)),...
                blend_data.path(2,blend_data.time>blend_data.event_times(ind_tr-1)&blend_data.time<blend_data.event_times(ind_tr)),'.',...
                'color',[1-blend_data.performance_mat(ind_tr) 0 blend_data.performance_mat(ind_tr)])
        end
    end
    axis equal
    axis([-3500 3500 0 7500])
    set(gca,'XTick',[])
    set(gca,'YTick',[])
    title 'trajectories'
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    figure('Position',[20 scrsz(4)/30 scrsz(3)/1.1 scrsz(4)/1.1]);
    hold on
    dashed_lines = blend_data.wallLeft_pos(1):100:blend_data.wallRight_pos(1);
    for ind=1:numel(dashed_lines)
        plot(dashed_lines(ind)*ones(1,2),[blend_data.back_wall_pos(2) blend_data.front_wall_pos(2)],'--k')
    end
     plot(blend_data.wallRight_pos(1)*ones(1,2), [blend_data.back_wall_pos(2) blend_data.front_wall_pos(2)],'k','linewidth',2)
    plot(blend_data.wallLeft_pos(1)*ones(1,2), [blend_data.back_wall_pos(2) blend_data.front_wall_pos(2)],'k','linewidth',2)
    plot(blend_data.ths_x(1)*ones(1,2), [blend_data.ths_y blend_data.front_wall_pos(2)],'r','linewidth',2)
    plot(blend_data.ths_x(2)*ones(1,2), [blend_data.ths_y blend_data.front_wall_pos(2)],'r','linewidth',2)
    plot([blend_data.wallLeft_pos(1) blend_data.ths_x(1)], blend_data.ths_y*ones(1,2),'r','linewidth',2)
    plot([blend_data.ths_x(2) blend_data.wallRight_pos(1)], blend_data.ths_y*ones(1,2),'r','linewidth',2)
    plot([blend_data.wallRight_pos(1),blend_data.wallLeft_pos(1)], blend_data.front_wall_pos(2)*ones(1,2),'g','linewidth',2)
    plot([blend_data.wallRight_pos(1),blend_data.wallLeft_pos(1)], blend_data.back_wall_pos(2)*ones(1,2),'k','linewidth',2)
    
    for ind_tr=1:numel(blend_data.event_times)
        if ind_tr==1
            plot(blend_data.path(1,blend_data.time<blend_data.event_times(ind_tr)),blend_data.path(2,blend_data.time<blend_data.event_times(ind_tr)),'+-',...
                'color',[1-blend_data.performance_mat(ind_tr) 0 blend_data.performance_mat(ind_tr)])%,'marker',finalPos_marker{final_position_mat_original(ind_tr)+1})
        else
            plot(blend_data.path(1,blend_data.time>blend_data.event_times(ind_tr-1)&blend_data.time<blend_data.event_times(ind_tr)),...
                blend_data.path(2,blend_data.time>blend_data.event_times(ind_tr-1)&blend_data.time<blend_data.event_times(ind_tr)),'+-',...
                'color',[1-blend_data.performance_mat(ind_tr) 0 blend_data.performance_mat(ind_tr)])%,'marker',finalPos_marker{final_position_mat_original(ind_tr)+1})
        end
    end
    axis equal
    axis([blend_data.wallLeft_pos(1) blend_data.wallRight_pos(1) blend_data.back_wall_pos(2) blend_data.front_wall_pos(2)])
    
    title 'original position'
    
    try
        if exist([blend_data.file(1:end-11) 'raw_velocity.txt'],'file')~=0
            fid = fopen([blend_data.file(1:end-11) 'raw_velocity.txt']);
            raw_velocity = textscan(fid,'%s');
            fclose(fid);
            raw_velocity = raw_velocity{1};
            contador_path = 0;
            blend_data.raw_velocity = nan(2,numel(raw_velocity));
            blend_data.raw_velocity_time = nan(1,numel(raw_velocity));
            for ind_vel=1:numel(raw_velocity)
                coord = raw_velocity{ind_vel};
                aux = strfind(coord,'t');
                time_aux = str2double(coord(aux(2)+1:end));
                if nnz(blend_data.event_times>time_aux)>0
                    contador_path = contador_path + 1;
                    blend_data.raw_velocity_time(contador_path) = time_aux;
                    
                    coord = coord(2:aux(2)-1);
                    x =-str2double(coord(2:strfind(coord,'turn')-1));
                    y = str2double(coord(strfind(coord,'turn')+4:end));
                    blend_data.raw_velocity(:,contador_path) = [x;y];
                else
                    break
                end
            end
            
            figure('Position',[20 scrsz(4)/30 scrsz(3)/1.1 scrsz(4)/1.1])
            hold on
            plot(blend_data.raw_velocity_time,blend_data.raw_velocity(1,:),'+-b')
            plot(blend_data.raw_velocity_time,blend_data.raw_velocity(2,:),'+-r')
            title('raw velocity')
            xlabel('time (s)')
            ylabel('velocities')
            legend('go','turn')
            txt3 = 'LEFT';
            text(nanmin(blend_data.raw_velocity_time),max(blend_data.raw_velocity(:))+max(blend_data.raw_velocity(:))/10,txt3,'HorizontalAlignment','left','verticalAlignment','top','fontSize',20,'color','r')
            txt3 = 'FORWARD';
            text(nanmax(blend_data.raw_velocity_time),max(blend_data.raw_velocity(:))+max(blend_data.raw_velocity(:))/10,txt3,'HorizontalAlignment','right','verticalAlignment','top','fontSize',20,'color','b')
            txt3 = 'RIGHT';
            text(nanmin(blend_data.raw_velocity_time),min(blend_data.raw_velocity(:))+min(blend_data.raw_velocity(:))/10,txt3,'HorizontalAlignment','left','verticalAlignment','bottom','fontSize',20,'color','r')
            txt3 = 'BACKWARD';
            text(nanmax(blend_data.raw_velocity_time),min(blend_data.raw_velocity(:))+min(blend_data.raw_velocity(:))/10,txt3,'HorizontalAlignment','right','verticalAlignment','bottom','fontSize',20,'color','b')
            
            for ind_tr=1:size(blend_data.trial_start_end,2)
                plot(blend_data.trial_start_end(1,ind_tr)*ones(1,2),[min(blend_data.raw_velocity(:)) max(blend_data.raw_velocity(:))],'g')
                plot(blend_data.trial_start_end(2,ind_tr)*ones(1,2),[min(blend_data.raw_velocity(:)) max(blend_data.raw_velocity(:))],'k')
            end
            ylim([min(blend_data.raw_velocity(:))+min(blend_data.raw_velocity(:))/10 max(blend_data.raw_velocity(:))+max(blend_data.raw_velocity(:))/10])
            xlim([-0.1 nanmax(blend_data.raw_velocity_time)+0.1])
        end
    catch
        errordlg('call Manuel!')
        keyboard
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(0,'currentFigure',h1)
    blend_data.rewards_proportion = mean(blend_data.performance_mat);
    index = ~cellfun(@isempty,strfind(data_summary,'num_right'));
    blend_data.num_right = str2double(data_summary{index}(10:end));
    index = ~cellfun(@isempty,strfind(data_summary,'num_left'));
    blend_data.num_left = str2double(data_summary{index}(9:end));
    blend_data.num_right_presentations = numel(find(blend_data.reward_position_mat==0));
    blend_data.num_left_presentations = numel(find(blend_data.reward_position_mat==1));
    index = ~cellfun(@isempty,strfind(data_summary,'num_rewards'));
    blend_data.num_rewards = str2double(data_summary{index}(12:end));
    index = ~cellfun(@isempty,strfind(data_summary,'num_fails'));
    blend_data.num_fails = str2double(data_summary{index}(10:end));
    subplot(4,2,[6,8])
    axis off
    fontSize = 20;
    text(0.1,0.95,'num trials:','fontSize',fontSize)
    text(0.8,0.95,num2str(blend_data.num_trials),'fontSize',fontSize)
    text(0.1,0.85,'proportion of rewards:','fontSize',fontSize)
    text(0.8,0.85,num2str(blend_data.rewards_proportion),'fontSize',fontSize)
    text(0.1,0.75,'num right:','fontSize',fontSize)
    text(0.8,0.75,num2str(blend_data.num_right),'fontSize',fontSize)
    text(0.1,0.65,'num left:','fontSize',fontSize)
    text(0.8,0.65,num2str(blend_data.num_left),'fontSize',fontSize)
    text(0.1,0.55,'num right presentations:','fontSize',fontSize)
    text(0.8,0.55,num2str(blend_data.num_right_presentations),'fontSize',fontSize)
    text(0.1,0.45,'num left presentations:','fontSize',fontSize)
    text(0.8,0.45,num2str(blend_data.num_left_presentations),'fontSize',fontSize)
    text(0.1,0.35,'num hits:','fontSize',fontSize)
    text(0.8,0.35,num2str(blend_data.num_rewards),'fontSize',fontSize)
    text(0.1,0.25,'num fails:','fontSize',fontSize)
    text(0.8,0.25,num2str(blend_data.num_fails),'fontSize',fontSize)
    subplot(4,2,[2,4])
    hold on
    blend_data.hit_percentages = cell(1,3);
    hit_percentages_figure = zeros(1,3);
    blend_data.wrongChoice_percentages = cell(1,3);
    wrongChoice_percentages_figure = zeros(1,3);
    for ind_ph=0:2
        aux = blend_data.performance_mat(blend_data.background==ind_ph);
        blend_data.hit_percentages{ind_ph+1} = aux;
        hit_percentages_figure(ind_ph+1) = mean(aux);
        %%%
        aux = blend_data.wrongChoiceFail_mat(blend_data.background==ind_ph);
        blend_data.wrongChoice_percentages{ind_ph+1} = aux;
        wrongChoice_percentages_figure(ind_ph+1) = mean(aux);
    end
    bar(0:2,[hit_percentages_figure;wrongChoice_percentages_figure]')
    %bar([mean(blend_data.performance_mat),mean(blend_data.wrongChoiceFail_mat)],'stacked')
    set(gca,'xtick',[1,2,3])
    set(gca,'xticklabel',{'NO TEXTURE','DOTS','STRIPES'})
    save(blend_data.file(1:end-11),'blend_data')
    saveas(h1,[blend_data.file(1:end-11) '_fig'],'png')
else
    load([blend_data.file(1:end-11) '.mat'])
end
hit_percentages = blend_data.hit_percentages;
wrongChoice_percentages = blend_data.wrongChoice_percentages;
end


