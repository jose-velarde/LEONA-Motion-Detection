%% Preallocate some variables
if ~exist('setup_isolated_areas', 'var')
    setup_isolated_areas = true;
    
    prev_labels(500) = struct('label', '', 'centroid', [], 'pixels', [], 'region_area',...
        0, 'minimum_temp', 0, 'min_temp_coord', [], 'mean_temp', 0, 'border', [],...
        'pos_light', [], 'neg_light', [], 'distance', 0);
    label_id = 1;
    
    prev_labels2(500) = struct('label', '', 'centroid', [], 'pixels', [], 'region_area',...
    0, 'minimum_temp', 0, 'min_temp_coord', [], 'mean_temp', 0, 'border', [],...
        'pos_light', [], 'neg_light', [], 'distance', 0);
    label_id2 = 1;
    
    prev_labels3(500) = struct('label', '', 'centroid', [], 'pixels', [], 'region_area',...
        0, 'minimum_temp', 0, 'min_temp_coord', [], 'mean_temp', 0, 'border', [],...
        'pos_light', [], 'neg_light', [], 'distance', 0);
    label_id3 = 1;
    
end
legends = {'Region, Pixels, Area, Dist'};

%% Process current time
date_time = strcat(YYYY{index},'-', MM{index},'-', DD{index},'-', hh{index},':', mm{index});

%%
% Set temperatures values to match a color in the imagesc
tempLabels = couttemp;
couttemp(couttemp >= T_cover) = warm_mask;
couttemp(couttemp <= T_cover & couttemp >= T_core) = T_cover_mask;
couttemp(couttemp <= T_core & couttemp >= T_most) = T_core_mask;
couttemp(couttemp <= T_most) = T_most_mask;
% set(couttemp_plot, 'XData', lns, 'YData', lts, 'CData', couttemp);

%% Plot all tcover
[tcover_lats, tcover_lons] = find(couttemp == T_cover_mask);

if ktt_aux == 1
    tcover_plot = plot(lns(tcover_lons), lts(tcover_lats), '.k', 'Color', tcoverOut_color);
else
    set(tcover_plot, 'XData', lns(tcover_lons), 'YData', lts(tcover_lats))
    uistack(tcover_plot, 'top')
end
%% T_Cover

