function [CC] = label_and_filter_custom(temp, lats, lons, T, pixels_threshold, origin, distance)
% Tests every pixel to find contiguous regions with temperature below T_threshold
% After finding region j and saving its pixels in CC.PixelIdxList{j}, it continues
% to look for the region j+1
CC = struct('PixelIdxList', [], 'ImageSize', size(temp), 'NumObjects', 0, 'Border', []);

fig = 0;
writerObj = 0;
j = 0;

[origin_lonv, origin_loni] = min(abs(lons - origin(1)));
[origin_latv, origin_lati] = min(abs(lats - origin(2)));
origin_i = [origin_loni origin_lati];
%% Find regions below the threshold
[lat_row, lon_col] = find(temp <= T);

% Test matrix, find continuous regions to these pixels
lat_lon = [lat_row lon_col];
while ~isempty(lat_lon)
    % test if pixel is inside the station observation range
%     if lat_lon(end,1) < origin_i(2)+distance && ...
%             lat_lon(end,2) < origin_i(1)+distance && ...
%             lat_lon(end,1) > origin_i(2)-distance && ...
%             lat_lon(end,2) > origin_i(1)-distance
        % find contiguous pixels
        [list_pix, border_pix] = floodFillScanlineStack(lat_lon(end,2), lat_lon(end,1), temp(lat_lon(end,1), lat_lon(end,2)), T, temp, size(lat_lon,1), fig, writerObj);
        % add found pixels to a region object
%         if ~isempty(list_pix)
            j = j + 1;
            for i = 1:length(list_pix(:,1))
                temp(list_pix(i,1),list_pix(i,2)) = 0;
            end
            CC.PixelIdxList{j} = list_pix;
            CC.Border{j} = border_pix;
%         end
        % remove pixels in the found region from the test matrix
        lat_lon = setdiff(lat_lon, list_pix, 'rows');
%     else
        % pixel not in range, remove it from the test matrix
%         lat_lon(end,:) = [];
%     end
end
%% Find NaN regions

[lat_row, lon_col] = find(isnan(temp));
lat_lon = [lat_row lon_col];
while ~isempty(lat_lon)
    [list_pix, border_pix] = NaNfloodFillScanlineStack(lat_lon(end,2), lat_lon(end,1), temp(lat_lon(end,1), lat_lon(end,2)), T, temp, lons, lats, fig, writerObj);
    if ~isempty(list_pix)
        j = j + 1;
        for i = 1:length(list_pix(:,1))
            temp(list_pix(i,1),list_pix(i,2)) = 0;
        end
        CC.PixelIdxList{j} = list_pix;
        CC.Border{j} = border_pix;

    end
    lat_lon = setdiff(lat_lon, list_pix, 'rows');
end
%%

if ~isempty(CC.PixelIdxList)
    CC.Border(cellfun(@numel, CC.PixelIdxList) < pixels_threshold*2) = [];
    CC.PixelIdxList(cellfun(@numel, CC.PixelIdxList) < pixels_threshold*2) = [];
end
CC.NumObjects = size(CC.PixelIdxList,2);
end

         