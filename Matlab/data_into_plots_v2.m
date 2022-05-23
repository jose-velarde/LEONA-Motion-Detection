%night 1
% clear all
% load('C:\Users\sauli\Downloads\Soft_Tesis\OpenCV\Matlab\workspace_14-11-2019_track_all.mat')

% night 6
% load C:\Users\sauli\Downloads\Soft_Tesis\OpenCV\Matlab\all_temp_data_13-12-2018.mat
% [g74 g62 g66 g81 g62 g80 g85 g83 g92 g88 g97 g105 g76 g55 g140 g143 g148 g150 g152 
% [c17 c28 c29 c30 c31

% se desprenden         85 92     141 143 148 150 152
% 1: 55 66 62 74 80 81 83     140 
% 2: 76 
% 3: 97
% 4: 105

% ROI_labels_cover = {'55', '66', '62', '74', '80', '81', '83', '140', '76', '97', '105'};
%     ROI_labels_cover = {'55', '66', '62', '74', '80', '81', '83', '85', '92', '140', '141', '143', '148', '150', '152','76', '97', '105'};

%     ROI_labels_core = {'17','20','21','22','23','24','25','27','28','29','30','31'};

ROI_labels_cover = {'a'};
ROI_labels_core = {'a'};

plot_all = 1;

calc_cover_area = 1;
calc_core_area = 1;

calc_cover_cg = 1;
calc_core_cg = 0;

if calc_cover_area
    T_selected = '-34';
elseif calc_core_area
    T_selected = '-54';
end

all_region_pos = cell(300,1);
all_region_neg= cell(300,1);
Ts2 = -100:2:10;

%% Initialize plot variables
marker_size = 3;
skip_time_axis = 6;
start_t = 20;
end_t = 12;
x_min = find(xtick_histogram >= (start_t-0.1) & xtick_histogram <= (start_t+0.1));
x_max = find(xtick_histogram == end_t);
k = x_min;

x_sprite_start_time = 5;
x_sprite_end_time = 8;
x_sprite_start = find(xtick_histogram >= (x_sprite_start_time-0.1) & xtick_histogram <= (x_sprite_start_time+0.1));
x_sprite_end = find(xtick_histogram >= (x_sprite_end_time-0.1) & xtick_histogram <= (x_sprite_end_time+0.1));


x_lim = [x_min x_max];
y_lim = [-70 -30];
%% Initialize data variables
temptimepos3 = [];
temptimeneg3 = [];
temptimetot3 = [];
cg = zeros(200,3);
area = zeros(200,2);
min_temp = zeros(200,1);
centroid = zeros(200,2);
filtered_regions = {'301'};
% Read and plot country/state lines
filepath_shp = 'C:\Users\sauli\Downloads\Soft_Tesis\OpenCV\Shapefiles\';
countries_shp = strcat(filepath_shp, 'ne_10m_admin_0_countries.shp');
brstates_shp = strcat(filepath_shp, 'BRA_ADM1.shp');
%% sprite circle test
circle = @(origin, azimuth, radius)  [origin(1) + radius*cosd(-azimuth+90); origin(2) + radius*sind(-azimuth+90)];
%% Create plots
if plot_all
    scrsz = get(groot,'ScreenSize');
    fig_review = figure('Position',[1 1 scrsz(3) scrsz(4)]);
    review_ax= axes('Parent', fig_review , 'FontSize',16);
    hold on
    % Plot cloud top temperatures
    temp_plot = pcolor(lns,lts,zeros(size(couttemp)));
    set(temp_plot, 'EdgeColor', 'none')
    % The plot objects are 'States' and 'Countries'
    countries = shaperead(countries_shp,'UseGeoCoords',true);
    Countries = geoshow([countries.Lat], [countries.Lon],'Color',[0.9 0.9 0.9], 'LineWidth', 1.5);
    % Colors
    hot = [.85, .41, .09];
    warmer = [.87, .42, .06];
    warm = [.96, .83, .16];
    tepid = [.44, .75, .25];
    breeze = [0, .99, 1];
    cool = [0, .57, .58];
    chilly = [.32, .65, .98];
    cold = [.02, .20, 1];
    nice_blue = [0 0.4470 0.7410];
    nice_orange = [0.8500 0.3250 0.0980];
    nice_yellow = [0.9290 0.6940 0.1250];
    nice_purple = [0.4940 0.1840 0.5560];
    nice_green = [0.4660 0.6740 0.1880];
    nice_cyan = [0.3010 0.7450 0.9330];
    nice_red = [0.6350 0.0780 0.1840];

    % Plot core temperature clouds
    cover_plot = plot(1,1, '.k', 'Color', warm, 'MarkerSize',10);
    core_plot = plot(1,1, '.k', 'Color', breeze, 'MarkerSize',10);
    most_plot = plot(1,1, '.k', 'Color', cool, 'MarkerSize',10);
    % Plot sprites
    sprite_plot = plot(1, 1, 'o','MarkerEdgeColor','blue','MarkerSize',10);
    for i = 1:10
%         sprite_circle(i) = patch([1,1], [2,2], 'red', 'FaceAlpha', 0, 'visible', 'off');
        sprite_circle(i) = plot(1, 1, 'o', 'MarkerEdgeColor', 'black', 'MarkerSize', 0.75, 'visible', 'off');
    end
    % Plot negative and positive lightning
    % Plot lightning out of target thunderstorm
    lightning_plot_missed = plot(1, 1, '.','MarkerEdgeColor',[0.3 0.3 0.3],'MarkerFaceColor',[0.3 0.3 0.3],'MarkerSize',9);
    lightning_plot_neg = plot(1, 1, '.','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',9);
    lightning_plot_pos = plot(1, 1, '+','MarkerEdgeColor','m','MarkerFaceColor','m','MarkerSize',9);
    parent_plot = plot(1, 1, 'd','MarkerEdgeColor','black','MarkerFaceColor','green','MarkerSize',10);
%     centroid_plot = plot(1, 1, '.','MarkerEdgeColor','black','MarkerFaceColor','black','MarkerSize',8);
    % Plot labels
    labels_plot_cover = text(1, 1, '1', 'FontSize',16);
    labels_plot_core = text(1, 1, '1', 'FontSize',16);
    % Plot fov
    patch_fov = patch([1,1], [2,2], 'red', 'FaceAlpha', 0.2, 'visible', 'off');
    
    % Set axis and grid
    set(review_ax,'xtick', -180:1:180, 'Layer','top');
    set(review_ax,'ytick', -90:1:90);
    set(review_ax, 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '-', 'GridColor', [0.6 0.6 0.6], 'LineWidth', 0.1, 'GridAlpha', 0.5);
%     axis([minlon(index), maxlon(index), minlat(index), maxlat(index)]);
    axis equal;

    axis([-69, -58, minlat(index), -31]);
    % Set colormap
    cmin = 70;
    cmax = 20;
    T_threshold = -34;
    custom_gray = gray(80);
    cm3 = colormap([jet(cmin+T_threshold); flipud(custom_gray(end+1-(cmax-T_threshold):end, :))]);
    
    cb3 = colorbar;
    caxis([-(cmin) cmax ]);
    caxis('manual')
    title(cb3,'Cloud top temperature (C)')
    % Define filter points
    filter_points_plot = plot(review_ax,[-66 -64 -60],  [-38 -38 -40], '.k', 'color', 'green','MarkerSize', 30, 'visible', 'off');
end

%% Video writer object
record = 'Yes';
if strcmp(record, 'Yes')
    aviFilename = strcat('_Test_', YYYY{index},'-', MM{index},'-', DD{index},'-', hh{index}, mm{index},'.avi');
    writerObj = VideoWriter(aviFilename);
    writerObj.FrameRate = 1;
    open(writerObj);
    fig.CurrentCharacter = 'd';
end
%% Create time string array
labelX = cell(1);
for all_t = 1:size(xtick_histogram,2)
    tt = xtick_histogram(all_t);
    hour = num2str(floor(tt));
    minute = num2str((tt-floor(tt))*60);
    if size(minute,2) == 1
        minute = strcat ('0', minute);
    end
    if size(hour,2) == 1
        hour = strcat ('0', hour);
    end
    
    labelX{all_t} = strcat(hour, ':', minute);
end
%% Concatenate data from found regions into one in each scan
% filter regions by area
% filter regions by location
while 1
    region_pos = [];
    region_neg = [];
    region_pixels_core = [];
    region_labels_core = [];
    region_pixels_cover = [];
    region_labels_cover = [];

    all_t = all_temperature(k);
    all_c = all_core_regions(k);
    all_g = all_cover_regions(k);
    all_l = all_lightning(k);
    all_pl = all_pos_lightning(k);
    all_nl = all_neg_lightning(k);
    
    all_s = all_sprites{k};
    all_sp = all_parents{k};
    %% Define ROI
    time = xtick_histogram(k);
%     if time >= 1.8333 && time < 20
%         ROI_labels_cover = {'69'};
%     else 
%         ROI_labels_cover = {'96'};
%     end%     

    if time >= 20.8332 && time < 21
        ROI_labels_cover = {'185'};
    elseif time >= 21 && time <= 23.8334
%     if time >= 21 && time <= 23.8334
        ROI_labels_cover = {'209'};
    elseif time >= 0 && time < 1.8333
        ROI_labels_cover = {'209'};
    elseif time > 1.8333 && time <= 19.999
        ROI_labels_cover = {'11'};
    end
    
%     ROI_labels_core = {'55'};
    ROI_labels_core = {'80'};
    
    %% Calculate core cg
    if calc_core_cg
        for region = all_c{:}
            if ~any(strcmp(ROI_labels_core, region.label))
                continue
            end
            region_pixels_core = [region_pixels_core; region.pixels];
            region_labels_core = [region_labels_core; [region.bounds(1,2) region.bounds(1,1) str2double(region.label)]];

%             % concatenate lightning
%             region_pos = [region_pos; region.pos_light];
%             region_neg = [region_neg; region.neg_light];
%             ntpos3 = histc(region_pos(:,3),Ts2);
%             ntpos3 =  ntpos3(:);
%             ntneg3 = histc(region_neg(:,3),Ts2);
%             ntneg3 =  ntneg3(:);
%             nttot3 = ntpos3 + ntneg3;
%             
%             cg(1,k) = size(region_pos,1);
%             cg(2,k) = size(region_neg,1);
%             cg(3,k) = size(region_pos,1) + size(region_neg,1);
% 
%             sprite(1,k) = size(all_s,1);
%             
%             temptimepos3(:,k) = ntpos3;
%             temptimeneg3(:,k) = ntneg3;
%             temptimetot3(:,k) = nttot3; 
        end
    end
    %% Calculate core area -54
    if calc_core_area
        area(2,k) = 0;
        min_temp(2,k) = 0;

        for region = all_c{:}
            if strcmp(ROI_labels_core, region.label)
                area(2,k) = region.region_area;
                min_temp(2,k) = region.minimum_temp;
            end
%             if ~any(strcmp(ROI_labels_core, region.label))
%                 continue
%             end
%             ind = str2double(region.label);
%             area(ind,k) = region.region_area;
            
        end
    end
    %% Calculate cover cg
    if calc_cover_cg
        for region = all_g{:}
            if ~any(strcmp(ROI_labels_cover, region.label))
                continue
            end
            region_pixels_cover = [region_pixels_cover; region.pixels];
            region_labels_cover = [region_labels_cover; [region.bounds(1,2) region.bounds(1,1) str2double(region.label)]];

            % concatenate lightning
            region_pos = [region_pos; region.pos_light];
            region_neg = [region_neg; region.neg_light];
            ntpos3 = histc(region_pos(:,3),Ts2);
            ntpos3 =  ntpos3(:);
            ntneg3 = histc(region_neg(:,3),Ts2);
            ntneg3 =  ntneg3(:);
            nttot3 = ntpos3 + ntneg3;
            
            cg(1,k) = size(region_pos,1);
            cg(2,k) = size(region_neg,1);
            cg(3,k) = size(region_pos,1) + size(region_neg,1);
            
            sprite(1,k) = size(all_s,1);

            temptimepos3(:,k) = ntpos3;
            temptimeneg3(:,k) = ntneg3;
            temptimetot3(:,k) = nttot3;  
        end
  
    end
    
    %% Calculate extended lightning
    if ~isempty(region_pixels_core) && calc_core_cg
        [extended_region, extended_border_pix] = floodFillScanlineStack(...
            region_pixels_core(end,2), region_pixels_core(end,1),...
            all_t{1}(region_pixels_core(end,1), region_pixels_core(end,2)),...
            -46, all_t{1}, size(region_pixels_core,1), fig, writerObj);
%         extended_pos_lightning = intersect(all_pl{1}(:,1:2), extended_region, 'rows');
%         extended_neg_lightning = intersect(all_nl{1}(:,1:2), extended_region, 'rows');
%         extended_lightning = [extended_pos_lightning; extended_neg_lightning];

        extended_pos_lightning = all_pl{1}(ismember(all_pl{1}(:,1:2), extended_region,'rows'),:);
        extended_neg_lightning = all_nl{1}(ismember(all_nl{1}(:,1:2), extended_region,'rows'),:);
        extended_lightning = [extended_pos_lightning; extended_neg_lightning];

        % concatenate lightning
        ntpos3 = histc(extended_pos_lightning(:,3),Ts2);
        ntpos3 =  ntpos3(:);
        ntneg3 = histc(extended_neg_lightning(:,3),Ts2);
        ntneg3 =  ntneg3(:);
        nttot3 = ntpos3 + ntneg3;

        temptimepos3(:,k) = ntpos3;
        temptimeneg3(:,k) = ntneg3;
        temptimetot3(:,k) = nttot3;  
    end
    
    %% Calculate cover area -34
    if calc_cover_area
        min_temp(1,k) = 0;
        area(1,k) = 0;
%         centroid(k,:) = zeros(1,2);

        for region = all_g{:}
            if strcmp(ROI_labels_cover, region.label)
                area(1,k) = region.region_area;
                min_temp(1,k) = region.minimum_temp;
                centroid(k,:) = region.centroid(1,:);
            end
        end
    end
    
    if isempty(region_pixels_cover)  && calc_cover_cg
        temptimepos3(:,k) = zeros(size(Ts2));
        temptimeneg3(:,k) = zeros(size(Ts2));
        temptimetot3(:,k) = zeros(size(Ts2));
    end
    
    if isempty(region_pixels_core)  && calc_core_cg
        temptimepos3(:,k) = zeros(size(Ts2));
        temptimeneg3(:,k) = zeros(size(Ts2));
        temptimetot3(:,k) = zeros(size(Ts2));
    end
    
    ntsprite3 = histc(all_s(:,3),Ts2);
    ntsprite3 = ntsprite3(:);
    temptimesprite3(:,k) = ntsprite3;
    
    ntposspr3 = histc(all_sp(:,3),Ts2);
    ntposspr3 = ntposspr3(:);
    temptimeposspr3(:,k) = ntposspr3;
    
    
    %% Erase plots
    
    if plot_all
%         set(temp_plot, 'XData', lns, 'YData', lts, 'CData', all_t{1});
%         set(core_plot, 'visible', 'off')
        delete(labels_plot_cover)
        set(core_plot, 'visible', 'off')
        delete(labels_plot_core)
        set(sprite_plot, 'visible', 'off')
        set(lightning_plot_pos, 'visible', 'off')
        set(lightning_plot_neg, 'visible', 'off')
        set(lightning_plot_missed, 'visible', 'off')
        set(parent_plot, 'visible', 'off')        
%         set(centroid_plot, 'visible', 'off')        
        i = 0;
        for i = 1:10
            set(sprite_circle(i), 'visible', 'off')
        end
    end
    %% Draw plots -34

    if ~isempty(region_pixels_cover) && plot_all && calc_cover_cg
        all_l{1} = all_l{1}(all_l{1}(:,3) <= 0,:);
        all_l{1} = setdiff(all_l{1},region_pos, 'rows');
        all_l{1} = setdiff(all_l{1},region_neg, 'rows');
%         set(lightning_plot_missed, 'XData', lns(all_l{1}(:,2)), 'YData', lts(all_l{1}(:,1)), 'visible', 'on');   

%         set(sprite_plot, 'XData', lns(all_s(:,2)), 'YData', lts(all_s(:,1)), 'visible', 'on');        
        set(lightning_plot_pos, 'XData', lns(region_pos(:,2)), 'YData', lts(region_pos(:,1)), 'visible', 'on');
        set(lightning_plot_neg, 'XData', lns(region_neg(:,2)), 'YData', lts(region_neg(:,1)), 'visible', 'on');
        set(parent_plot, 'XData', lns(all_sp(:,2)), 'YData', lts(all_sp(:,1)), 'visible', 'on');
        
        % centroid test
%         plot(lns(centroid(k,1)), lts(centroid(k,2)), '.','MarkerEdgeColor','green','MarkerSize',8);

        % hide threshold area 
%         set(cover_plot, 'XData', lns(region_pixels_cover(:,2)), 'YData', lts(region_pixels_cover(:,1)));
        labels_plot_cover = text(lns(region_labels_cover(:,2)), lts(region_labels_cover(:,1)), strcat('g', num2str(region_labels_cover(:,3))), 'FontSize',16);    

        i = 0;
        for i = 1:size(all_s, 1)
            arc = circle([lns(all_s(i,2)) lts(all_s(i,1))], 1:0.5:360, 0.27);
            set(sprite_circle(i), 'XData', arc(1,:), 'YData', arc(2,:), 'visible', 'on')
        end
        plot_fov_into_plots
        
        legend([cover_plot core_plot lightning_plot_pos lightning_plot_neg lightning_plot_missed sprite_circle(i) parent_plot],...
            {'-34C Tc Area','-54C Tc Area','+CG','-CG', 'out of ROI CG','Sprites', 'CG Sprite Parent'})
    end
    %% Draw plots -54
    if ~isempty(region_pixels_core) && plot_all && calc_core_cg
%         all_l{1} = all_l{1}(all_l{1}(:,3) <= 0,:);
%         all_l{1} = setdiff(all_l{1},region_pos, 'rows');
%         all_l{1} = setdiff(all_l{1},region_neg, 'rows');
%         all_l{1} = intersect(all_l{1}(:,1:2), extended_region, 'rows');
%         set(lightning_plot_missed, 'XData', lns(all_l{1}(:,2)), 'YData', lts(all_l{1}(:,1)), 'visible', 'on');   
  
%         set(lightning_plot_missed, 'XData', lns(extended_lightning(:,2)), 'YData', lts(extended_lightning(:,1)), 'visible', 'on');   

%         set(sprite_plot, 'XData', lns(all_s(:,2)), 'YData', lts(all_s(:,1)), 'visible', 'on');
%         set(lightning_plot_pos, 'XData', lns(region_pos(:,2)), 'YData', lts(region_pos(:,1)), 'visible', 'on');
%         set(lightning_plot_neg, 'XData', lns(region_neg(:,2)), 'YData', lts(region_neg(:,1)), 'visible', 'on');

%         set(core_plot, 'XData', lns(region_pixels_core(:,2)), 'YData', lts(region_pixels_core(:,1)), 'visible', 'on');
        labels_plot_core = text(lns(region_labels_core(:,2)), lts(region_labels_core(:,1)), strcat('c', num2str(region_labels_core(:,3))), 'FontSize',16);
    end
    
	%% Record 	
    if plot_all
        title(strcat('Night 12/13/2022-12/14/2022. Time:', labelX(k)))
        if strcmp(record, 'Yes')
            pause(0.01)
            frame = getframe(fig_review);
            writeVideo(writerObj,frame);
            if xtick_histogram(k) >= 20 && xtick_histogram(k) <= 23.99
                date_time = strcat('20191213', strrep(labelX{k}, ':', ''));
            else
                date_time = strcat('20191214', strrep(labelX{k}, ':', ''));
            end
            imwrite(frame.cdata, strcat('png\','Test_', date_time, '.png'));
        else
            waitforbuttonpress
        end
        
        if fig_review.CurrentCharacter == 'd'
            k = k + 1;
        end
        if fig_review.CurrentCharacter == 'a'
            k = k - 1;
        end
        if (fig_review.CurrentCharacter == 'q')
            break
        end
    else
        k = k + 1;
    end
    
    
    if k > size(all_core_regions,2)
        break
    end
    
end

close(writerObj);


%% Remove zeros
area = removeZeros(area, 1);
area = removeZeros(area, 2);
cg = removeZeros(cg, 1);
cg = removeZeros(cg, 2);
cg = removeZeros(cg, 3);
min_temp = removeZeros(min_temp, 1);
min_temp = removeZeros(min_temp, 2);

%% Create the histograms
% *************************************************************************
primary = [0 0 0];
secondary = nice_orange;
sprite_obs_color = nice_blue;
tracking_color = nice_red;

scrsz = get(groot,'ScreenSize');
fig10 = figure('Position',[1 1 scrsz(3) scrsz(4)]);

%% Number of CGs (Histogram)
% subplot(4,2,1)
% % h10 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimetot3);
% h10 = pcolor(1:size(xtick_histogram,2), Ts2(1,:), temptimetot3);
% set(h10, 'EdgeColor', 'none')
% 
% set(gca,'XTick', x_lim(1):skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,x_lim(1):skip_time_axis:end));
% set(gca,'XLim', x_lim, 'XTickLabelRotation', 45); 
% set(gca,'YLim', y_lim);
% 
% xlabel('Time (UT)');
% ylabel('Temperature (C)');
% colormap(jet); 
% cb10 = colorbar;
% title(cb10,'Number of CGs')
%% Number of Sprites (Histogram)
subplot(4,2,1)
% h11 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimesprite3);
h11 = pcolor(1:size(xtick_histogram,2), Ts2(1,:), temptimesprite3);
set(h11, 'EdgeColor', 'none')

set(gca,'XTick', x_lim(1):skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,x_lim(1):skip_time_axis:end));
set(gca,'XLim', x_lim, 'XTickLabelRotation', 45); 
set(gca,'YLim', y_lim);

