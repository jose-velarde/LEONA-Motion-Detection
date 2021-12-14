%% Setup

if ~exist('setup_isolated_areas', 'var')
    setup_isolated_areas = true;
    
    prev_labels(1000) = struct('label', '', 'centroid', [], 'pixels', [], 'area', 0);
%     current_labels(1000) = struct('label', '', 'centroid', [], 'pixels', [], 'area', 0);
    current_centroids = cell(1, 100);
    label_id = 1;
    
    prev_labels2(1000) = struct('label', '', 'centroid', [], 'pixels', [], 'area', 0);
%     current_labels2(1000) = struct('label', '', 'centroid', [], 'pixels', [], 'area', 0);
    current_centroids2 = cell(1, 100);
    label_id2 = 1;
    
    prev_labels3(1000) = struct('label', '', 'centroid', [], 'pixels', [], 'area', 0);
%     current_labels3(1000) = struct('label', '', 'centroid', [], 'pixels', [], 'area', 0);
    current_centroids3 = cell(1, 100);
    label_id3 = 1;
end

legends = {'Region, Pixels, Area, Dist'};
% Set temperatures values to match a color in the imagesc
tempLabels = plottedTemp;
plottedTemp(plottedTemp >= T_cover) = warm_mask;
plottedTemp(plottedTemp <= T_cover & plottedTemp >= T_core) = T_cover_mask;
plottedTemp(plottedTemp <= T_core & plottedTemp >= T_most) = T_core_mask;
plottedTemp(plottedTemp <= T_most) = T_most_mask;
set(temp_plot, 'XData', plottedLons, 'YData', plottedLats, 'CData', plottedTemp);
%% T_Cover

[CC2, L2] = label_and_filter(tempLabels, plottedLats, plottedLons, T_cover, min_pix_cover, origin, dist_cover);
[current_labels2, label_id2] = get_regions(prev_labels2, label_id2, CC2, L2);

for current_region2 = current_labels2(~cellfun(@isempty, {current_labels2.label}))
    current_label = str2double(current_region2.label);
    
    label_already_in = label_in_labels(current_label, prev_labels2);
    
    if label_already_in
        set(region_plot2(current_label), 'XData', plottedLons(current_region2.pixels(:, 2)), 'YData', plottedLats(current_region2.pixels(:, 1)))
        uistack(region_plot2(current_label), 'top')
    else
        region_plot2(current_label) = plot(plottedLons(current_region2.pixels(:, 2)), plottedLats(current_region2.pixels(:, 1)), '.k', 'Color', tcoverIn_color);
    end
    
end

for previous_region2 = prev_labels2(~cellfun(@isempty, {prev_labels2.label}))
    prev_label = str2double(previous_region2.label);
    
    label_already_in = label_in_labels(prev_label, current_labels2);
    
    if ~label_already_in
        set(region_plot2(prev_label), 'visible', 'off')
        delete(region_plot2(prev_label))
    end
    
end

for current_region2 = current_labels2(~cellfun(@isempty, {current_labels2.label}))
    current_label = str2double(current_region2.label);
    
    label_already_in = label_in_labels(current_label, prev_labels2);
    
    if label_already_in
        set(region_plot_label2(current_label), ...
            'Position', ...
            [plottedLons(1, current_region2.bounds(1)) plottedLats(current_region2.bounds(2), 1)], ...
            'visible', 'on');
        uistack(region_plot_label2(current_label), 'top')
    else
        region_plot_label2(current_label) = text(plottedLons(1, ...
            current_region2.bounds(1)), ...
            plottedLats(current_region2.bounds(2), 1), ...
            strcat('g', current_region2.label), 'color', 'black', 'FontSize', 17);
    end
    
end

for previous_region2 = prev_labels2(~cellfun(@isempty, {prev_labels2.label}))
    prev_label = str2double(previous_region2.label);
    
    label_already_in = label_in_labels(prev_label, current_labels2);
    
    if ~label_already_in
        set(region_plot_label2(prev_label), 'visible', 'off');
        delete(region_plot_label2(prev_label))
    end
    
end

