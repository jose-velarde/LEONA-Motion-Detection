function [distanceRefToLoc] = distanceRefToLoc(latRef, lonRef, latLoc, lonLoc)
% Equirectangular approximation: Calculates the distance in Km from Ref to Loc
% x = Delta(lambda)*cos(phi_m)
% y = Delta(phi)
% d = R * sqrt(x^2 + y^2)
% R = 6378
% (pi/180) degree to rad

dLat = abs(latRef - latLoc);
dLon = abs(lonRef - lonLoc);
dDistLat = dLat*6378*(pi/180);                           % convert dlat in degrees into distance in km on the great cicle path
dDistLon = dLon*6378*(pi/180)*cos(latLoc*(pi/180));   % convert dlon in degrees into distance in km on the latitude cicle
distanceRefToLoc = sqrt(dDistLat^2 + dDistLon^2);