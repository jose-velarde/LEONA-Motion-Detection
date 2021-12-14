%% Figure setup

if ~exist('setup_isolated_areas', 'var')
    setup_isolated_areas = true;
    prev_labels(100) = struct('label', '', 'centroid', [], 'pixels', []);
    current_labels(100) = struct('label', '', 'centroid', []);
    current_centroids = cell(1, 100);
    prev_centroids = cell(1, 100);
    bounds = cell(1,100);
    label_id = 1;

    prev_labels2(100) = struct('label', '', 'centroid', []);
    current_labels2(100) = struct('label', '', 'centroid', []);
    current_centroids2 = cell(1, 100);
    prev_centroids2 = cell(1, 100);
    bounds2 = cell(1,100);
    label_id2 = 1;

end

%% Black and White mask
% Set data as 0 or 1, 1 being pixels above the threshold
T_cover = -32;
T_core = -52;
T_cover_mask = -20;
T_core_mask = -52;
warm_mask = 5;
tempLabels = plottedTemp;
plottedTemp(plottedTemp >= T_cover) = warm_mask;
plottedTemp(plottedTemp <= T_cover & plottedTemp >= T_core) = T_cover_mask;
plottedTemp(plottedTemp <= T_core) = T_core_mask;
set(temp_plot, 'XData', plottedLons, 'YData', plottedLats, 'CData', plottedTemp);
%% T_Cover

pixel_size = 1000;
distance = 1100;
[CC2, L2] = label_and_filter(tempLabels, plottedLats, plottedLons, T_cover, pixel_size,  origin, distance);
regions_info = regionprops(L2, 'basic');

isolatedRegions = unique(L2);
isolatedRegions = isolatedRegions(isolatedRegions~=0);
% if n == 1
%% Plot new regions if none exists
if isempty([prev_labels2(:).label])
    for i = isolatedRegions'
        if isempty(i)
            continue
        end
        [isolated_lats, isolated_lons] = ind2sub(CC2.ImageSize, CC2.PixelIdxList{i});

        isolated_plot2(label_id2) = plot(plottedLons(isolated_lons), plottedLats(isolated_lats), '.k', 'Color', 'red');

        prev_labels2(label_id2).centroid = round(regions_info(i).Centroid);
        prev_labels2(label_id2).bounds = round(regions_info(i).BoundingBox);
        prev_labels2(label_id2).label = num2str(label_id2);


        label_centroid2(label_id2) = text(...
            plottedLons(1, prev_labels2(label_id2).bounds(1)),... 
            plottedLats(prev_labels2(label_id2).bounds(2), 1), ...
            strcat('g', prev_labels2(label_id2).label), 'color', 'black', 'FontSize', 17);
        label_id2 = label_id2 + 1;
    end
    
else
%% Plot existing regions
    current_labels2 = prev_labels2;
    for region_c = current_labels2(~cellfun(@isempty, {current_labels2.label}))
        current_label_id2 = str2double(region_c.label);
        label_already_in = false;

        %% Check if region j is less than 10 pixels away any current isolated region
        for l = isolatedRegions'

            if isempty(l) || l == 0
                continue
            end

            current_centroids{l} = round(regions_info(l).Centroid);
            bounds2{l} = round(regions_info(l).BoundingBox);
            
            %% Find region matching to label_j
            if max(abs(region_c.centroid - current_centroids{l})) < 20 && ~label_already_in
                % Plot region
                [isolated_lats, isolated_lons] = ind2sub(CC2.ImageSize, CC2.PixelIdxList{l});
                set(isolated_plot2(current_label_id2), 'XData', plottedLons(isolated_lons), 'YData', plottedLats(isolated_lats))
                % Plot region label
                set(label_centroid2(current_label_id2), ...
                'Position', ...
                    [plottedLons(1, bounds2{l}(1)) plottedLats(bounds2{l}(2), 1)], ...
                    'visible', 'on');
