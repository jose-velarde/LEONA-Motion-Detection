function [dlat_geo, dlon_geo, dlat_rect, dlon_rect, dlat_CPTEC, dlon_CPTEC] = getPixelSize(lon_cursor, lat_cursor, coutrows, coutcols, outlat, outlon, outimage, lns, lts, couttemp, plottedLons, plottedLats, plottedTemp)
% geo data: latarray, lonarray, goes
% rect data: lns, lts, couttemp
% CPTEC data: plottedLons, plottedLats, plottedTemp
% pixel data (rect plot) lon_cursor, lat_cursor
%% NOTES
T_threshold = -32;
% step 0.018
% r = 277
% c = 444
% -32.5347
% -32.5527
% (-32.5594, -66.5290)
% -32.5707

%% Get row/col of input in the rectangular projection
[delta_col, col] = min(abs(lns - lon_cursor));
[delta_row, row] = min(abs(lts - lat_cursor));

fprintf('Rectangular projection\n')
lat_rect = lts(row);
lon_rect = lns(col);
temp_rect = couttemp(row, col);
fprintf('lat: %4.2f, lon: %4.2f, temp: %4.2f\n', lat_rect, lon_rect, temp_rect)

dlat_rect = deltaAngleToArc(lat_rect, lon_rect,...
    lat_rect + 0.018,lon_rect);    
dlon_rect = deltaAngleToArc(lat_rect ,lon_rect,...
    lat_rect ,lon_rect + 0.018);
dArea_rect = dlat_rect * dlon_rect;
fprintf('dlat: %4.2f, dlon: %4.2f, dArea: %4.2f\n', dlat_rect, dlon_rect, dArea_rect)

tic
list_pix = floodFillScanlineStack(col, row, couttemp(row, col), T_threshold, couttemp, lts, lns, 1, 1);
Flood_Fill_ScanLine_Stack = toc;

fprintf('%d pixels in %f \n', size(list_pix, 1), Flood_Fill_ScanLine_Stack)
area_calc_rect_jose
fprintf('Rect proj area is %7.6f km2\n', Area)
%%

% to find couttemp(r, c) = outimage(rr, cc)
% coutrows (r,c) -> rr -> coutrows(277, 444) = 207
% coutcols (r,c) -> cc -> coutcols(277, 444) = 339
% lts(r) -> closest lat to lat/lon -> lts(277) = -35.9727
% lns(c) -> closest lon to lat/lon -> lns(444) = -61.0178

% outlat(rr, cc) -> lat (real) ->  outlat(207, 339) = -35.9621
% outlon(rr, cc) -> lon (real) ->  outlat(207, 339) = -61.0075
% outimage(rr, cc) -> couttemp(r, c) -> outimage(207, 339) = 4.0870 = couttemp(277, 444)
fprintf('Geostationary projection\n')

rr = coutrows(row, col);  
cc = coutcols(row, col);

lat_geo = outlat(rr, cc);
lon_geo = outlon(rr, cc);
temp_geo = outimage(rr, cc);
fprintf('lat: %4.2f, lon: %4.2f, temp: %4.2f\n', lat_geo, lon_geo, temp_geo)

dlon_geo_prev = deltaAngleToArc(...
    outlat(rr,cc),... % initial latitude
    outlon(rr,cc),... % initial longitude
    outlat(rr,cc),... % initial latitude
    outlon(rr,cc-1)); % next longitude to the left

dlon_geo_next = deltaAngleToArc(...
    outlat(rr,cc),... % initial latitude
    outlon(rr,cc),... % initial longitude
    outlat(rr,cc),... % initial latitude
    outlon(rr,cc+1)); % next longitude to the right

dlon_geo = (dlon_geo_prev + dlon_geo_next) / 2;

dlat_geo_prev = deltaAngleToArc(...
    outlat(rr,cc),...   % initial latitude
    outlon(rr,cc),...   % initial longitude
    outlat(rr-1,cc),... % next latitude above
    outlon(rr,cc));     % initial longitude

