function [regions, id] = get_regions_custom(regions, id, CC, temp)
% CC contains the newly found regions in the currents satellite scan
% regions contains the regions of the previous scan
% id tracks the total count of found regions
new_region = struct('Centroid',[], 'BoundingBox',[],'Border',[], 'MinimumTemperature',0,'MinTempCoordinates', [],'MeanTemperature',0);

%% Calculate new regions parameters
found_regions = 1:CC.NumObjects;
temp_regions_matrix = zeros(length(found_regions),2,'double');

for i = found_regions
    % Calculate total number of rows and columns
    rows = unique(CC.PixelIdxList{i}(:,1));
    cols = unique(CC.PixelIdxList{i}(:,2));
    rows_size = size(rows, 1);
    cols_size = size(cols, 1);
    % Convert list of pixel pairs to indices
    I = sub2ind(size(temp),CC.PixelIdxList{i}(:,1),CC.PixelIdxList{i}(:,2));
    % Find minimum temperature pixel in the region
    [min_temp, min_t_index] = min(temp(I));
    % Find minimum temperature pixel coordinates
    [min_temp_coordinates(1), min_temp_coordinates(2)] = ind2sub(size(temp),I(min_t_index));
%     % Get border pixels of the region
%     bb = boundary(CC.PixelIdxList{i}(:,1), CC.PixelIdxList{i}(:,2),1);
%     % Save values to region object
%     new_region(i).Border = [CC.PixelIdxList{i}(bb,1) CC.PixelIdxList{i}(bb,2)];
    new_region(i).Border = CC.Border{i};
    
    new_region(i).MinimumTemperature = min_temp;
    new_region(i).MinTempCoordinates = min_temp_coordinates;
    new_region(i).MeanTemperature = mean(temp(I));
    new_region(i).Centroid = [min(cols)+floor(cols_size/2) min(rows)+floor(rows_size/2)];
    new_region(i).BoundingBox = [min(cols) min(rows) cols_size rows_size];
    
    temp_regions_matrix(i,:) = [double(i)  size(CC.PixelIdxList{i},1)];
end
% Sort new regions by size
sorted_regions_matrix = double(sortrows(temp_regions_matrix, -2));
found_regions = sorted_regions_matrix(:,1)';

prev_regions = regions;
%% Look for existing regions
for region_g = prev_regions(~cellfun(@isempty, {prev_regions.label}))
    current_id = str2double(region_g.label);
    label_already_in = false;
    regions_count = found_regions;

    %% Check if region j is less than 10 pixels away any current isolated region
    for l = regions_count
        % 
        if isempty(l)
            continue
        end
        % Don't map prev region to new if the new region contains non-data
        if isnan(temp(CC.PixelIdxList{l}(1,1))) && size(intersect(region_g.border, CC.PixelIdxList{l}, 'rows'),1) > 2 
            label_already_in = true;
            break
        end
        % Map prev scan region to current scan region if borders match
%         if size(intersect(region_g.border, new_region(l).Border, 'rows'),1) > 2 && ~label_already_in
        if size(intersect(region_g.pixels, CC.PixelIdxList{l}, 'rows'),1) > 10 && ~label_already_in
            regions(current_id).pixels = CC.PixelIdxList{l};
            regions(current_id).centroid = new_region(l).Centroid;
            regions(current_id).bounds = new_region(l).BoundingBox;
            regions(current_id).label = num2str(current_id);
            regions(current_id).minimum_temp = new_region(l).MinimumTemperature;
            regions(current_id).min_temp_coord = new_region(l).MinTempCoordinates;
            regions(current_id).mean_temp = new_region(l).MeanTemperature;
            regions(current_id).border = new_region(l).Border;

            % Remove found region from following checks
            label_already_in = true;
            found_regions(found_regions == l) = [];

            break
        end

    end

    %% Remove prev region from current scan if there was no match
    if ~label_already_in
        regions(current_id).label = [];
    end

end

%% Create new region 
if ~isempty(found_regions)

    for k = found_regions
        % Skip region if it contains non-data
        if isnan(temp(CC.PixelIdxList{k}(1,1)))
            continue
        end
        regions(id).pixels = CC.PixelIdxList{k};
        regions(id).centroid = new_region(k).Centroid;
        regions(id).bounds = new_region(k).BoundingBox;
        regions(id).label = num2str(id);
        regions(id).minimum_temp = new_region(k).MinimumTemperature;
        regions(id).min_temp_coord = new_region(k).MinTempCoordinates;
        regions(id).mean_temp = new_region(k).MeanTemperature;
        regions(id).border = new_region(k).Border;

        id = id + 1;

    end

end
    
end