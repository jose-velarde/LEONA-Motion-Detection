%% Area calculation Jose (haversine) 

lonlat = list_pix;
dArea = 0;
% lonlat(1,1) = y
% lonlat(1,2) = x

% distance between lons is always the same
dlon = haversineDist(...
    lats_goes(lonlat(1,1),lonlat(1,2)),... % initial latitude
    lons_goes(lonlat(1,1),lonlat(1,2)),... % initial longitude
    lats_goes(lonlat(1,1),lonlat(1,2)),... % initial latitude
    lons_goes(lonlat(1,1),lonlat(1,2)+1)); % next longitude to the right

% distance between lats has to be calculated every new lat
prev_dlat = haversineDist(...
    lats_goes(lonlat(1,1),lonlat(1,2)),...   % initial latitude
    lons_goes(lonlat(1,1),lonlat(1,2)),...   % initial longitude
    lats_goes(lonlat(1,1)+1,lonlat(1,2)),... % next latitude above
    lons_goes(lonlat(1,1),lonlat(1,2)));     % initial longitude

for i = 1 : size(lonlat,1)

    prev_dlat = haversineDist(...
            lats_goes(lonlat(i,1),lonlat(i,2)),...   % initial latitude
            lons_goes(lonlat(i,1),lonlat(i,2)),...   % initial longitude
            lats_goes(lonlat(i,1)+1,lonlat(i,2)),... % next latitude above
            lons_goes(lonlat(i,1),lonlat(i,2)));     % initial longitude

    dArea = dArea + prev_dlat*dlon;
end
fprintf('Jose: Pixels: %4d , Area: %6.2f km2\n',i, dArea)