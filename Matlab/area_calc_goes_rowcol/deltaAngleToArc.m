function distance = deltaAngleToArc(lat1, lon1, lat2, lon2)
% Equirectangular approx:
% x = dLambda * cos (phi_m)
% y = dPhi
% d = R sqrt(x*x+y*y)

% d = acos(sin phi1 * sin phi2 + cos phi1 * cos phi2 * cos dLambda/2) * R

% where	phi is latitude, lambda is longitude, R is earth's radius (mean radius = 6,371km);
% note that angles need to be in radians to pass to trig functions!

	R = 6378; % km
	dlat_rad = (lat2 - lat1) * pi/180; %  in radians
    dlon_rad = (lon2 - lon1) * pi/180;

    
    y = dlat_rad;
%     x: arc distance from lon1 to lon2 in lat1
%     x = dlon_rad * cos(lat1 * pi/180);
    x = dlon_rad * cos(((lat1+lat2) * pi/180)/2);

    distance = (abs(x)+abs(y))*R; % km
end