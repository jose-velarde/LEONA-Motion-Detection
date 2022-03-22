function [regions, id] = get_regions_custom(regions, id, CC, temp)

regions_info = struct('Centroid',[], 'BoundingBox',[],'Border',[], 'MinimumTemperature',0,'MinTempCoordinates', [],'MeanTemperature',0);

found_regions = 1:CC.NumObjects;

temporal = zeros(length(found_regions),2,'double');
for i = found_regions
    rows = unique(CC.PixelIdxList{i}(:,1));
    cols = unique(CC.PixelIdxList{i}(:,2));
    rows_size = size(rows, 1);
    cols_size = size(cols, 1);
    
%     min_temp = 0;
%     for j = 1:size(CC.PixelIdxList{i},1)
%         current_temp = temp(CC.PixelIdxList{i}(j,1),CC.PixelIdxList{i}(j,2));
%         if  current_temp <= min_temp
%             min_temp = current_temp;
%             min_temp_coordinates = CC.PixelIdxList{i}(j,:);
%         end
%     end
    I = sub2ind(size(temp),CC.PixelIdxList{i}(:,1),CC.PixelIdxList{i}(:,2));
    
    [min_temp, min_t_index] = min(temp(I));
    [min_temp_coordinates(1), min_temp_coordinates(2)] = ind2sub(size(temp),I(min_t_index));
    
    bb = boundary(CC.PixelIdxList{i}(:,1), CC.PixelIdxList{i}(:,2),1);
%     plot(CC.PixelIdxList{1}(bb,1),CC.PixelIdxList{1}(bb,2))
    regions_info(i).Border = [CC.PixelIdxList{i}(bb,1) CC.PixelIdxList{i}(bb,2)];
    
    regions_info(i).MinimumTemperature = min_temp;
    regions_info(i).MinTempCoordinates = min_temp_coordinates;
    regions_info(i).MeanTemperature = mean(temp(I));
    regions_info(i).Centroid = [min(cols)+floor(cols_size/2) min(rows)+floor(rows_size/2)];
    regions_info(i).BoundingBox = [min(cols) min(rows) cols_size rows_size];
    
    temporal(i,:) = [double(i)  size(CC.PixelIdxList{i},1)];
end
B = double(sortrows(temporal, -2));

if isempty([regions(:).label])
    for i = B(:,1)'
        if isempty(i)
            continue
        end
        
        regions(id).pixels = CC.PixelIdxList{i};
        regions(id).centroid = regions_info(i).Centroid;
        regions(id).bounds = regions_info(i).BoundingBox;
        regions(id).label = num2str(id);
        regions(id).minimum_temp = regions_info(i).MinimumTemperature;
        regions(id).min_temp_coord = regions_info(i).MinTempCoordinates;
        regions(id).mean_temp = regions_info(i).MeanTemperature;
        regions(id).border = regions_info(i).Border;

        id = id + 1;
    end
    
else
    current_labels = regions;
    %% Look for existing regions
    for region_g = current_labels(~cellfun(@isempty, {current_labels.label}))
        current_id = str2double(region_g.label);
        label_already_in = false;
        regions_count = found_regions;
        %% Check if region j is less than 10 pixels away any current isolated region
        for l = regions_count
            
            if isempty(l)
                continue
            end
            
            if size(intersect(region_g.border, regions_info(l).Border, 'rows'),1) > 1 && ~label_already_in
%             if max(abs(region_g.centroid - current_centroids{l})) < 10 && ~label_already_in
                regions(current_id).pixels = CC.PixelIdxList{l};
                regions(current_id).centroid = regions_info(l).Centroid;
                regions(current_id).bounds = regions_info(l).BoundingBox;
                regions(current_id).label = num2str(current_id);
                regions(current_id).minimum_temp = regions_info(l).MinimumTemperature;
                regions(current_id).min_temp_coord = regions_info(l).MinTempCoordinates;
                regions(current_id).mean_temp = regions_info(l).MeanTemperature;
                regions(current_id).border = regions_info(l).Border;

                % Remove found region from following checks
                label_already_in = true;
                found_regions(found_regions == l) = [];
                
                
                break
            end
            
        end
        
        %% Remove region
        if ~label_already_in
            regions(current_id).label = [];
        end
        
    end
    
    %% Create new region
    if ~isempty(found_regions)
        
        for k = found_regions
            regions(id).pixels = CC.PixelIdxList{k};
            regions(id).centroid = regions_info(k).Centroid;
            regions(id).bounds = regions_info(k).BoundingBox;
            regions(id).label = num2str(id);
            regions(id).minimum_temp = regions_info(k).MinimumTemperature;
            regions(id).min_temp_coord = regions_info(k).MinTempCoordinates;
            regions(id).mean_temp = regions_info(k).MeanTemperature;
            regions(id).border = regions_info(k).Border;

            id = id + 1;
            
        end
        
    end
    
end