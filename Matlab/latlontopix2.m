
function [r,c] = latlontopix2(lat,lon,latarray,lonarray)

% LatLonToPix2 take lat-lon pairs and compute the corresponding
% pixel coordinates in an image

% input:    lat = latitude
%			lon = longitude
%			latarray = array of image latitudes
%			lonarray = array of image longitudes
% output:   r = row in image where latitude = lat
%			c = column in image where longitude = lon

persistent olat dlat latmin xdlat
persistent olon dlon lonmin xdlon

[rarray carray] = size(latarray);
if isempty(olat) || lat ~= olat
   olat = lat;
   dlat = (latarray - lat); % .^ 2;		% create array of lat variances
   [dum latmin] = min(abs(dlat));	    % find min for each col
   
% Create vector array with pixel coordinates for lat
	xdlat = [latmin; 1:carray]';        % latmin gives rows
end

if isempty(olon) || lon ~= olon 
   olon = lon;
   dlon = (lonarray - lon); % .^ 2;		% create array of lon variances
   [dum lonmin] = min(abs(dlon'));	    % find min for each row
    
% Create vector array with pixel coordinates for lon
	xdlon = [1:rarray; lonmin]';        % lonmin gives colum
end

%To debug check results visually
% plot (xdlat(:,2), xdlat(:,1))
% set(gca,'YDir','reverse')
%hold on
% plot (xdlon(:,2), xdlon(:,1))
% axis([0,700,0,160])
%hold off

u = intersect2(xdlat,xdlon,'rows');
% if size(u,1) > 1
%     u;
%     plot (xdlat(:,2), xdlat(:,1))
%     set(gca,'YDir','reverse')
%     hold on
%     plot (xdlon(:,2), xdlon(:,1))
%     axis([0,700,0,160])
%     hold off
% end
if ~isempty(u),
    r = u(1,1); c = u(1,2);
else
    r = nan; c = nan; beep;
end



