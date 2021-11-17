%% DEPRECATED, 1ST VERSION

% need to set data as 0 or 1, 1 being pixels above the threshold

plottedTemp(plottedTemp == -10) = 1;
plottedTemp(plottedTemp == -52) = 1;
plottedTemp(plottedTemp ~= 1) = 0;

% Matrix L contains isolated regions

% tic
% L = bwlabel(plottedTemp,4);
% minPixelArea = 1000;
% for group = 1 : length(unique(L))
%     if nnz(L==group) < minPixelArea
%         L(L==group)=0;
%     end
% end
% bwlab = toc

%% bwconncomp is faster than bwlabel, 0.003 seg to 0.44 seg
% tic
CC = bwconncomp(plottedTemp);
CC.PixelIdxList(cellfun(@numel,CC.PixelIdxList)<1000)=[];
CC.NumObjects=numel(CC.PixelIdxList);
L = labelmatrix(CC);
% bwconn = toc

isolatedRegions = unique(L);
isolatedRegions = isolatedRegions(2:end);
%% Old area, not correct
% tic
% for nRegion = isolatedRegions'
%     % find all the pixels of the n region:
%     [lon,lat] = find(L==nRegion);
%     % [lat,lon]
%     lonlat = [lon lat];
%     dArea = 0;
%     text(plottedLons(1,lonlat(1,2)), plottedLats(lonlat(1,1),1), int2str(nRegion), 'color', 'black', 'FontSize', 16);
%     
%     for i = 1 : size(lonlat)
%         % get distance from [lat(i) lon(i)] to [lat(i+1) lon(i)]
%         try
%             dlat = haversineDist(...
%                 plottedLats(lonlat(i,1),1),...
%                 plottedLons(1,lonlat(i,2)),...
%                 plottedLats(lonlat(i,1)+1,1),...
%                 plottedLons(1,lonlat(i,2)));
%         catch
%             dlat = haversineDist(...
%                 plottedLats(lonlat(i,1),1),...
%                 plottedLons(1,lonlat(i,2)),...
%                 plottedLats(lonlat(i,1),1)+0.0291,...
%                 plottedLons(1,lonlat(i,2)));
%         end
%         % get distance from [lat(i) lon(i)] to [lat(i) lon(i+1)]
%         try
%             dlon = haversineDist(...
%                 plottedLats(lonlat(i,1),1),...
%                 plottedLons(1,lonlat(i,2)),...
%                 plottedLats(lonlat(i,1),1),...
%                 plottedLons(1,lonlat(i,2)+1));
%         catch
%             dlon = haversineDist(...
%                 plottedLats(lonlat(i,1),1),...
%                 plottedLons(1,lonlat(i,2)),...
%                 plottedLats(lonlat(i,1),1),...
%                 plottedLons(1,lonlat(i,2))+0.0291);
%         end
%         % calculate current pixel area as the product between deltas
%         % add each pixel area to the isolated region area
%         dArea = dArea + dlat*dlon;
%     end
%     fprintf('Pixels: %4d , Area: %6.0f km2, nRegion: %d\n',i, dArea, nRegion)
% end
% old_area = toc

tic
for nRegion = isolatedRegions'
    % find all the pixels of the n region:
    [lon,lat] = find(L==nRegion);
    % [lat,lon]
    lonlat = [lon lat];
    dArea = 0;
    text(plottedLons(1,lonlat(1,2)), plottedLats(lonlat(1,1),1), int2str(nRegion), 'color', 'black', 'FontSize', 16);
    
    % distance between lons is always the same
    dlon = haversineDist(...
        plottedLats(lonlat(1,1),1),...
        plottedLons(1,lonlat(1,2)),...
        plottedLats(lonlat(1,1),1),...
        plottedLons(1,lonlat(1,2)+1));
    
    % distance between lats has to be calculated every new lat
    prev_dlat = haversineDist(...
        plottedLats(lonlat(1,1),1),...
        plottedLons(1,lonlat(1,2)),...
        plottedLats(lonlat(1,1),1)+0.0291,...
        plottedLons(1,lonlat(1,2)));
    
    prev_lat = lonlat(1,2);

    for i = 1 : size(lonlat)
        if prev_lat ~= lonlat(i,2)
            prev_lat = lonlat(i,2);
            prev_dlat = haversineDist(...
                plottedLats(lonlat(i,1),1),...
                plottedLons(1,lonlat(i,2)),...
                plottedLats(lonlat(i,1),1)+0.0291,...
                plottedLons(1,lonlat(i,2)));        
        end
        dArea = dArea + prev_dlat*dlon;
    end
    fprintf('Pixels: %4d , Area: %6.0f km2, nRegion: %d\n',i, dArea, nRegion)
end
new_area = toc

plottedTemp(plottedTemp == 1) = -10;

set(temp_plot, 'XData', plottedLons, 'YData', plottedLats, 'CData', plottedTemp);
waitforbuttonpress
