function distance = sphericalLawCosines(lat1, lon1, lat2, lon2)
% Law of cosines formula:
% d = acos(sin phi1 * sin phi2 + cos phi1 * cos phi2 * cos dLambda/2) * R

% where	phi is latitude, lambda is longitude, R is earth's radius (mean radius = 6378km);
% note that angles need to be in radians to pass to trig functions!

	R = 6378; % km
	phi1 = lat1 * pi/180; % phi, lambda in radians
	phi2 = lat2 * pi/180;
	dLambda = (lon2-lon1) * pi/180;
		
	distance = acos(sin(phi1) * sin(phi2)+ cos(phi1) * cos(phi2) * cos(dLambda)) * R; % km
end