for current_region2 = current_labels2(~cellfun(@isempty, {current_labels2.label}))
    current_label2 = str2double(current_region2.label);
    
    [total_pixels, trash] = size(current_region2.pixels(:,2));
    current_region2.area = total_pixels*4;
    
    distance = haversineDist(plottedLats(current_region2.centroid(2)), ...
        plottedLons(current_region2.centroid(1)), ...
        origin(2), ...
        origin(1));
    
%     fprintf('Pixels: %4d , Area: %6.0f km2, nRegion: G%d, distance: %.0f km\n', total_pixels, current_region2.area, current_label2, distance);
    legends{end+1}= sprintf('G%03d, %8d, %8.0f, %8.0f\n', current_label2, total_pixels, current_region2.area, distance);

    fprintf(fileID ,'%10s, G%03d, %6d, %6.0f, %6.0f\n', date_time, current_label2, total_pixels, current_region2.area, distance);
end

prev_labels2 = current_labels2;


%% Plot all tcore
[tcore_lats, tcore_lons] = find(plottedTemp == T_core_mask);

if n == 1
    tcore_plot = plot(plottedLons(tcore_lons), plottedLats(tcore_lats), '.k', 'Color', tcoreOut_color);
else
    set(tcore_plot, 'XData', plottedLons(tcore_lons), 'YData', plottedLats(tcore_lats))
    uistack(tcore_plot, 'top')
end

%% T_Core

[CC, L] = label_and_filter(tempLabels, plottedLats, plottedLons, T_core, min_pix_core, origin, dist_core);

[current_labels, label_id] = get_regions(prev_labels, label_id, CC, L);

for current_region = current_labels(~cellfun(@isempty, {current_labels.label}))
    current_label = str2double(current_region.label);
    
    label_already_in = label_in_labels(current_label, prev_labels);
    
    if label_already_in
        set(region_plot(current_label), 'XData', plottedLons(current_region.pixels(:, 2)), 'YData', plottedLats(current_region.pixels(:, 1)))
        uistack(region_plot(current_label), 'top')
    else
        region_plot(current_label) = plot(plottedLons(current_region.pixels(:, 2)), plottedLats(current_region.pixels(:, 1)), '.k', 'Color', tcoreIn_color);
    end
    
end

for previous_region = prev_labels(~cellfun(@isempty, {prev_labels.label}))
    prev_label = str2double(previous_region.label);
    
    label_already_in = label_in_labels(prev_label, current_labels);
    
    if ~label_already_in
        set(region_plot(prev_label), 'visible', 'off')
        delete(region_plot(prev_label))
    end
    
end

for current_region = current_labels(~cellfun(@isempty, {current_labels.label}))
    current_label = str2double(current_region.label);
    
    label_already_in = label_in_labels(current_label, prev_labels);
    
    if label_already_in
        set(region_plot_label(current_label), ...
            'Position', ...
            [plottedLons(1, current_region.bounds(1) + current_region.bounds(3)) plottedLats(current_region.bounds(2) + current_region.bounds(4) -1, 1)], ...
            'visible', 'on');
        uistack(region_plot_label(current_label), 'top')
    else
        region_plot_label(current_label) = text(plottedLons(1, ...
            current_region.bounds(1) + current_region.bounds(3)), ...
            plottedLats(current_region.bounds(2) + current_region.bounds(4) -1, 1), ...
            strcat('c', current_region.label), 'color', 'black', 'FontSize', 17);
    end
    
end

for previous_region = prev_labels(~cellfun(@isempty, {prev_labels.label}))
    prev_label = str2double(previous_region.label);
    
    label_already_in = label_in_labels(prev_label, current_labels);
    
    if ~label_already_in
        set(region_plot_label(prev_label), 'visible', 'off');
        delete(region_plot_label(prev_label))
    end
    
end


for current_region = current_labels(~cellfun(@isempty, {current_labels.label}))
    current_label = str2double(current_region.label);
    
    [total_pixels, trash] = size(current_region.pixels(:,2));
    current_region.area = total_pixels*4;
    
    distance = haversineDist(plottedLats(current_region.centroid(2)), ...
        plottedLons(current_region.centroid(1)), ...
        origin(2), ...
        origin(1));
