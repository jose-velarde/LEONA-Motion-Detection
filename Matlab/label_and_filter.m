function [CC, L] = label_and_filter(temp, lats, lons, T, size, origin, distance)
% Set data as 0 or 1, 1 being pixels above the threshold
coreTemp = temp;
coreTemp(coreTemp <= T) = 1;
coreTemp(coreTemp ~= 1) = 0;


%% Look for isolated regions smaller than 300 pixels and 1000 km away or less
CC = bwconncomp(coreTemp);
CC.PixelIdxList(cellfun(@numel, CC.PixelIdxList) < size) = [];
CC.NumObjects = numel(CC.PixelIdxList);

regions_info = regionprops(CC, 'basic');
for i = 1:CC.NumObjects
    distance_to_station = haversineDist(lats(round(regions_info(i).Centroid(2))),...
        lons(round(regions_info(i).Centroid(1))),...
        origin(2), ...
        origin(1));
    
    if distance_to_station > distance
        CC.PixelIdxList{i} = [];
    end
end
CC.NumObjects = numel(CC.PixelIdxList);

%% Labeling
L = labelmatrix(CC);

end