if strcmp(t_cover, 'Yes')
    [CC2] = label_and_filter_custom(tempLabels, lts, lns, T_cover, min_pix_cover, origin, dist_cover);
    [current_labels2, label_id2] = get_regions_custom(prev_labels2, label_id2, CC2, tempLabels);

    for current_region2 = current_labels2(~cellfun(@isempty, {current_labels2.label}))
        current_label = str2double(current_region2.label);

        label_already_in = label_in_labels(current_label, prev_labels2);

        if label_already_in
            set(region_plot2(current_label), 'XData', lns(current_region2.pixels(:, 2)), 'YData', lts(current_region2.pixels(:, 1)))
            uistack(region_plot2(current_label), 'top')
        else
            region_plot2(current_label) = plot(lns(current_region2.pixels(:, 2)), lts(current_region2.pixels(:, 1)), '.k', 'Color', tcoverIn_color);
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
                'Position', [lns( current_region2.bounds(1)) lts(current_region2.bounds(2), 1)], ...
                'visible', 'on');
            uistack(region_plot_label2(current_label), 'top')
        else
            region_plot_label2(current_label) = text(lns(current_region2.bounds(1)), ...
                lts(current_region2.bounds(2), 1), ...
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
        current_region2.region_area = getAreaRectaangularProj(current_region2.pixels, lns, lts);
        current_labels2(current_label).region_area = current_region2.region_area;
        
        distance = deltaAngleToArc(lts(current_region2.centroid(2)), lns(current_region2.centroid(1)), ...
            origin(2), origin(1));
        current_labels2(current_label).distance = distance;


        distance = deltaAngleToArc(lts(current_region2.centroid(2)), lns(current_region2.centroid(1)), ...
            origin(2), origin(1));
        legends{end+1}= sprintf('G%03d, %10d, %10.0f km2, %10.0f km\n', current_label2, total_pixels, current_region2.region_area, distance);

        fprintf(fileID ,'%10s, G%03d, %6d, %6.0f, %6.0f, %6.2f, %3i %3i, %6.2f\n',...
            date_time, current_label2, total_pixels, current_region2.region_area, distance,...
            current_region2.minimum_temp, current_region2.min_temp_coord, current_region2.mean_temp);
    end

    prev_labels2 = current_labels2;

end

%% Plot all tcore
[tcore_lats, tcore_lons] = find(couttemp == T_core_mask);

if ktt_aux == 1
    tcore_plot = plot(lns(tcore_lons), lts(tcore_lats), '.k', 'Color', tcoreOut_color);
else
    set(tcore_plot, 'XData', lns(tcore_lons), 'YData', lts(tcore_lats))
    uistack(tcore_plot, 'top')
end
%% T_Core

if strcmp(t_core, 'Yes')
    [CC] = label_and_filter_custom(tempLabels, lts, lns, T_core, min_pix_core, origin, dist_core);
    [current_labels, label_id] = get_regions_custom(prev_labels, label_id, CC, tempLabels);
    %% Draw regions
    for current_region = current_labels(~cellfun(@isempty, {current_labels.label}))
        current_label = str2double(current_region.label);

        label_already_in = label_in_labels(current_label, prev_labels);

        if label_already_in
            set(region_plot(current_label), 'XData', lns(current_region.pixels(:, 2)), 'YData', lts(current_region.pixels(:, 1)))
            uistack(region_plot(current_label), 'top')
        else
            region_plot(current_label) = plot(lns(current_region.pixels(:, 2)), lts(current_region.pixels(:, 1)), '.k', 'Color', tcoreIn_color);
        end

    end
    %% Delete non-existant regions
    for previous_region = prev_labels(~cellfun(@isempty, {prev_labels.label}))
        prev_label = str2double(previous_region.label);

        label_already_in = label_in_labels(prev_label, current_labels);

        if ~label_already_in
            set(region_plot(prev_label), 'visible', 'off')
            delete(region_plot(prev_label))
        end

    end
    %% Put labels
    for current_region = current_labels(~cellfun(@isempty, {current_labels.label}))
        current_label = str2double(current_region.label);

        label_already_in = label_in_labels(current_label, prev_labels);

        if label_already_in
            set(region_plot_label(current_label), ...
                'Position', ...
                [lns( current_region.bounds(1) + current_region.bounds(3) - 1) lts(current_region.bounds(2) + current_region.bounds(4) -1, 1)], ...
                'visible', 'on');
            uistack(region_plot_label(current_label), 'top')
        else
            region_plot_label(current_label) = text(lns(current_region.bounds(1) + current_region.bounds(3) - 1), ...
                lts(current_region.bounds(2) + current_region.bounds(4) - 1, 1), ...
                strcat('c', current_region.label), 'color', 'black', 'FontSize', 17);
        end

    end
    %% Delete non-existant labels
    for previous_region = prev_labels(~cellfun(@isempty, {prev_labels.label}))
        prev_label = str2double(previous_region.label);

        label_already_in = label_in_labels(prev_label, current_labels);

        if ~label_already_in
            set(region_plot_label(prev_label), 'visible', 'off');
            delete(region_plot_label(prev_label))
        end

    end

    %% Area calculation
    for current_region = current_labels(~cellfun(@isempty, {current_labels.label}))
        current_label = str2double(current_region.label);
        
        [total_pixels, trash] = size(current_region.pixels(:,2));
        current_region.region_area = getAreaRectaangularProj(current_region.pixels, lns, lts);
        current_labels(current_label).region_area = current_region.region_area;
        
        distance = deltaAngleToArc(lts(current_region.centroid(2)), lns(current_region.centroid(1)), ...
            origin(2), origin(1));
        
        current_labels(current_label).distance = distance;

        legends{end+1} = sprintf('C%03d, %10d, %10.0f km2, %10.0f km\n', current_label, total_pixels, current_region.region_area, distance);

        fprintf(fileID,'%10s, C%03d, %6d, %6.0f, %6.0f, %6.2f, %3i %3i, %6.2f\n',...
            date_time, current_label, total_pixels, current_region.region_area, distance, ...
            current_region.minimum_temp, current_region.min_temp_coord, current_region.mean_temp);

    end
    
    prev_labels = current_labels;
end

%% Plot all T most convective
[tmost_lats, tmost_lons] = find(couttemp == T_most_mask);

if ktt_aux == 1
%     tmost_plot = plot(lns(tmost_lons), lts(tmost_lats), '.k', 'Color', tmostOut_color);
    tmost_plot = plot(lns(1), lts(1), '.k', 'Color', tmostOut_color);
else
    set(tmost_plot, 'XData', lns(tmost_lons), 'YData', lts(tmost_lats))
    uistack(tmost_plot, 'top')
end
%% T most convective

if strcmp(t_most, 'Yes')
    [CC3] = label_and_filter_custom(tempLabels, lts, lns, T_most, min_pix_most, origin, dist_most);
    [current_labels3, label_id3] = get_regions_custom(prev_labels3, label_id3, CC3, tempLabels);

    for current_region = current_labels3(~cellfun(@isempty, {current_labels3.label}))
        current_label = str2double(current_region.label);

        label_already_in = label_in_labels(current_label, prev_labels3);

        if label_already_in
            set(region_plot3(current_label), 'XData', lns(current_region.pixels(:, 2)), 'YData', lts(current_region.pixels(:, 1)))
            uistack(region_plot3(current_label), 'top')
        else
            region_plot3(current_label) = plot(lns(current_region.pixels(:, 2)), lts(current_region.pixels(:, 1)), '.k', 'Color', tmostIn_color);
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
                [lns( current_region.bounds(1) + current_region.bounds(3) - 1) lts(current_region.bounds(2) + current_region.bounds(4) -1, 1)], ...
                'visible', 'on');
            uistack(region_plot_label3(current_label), 'top')
        else
            region_plot_label3(current_label) = text(lns(current_region.bounds(1) + current_region.bounds(3) - 1), ...
                lts(current_region.bounds(2) + current_region.bounds(4) -1, 1), ...
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
        
        current_region.region_area = getAreaRectaangularProj(current_region.pixels, lns, lts);
        current_labels3(current_label).region_area = current_region.region_area;

        distance = deltaAngleToArc(lts(current_region.centroid(2)), lns(current_region.centroid(1)), ...
            origin(2), origin(1));
        current_labels3(current_label).distance = distance;

        legends{end+1} = sprintf('M%03d, %10d, %10.0f km2, %10.0f km\n', current_label, total_pixels, current_region.region_area, distance);

        fprintf(fileID,'%10s, M%03d, %6d, %6.0f, %6.0f, %6.2f, %3i %3i, %6.2f\n',...
            date_time, current_label, total_pixels, current_region.region_area, distance,...
            current_region.minimum_temp, current_region.min_temp_coord, current_region.mean_temp);
    end

    prev_labels3 = current_labels3;
end

legends_handler = legend(legends(:), 'location', 'northeastoutside');
set(cb3, 'visible', 'off')
% pause(0.01)
couttemp = tempLabels;
