function [regions, id] = get_regions(regions, id, CC, L)
current_centroids = cell(1, 100);
bounds = cell(1,100);

regions_info = regionprops(L, 'basic');

found_regions = unique(L);
found_regions = found_regions(found_regions~=0);
temp = zeros(length(found_regions'),2,'double');
for i = found_regions'
    temp(i,:) = [double(i)  size(CC.PixelIdxList{i},1)];
end
B = double(sortrows(temp, -2));

if isempty([regions(:).label])
    for i = B(:,1)'
%     for i = found_regions'
        if isempty(i)
            continue
        end
        [isolated_lats, isolated_lons] = ind2sub(CC.ImageSize, CC.PixelIdxList{i});
        
        regions(id).pixels = [isolated_lats, isolated_lons];
        regions(id).centroid = round(regions_info(i).Centroid);
        regions(id).bounds = round(regions_info(i).BoundingBox);
        regions(id).label = num2str(id);

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
        for l = regions_count'

            if isempty(l)
                continue
            end

            current_centroids{l} = round(regions_info(l).Centroid);
            bounds{l} = round(regions_info(l).BoundingBox);
            
            if max(abs(region_g.centroid - current_centroids{l})) < 10 && ~label_already_in
                [isolated_lats, isolated_lons] = ind2sub(CC.ImageSize, CC.PixelIdxList{l});
                regions(current_id).pixels = [isolated_lats, isolated_lons];
                regions(current_id).centroid = current_centroids{l};
                regions(current_id).bounds = bounds{l};
                regions(current_id).label = num2str(current_id);
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
    if ~isempty(found_regions')

        for k = found_regions'
            [isolated_lats, isolated_lons] = ind2sub(CC.ImageSize, CC.PixelIdxList{k});
            
            regions(id).pixels = [isolated_lats, isolated_lons];
            regions(id).centroid = round(regions_info(k).Centroid);
            regions(id).bounds = round(regions_info(k).BoundingBox);
            regions(id).label = num2str(id);
            
            id = id + 1;

        end

    end

end