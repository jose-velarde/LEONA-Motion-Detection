clear all
T_threshold = -32;
%% Set up figure
% Configure plot size
scrsz = get(groot,'ScreenSize');
% fig = figure('Position',[1 scrsz(4)*1/5 scrsz(3)*2/3 scrsz(4)*2/3]);
% fig = figure('Position',[1 scrsz(4)*1/9 scrsz(3)*8/9 scrsz(4)*8/9]);
fig2 = figure('Position',[1 1 scrsz(3) scrsz(4)]);

% Configure axis labels
ax = axes('Parent', fig2, 'FontSize',16);
hold(ax, 'on');
% axis ij;
axis equal;
% set(gca,'XColor', 'none','YColor','none')

% set(ax,'xtick', -180:5:180, 'Layer','top');
% set(ax,'ytick', -90:5:90);
xlabel(ax, 'Longitude (Degree)', 'FontSize', 16);
ylabel(ax, 'Latitude (Degree)', 'FontSize', 16);
% Display grid
% set(ax, 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '--', 'GridColor', 'white', 'LineWidth', 0.1, 'GridAlpha', 1);
%% Define colormap and colorbar
% The following sets the colorbar from 20C to -90C
cmin = 90;
cmax = 20;
% The following set gray scale for positive temperature, and jet colormap for
% negative temperatures
cm = colormap([jet(cmin+T_threshold); flipud(gray(cmax-T_threshold))]);

% Subtract and add to displace the grayscale/jetcolormap division
% With the following line the division is set at 32C
% cm = colormap([jet(cmin-32); flipud(gray(cmax+32))]);

% Configure colorbar
cb = colorbar;
caxis([-(cmin) cmax ]);
caxis('manual')
title(cb,'Cloud top temperature (C)')
%% Define .nc files path
% Folder with CPTEC .nc data has to be YYYY_nc, ie '2018_nc' or '2019_nc'
filepath_nc = strcat('C:/Users/sauli/Downloads/Soft_Tesis/OpenCV/GOES data/', '2018','_nc/');
% Find every file in the folder
filenames_nc = dir(fullfile(filepath_nc, '*.nc'));
% Create a cell array with found filenames
files = {filenames_nc.name};
% Create full path for every found filename
path_nc = strcat(filepath_nc, files);

title(ax, ['2018', '/', '12', '/', '13',' - ', '23', ':', '00'], 'FontSize', 16);

%% Read data from files
n=1;

filename = path_nc{n};

goes = rot90(ncread(filename, 'CMI')-273.15);
fid = fopen('goes16_2km_lat.bin');
fid2 = fopen('goes16_2km_lon.bin');


% lat = flipud(rot90(fread(fid,[5424,5424],'float64')));
lat = rot90(fread(fid,[5424,5424],'float64'));
lon = rot90(fread(fid2,[5424,5424],'float64'));

%%
latarray=lat;
lonarray=lon;
latsize=size(latarray,1);
lonsize=size(latarray,2);

% compute min, max ranges of the map.  Exclude off-earth regions
% maxlat = max(latarray(latarray > -90 & latarray < 90));       % 81.1475
% minlat = min(latarray(latarray > -90 & latarray < 90));       % -81.1475
% maxlon = max(lonarray(lonarray > -180 & lonarray < 180));     % 6.1963
% minlon = min(lonarray(lonarray > -180 & lonarray < 180));     % -156.1963

%% Specify plotting area
maxlat = -31;       
minlat = -35;       
maxlon = -62;       
minlon = -68.5;     
% maxlat = 81.1475;
% minlat = -81.1475;
% maxlon = 6.1963;
% minlon = -156.1963;

dlat = abs(maxlat - latarray);
[dlat_max_values, dlat_max_rows] = min(dlat);
[dlat_max_val, dlat_max_col] = min(dlat_max_values);
dlat_max_row = dlat_max_rows(dlat_max_col);

dlat = abs(minlat - latarray);
[dlat_min_values, dlat_min_rows] = min(dlat);
[dlat_min_val, dlat_min_col] = min(dlat_min_values);
dlat_min_row = dlat_min_rows(dlat_min_col);

dlon = abs(maxlon - lonarray);
[dlon_max_values, dlon_max_rows] = min(dlon);
[dlon_max_val, dlon_max_col] = min(dlon_max_values);
dlon_max_row = dlon_max_rows(dlon_max_col);

dlon = abs(minlon - lonarray);
[dlon_min_values, dlon_min_rows] = min(dlon);
[dlon_min_val, dlon_min_col] = min(dlon_min_values);
dlon_min_row = dlon_min_rows(dlon_min_col);

maxlatplot = latarray(dlat_max_row, dlat_max_col);
maxlonplot = lonarray(dlon_max_row, dlon_max_col);

