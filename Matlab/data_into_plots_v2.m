%night 1
load('C:\Users\sauli\Downloads\Soft_Tesis\OpenCV\Matlab\workspace_14-11-2019_34-300_54-30_70-10.mat')

% night 6
% load C:\Users\sauli\Downloads\Soft_Tesis\OpenCV\Matlab\all_temp_data_13-12-2018.mat
% [g74 g62 g66 g81 g62 g80 g85 g83 g92 g88 g97 g105 g76 g55 g140 g143 g148 g150 g152 
% [c17 c28 c29 c30 c31

%se desprenden         85 92     141 143 148 150 152
%1: 55 66 62 74 80 81 83     140 
%2: 76 
%3: 97
%4: 105

% ROI_labels_cover = {'55', '66', '62', '74', '80', '81', '83', '140', '76', '97', '105'};
%     ROI_labels_cover = {'55', '66', '62', '74', '80', '81', '83', '85', '92', '140', '141', '143', '148', '150', '152','76', '97', '105'};

%     ROI_labels_core = {'17','20','21','22','23','24','25','27','28','29','30','31'};

plot_all = 0;

calc_cover_area = 1;
calc_core_area = 1;

calc_cover_cg = 1;

if calc_cover_cg
    calc_core_cg = 0;
else
    calc_core_cg = 1;
end

if calc_cover_area
    T_selected = '-34';
elseif calc_core_area
    T_selected = '-54';
end


all_region_pos = cell(300,1);
all_region_neg= cell(300,1);
Ts2 = -100:2:10;

skip_time_axis = 6;
start_t = 20;
end_t = 13;
x_min = find(xtick_histogram == start_t);
x_max = find(xtick_histogram == end_t);
k = x_min;

% xlim = [1 size(xtick_histogram,2)];
x_lim = [x_min x_max];
y_lim = [-70 -30];
%% 
temptimepos3 = [];
temptimeneg3 = [];
temptimetot3 = [];
cg = zeros(200,3);
area = zeros(200,2);
min_temp = zeros(200,1);
filtered_regions = {'301'};
% Read and plot country/state lines
filepath_shp = 'C:\Users\sauli\Downloads\Soft_Tesis\OpenCV\Shapefiles\';
countries_shp = strcat(filepath_shp, 'ne_10m_admin_0_countries.shp');
brstates_shp = strcat(filepath_shp, 'BRA_ADM1.shp');

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
    Countries = geoshow([countries.Lat], [countries.Lon],'Color',[0.6 0.6 0.6], 'LineWidth', 1.5);
    % Colores
    hot = [.85, .41, .09];
    warmer = [.87, .42, .06];
    warm = [.96, .83, .16];
    tepid = [.44, .75, .25];
    breeze = [0, .99, 1];
    cool = [0, .57, .58];
    chilly = [.32, .65, .98];
    cold = [.02, .20, 1];
    % Plot core temperature clouds
    cover_plot = plot(1,1, '.k', 'Color', warm);
    core_plot = plot(1,1, '.k', 'Color', breeze);
    most_plot = plot(1,1, '.k', 'Color', cool);
    % Plot negative and positive lightning
    % Plot lightning out of target thunderstorm
    sprite_plot = plot(1, 1, 'o','MarkerEdgeColor','blue','MarkerSize',10);
    lightning_plot_missed = plot(1, 1, '.','MarkerEdgeColor','blue','MarkerFaceColor','blue','MarkerSize',9);
    lightning_plot_neg = plot(1, 1, '.','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',9);
    lightning_plot_pos = plot(1, 1, '+','MarkerEdgeColor','m','MarkerFaceColor','m','MarkerSize',6);
    % Plot labels
    labels_plot_cover = text(1, 1, '1', 'FontSize',16);
    labels_plot_core = text(1, 1, '1', 'FontSize',16);
    % Set axis and grid
    set(review_ax,'xtick', -180:2:180, 'Layer','top');
    set(review_ax,'ytick', -90:2:90);
    set(review_ax, 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '-', 'GridColor', [0.6 0.6 0.6], 'LineWidth', 0.1, 'GridAlpha', 0.5);
    axis([minlon(index), maxlon(index), minlat(index), maxlat(index)]);
    % Set colormap
    cmin = 90;
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
    %% Define ROI
    time = xtick_histogram(k);
    if time >= 1.8333 && time < 20
        ROI_labels_cover = {'69'};
    else 
        ROI_labels_cover = {'96'};
    end
    
    ROI_labels_core = {'55'};
    
    %% Calculate core cg
    if calc_core_cg
        for region = all_c{:}
            if ~any(strcmp(ROI_labels_core, region.label))
                continue
            end
            region_pixels_core = [region_pixels_core; region.pixels];
            region_labels_core = [region_labels_core; [region.bounds(1,2) region.bounds(1,1) str2double(region.label)]];

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
        for region = all_g{:}
            if strcmp(ROI_labels_cover, region.label)
                area(1,k) = region.region_area;
                min_temp(1,k) = region.minimum_temp;
            end
%             if ~any(strcmp(ROI_labels_cover, region.label))
%                 area(1,k) = 0;
%                 continue
%             end
%             ind = str2double(region.label);
%             area(ind,k) = region.region_area;
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
    
    if plot_all
        set(temp_plot, 'XData', lns, 'YData', lts, 'CData', all_t{1});
        set(core_plot, 'visible', 'off')
        delete(labels_plot_cover)
        set(core_plot, 'visible', 'off')
        delete(labels_plot_core)
        set(sprite_plot, 'visible', 'off')
        set(lightning_plot_pos, 'visible', 'off')
        set(lightning_plot_neg, 'visible', 'off')
        set(lightning_plot_missed, 'visible', 'off')
            
    end
    
    if ~isempty(region_pixels_cover) && plot_all && calc_cover_cg
        all_l{1} = all_l{1}(all_l{1}(:,3) <= 0,:);
        all_l{1} = setdiff(all_l{1},region_pos, 'rows');
        all_l{1} = setdiff(all_l{1},region_neg, 'rows');
        set(lightning_plot_missed, 'XData', lns(all_l{1}(:,2)), 'YData', lts(all_l{1}(:,1)), 'visible', 'on');   

        set(sprite_plot, 'XData', lns(all_s(:,2)), 'YData', lts(all_s(:,1)), 'visible', 'on');        
        set(lightning_plot_pos, 'XData', lns(region_pos(:,2)), 'YData', lts(region_pos(:,1)), 'visible', 'on');
        set(lightning_plot_neg, 'XData', lns(region_neg(:,2)), 'YData', lts(region_neg(:,1)), 'visible', 'on');

        set(cover_plot, 'XData', lns(region_pixels_cover(:,2)), 'YData', lts(region_pixels_cover(:,1)));
        labels_plot_cover = text(lns(region_labels_cover(:,2)), lts(region_labels_cover(:,1)), strcat('g', num2str(region_labels_cover(:,3))), 'FontSize',16);    
    end
    
    if ~isempty(region_pixels_core) && plot_all && calc_core_cg
        
%         all_l{1} = all_l{1}(all_l{1}(:,3) <= 0,:);
%         all_l{1} = setdiff(all_l{1},region_pos, 'rows');
%         all_l{1} = setdiff(all_l{1},region_neg, 'rows');
%         all_l{1} = intersect(all_l{1}(:,1:2), extended_region, 'rows');

%         set(lightning_plot_missed, 'XData', lns(all_l{1}(:,2)), 'YData', lts(all_l{1}(:,1)), 'visible', 'on');   
  
        set(lightning_plot_missed, 'XData', lns(extended_lightning(:,2)), 'YData', lts(extended_lightning(:,1)), 'visible', 'on');   

        set(sprite_plot, 'XData', lns(all_s(:,2)), 'YData', lts(all_s(:,1)), 'visible', 'on');        

        set(lightning_plot_pos, 'XData', lns(region_pos(:,2)), 'YData', lts(region_pos(:,1)), 'visible', 'on');
        set(lightning_plot_neg, 'XData', lns(region_neg(:,2)), 'YData', lts(region_neg(:,1)), 'visible', 'on');

        set(core_plot, 'XData', lns(region_pixels_core(:,2)), 'YData', lts(region_pixels_core(:,1)), 'visible', 'on');
        labels_plot_core = text(lns(region_labels_core(:,2)), lts(region_labels_core(:,1)), strcat('c', num2str(region_labels_core(:,3))), 'FontSize',16);
    end
    
    if plot_all
        title(strcat('Night 12/13/2022-12/14/2022. Time:', labelX(k)))
        waitforbuttonpress
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

%% Create the histograms
% *************************************************************************
nice_blue = [0 0.4470 0.7410];
nice_orange = [0.8500 0.3250 0.0980];
nice_yellow = [0.9290 0.6940 0.1250];
nice_purple = [0.4940 0.1840 0.5560];
nice_green = [0.4660 0.6740 0.1880];
nice_cyan = [0.3010 0.7450 0.9330];
nice_red = [0.6350 0.0780 0.1840];

%% +CG
scrsz = get(groot,'ScreenSize');
% All regions
fig10 = figure('Position',[1 1 scrsz(3) scrsz(4)]);
% ax10 = axes('Parent', fig10);
subplot(4,2,1)
% temptimepos2
h10 = pcolor(1:size(xtick_histogram,2), Ts2(1,:), temptimetot3);
set(h10, 'EdgeColor', 'none')
% h10 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimetot3);
set(gca,'XTick', 1:skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,1:skip_time_axis:end));
set(gca,'XLim', x_lim, 'XTickLabelRotation', 45); 
set(gca,'YLim', y_lim);