xlabel('Time (UT)');
ylabel('Temperature (C)');
colormap(jet); 
cb13 = colorbar;
title(cb13,'Number of Sprites')
%% Number of Sprite parent (Histogram)
subplot(4,2,3)
% h10 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimetot3);
h10 = pcolor(1:size(xtick_histogram,2), Ts2(1,:), temptimeposspr3);
set(h10, 'EdgeColor', 'none')

set(gca,'XTick', x_lim(1):skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,x_lim(1):skip_time_axis:end));
set(gca,'XLim', x_lim, 'XTickLabelRotation', 45); 
set(gca,'YLim', y_lim);

xlabel('Time (UT)');
ylabel('Temperature (C)');
colormap(jet); 
cb10 = colorbar;
title(cb10,'Number of Sprite Parents')
%% Number of +CGs (Histogram)
subplot(4,2,5)
% h13 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimepos3);
h13 = pcolor(1:size(xtick_histogram,2),Ts2(1,:), temptimepos3);
set(h13, 'EdgeColor', 'none')

set(gca,'XTick', x_lim(1):skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,x_lim(1):skip_time_axis:end));
set(gca,'XLim', x_lim, 'XTickLabelRotation', 45); 
set(gca,'YLim', y_lim);

xlabel('Time (UT)');
ylabel('Temperature (C)');
colormap(jet); 
cb14 = colorbar;
title(cb14,'Number of +CGs')
%% Number of -CGs (Histogram)
subplot(4,2,7)
% h12 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimeneg3);
h12 = pcolor(1:size(xtick_histogram,2), Ts2(1,:), temptimeneg3);
set(h12, 'EdgeColor', 'none')

