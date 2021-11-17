function [stormarea, cr] = area_temp_record(temp, lons, lats, fig, writerObj)

T = inputdlg('Set Temperature Threshold');
T = str2double(T);
cursor_point = ginput;
lon_cursor = cursor_point(1,1);
lat_cursor = cursor_point(1,2);
%         disp([lon_cursor lat_cursor]);
[delta_x,x] = min(abs(lons - lon_cursor));
[delta_y,y] = min(abs(lats - lat_cursor));

while temp(y,x) >= T
    cursor_point = ginput;
    lon_cursor = cursor_point(1,1);
    lat_cursor = cursor_point(1,2);
    [delta_x,x] = min(abs(lons - lon_cursor));
    [delta_y,y] = min(abs(lats - lat_cursor));
    fprintf('Selected pixel is below the threshold: %.2f > %.2f \n',temp(y,x), T)
end
fprintf('Processing...\n')

outimage = temp;
cr = [x y];

listpix = zeros(1,2);
pixarea = zeros(1,2);

k = 1;
kp = 1;
s = 1;

v(1) = cr(2);
v(2) = cr(1);

[pixarea k listpix kp] = newtryneighboors_record(pixarea, k, listpix, kp, outimage, v, T, lons, lats, fig, writerObj );

v = listpix(kp-1,:);
listpix(kp-1,:) = [];
kp = kp - 1;

while kp>1 %~isempty(listpix)
    [pixarea k listpix kp] = newtryneighboors_record(pixarea, k, listpix, kp, outimage, v, T, lons, lats, fig, writerObj);

    if kp>1
        kp = kp - 1;
        v = listpix(kp,:);
        listpix(kp,:) = [];
    end
    if k>= s*1000 && k<=(s+1)*1000
        ih = k;
        s=s+1;
    end
end

% plot(lons(pixarea(:,2)), lats(pixarea(:,1)),'.k', 'Color', 'black');

% dlat = (0.0291)*6378*(pi/180);
dlat = haversineDist( ...
    lats(1, 1), ...
    lons(1, 1), ...
    lats(1, 1) + 0.0291, ...
    lons(1, 1));
dlon=dlat;

area_per_pixel = dlat*dlon;
stormarea = area_per_pixel * size(pixarea,1);
fprintf('lon: %.2f , lat: %.2f , T: %.2f, area: %.2f km2\n',lon_cursor, lat_cursor, T, stormarea)
% for k=1:size(pixarea,1)
%     stormarea = stormarea + sum(sum( dA(pixarea(k,1),pixarea(k,2)) ));
% end
end