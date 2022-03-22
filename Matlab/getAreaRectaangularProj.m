function Area = getAreaRectaangularProj(list_pix, lns, lts)
% dArea = zeros(10000,1);
list_pix = sortrows(list_pix,1);
Area = 0;
w = size(lns,1);
h = size(lts,1);
% distance between lats is always the same
if list_pix(1,1) >= 1 && list_pix(1,1) ~= h
    dlat = deltaAngleToArc(lts(list_pix(1,1)),lns(list_pix(1,2)),...
        lts(list_pix(1,1)+1),lns(list_pix(1,2)));
elseif list_pix(1,1) == h
    dlat = deltaAngleToArc(lts(list_pix(1,1)),lns(list_pix(1,2)),...
        lts(list_pix(1,1)-1),lns(list_pix(1,2)));
end
% distance between lons has to be calculated every new lat

prev_lat = lts(list_pix(1,1));
if list_pix(1,2) >= 1 && list_pix(1,2) ~= w
    dlon = deltaAngleToArc(prev_lat, lns(list_pix(1,2)),...
        prev_lat, lns(list_pix(1,2)+1));
elseif list_pix(1,2) == w
    dlon = deltaAngleToArc(prev_lat, lns(list_pix(1,2)),...
        prev_lat, lns(list_pix(1,2)-1));
end

for i = 1 : size(list_pix,1)
    current_lat = lts(list_pix(i,1));
    if current_lat ~= prev_lat
%         dlon = deltaAngleToArc(current_lat, lns(list_pix(1,2)),...
%             current_lat ,lns(list_pix(1,2)+1));

        if list_pix(1,2) == 1
            dlon_to_next = deltaAngleToArc(current_lat, lns(list_pix(1,2)),...
                current_lat ,lns(list_pix(1,2)+1));
            dlon = dlon_to_next;
        end
        
        if list_pix(1,2) == w
            dlon_to_prev = deltaAngleToArc(current_lat, lns(list_pix(1,2)),...
                current_lat ,lns(list_pix(1,2)-1));
            dlon = dlon_to_prev;
        end

        if list_pix(1,2) ~= 1 && list_pix(1,2) ~= w 
            dlon_to_prev = deltaAngleToArc(current_lat, lns(list_pix(1,2)),...
                current_lat ,lns(list_pix(1,2)-1));

            dlon_to_next = deltaAngleToArc(current_lat, lns(list_pix(1,2)),...
                current_lat ,lns(list_pix(1,2)+1));

            dlon = (dlon_to_prev + dlon_to_next ) / 2;
        end
        
        prev_lat = current_lat;
    end
    Area = Area + dlon *dlat;
%     dArea(i) = dlon *dlat;
end
% Area = sum(dArea);