set(gca,'XTick', x_lim(1):skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,x_lim(1):skip_time_axis:end));
set(gca,'XLim', x_lim, 'XTickLabelRotation', 45); 
set(gca,'YLim', y_lim);

xlabel('Time (UT)');
ylabel('Temperature (C)');
colormap(jet); 
cb11 = colorbar;
title(cb11,'Number of -CGs')
%% Plot areas
subplot(4,2,2)
hold on
h14 = plot(1:size(area,2),area(1,:), '-o',...
    1:size(area,2),area(2,:), '-d');

set(h14, { 'Color' }, {primary; secondary}, { 'MarkerSize' }, {marker_size;marker_size},...
    {'MarkerFaceColor'}, {primary; secondary})

legend('Area T <= -34C', 'Area T <= -54C')
set(gca,'XTick', x_lim(1):skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,x_lim(1):skip_time_axis:end));
set(gca,'XLim', x_lim, 'XTickLabelRotation', 45); 
xlabel('Time (UT)');
ylabel(strcat('Isolated Regions Area (km2)'));

%Draw start/end of sprite observation
sprite_vertical = plot([x_sprite_start x_sprite_start],[0 max(area(1,:))],[x_sprite_end x_sprite_end],[0 max(area(1,:))]);
set(sprite_vertical, { 'Color' }, {sprite_obs_color; sprite_obs_color});

