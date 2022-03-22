function [CC] = label_and_filter_custom_old(temp, lats, lons, T, region_area, origin, distance)
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

% [lat_row, lon_col] = find(temp <= T);
% lat_lon = [lat_row lon_col];
% while ~isempty(lat_lon)
% 
%     if lat_lon(end,1) < origin_i(2)+distance && ...
%             lat_lon(end,2) < origin_i(1)+distance && ...
%             lat_lon(end,1) > origin_i(2)-distance && ...
%             lat_lon(end,2) > origin_i(1)-distance
%         [list_pix, border_pix] = floodFillScanlineStack(lat_lon(end,2), lat_lon(end,1), temp(lat_lon(end,1), lat_lon(end,2)), T, temp, lons, lats, fig, writerObj);
%         if ~isempty(list_pix)
%             j = j + 1;
%             for i = 1:length(list_pix(:,1))
%                 temp(list_pix(i,1),list_pix(i,2)) = 0;
%             end
%             CC.PixelIdxList{j} = list_pix;
%             CC.Border{j} = border_pix;
%         end
%         lat_lon = setdiff(lat_lon, list_pix, 'rows');
%     else
%         lat_lon(end,:) = [];
%     end
% end
% if ~isempty(CC.PixelIdxList)
%     CC.PixelIdxList(cellfun(@numel, CC.PixelIdxList) < region_area*2) = [];
% end
% CC.NumObjects = size(CC.PixelIdxList,2);
% end

for lat_row = 1:length(lats)
    for lon_col = 1:length(lons)
        if temp(lat_row, lon_col) <= T && ...
                lat_row < origin_i(2)+distance && ...
                lon_col < origin_i(1)+distance && ...
                lat_row > origin_i(2)-distance && ...
                lon_col > origin_i(1)-distance
            [list_pix, border_pix] = floodFillScanlineStack(lon_col, lat_row, temp(lat_row, lon_col), T, temp, lons, lats, fig, writerObj);

            if ~isempty(list_pix)
                j = j + 1;
                for i = 1:length(list_pix(:,1))
                    temp(list_pix(i,1),list_pix(i,2)) = 0;
                end
                CC.PixelIdxList{j} = list_pix;
                CC.Border{j} = border_pix;
            end
%         elseif isnan(temp(lat_row, lon_col))
%                 list_pix = NaNfloodFillScanlineStack(lon_col, lat_row, temp(lat_row, lon_col), T, temp, lons, lats, fig, writerObj);
%                 if ~isempty(list_pix)
%                     j = j + 1;
%                     for i = 1:length(list_pix(:,1))
%                         temp(list_pix(i,1),list_pix(i,2)) = 0;
%                     end
%                     CC.PixelIdxList{j} = list_pix;
%                 end
        end
        
    end
    
end

if ~isempty(CC.PixelIdxList)
    CC.PixelIdxList(cellfun(@numel, CC.PixelIdxList) < region_area*2) = [];
end
CC.NumObjects = size(CC.PixelIdxList,2);

end