xlabel('Time (UT)');
ylabel('Temperature (C)');
colormap(jet); 
cb10 = colorbar;
title(cb10,'Number of CGs')
% -52 regions regions

% fig13 = figure(13);
% ax13 = axes('Parent', fig13);
% ax13 = axes('Parent', fig10);
subplot(4,2,3)
h13 = pcolor(1:size(xtick_histogram,2), Ts2(1,:), temptimesprite3);
set(h13, 'EdgeColor', 'none')

% h13 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimesprite3);
set(gca,'XTick', 1:skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,1:skip_time_axis:end));
set(gca,'XLim', x_lim, 'XTickLabelRotation', 45); 
set(gca,'YLim', y_lim);

xlabel('Time (UT)');
ylabel('Temperature (C)');
colormap(jet); 
cb13 = colorbar;
title(cb13,'Number of Sprites')


%% -CG
% all regions
% fig11 = figure(11);
% ax11 = axes('Parent', fig11);
subplot(4,2,5)
% h11 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimeneg3);
h11 = pcolor(1:size(xtick_histogram,2), Ts2(1,:), temptimeneg3);
set(h11, 'EdgeColor', 'none')
set(gca,'XTick', 1:skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,1:skip_time_axis:end));
set(gca,'XLim', x_lim, 'XTickLabelRotation', 45); 
set(gca,'YLim', y_lim);