%Draw start/end of tracking criteria
area_vertical_34 = plot([11 11],[0 max(area(1,:))], '--',[95 95],[0 max(area(1,:))], '--');
set(area_vertical_34, { 'Color' }, {tracking_color; tracking_color})
area_vertical_54 = plot([25 25],[0 max(area(1,:))], '--',[74 74],[0 max(area(1,:))], '--');
set(area_vertical_54, { 'Color' }, {tracking_color; tracking_color})

hold off

%% Minimum temperature
subplot(4,2,4)
hold on
h17 = plot(1:1:size(min_temp,2), min_temp(1,1:end), '-o');

set(h17, { 'Color' }, {primary}, { 'MarkerSize' }, {marker_size},...
    {'MarkerFaceColor'}, {primary})

legend('Minimum Temperature')

set(gca,'XTick', x_lim(1):skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,x_lim(1):skip_time_axis:end));
set(gca,'XLim', x_lim, 'XTickLabelRotation', 45);
set(gca,'YLim', [-80 -30]);
xlabel('Time (UT)');
ylabel(strcat('Minimum Temperature'));

%Draw start/end of sprite observation
sprite_vertical = plot([x_sprite_start x_sprite_start], [-80 -30], [x_sprite_end x_sprite_end], [-80 -30]);
set(sprite_vertical, { 'Color' }, {sprite_obs_color; sprite_obs_color});
%Draw start/end of tracking criteria
area_vertical_34 = plot([11 11],[-80 -30], '--',[95 95],[-80 -30], '--');
set(area_vertical_34, { 'Color' }, {tracking_color; tracking_color})
area_vertical_54 = plot([25 25],[-80 -30], '--',[74 74],[-80 -30], '--');
set(area_vertical_54, { 'Color' }, {tracking_color; tracking_color})

