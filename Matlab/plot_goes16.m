%% Matlab configuration
% close all
hold off;
beep off;
set(0,'DefaultFigureWindowStyle','docked')
%% Define paths
filepath_nc = 'C:/Users/sauli/Downloads/Soft_Tesis/OpenCV/CPTEC data/201910_nc/';
filenames_nc = dir(filepath_nc);
filename_nc = strcat(filepath_nc, filenames_nc(3).name);
filepath_shp = 'C:\Users\sauli\Downloads\Soft_Tesis\OpenCV\Shapefiles\';
countries_shp = strcat(filepath_shp, 'ne_10m_admin_0_countries.shp');
brstates_shp = strcat(filepath_shp, 'BRA_ADM1.shp');

%% Load netcdf4 file into variables
% Get the latitudes
lats = ncread(filename_nc, 'lat');
% Get the longitudes
lons = ncread(filename_nc, 'lon')';
% Extract the Brightness Temperature values from the NetCDF
temp = ncread(filename_nc, 'Band1');

%% Set the visualization extent (min lon, max lon, min lat, max lat)
% extent = [-115.98  -25.01  -55.98  34.98];
% extent = [-79, -30.01, -50.98, -11];
extent = [-60, -51, -40, -31];


min_lon = extent(1);
max_lon = extent(2);
min_lat = extent(3);
max_lat = extent(4);

%% Get corresponding index for extent values
% latitude lower and upper index
[latlv, latli] = min(abs(lats - extent(3)));
[latuv, latui] = min(abs(lats - extent(4)));

% longitude lower and upper index
[lonlv, lonli] = min(abs(lons - extent(1)));
[lonuv, lonui] = min(abs(lons - extent(2)));

%% Flip the y axis, divide by 100 and subtract 273.15 to convert to celcius
temp = flipud(rot90(temp))/ 100 - 273.15;

%%  Set station coordinates
%  SMS 		-29.442333, -53.821917
%  Anillaco 	-28.812507, -66.937308
%  La Maria	-28.023238, -64.230930
%  Chamical 	-30.507962, -66.120539
%  Fraiburgo -26.989072, -50.715612
%  Jatai 	-17.881116, -51.726366
%  Cuiaba 	-15.555339, -56.070155
%  CCST		-23.211277, -45.860655

stations_lon = [...
                -53.821917,...
                -66.937308,...
                -64.230930,...
                -66.120539,...
                -50.715612,...
                -51.726366,...
                -56.070155,...
                -45.860655];
stations_lat = [...
                -29.442333,...
                -28.812507,...
                -28.023238,...
                -30.507962,...
                -26.989072,...
                -17.881116,...
                -15.555339,...
                -23.211277];

%% Prepare Temperature Data
% load less values for faster processing
skip = 1;
% load data within the set extent
plottedTemp = temp(latli:skip:latui, lonli:skip:lonui);
plottedLons = lons(lonli:skip:lonui);
plottedLats = lats(latli:skip:latui);
% Filter out temperatures
% thresholdTemp = -66;
% plottedTemp(plottedTemp > thresholdTemp) = NaN;
%% Plot using the imagesc
tic
figure(2)

hold on;
imagesc(plottedLons, plottedLats, plottedTemp);
gca
axis xy;
axis equal;

axis([lons(lonli), lons(lonui), lats(latli), lats(latui)]);
set(gca,'xtick', -180:10:180, 'XGrid', 'on');
set(gca,'ytick', -90:10:90, 'YGrid', 'on');
set(gca, 'GridLineStyle', '--', 'GridColor', 'black', 'LineWidth', 1.5);
gca
plot(stations_lon, stations_lat, 'pblack', 'MarkerSize', 10,'MarkerFaceColor', 'm')

[cmin, cmax] = caxis;
cmin = floor(abs(cmin));
cmax = floor(cmax);
% blanco para las nubes.
cm = colormap([jet(cmin); flipud(gray(cmax))]);

cb = colorbar;
ylabel(cb,'cloud top temperature (C)')
title 'Title';

imagesc_time = toc

%% Plot using the Mapping Toolbox (with outlined countries/states)

% tic
% fig = figure(1);
% hold on
% 
% set(fig, 'MenuBar', 'None', 'ToolBar', 'None');
% 
% ax = axesm ('pcarree', 'Frame', 'on', 'Grid', 'on', 'MapLatLimit',[-55.98 -11], ...
%     'MapLonLimit', [-79 -25.01], 'MLineLocation', 10,'PLineLocation', 10, ...
%     'MeridianLabel', 'on', 'ParallelLabel', 'on', 'GColor', 'white');
% 
% pcolorm(lats(latli:5:latui), lons(lonli:5:lonui),...
%     temp(latli:5:latui, lonli:5:lonui));
% 
% title 'Title';
% axis off;
% cm =colormap([jet(cmin); gray(cmax)]);
% 
% cb = colorbar;
% ylabel(cb,'cloud top temperature (C)')
% 
% pcolorm_time = toc;
% states = shaperead(brstates_shp,'UseGeoCoords',true);
% geoshow([states.Lat], [states.Lon],'Color','white');
% countries = shaperead(countries_shp,'UseGeoCoords',true);
% geoshow([countries.Lat], [countries.Lon],'Color','magenta');
% plotm(stations_lat, stations_lon, 'pblack', 'MarkerSize', 10,'MarkerFaceColor', 'r')
% 
% pcolorm_time = toc

%% Implementation of old function to determine cloud area
% function [stormarea, cr] = n1ewtryareatemp(latarray, lonarray, outimage, frow, lrow, fcol, lcol, T)

% T = [-66];
% latarray = repmat(lats, 1, size(lons,2));
% lonarray = repmat(lons, size(lats,1),1);
% outimage = temp;
% frow = lonli;
% lrow = lonui;
% fcol = latli;
% lcol = latui;
% 
% [stormarea, cr] = n1ewtryareatemp(latarray, lonarray', outimage, frow, lrow, fcol, lcol, T(1));
%% Label isolated regions 
% need to set data as 0 or 1, 1 being pixels above the threshold
thresholdTemp = -70;
plottedTemp(plottedTemp > thresholdTemp) = 0;
plottedTemp(plottedTemp < thresholdTemp) = 1;

L = bwlabel(plottedTemp,4);
% find all the pixel coordinates of the 1st region:
[r,c] = find(L==3);
rc = [r c];
length(unique(L))
% Matrix L contains isolated regions
% The area of each pixel is the product of the distance to the next latitude
% pixel and the next longitude pixel

%% Contour plot
contourData = temp(latli:skip:latui, lonli:skip:lonui);
% mask data to not show in the contour
% contourData(contourData > -52) = NaN;
% Set contour bands
% values = [-46 -52 -58 -64 -70 -76 -80];
% values = [-46 -56 -66 -76];
values = [thresholdTemp -80];

% plot the contour
[C,h] = contour(plottedLons,plottedLats,contourData, values, 'Fill', 'on');
% clabel(C,h);

