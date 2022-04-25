%night 1
% load('C:\Users\sauli\Downloads\Soft_Tesis\OpenCV\Matlab\workspace_14-11-2019.mat')

% night 6
% load C:\Users\sauli\Downloads\Soft_Tesis\OpenCV\Matlab\all_temp_data_13-12-2018.mat
% [g74 g62 g66 g81 g62 g80 g85 g83 g92 g88 g97 g105 g76 g55 g140 g143 g148 g150 g152 
% [c17 c28 c29 c30 c31

%se desprenden         85 92     141 143 148 150 152
%1: 55 66 62 74 80 81 83     140 
%2: 76 
%3: 97
%4: 105

% ROI_labels = {'55', '66', '62', '74', '80', '81', '83', '140', '76', '97', '105'};
          
ROI_labels = {'55', '66', '62', '74', '80', '81', '83', '85', '92', '140', '141', '143', '148', '150', '152','76', '97', '105'};

plot_all = 0;
calc_cover = 1;
calc_core = 0;
area_threshold = 1;
skip = 20;
k = 1;
all_region_pos = cell(300,1);
all_region_neg= cell(300,1);
Ts2 = -100:2:10;
%% 
temptimepos3 = [];
temptimeneg3 = [];
temptimetot3 = [];
area = zeros(200,2);
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

    % Plot core temperature clouds
    cover_plot = plot(1,1, '.k', 'Color', 'green');
    core_plot = plot(1,1, '.k', 'Color', 'red');
    most_plot = plot(1,1, '.k', 'Color', 'blue');
    % Plot negative and positive lightning
    % Plot lightning out of target thunderstorm
    sprite_plot = plot(1, 1, 'o','MarkerEdgeColor','blue','MarkerSize',9);
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
    T_threshold = -32;
    custom_gray = gray(80);
    cm3 = colormap([hot(cmin+T_threshold); flipud(custom_gray(end+1-(cmax-T_threshold):end, :))]);
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
    all_s = all_sprites{k};
    
    for region = all_c{:}
        border_lats = lts(region.border(:,1));
        border_lons = lns(region.border(:,2));
        %
        % Manual cut
%         if any(all([(border_lats < -38) (border_lons < -66)],2)) ||...
%             any(all([(border_lats < -38) (border_lons < -64)],2)) ||...
%             any(all([(border_lats < -40) (border_lons < -60)],2))
%             continue
%         end
        % Area filter
%         if region.region_area < area_threshold
%             continue
%         end
        region_pixels_core = [region_pixels_core; region.pixels];
        region_labels_core = [region_labels_core; [region.bounds(1,2) region.bounds(1,1) str2double(region.label)]];
        
        if calc_core
            % concatenate lightning
            region_pos = [region_pos; region.pos_light];
            region_neg = [region_neg; region.neg_light];

            ntpos3 = histc(region_pos(:,3),Ts2);
            ntpos3 =  ntpos3(:);
            ntneg3 = histc(region_neg(:,3),Ts2);
            ntneg3 =  ntneg3(:);
            nttot3 = ntpos3 + ntneg3;

            % Concatenate the current histogram vector into a matrix (used to create the spectrogram image)

            temptimepos3(:,k) = ntpos3;
            temptimeneg3(:,k) = ntneg3;
            temptimetot3(:,k) = nttot3;
    %         
            ind = str2double(region.label);
            area(ind,k) = region.region_area;
        end
    end
    
    for region = all_g{:}
        border_lats = lts(region.border(:,1));
        border_lons = lns(region.border(:,2));

        if ~any(strcmp(ROI_labels, region.label))
            continue
        end
%         if any(all([(border_lats < -38) (border_lons < -66)],2)) ||...
%             any(all([(border_lats < -38) (border_lons < -64)],2)) ||...
%             any(all([(border_lats < -40) (border_lons < -60)],2))
%             continue
%         end
%         if region.region_area < area_threshold
%             continue
%         end
        region_pixels_cover = [region_pixels_cover; region.pixels];
        region_labels_cover = [region_labels_cover; [region.bounds(1,2) region.bounds(1,1) str2double(region.label)]];
        
        if calc_cover
            % concatenate lightning
            region_pos = [region_pos; region.pos_light];
            region_neg = [region_neg; region.neg_light];
            ntpos3 = histc(region_pos(:,3),Ts2);
            ntpos3 =  ntpos3(:);
            ntneg3 = histc(region_neg(:,3),Ts2);
            ntneg3 =  ntneg3(:);
            nttot3 = ntpos3 + ntneg3;

            % Concatenate the current histogram vector into a matrix (used to create the spectrogram image)

            temptimepos3(:,k) = ntpos3;
            temptimeneg3(:,k) = ntneg3;
            temptimetot3(:,k) = nttot3;

            ind = str2double(region.label);
            area(ind,k) = region.region_area;
        end
    end
    
%     if ~isempty(all_s)
    ntsprite3 = histc(all_s(:,3),Ts2);
    ntsprite3 = ntsprite3(:);
    temptimesprite3(:,k) = ntsprite3;
%     end
    
    if plot_all
        set(temp_plot, 'XData', lns, 'YData', lts, 'CData', all_t{1});
            set(core_plot, 'visible', 'off')
            delete(labels_plot_cover)
            set(core_plot, 'visible', 'off')
            delete(labels_plot_core)
            set(sprite_plot, 'visible', 'off')
            set(lightning_plot_pos, 'visible', 'off')
            set(lightning_plot_neg, 'visible', 'off')

    end
    if ~isempty(region_pixels_cover) && plot_all
        set(cover_plot, 'XData', lns(region_pixels_cover(:,2)), 'YData', lts(region_pixels_cover(:,1)));
        labels_plot_cover = text(lns(region_labels_cover(:,2)), lts(region_labels_cover(:,1)), strcat('g', num2str(region_labels_cover(:,3))), 'FontSize',16);    
    end
    
    if ~isempty(region_pixels_core) && plot_all && calc_core
%         l{1} = l{1}(l{1}(:,3) <= T_core,:);
        all_l{1} = setdiff(all_l{1},region_pos, 'rows');
        all_l{1} = setdiff(all_l{1},region_neg, 'rows');

        set(sprite_plot, 'XData', lns(all_s{1}(:,2)), 'YData', lts(all_s{1}(:,1)), 'visible', 'on');        
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

%% +CG
scrsz = get(groot,'ScreenSize');
% All regions
fig10 = figure('Position',[1 1 scrsz(3) scrsz(4)]);
% ax10 = axes('Parent', fig10);
subplot(4,2,1)
% temptimepos2
h10 = pcolor(1:size(xtick_histogram,2), Ts2(1,:), temptimesprite3);
set(h10, 'EdgeColor', 'none')
% h10 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimesprite3);
set(gca,'XTick', 1:skip:size(xtick_histogram,2), 'XTickLabel', labelX(1,1:skip:end));

xlabel('Time (UT)');
ylabel('Temperature (C)');
colormap(jet); 
cb10 = colorbar;
title(cb10,'Number of +CGs')
% -52 regions regions

% fig13 = figure(13);
% ax13 = axes('Parent', fig13);
% ax13 = axes('Parent', fig10);
subplot(4,2,2)
% h13 = pcolor(1:size(xtick_histogram,2), Ts2(1,:), temptimepos2);
% set(h13, 'EdgeColor', 'none')

h13 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimepos3);
set(gca,'XTick', 1:skip:size(xtick_histogram,2), 'XTickLabel', labelX(1,1:skip:end));
xlabel('Time (UT)');
ylabel('Temperature (C)');
colormap(jet); 
cb13 = colorbar;
title(cb13,'Number of +CGs')