hold off
%% Minimum temperature
% subplot(4,2,8)
% h17 = plot(1:1:size(min_temp,2), min_temp(1,1:1:end), '-o',...
%     1:1:size(min_temp,2), min_temp(2,1:1:end), '-d');
% 
% set(h17, { 'Color' }, {nice_orange; nice_cyan}, { 'MarkerSize' }, {marker_size;marker_size},...
%     {'MarkerFaceColor'}, {nice_orange; nice_cyan})
% 
% %     'Color', nice_orange, 'MarkerSize',5, 'MarkerFaceColor', nice_orange)
% legend('Minimum Temperature -34', 'Minimum Temperature -54')
% 
% set(gca,'XTick', x_lim(1):skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,x_lim(1):skip_time_axis:end));
% set(gca,'XLim', x_lim, 'XTickLabelRotation', 45);
% xlabel('Time (UT)');
% ylabel(strcat('Minimum Temperature'));
%% Plot sprites and +cg
subplot(4,2,6)
hold on

% % Fix NaN in zero values
% idx = ~any(isnan(cg(3,1:end)),1);
% plot(1:size(idx),cg(3,idx));

% plot(1:1:size(sprite,2),sprite(1,1:1:end), '-o', 'Color', nice_red, 'MarkerSize',5, 'MarkerFaceColor', nice_red)
[h15, h_sprites, h_cgplus] = plotyy(1:1:size(sprite,2),sprite(1,1:1:end), 1:1:size(cg,2),cg(1,1:1:end), 'bar','plot');