minlatplot = latarray(dlat_min_row, dlat_min_col);
minlonplot = lonarray(dlon_min_row, dlon_min_col);

[frow, midcol] = find(lat == minlatplot);
[lrow, midcol] = find(lat == maxlatplot);
[midcol, fcol] = find(lon == minlonplot);
[midcol, lcol] = find(lon == maxlonplot);

temp_goes = goes(frow(1):lrow(1),fcol(1):lcol(1));
lons_goes = lon(frow(1):lrow(1), fcol(1):lcol(1));
lats_goes = lat(frow(1):lrow(1), fcol(1):lcol(1));

% nr= lrow(1)-frow(1) + 1;
% nc= lcol(1)-fcol(1) + 1;
%
%
% %create matrixes containing rows and cols of region of interest
% outrows = ones(nr,nc);
% outcols = outrows;
% for k2=1:nc
%     outrows(:,k2) = outrows(:,k2).*(frow:lrow)';
% end
%
% for k1=1:nr
%     outcols (k1,:)= outcols(k1,:).*(fcol:lcol);
% end
% %create matrixes containing lat and lon of region of interest
% outlat=latarray(frow:lrow,fcol:lcol);
% outlon=lonarray(frow:lrow,fcol:lcol);
%
% maxlat=outlat(1,1);    %redifine limits to include
% minlat=outlat(nr,nc);   %the whole image
% maxlon=outlon(nr,nc);
% minlon=outlon(1,1);


% outrows and outcols have been calculated at this point,
% but no new image has been made.  outrows and outcols
% can be saved and used in subsequent maps covering the
% same lat-lon area without having to recalculate them.
outimage = goes(frow:lrow,fcol:lcol);

% imagesc(outimage);
% 
% [clat, hlat] = contour(lats_goes,5, 'white');
% clabel(clat, 'FontSize',16,'Color','white');
% 
% [clon, hlon] = contour(lons_goes,5,  'white');
% clabel(clon, 'FontSize',16,'Color','white');
% 
% waitforbuttonpress
% %% Pixel area calculation
% cursor_point = get(gca, 'CurrentPoint');
% lon_cursor = cursor_point(1,1);
% lat_cursor = cursor_point(1,2);
% disp([lon_cursor lat_cursor]);
% 
% y = round(lat_cursor);
% x = round(lon_cursor);
% disp([x y])
% 
% tic
% list_pix = floodFillScanlineStack(x, y, outimage(y,x), T_threshold, outimage, 1, 1, 1, 1);
% Flood_Fill_ScanLine_Stack = toc;
% 
% fprintf('%d pixels in %f \n', size(list_pix, 1), Flood_Fill_ScanLine_Stack)
% plot(list_pix(:,2),list_pix(:,1),'.k', 'color', 'white');
% 
% % saveas(fig,'jose_area.png')
% area_calc_geo_jose
% area_calc_geo_eliah

% return
%% Geo to rectangular proj
outlat = latarray(frow:lrow,fcol:lcol);
outlon = lonarray(frow:lrow,fcol:lcol);

USAPixToLatLon
% Now use coutrows and coutcols to create desired image from original image
coutimage = -inf*ones(size(coutrows));          % create new image matrix
[rz, cz] = size(coutrows);

for k1 = 1:rz,
    for k2 = 1:cz,
        rr = coutrows(k1,k2);   	             % get row value
        cc = coutcols(k1,k2);		             % get col value
        if rr ~= 0 && cc ~= 0,			         % ck for valid (non-zero)
            coutimage(k1,k2) = outimage(rr,cc);   % fill with values from original image
        end
    end
end

couttemp = coutimage;
rect_plot = pcolor(lns,lts,couttemp);
set(rect_plot, 'EdgeColor', 'none')

waitforbuttonpress

cursor_point = get(gca, 'CurrentPoint');
lon_cursor = cursor_point(1,1);
lat_cursor = cursor_point(1,2);
disp([lon_cursor lat_cursor]);

[delta_x,x] = min(abs(lns - lon_cursor));
[delta_y,y] = min(abs(lts - lat_cursor));

% x = round(lat_cursor);
% y = round(lon_cursor);
disp([x y])


tic
list_pix = floodFillScanlineStack(y, x, outimage(y,x), -32, outimage, 1, 1, 1, 1);

% list_pix = floodFillScanlineStack(y,x, outimage(x,y), -32, outimage, 1, 1, 1, 1);

Flood_Fill_ScanLine_Stack = toc;
%
% fprintf('%d pixels in %f \n', size(list_pix, 1), Flood_Fill_ScanLine_Stack)
% plot(list_pix(:,2),list_pix(:,1),'.k', 'color', 'blue');
% plot(lns(list_pix(1:2000,2)),lts(list_pix(1:2000,1)),'.k', 'color', 'blue');

% saveas(fig,'jose_area.png')
