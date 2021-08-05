% This works perfectly and is fast!

function [stormarea, cr] = n1ewtryareatemp(latarray, lonarray, outimage, frow, lrow, fcol, lcol, T)

% Calculate the area of cloud cover with Tir <= -32oC
% and Tir <= -52oC
% First need to calculate for each pixel dlat and dlon
% then the correspondent distance and multiply to get the area.
% Use dlat = ( (lat - lat(k-1)) + (lat(k+1)-lat) )/2

% Momentarly redifine outlat and outlon to include:
% 1 row before first row and 1 after last row and
% calculate dlat
% outlat = latarray(frow-1:lrow+1,fcol:lcol);
outlat = latarray(fcol-1:lcol+1,frow:lrow);
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
% outlon = lonarray(fcol:lcol,frow-1:lrow+1);

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
% dA = ddistlat.*ddistlon;

% Now calculate the area of pixels within T range of interest

% Test the temperature of pixel at center of region of interest
% and then for adjacent pixels
% centerrow= round(nr/2);
% centercol= round(nc/2);

listpix = zeros(1,2);       % inicialization
pixarea = zeros(1,2);

k = 1;
kp = 1; s = 1;

% Check all neighboors around chosen pixel
display('--->>> Select a region.');
% cr = round(ginput(1));  % returns the X and Y coordinates of the selected point
cr = [2168 757];
% ginput return the lon, lat coordinates, need to find the corresponding col,
% row
% outimage( lon, lat)

% get index of lat lon
[latv, lati] = min(abs(latarray - cr(2)));
[lonv, loni] = min(abs(lonarray - cr(1)));
cr = [loni(1) lati(1)];


while outimage(cr(2),cr(1)) > T
    display('--->>> Select a region.');
    cr = round(ginput(1))  % returns the X and Y coordinates of the selected point
    %     [latv, lati] = min(abs(latarray - cr(2)));
    %     [lonv, loni] = min(abs(lonarray - cr(1)));
    [latv, lati] = min(abs(outlat - cr(2)));
    [lonv, loni] = min(abs(outlon - cr(1)));
    cr = [loni(1) lati(1)]
    outimage(cr(2),cr(1));
end

% v(1,1) = cr(1,2);
% v(1,2) = cr(1,1);
v(1)=cr(2);
v(2)=cr(1);

[pixarea k listpix kp] = newtryneighboors(pixarea, k, listpix, kp, outimage, v, T);

v = listpix(kp-1,:);
listpix(kp-1,:) = [];
kp = kp - 1;

while kp>1 %~isempty(listpix)
    [pixarea k listpix kp] = newtryneighboors(pixarea, k, listpix, kp, outimage, v, T);
    if kp>1
        kp = kp - 1;
        v = listpix(kp,:);
        listpix(kp,:) = [];
    end
    if k>= s*1000 & k<=(s+1)*1000
        ih = k;
        s=s+1;
    end
end

% figure(90)
% imagesc(outimage)
% hold on
plot(pixarea(:,2),pixarea(:,1),'.k');
hold on

stormarea = 0;
for k=1:size(pixarea,1)
    stormarea = stormarea + sum(sum( dA(pixarea(k,1),pixarea(k,2)) ));
end