xlabel('Time (UT)');
ylabel('Temperature (C)');
colormap(jet); 
cb11 = colorbar;
title(cb11,'Number of -CGs')

% -52 regions regions
% fig14 = figure(14);
% ax14 = axes('Parent', fig14);
% ax14 = axes('Parent', fig11);
subplot(4,2,7)
% h14 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimepos3);
h14 = pcolor(1:size(xtick_histogram,2),Ts2(1,:), temptimepos3);
set(h14, 'EdgeColor', 'none')
set(gca,'XTick', 1:skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,1:skip_time_axis:end));
set(gca,'XLim', x_lim, 'XTickLabelRotation', 45); 
set(gca,'YLim', y_lim);

xlabel('Time (UT)');
ylabel('Temperature (C)');
colormap(jet); 
cb14 = colorbar;
title(cb14,'Number of +CGs')

%% Plot areas
% subplot(4,2,[5 7], 'Position', [0.1300 0.1000 0.300 0.350])
subplot(4,2,2)
plot(1:size(area,2),area(1:2,:), '-.')

legend('Area T <= -34C', 'Area T <= -54C')
set(gca,'XTick', 1:skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,1:skip_time_axis:end));
set(gca,'XLim', x_lim, 'XTickLabelRotation', 45); 
xlabel('Time (UT)');
ylabel(strcat('Isolated Regions Area (km2)'));