%     fprintf('Pixels: %4d , Area: %6.0f km2, nRegion: C%d, distance: %.0f km\n', total_pixels, current_region.area, current_label, distance);
    legends{end+1} = sprintf('C%03d, %8d, %8.0f, %8.0f\n', current_label, total_pixels, current_region.area, distance);
    
    fprintf(fileID,'%10s, C%03d, %6d, %6.0f, %6.0f\n', date_time, current_label, total_pixels, current_region.area, distance);
    
end

prev_labels = current_labels;
%% Plot all T most convective
[tmost_lats, tmost_lons] = find(plottedTemp == T_most_mask);

if n == 1
    tmost_plot = plot(plottedLons(tmost_lons), plottedLats(tmost_lats), '.k', 'Color', tmostOut_color);
else
    set(tmost_plot, 'XData', plottedLons(tmost_lons), 'YData', plottedLats(tmost_lats))
    uistack(tmost_plot, 'top')
end

%% T most convective

[CC3, L3] = label_and_filter(tempLabels, plottedLats, plottedLons, T_most, min_pix_most, origin, dist_most);

[current_labels3, label_id3] = get_regions(prev_labels3, label_id3, CC3, L3);

for current_region = current_labels3(~cellfun(@isempty, {current_labels3.label}))
    current_label = str2double(current_region.label);
    
    label_already_in = label_in_labels(current_label, prev_labels3);
    
    if label_already_in
        set(region_plot3(current_label), 'XData', plottedLons(current_region.pixels(:, 2)), 'YData', plottedLats(current_region.pixels(:, 1)))
        uistack(region_plot3(current_label), 'top')
    else
        region_plot3(current_label) = plot(plottedLons(current_region.pixels(:, 2)), plottedLats(current_region.pixels(:, 1)), '.k', 'Color', tmostIn_color);
    end
    
end

for previous_region = prev_labels3(~cellfun(@isempty, {prev_labels3.label}))
    prev_label = str2double(previous_region.label);
    
    label_already_in = label_in_labels(prev_label, current_labels3);
    
    if ~label_already_in
        set(region_plot3(prev_label), 'visible', 'off')
        delete(region_plot3(prev_label))
    end
    
end

for current_region = current_labels3(~cellfun(@isempty, {current_labels3.label}))
    current_label = str2double(current_region.label);
    
    label_already_in = label_in_labels(current_label, prev_labels3);
    
    if label_already_in
        set(region_plot_label3(current_label), ...
            'Position', ...
            [plottedLons(1, current_region.bounds(1) + current_region.bounds(3)) plottedLats(current_region.bounds(2) + current_region.bounds(4) -1, 1)], ...
            'visible', 'on');
        uistack(region_plot_label3(current_label), 'top')
    else
        region_plot_label3(current_label) = text(plottedLons(1, ...
            current_region.bounds(1) + current_region.bounds(3)), ...
            plottedLats(current_region.bounds(2) + current_region.bounds(4) -1, 1), ...
            strcat('m', current_region.label), 'color', 'black', 'FontSize', 10);
    end
    
end

for previous_region = prev_labels3(~cellfun(@isempty, {prev_labels3.label}))
    prev_label = str2double(previous_region.label);
    
    label_already_in = label_in_labels(prev_label, current_labels3);
    
    if ~label_already_in
        set(region_plot_label3(prev_label), 'visible', 'off');
        delete(region_plot_label3(prev_label))
    end
    
end


for current_region = current_labels3(~cellfun(@isempty, {current_labels3.label}))
    current_label = str2double(current_region.label);
    
    [total_pixels, trash] = size(current_region.pixels(:,2));
    current_region.area = total_pixels*4;
    
    distance = haversineDist(plottedLats(current_region.centroid(2)), ...
        plottedLons(current_region.centroid(1)), ...
        origin(2), ...
        origin(1));
    
%     fprintf('Pixels: %4d , Area: %6.0f km2, nRegion: M%d, distance: %.0f km\n', total_pixels, current_region.area, current_label, distance);
    legends{end+1} = sprintf('M%03d, %8d, %8.0f, %8.0f\n', current_label, total_pixels, current_region.area, distance);
    
    fprintf(fileID,'%10s, M%03d, %6d, %6.0f, %6.0f\n',date_time, current_label, total_pixels, current_region.area, distance);
end

prev_labels3 = current_labels3;


legends_handler = legend(legends(:), 'location', 'northeastoutside');
set(cb, 'visible', 'off')
% pause(0.01)
