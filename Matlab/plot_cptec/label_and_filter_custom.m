function [CC] = label_and_filter_custom(temp, lats, lons, T, region_area, origin, distance)
% label_and_filter_custom(plottedTemp, plottedLats, plottedLons, -32, 500, [-32 -32], 1000)
CC = struct('PixelIdxList', [], 'ImageSize', size(temp), 'NumObjects', 0);
L = struct('Label', 0,'Centroid', [],'BoundingBox', []);
fig = 0;
writerObj = 0;
j = 0;

[origin_lonv, origin_loni] = min(abs(lons - origin(1)));
[origin_latv, origin_lati] = min(abs(lats - origin(2)));
origin_i = [origin_loni origin_lati];

for lat_row = 1:length(lats)
    for lon_col = 1:length(lons)
        if temp(lat_row, lon_col) <= T && ...
                lat_row < origin_i(2)+distance && ...
                lon_col < origin_i(1)+distance && ...
                lat_row > origin_i(2)-distance && ...
                lon_col > origin_i(1)-distance
            list_pix = floodFillScanlineStack(lon_col, lat_row, temp(lat_row, lon_col), T, temp, lons, lats, fig, writerObj);
            %                 fprintf('%.2d %.2d %.2f %.2d \n',lat_row, lon_col, temp(lat_row, lon_col),length(list_pix(:,1)));
            
            if ~isempty(list_pix)
                j = j + 1;
                for i = 1:length(list_pix(:,1))
                    temp(list_pix(i,1),list_pix(i,2)) = 0;
                end
                CC.PixelIdxList{j} = list_pix;
                
            end
            
        end
        
    end
    
end

if ~isempty(CC.PixelIdxList)
    CC.PixelIdxList(cellfun(@numel, CC.PixelIdxList) < region_area*2) = [];
end
CC.NumObjects = size(CC.PixelIdxList,2);

end