%% -CG
% all regions
% fig11 = figure(11);
% ax11 = axes('Parent', fig11);
subplot(4,2,3)
h11 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimeneg2);
% h11 = pcolor(1:size(xtick_histogram,2), Ts2(1,:), temptimeneg2);
% set(h11, 'EdgeColor', 'none')
set(gca,'XTick', 1:skip:size(xtick_histogram,2), 'XTickLabel', labelX(1,1:skip:end));
xlabel('Time (UT)');
ylabel('Temperature (C)');
colormap(jet); 
cb11 = colorbar;
title(cb11,'Number of -CGs')

% -52 regions regions
% fig14 = figure(14);
% ax14 = axes('Parent', fig14);
% ax14 = axes('Parent', fig11);
subplot(4,2,4)
h14 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimeneg3);
% h14 = pcolor(1:size(xtick_histogram,2),Ts2(1,:), temptimeneg3);
% set(h14, 'EdgeColor', 'none')
set(gca,'XTick', 1:skip:size(xtick_histogram,2), 'XTickLabel', labelX(1,1:skip:end));
xlabel('Time (UT)');
ylabel('Temperature (C)');
colormap(jet); 
cb14 = colorbar;
title(cb14,'Number of -CGs')

%% All lightning
% all regions
% fig12 = figure(12);
% ax12 = axes('Parent', fig12);

subplot(4,2,5)
h12 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimetot2);
% h12 = pcolor(1:size(xtick_histogram,2),Ts2(1,:), temptimetot2);
% set(h12, 'EdgeColor', 'none')
set(gca,'XTick', 1:skip:size(xtick_histogram,2), 'XTickLabel', labelX(1,1:skip:end));
xlabel('Time (UT)');
ylabel('Temperature (C)');
colormap(jet); 
cb12 = colorbar;
title(cb12,'Number of +/-CGs')

% -52 regions regions
% fig15 = figure(15);
% ax15 = axes('Parent', fig15);
% ax15 = axes('Parent', fig12);

subplot(4,2,6)

h15 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimetot3);
% h15 = pcolor(1:size(xtick_histogram,2),Ts2(1,:), temptimetot3);
% set(h15, 'EdgeColor', 'none')

set(gca,'XTick', 1:skip:size(xtick_histogram,2), 'XTickLabel', labelX(1,1:skip:end));
xlabel('Time (UT)');
ylabel('Temperature (C)');
colormap(jet); 
cb15 = colorbar;
title(cb15,'Number of +/-CGs')

%% Plot areas
subplot(4,2,7)
% figure()
% plot(1:size(area,2),area(:,:))
plot(1:size(area,2),area(:,:), '.')

set(gca,'XTick', 1:skip:size(xtick_histogram,2), 'XTickLabel', labelX(1,1:skip:end));
xlabel('Time (UT)');
ylabel('Area (km2)');

subplot(4,2,8)
plot(1:size(area,2),area(:,:), '-.')

set(gca,'XTick', 1:skip:size(xtick_histogram,2), 'XTickLabel', labelX(1,1:skip:end));
xlabel('Time (UT)');
ylabel('Area (km2)');