set(h_sprites, 'FaceColor', secondary)
set(h_cgplus, 'Marker', 'o', 'MarkerSize', marker_size, 'MarkerFaceColor', nice_cyan);

% bar(1:1:size(sprite,2),sprite(1,1:1:end))    
% plot(1:1:size(cg,2),cg(1,1:1:end), '-s', 'Color', nice_red, 'MarkerSize',marker_size, 'MarkerFaceColor', nice_red)

legend('Sprites', '+CG')
set(gca,'XTick', x_lim(1):skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,x_lim(1):skip_time_axis:end));
set(gca,'XLim', x_lim, 'XTickLabelRotation', 45);

xlabel('Time (UT)');
set(h15(1),'YLim', [0 max(sprite(1,1:1:end))+0.5]);
set(h15(2),'YLim', [0 (max(sprite(1,1:1:end))+0.5)*10]);
ylabel(h15(1),strcat('N of Sprites'));% left y-axis
ylabel(h15(2),strcat('N of +CG')) % right y-axis

%Draw start/end of tracking criteria
area_vertical_34 = plot([11 11],[0 (max(sprite(1,1:1:end))+0.5)*10], '--',[95 95],[0 (max(sprite(1,1:1:end))+0.5)*10], '--');
set(area_vertical_34, { 'Color' }, {tracking_color; tracking_color})
area_vertical_54 = plot([25 25],[0 (max(sprite(1,1:1:end))+0.5)*10], '--',[74 74],[0 (max(sprite(1,1:1:end))+0.5)*10], '--');
set(area_vertical_54, { 'Color' }, {tracking_color; tracking_color})