%                 fprintf('label g%s is the same at %d %d\n', ...
%                     label_j.label, current_centroids{l}(1), current_centroids{l}(2))
                % Remove found region from following checks
                label_already_in = true;
                isolatedRegions(isolatedRegions == l) = [];
                prev_labels2(current_label_id2).centroid = current_centroids{l};
                break
            end

        end

        %% Remove region
        if ~label_already_in
            set(isolated_plot2(current_label_id2), 'visible', 'off')
            delete(isolated_plot2(current_label_id2))
            set(label_centroid2(current_label_id2), 'visible', 'off');
            delete(label_centroid2(current_label_id2))
            prev_labels2(current_label_id2).label = [];
        end

    end

    %% Plot new regions
    if ~isempty(isolatedRegions')

        for k = isolatedRegions'
          [isolated_lats, isolated_lons] = ind2sub(CC2.ImageSize, CC2.PixelIdxList{k});

          isolated_plot2(label_id2) = plot(plottedLons(isolated_lons), plottedLats(isolated_lats), '.k', 'Color', 'red');

          prev_labels2(label_id2).centroid = round(regions_info(k).Centroid);
          prev_labels2(label_id2).bounds = round(regions_info(k).BoundingBox);
          prev_labels2(label_id2).label = num2str(label_id2);


            label_centroid2(label_id2) = text( ...
                plottedLons(1, prev_labels2(label_id2).bounds(1)), ...
                plottedLats(prev_labels2(label_id2).bounds(2), 1), ...
                strcat('g', prev_labels2(label_id2).label), 'color', 'black', 'FontSize', 17);
            label_id2 = label_id2 + 1;
        end

    end

end

legend_array = {};
isolatedRegions = unique(L2);
isolatedRegions = isolatedRegions(isolatedRegions~=0);

for nRegion = isolatedRegions'

    if isempty(isolatedRegions)
        continue
    end

    % find all the pixels of the n region:
    [lat, lon] = find(L2 == nRegion);
    lonlat = [lon lat];
    % distance between lats is always the same
% 
    dArea = size(lonlat, 1) * 4;

    current_centroids{nRegion} = round(regions_info(nRegion).Centroid);

    distance = haversineDist(plottedLats(current_centroids{nRegion}(2)), ...
        plottedLons(current_centroids{nRegion}(1)), ...
        origin(2), ...
        origin(1));

    for region_c = prev_labels2(~cellfun(@isempty, {prev_labels2.label}))
        current_label_id = str2double(region_c.label);

        if max(abs(region_c.centroid - current_centroids{nRegion})) < 30

            legend_array{end + 1} = sprintf('Area#%2d %3.0f km2', current_label_id, dArea);
            fprintf('Pixels: %4d , Area: %6.0f km2, nRegion: g%d, distance: %.0f km\n', size(lonlat, 1), dArea, current_label_id, distance)
        end

    end

end

%% Plot all tcore
[tcore_lats tcore_lons] = find(plottedTemp == T_core_mask);
if n==1
    tcore_plot = plot(plottedLons(tcore_lons), plottedLats(tcore_lats), '.k', 'Color', 'cyan');
else
    set(tcore_plot, 'XData', plottedLons(tcore_lons), 'YData', plottedLats(tcore_lats))
    uistack(tcore_plot, 'top')
end

%% T_Core
pixel_size = 300;
distance = 1000;

[CC, L] = label_and_filter(tempLabels, plottedLats, plottedLons, T_core, pixel_size, origin, 1000);

regions_info = regionprops(L, 'basic');

isolatedRegions = unique(L);
isolatedRegions = isolatedRegions(isolatedRegions~=0);

if isempty([prev_labels(:).label])

    for i = isolatedRegions'
        if isempty(i)
            continue
        end
        [isolated_lats, isolated_lons] = ind2sub(CC.ImageSize, CC.PixelIdxList{i});
        isolated_plot(label_id) = plot(plottedLons(isolated_lons), plottedLats(isolated_lats), '.k', 'Color', 'blue');
        
        prev_labels(label_id).pixels = [isolated_lats, isolated_lons];
        prev_labels(label_id).centroid = round(regions_info(i).Centroid);
        prev_labels(label_id).bounds = round(regions_info(i).BoundingBox);

        prev_labels(label_id).label = num2str(label_id);

        label_centroid(label_id) = text(plottedLons(1, ...
            prev_labels(label_id).bounds(1) + prev_labels(label_id).bounds(3)), ...
            plottedLats(prev_labels(label_id).bounds(2) + prev_labels(label_id).bounds(4) -1, 1), ...
            strcat('c', prev_labels(label_id).label), 'color', 'black', 'FontSize', 17);
        uistack(isolated_plot(label_id), 'top')
        uistack(label_centroid(label_id), 'top')

        label_id = label_id + 1;
    end

else
    current_labels = prev_labels;
    %% Look for existing regions
    for region_g = current_labels(~cellfun(@isempty, {current_labels.label}))
        current_label_id = str2double(region_g.label);
        label_already_in = false;
        regions_count = isolatedRegions;
        %% Check if region j is less than 10 pixels away any current isolated region
        for l = regions_count'

            if isempty(l)
                continue
            end

            current_centroids{l} = round(regions_info(l).Centroid);
            bounds{l} = round(regions_info(l).BoundingBox);
            
            if max(abs(region_g.centroid - current_centroids{l})) < 10 && ~label_already_in
                %% Found matching region to label j
                % Plot region
                [isolated_lats, isolated_lons] = ind2sub(CC.ImageSize, CC.PixelIdxList{l});
                set(isolated_plot(current_label_id), 'XData', plottedLons(isolated_lons), 'YData', plottedLats(isolated_lats))
                % Plot region label
                set(label_centroid(current_label_id), ...
                'Position', ...
                    [plottedLons(1, bounds{l}(1) + bounds{l}(3)) plottedLats(bounds{l}(2) + bounds{l}(4) - 1, 1)], ...
                    'visible', 'on');
%                 fprintf('label c%s is the same at %d %d\n', ...
%                     label_j.label, current_centroids{l}(1), current_centroids{l}(2))
                % Remove found region from following checks
                label_already_in = true;
                isolatedRegions(isolatedRegions == l) = [];
                prev_labels(current_label_id).centroid = current_centroids{l};
                uistack(isolated_plot(current_label_id), 'top')
                uistack(label_centroid(current_label_id), 'top')

                break
            end

        end

        %% Remove region
        if ~label_already_in
            set(isolated_plot(current_label_id), 'visible', 'off')
            delete(isolated_plot(current_label_id))
            set(label_centroid(current_label_id), 'visible', 'off');
            delete(label_centroid(current_label_id))
            prev_labels(current_label_id).label = [];
        end

    end

    %% Create new region
    if ~isempty(isolatedRegions')

        for k = isolatedRegions'
            [isolated_lats, isolated_lons] = ind2sub(CC.ImageSize, CC.PixelIdxList{k});
            isolated_plot(label_id) = plot(plottedLons(isolated_lons), plottedLats(isolated_lats), '.k', 'Color', 'blue');

            prev_labels(label_id).centroid = round(regions_info(k).Centroid);
            prev_labels(label_id).bounds = round(regions_info(k).BoundingBox);
            prev_labels(label_id).label = num2str(label_id);


            label_centroid(label_id) = text( ...
                plottedLons(1, prev_labels(label_id).bounds(1) + prev_labels(label_id).bounds(3)), ...
                plottedLats(prev_labels(label_id).bounds(2) + prev_labels(label_id).bounds(4) - 1, 1), ...
                strcat('c', prev_labels(label_id).label), 'color', 'black', 'FontSize', 17);
            
            uistack(isolated_plot(label_id), 'top')
            uistack(label_centroid(label_id), 'top')
            
            label_id = label_id + 1;

        end

    end

end

prev_labels(~cellfun(@isempty, {prev_labels.label}))

legend_array = {};
isolatedRegions = unique(L);
isolatedRegions = isolatedRegions(isolatedRegions~=0);

for nRegion = isolatedRegions'

    if isempty(isolatedRegions)
        continue
    end

    % find all the pixels of the n region:
    [lat, lon] = find(L == nRegion);
    lonlat = [lon lat];
    % distance between lats is always the same
    dArea = size(lonlat, 1) * 4;

    current_centroids{nRegion} = round(regions_info(nRegion).Centroid);

    distance = haversineDist(plottedLats(current_centroids{nRegion}(2)), ...
        plottedLons(current_centroids{nRegion}(1)), ...
        origin(2), ...
        origin(1));

    for region_g = prev_labels(~cellfun(@isempty, {prev_labels.label}))
        current_label_id = str2double(region_g.label);

        if max(abs(region_g.centroid - current_centroids{nRegion})) < 30

            legend_array{end + 1} = sprintf('Area#%2d %3.0f km2', current_label_id, dArea);
            fprintf('Pixels: %4d , Area: %6.0f km2, nRegion: c%d, distance: %.0f km\n', size(lonlat, 1), dArea, current_label_id, distance)
        end

    end

end
fprintf('\n');
% legends_handler = legend(legend_array(:), 'location', 'southeast');
set(cb, 'visible', 'off')

% waitforbuttonpress
% pause(0.01)
