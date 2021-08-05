function [cloudArea] = getCloudArea(startingPixel, lons, lats, temp)
% startingPixel is an array with [lon, lat] in degrees.

lonCoord = startingPixel(1);
latCoord = startingPixel(2);

% Find index of coordinates in the lon and lat data.
% latitude index
[latValue, latIndex] = min(abs(lats - latCoord));
% longitude index
[lonValue, lonIndex] = min(abs(lons - lonCoord));

% if I get the border of a region:
% 000011111100
% 0011XXXXXX10
% 01XXXXXXXX10
% 01XXXXXXXX10
% 01XXXXXXXX10
% 011111111110
display(lons(lonIndex)) ;
display(lats(latIndex)) ;
display(temp(latIndex, lonIndex)); 