dlat_geo_next = deltaAngleToArc(...
    outlat(rr,cc),...   % initial latitude
    outlon(rr,cc),...   % initial longitude
    outlat(rr+1,cc),... % next latitude below
    outlon(rr,cc));     % initial longitude

dlat_geo = (dlat_geo_prev + dlat_geo_next) / 2;

dArea_geo = dlat_geo*dlon_geo;
    
fprintf('dlat: %4.2f, dlon: %4.2f, dArea: %4.2f\n', dlat_geo, dlon_geo, dArea_geo)
tic
list_pix = floodFillScanlineStack(cc, rr, outimage(rr, cc), T_threshold, outimage, outlon, outlat, 1, 1);
Flood_Fill_ScanLine_Stack = toc;

fprintf('%d pixels in %f \n', size(list_pix, 1), Flood_Fill_ScanLine_Stack)
area_calc_geo_jose
fprintf('Geo proj area is %7.6f km2\n', Area)
    
%%
fprintf('CPTEC projection\n')
[delta_col, col] = min(abs(plottedLons - lon_cursor));
[delta_row, row] = min(abs(plottedLats - lat_cursor));

lat_CPTEC = plottedLats(row);
lon_CPTEC = plottedLons(col);

temp_CPTEC = plottedTemp(row, col);
fprintf('lat: %4.2f, lon: %4.2f, temp: %4.2f\n', lat_CPTEC, lon_CPTEC, temp_CPTEC)


dlat_CPTEC = deltaAngleToArc(lat_CPTEC, lon_CPTEC,...
    lat_CPTEC + 0.0291,lon_CPTEC);    
dlon_CPTEC = deltaAngleToArc(lat_CPTEC ,lon_CPTEC,...
    lat_CPTEC ,lon_CPTEC + 0.0291);
dArea_CPTEC = dlat_CPTEC * dlon_CPTEC;
fprintf('dlat: %4.2f, dlon: %4.2f, dArea: %4.2f\n', dlat_CPTEC, dlon_CPTEC, dArea_CPTEC)

tic
list_pix = floodFillScanlineStack(col, row, plottedTemp(row, col), T_threshold, plottedTemp, plottedLons, plottedLats, 1, 1);
Flood_Fill_ScanLine_Stack = toc;

fprintf('%d pixels in %f \n', size(list_pix, 1), Flood_Fill_ScanLine_Stack)
area_calc_CPTEC_jose
fprintf('CPTEC proj area is %7.6f km2\n', Area)
end

% Rectangular projection
% lat: 34.99, lon: -74.99, temp: -12.81
% dlat: 2.00, dlon: 1.64, dArea: 3.29
% Geostationary projection
% lat: 34.98, lon: -74.99, temp: -12.81
% dlat: 2.75, dlon: 2.08, dArea: 5.70
% CPTEC projection
% lat: 34.99, lon: -75.00, temp: -9.87
% dlat: 3.24, dlon: 2.65, dArea: 8.60

% Rectangular projection
% lat: 0.01, lon: -74.99, temp: 18.34
% dlat: 2.00, dlon: 2.00, dArea: 4.01
% Geostationary projection
% lat: 0.01, lon: -74.99, temp: 18.34
% dlat: 2.02, dlon: 2.00, dArea: 4.04
% CPTEC projection
% lat: -0.01, lon: -75.00, temp: 18.34
% dlat: 3.24, dlon: 3.24, dArea: 10.49

% Rectangular projection
% lat: -55.98, lon: -74.99, temp: -5.44
% dlat: 2.00, dlon: 1.12, dArea: 2.25
% Geostationary projection
% lat: -55.97, lon: -74.98, temp: -5.44
% dlat: 4.93, dlon: 2.18, dArea: 10.72
% CPTEC projection
% lat: -55.99, lon: -75.00, temp: -4.95
% dlat: 3.24, dlon: 1.81, dArea: 5.87
