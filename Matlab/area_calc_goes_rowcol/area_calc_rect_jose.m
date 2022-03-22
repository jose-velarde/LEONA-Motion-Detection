dArea = zeros(10000,1);
list_pix = sortrows(list_pix,1);

% distance between lats is always the same
dlat = deltaAngleToArc(lts(list_pix(1,1)),lns(list_pix(1,2)),...
    lts(list_pix(1,1)+1),lns(list_pix(1,2)));

% distance between lons has to be calculated every new lat

prev_lat = lts(list_pix(1,1));
dlon = deltaAngleToArc(prev_lat ,lns(list_pix(1,2)),...
    prev_lat ,lns(list_pix(1,2)+1));
for i = 1 : size(list_pix,1)
    current_lat = lts(list_pix(i,1));
    if current_lat ~= prev_lat
%         dlon = deltaAngleToArc(current_lat, lns(list_pix(1,2)),...
%             current_lat ,lns(list_pix(1,2)+1));
        dlon_to_prev = deltaAngleToArc(current_lat, lns(list_pix(1,2)),...
            current_lat ,lns(list_pix(1,2)-1));
        dlon_to_next = deltaAngleToArc(current_lat, lns(list_pix(1,2)),...
            current_lat ,lns(list_pix(1,2)+1));
        dlon = (dlon_to_prev + dlon_to_next ) / 2;
        
        prev_lat = current_lat;
    end
    
    dArea(i) = dlon *dlat;
end
Area = sum(dArea);