%% Plot sprites

sprite(1:85) = NaN;
sprite(97:end) = NaN;

subplot(4,2,4)
plot(1:1:size(sprite,2),sprite(1,1:1:end), '-o', 'Color', nice_red, 'MarkerSize',5, 'MarkerFaceColor', nice_red)

legend('Sprites')
set(gca,'XTick', 1:skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,1:skip_time_axis:end));
set(gca,'XLim', x_lim, 'XTickLabelRotation', 45);
set(gca,'yLim', [0 5]);
xlabel('Time (UT)');
ylabel(strcat('N of Sprites'));
%% Plot lightning total and -cg
subplot(4,2,6)
h15 = plot(1:skip_time_axis:size(cg,2),cg(3,1:skip_time_axis:end), '-o', ...
    1:skip_time_axis:size(cg,2),cg(2,1:skip_time_axis:end), '-d',...
    1:skip_time_axis:size(cg,2),cg(1,1:skip_time_axis:end), '-s');
set(h15, { 'Color' },{nice_orange; nice_cyan; nice_purple}, { 'MarkerSize' }, {5;5;5},...
    {'MarkerFaceColor'}, {nice_orange; nice_cyan; nice_purple})

legend('Total CG', '-CG', '+CG')
set(gca,'XTick', 1:skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,1:skip_time_axis:end));
set(gca,'XLim', x_lim, 'XTickLabelRotation', 45);
xlabel('Time (UT)');
ylabel(strcat('N of CGs and -CGs '));
% %% Plot lightning +cg
% % subplot(4,2,8, 'Position', [0.5725 0.1000 0.295 0.355])
% subplot(4,2,8)
% plot(1:skip_time_axis:size(cg,2),cg(1,1:skip_time_axis:end), '-o', 'Color', nice_orange, 'MarkerSize',5, 'MarkerFaceColor', nice_orange)
% legend('+CG')
% 
% set(gca,'XTick', 1:skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,1:skip_time_axis:end));
% set(gca,'XLim', x_lim, 'XTickLabelRotation', 45);
% xlabel('Time (UT)');
% ylabel(strcat('N of +CGs'));
%% Minimum temperature
subplot(4,2,8)
h16 = plot(1:skip_time_axis:size(min_temp,2), min_temp(1,1:skip_time_axis:end), '-o',...
    1:skip_time_axis:size(min_temp,2), min_temp(2,1:skip_time_axis:end), '-d');

set(h16, { 'Color' }, {nice_orange; nice_cyan}, { 'MarkerSize' }, {5;5},...
    {'MarkerFaceColor'}, {nice_orange; nice_cyan})

%     'Color', nice_orange, 'MarkerSize',5, 'MarkerFaceColor', nice_orange)
legend('Minimum Temperature -34', 'Minimum Temperature -54')

set(gca,'XTick', 1:skip_time_axis:size(xtick_histogram,2), 'XTickLabel', labelX(1,1:skip_time_axis:end));
set(gca,'XLim', x_lim, 'XTickLabelRotation', 45);
xlabel('Time (UT)');
ylabel(strcat('Minimum Temperature'));
