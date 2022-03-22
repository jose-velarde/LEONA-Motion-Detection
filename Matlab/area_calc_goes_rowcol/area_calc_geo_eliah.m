%% Area calculation (Eliah)

% First need to calculate for each pixel dlat and dlon
% then the correspondent distance and multiply to get the area.
% Use dlat = ( (lat - lat(k-1)) + (lat(k+1)-lat) )/2

% Momentarly redefine outlat and outlon to include:
% 1 row before first row and 1 after last row and
% calculate dlat
outlat = latarray(frow-1:lrow+1,fcol:lcol);
[nr nc] = size(outlat);
dlat = zeros(nr-2,nc);
ddistlat = dlat;
for kc=1:nc
    k=1;
    for kr=2:nr-1
        dlat(k,kc) = ( abs(outlat(kr,kc) - outlat(kr-1,kc)) + abs(outlat(kr+1,kc) - outlat(kr,kc)) )/2;
        ddistlat(k,kc) = dlat(k,kc)*6378*(pi/180); % convert dlat in degrees into
        k=k+1;                                     % dist. in km on the great cicle path
    end
end

% Return to original definition
outlat(1,:) = [];
outlat(end,:) = [];

% Calculate dlon = ( (lon- lon(k-1)) + (lon(k+1)-lon) )/2
% Include 1 col before first col and 1 after last
outlon = lonarray(frow:lrow,fcol-1:lcol+1);
[nr nc] = size(outlon);
dlon = zeros(nr,nc-2);
ddistlon = dlon;
for kr=1:nr
    k = 1;
    for kc=2:nc-1
        dlon(kr,k) = ( abs(outlon(kr,kc)-outlon(kr,kc-1)) + abs(outlon(kr,kc+1)-outlon(kr,kc)) )/2;
        ddistlon(kr,k) = dlon(kr,k)*6378*(pi/180)*cos(outlat(kr,kc-1)*(pi/180)); % convert dlon
        k = k+1;                                                                % in degrees into dist. in km on the latitude cicle
    end
end

% Return to original definition (delete de 1st and last column)
outlon(:,1) = [];
outlon(:,end) = [];
[nr nc] = size(outlon);

% (differential) area (dA) of each pixel
dA = ddistlat.*ddistlon;

stormarea = 0;
for k=1:size(list_pix,1)
    stormarea = stormarea + sum(sum(dA(list_pix(k,1),list_pix(k,2))));
end
fprintf('Eliah: Area is %f km2\n', stormarea);
