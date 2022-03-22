function distance = haversineDist(lat1, lon1, lat2, lon2)
% Haversine formula:	
% a = sin^2 (dPhi/2) + cos phi1 * cos phi2 * sin^2(dLambda/2)
% c = 2 * atan2( sqrt(a), sqrt(1-a) )
% d = R * c
% where	phi is latitude, lambda is longitude, R is earth's radius (mean radius = 6,371km);
% note that angles need to be in radians to pass to trig functions!

	R = 6378; % km
	phi1 = lat1 * pi/180; % phi, lambda in radians
	phi2 = lat2 * pi/180;
	dPhi = (lat2-lat1) * pi/180;
	dLambda = (lon2-lon1) * pi/180;
	a = sin(dPhi/2) * sin(dPhi/2) + cos(phi1) * cos(phi2) * sin(dLambda/2) * sin(dLambda/2);
	c = 2 * atan2(sqrt(a), sqrt(1-a));
	distance = R * c; % km
end