hold off
%% Plot lightning total and -cg
subplot(4,2,8)
hold on

h16 = plot(1:1:size(cg,2),cg(3,1:end), '-o', ...
    1:1:size(cg,2),cg(2,1:end), '-d');
set(h16, { 'Color' },{primary; secondary}, { 'MarkerSize' }, {marker_size;marker_size},...
    {'MarkerFaceColor'}, {primary; secondary})

legend('Total CG', '-CG')
set(gca,'XTick', x_lim(1):skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,x_lim(1):skip_time_axis:end));
set(gca,'XLim', x_lim, 'XTickLabelRotation', 45);
xlabel('Time (UT)');
ylabel(strcat('N of CGs and -CGs '));



%Draw start/end of sprite observation
sprite_vertical = plot([x_sprite_start x_sprite_start],[0 max(cg(3,1:end))],[x_sprite_end x_sprite_end],[0 max(cg(3,1:end))]);
set(sprite_vertical, { 'Color' }, {sprite_obs_color; sprite_obs_color});

%Draw start/end of tracking criteria
area_vertical_34 = plot([11 11],[0 max(cg(3,1:end))], '--',[95 95],[0 max(cg(3,1:end))], '--');
set(area_vertical_34, { 'Color' }, {tracking_color; tracking_color})
area_vertical_54 = plot([25 25],[0 max(cg(3,1:end))], '--',[74 74],[0 max(cg(3,1:end))], '--');
set(area_vertical_54, { 'Color' }, {tracking_color; tracking_color})

hold off
% %% Plot lightning +cg
% subplot(4,2,8)
% plot(1:skip_time_axis:size(cg,2),cg(1,1:skip_time_axis:end), '-o', 'Color', nice_orange, 'MarkerSize',5, 'MarkerFaceColor', nice_orange)
% legend('+CG')
% 
% set(gca,'XTick', 1:skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,1:skip_time_axis:end));
% set(gca,'XLim', x_lim, 'XTickLabelRotation', 45);
% xlabel('Time (UT)');
% ylabel(strcat('N of +CGs'));