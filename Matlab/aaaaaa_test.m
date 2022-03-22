% save('C:\Users\sauli\Downloads\Soft_Tesis\OpenCV\Matlab\all_temp_data_13-12-2018.mat', '-v7.3')
% load C:\Users\sauli\Downloads\Soft_Tesis\OpenCV\Matlab\all_temp_data_13-12-2018.mat
plot_all = 1;
area_threshold = 5000;
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

    % Plot lightning out of target thunderstorm
    lightning_plot_out = plot(1, 1, 'o','MarkerFaceColor','b','MarkerSize',9);
    % Plot core temperature clouds
    cover_plot = plot(1,1, '.k', 'Color', 'green');
    core_plot = plot(1,1, '.k', 'Color', 'red');
    most_plot = plot(1,1, '.k', 'Color', 'blue');
    % Plot negative and positive lightning
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
    filter_points_plot = plot(review_ax,[-66 -64 -60],  [-38 -38 -40], '.k', 'color', 'green','MarkerSize', 30);
end
%% Create time string array

labelX = cell(1);
for t = 1:size(xtick_histogram,2)
    tt = xtick_histogram(t);
    hour = num2str(floor(tt));
    minute = num2str((tt-floor(tt))*60);
    if size(minute,2) == 1
        minute = strcat ('0', minute);
    end
    if size(hour,2) == 1
        hour = strcat ('0', hour);
    end
    
    labelX{t} = strcat(hour, ':', minute);
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

    t = all_temperature(k);
    c = all_core_regions(k);
    g = all_cover_regions(k);
    l = all_lightning(k);
    
    
    set(temp_plot, 'XData', lns, 'YData', lts, 'CData', t{1});
    
    for region = c{:}
        border_lats = lts(region.border(:,1));
        border_lons = lns(region.border(:,2));
        
        if any(all([(border_lats < -38) (border_lons < -66)],2)) ||...
            any(all([(border_lats < -38) (border_lons < -64)],2)) ||...
            any(all([(border_lats < -40) (border_lons < -60)],2))
            continue
        end
        if region.region_area < area_threshold
            continue
        end
        % concatenate lightning
        region_pos = [region_pos; region.pos_light];
        region_neg = [region_neg; region.neg_light];
        region_pixels_core = [region_pixels_core; region.pixels];
        region_labels_core = [region_labels_core; [region.bounds(1,2) region.bounds(1,1) str2double(region.label)]];
        
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
    
    for region = g{:}
        border_lats = lts(region.border(:,1));
        border_lons = lns(region.border(:,2));
        
%         if any(all([(border_lats < -38) (border_lons < -66)],2)) ||...
%             any(all([(border_lats < -38) (border_lons < -64)],2)) ||...
%             any(all([(border_lats < -40) (border_lons < -60)],2))
%             continue
%         end
%         if region.region_area < area_threshold
%             continue
%         end
        % concatenate lightning
%         region_pos = [region_pos; region.pos_light];
%         region_neg = [region_neg; region.neg_light];
        region_pixels_cover = [region_pixels_cover; region.pixels];
        region_labels_cover = [region_labels_cover; [region.bounds(1,2) region.bounds(1,1) str2double(region.label)]];
        
%         ntpos3 = histc(region_pos(:,3),Ts2);
%         ntpos3 =  ntpos3(:);
%         ntneg3 = histc(region_neg(:,3),Ts2);
%         ntneg3 =  ntneg3(:);
%         nttot3 = ntpos3 + ntneg3;

        % Concatenate the current histogram vector into a matrix (used to create the spectrogram image)

%         temptimepos3(:,k) = ntpos3;
%         temptimeneg3(:,k) = ntneg3;
%         temptimetot3(:,k) = nttot3;
%         
%         ind = str2double(region.label);
%         area(ind,k) = region.region_area;
    end
    
    if ~isempty(region_pixels_cover) && plot_all
        set(cover_plot, 'XData', lns(region_pixels_cover(:,2)), 'YData', lts(region_pixels_cover(:,1)));
        delete(labels_plot_cover)
        labels_plot_cover = text(lns(region_labels_cover(:,2)), lts(region_labels_cover(:,1)), num2str(region_labels_cover(:,3)), 'FontSize',16);    
    end

    if ~isempty(region_pixels_core) && plot_all
        l{1} = l{1}(l{1}(:,3) <= -52,:);
        l{1} = setdiff(l{1},region_pos, 'rows');
        l{1} = setdiff(l{1},region_neg, 'rows');

        set(lightning_plot_out, 'XData', lns(l{1}(:,2)), 'YData', lts(l{1}(:,1)));        
        set(lightning_plot_pos, 'XData', lns(region_pos(:,2)), 'YData', lts(region_pos(:,1)));
        set(lightning_plot_neg, 'XData', lns(region_neg(:,2)), 'YData', lts(region_neg(:,1)));

        set(core_plot, 'XData', lns(region_pixels_core(:,2)), 'YData', lts(region_pixels_core(:,1)));
        delete(labels_plot_core)
        labels_plot_core = text(lns(region_labels_core(:,2)), lts(region_labels_core(:,1)), num2str(region_labels_core(:,3)), 'FontSize',16);
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
    
    if k == size(all_core_regions,2)
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
h10 = pcolor(1:size(xtick_histogram,2), Ts2(1,:), temptimepos2);
set(h10, 'EdgeColor', 'none')
% h10 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimepos2);
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
h13 = pcolor(1:size(xtick_histogram,2), Ts2(1,:), temptimepos2);
set(h13, 'EdgeColor', 'none')

% h13 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimepos3);
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
% imagesc([xtick_histogram(1,1) xtick_histogram(1,end)], [Ts2(1,1) Ts2(1,end)], temptimeneg2);
subplot(4,2,4)
h14 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimeneg3);
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

% h12 = imagesc([xtick_histogram(1,1) xtick_histogram(1,end)], [Ts2(1,1) Ts2(1,end)], temptimetot2);
subplot(4,2,5)
h12 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimetot2);
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
% h15 = imagesc([xtick_histogram(1,1) xtick_histogram(1,end)], [Ts2(1,1) Ts2(1,end)], temptimetot2);
h15 = imagesc(1:size(xtick_histogram,2),Ts2(1,:), temptimetot3);
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
