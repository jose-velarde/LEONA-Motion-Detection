%% Area calculation Jose

Area = 0;
% lonlat(1,1) = y
% lonlat(1,2) = x
% Replace function to calculate distance between pixels with haversineDist,
% sphericalLawCosines or equirectangularApprox
for i = 1 : size(list_pix,1)
    dlon_prev = deltaAngleToArc(...
        outlat(list_pix(i,1),list_pix(i,2)),... % initial latitude
        outlon(list_pix(i,1),list_pix(i,2)),... % initial longitude
        outlat(list_pix(i,1),list_pix(i,2)),... % initial latitude
        outlon(list_pix(i,1),list_pix(i,2)-1)); % next longitude to the left

    dlon_next = deltaAngleToArc(...
        outlat(list_pix(i,1),list_pix(i,2)),... % initial latitude
        outlon(list_pix(i,1),list_pix(i,2)),... % initial longitude
        outlat(list_pix(i,1),list_pix(i,2)),... % initial latitude
        outlon(list_pix(i,1),list_pix(i,2)+1)); % next longitude to the right

    dlon = (dlon_prev + dlon_next) / 2;

    dlat_prev = deltaAngleToArc(...
        outlat(list_pix(i,1),list_pix(i,2)),...   % initial latitude
        outlon(list_pix(i,1),list_pix(i,2)),...   % initial longitude
        outlat(list_pix(i,1)-1,list_pix(i,2)),... % next latitude above
        outlon(list_pix(i,1),list_pix(i,2)));     % initial longitude

    dlat_next = deltaAngleToArc(...
        outlat(list_pix(i,1),list_pix(i,2)),...   % initial latitude
        outlon(list_pix(i,1),list_pix(i,2)),...   % initial longitude
        outlat(list_pix(i,1)+1,list_pix(i,2)),... % next latitude below
        outlon(list_pix(i,1),list_pix(i,2)));     % initial longitude
    
    dlat = (dlat_prev + dlat_next) / 2;

    Area = Area + dlat*dlon;
end

% equirect eliah (abs(x)+abs(y))*R
% Jose: Pixels: 6640 , Area: 37648.068745 km2
% Eliah: Area is 37648.068745 km2

% equirect sqrt(x*x+y*y)*R
% Jose: Pixels: 6640 , Area: 37648.068745 km2
% Eliah: Area is 37648.068745 km2

% spherical law of cosines
% Jose: Pixels: 6640 , Area: 37648.068670 km2
% Eliah: Area is 37648.068745 km2

% haversine
% Jose: Pixels: 6640 , Area: 37648.068670 km2
% Eliah: Area is 37648.068745 km2