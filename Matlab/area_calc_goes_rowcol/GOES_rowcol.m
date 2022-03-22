% clear all
T_threshold = -32;
step = 0.018;
% calc_area = 'Yes';
calc_area = 'No';
plot_geo = 'No';
plot_CPTEC = 'No';
load_cg_data = 'No';
%% Set up figure (Geo)
% Configure plot size
scrsz = get(groot,'ScreenSize');
% fig = figure('Position',[1 scrsz(4)*1/5 scrsz(3)*2/3 scrsz(4)*2/3]);
% fig = figure('Position',[1 scrsz(4)*1/9 scrsz(3)*8/9 scrsz(4)*8/9]);
fig2 = figure('Position',[1 1 scrsz(3) scrsz(4)]);

% Configure axis labels
ax2 = axes('Parent', fig2, 'FontSize',16);
hold(ax2, 'on');
axis ij;
axis equal;
% set(gca,'XColor', 'none','YColor','none')

% set(ax,'xtick', -180:5:180, 'Layer','top');
% set(ax,'ytick', -90:5:90);
xlabel(ax2, 'Longitude (Degree)', 'FontSize', 16);
ylabel(ax2, 'Latitude (Degree)', 'FontSize', 16);
% Display grid
% set(ax, 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '--', 'GridColor', 'white', 'LineWidth', 0.1, 'GridAlpha', 1);
%% Define colormap and colorbar (Geo)
% The following sets the colorbar from 20C to -90C
cmin = 90;
cmax = 20;
% The following set gray scale for positive temperature, and jet colormap for
% negative temperatures
cm2 = colormap([jet(cmin+T_threshold); flipud(gray(cmax-T_threshold))]);

% Subtract and add to displace the grayscale/jetcolormap division
% With the following line the division is set at 32C
% cm = colormap([jet(cmin-32); flipud(gray(cmax+32))]);

% Configure colorbar
cb2 = colorbar;
caxis([-(cmin) cmax ]);
caxis('manual')
title(cb2,'Cloud top temperature (C)')
%% Define .nc files path (Geo)
% Folder with CPTEC .nc data has to be YYYY_nc, ie '2018_nc' or '2019_nc'
filepath_nc = strcat('C:/Users/sauli/Downloads/Soft_Tesis/OpenCV/GOES data/', '2018','_nc/');
% Find every file in the folder
filenames_nc = dir(fullfile(filepath_nc, '*.nc'));
% Create a cell array with found filenames
files = {filenames_nc.name};
% Create full path for every found filename
path_nc = strcat(filepath_nc, files);

title(ax2, ['Geostationary projection ','2018', '/', '12', '/', '13',' - ', '23', ':', '00'], 'FontSize', 16);

%% Read data from files (Geo)
n=1;

filename = path_nc{n};

goes = flipud(rot90(ncread(filename, 'CMI')-273.15));
fid = fopen('goes16_2km_lat.bin');
fid2 = fopen('goes16_2km_lon.bin');

latarray = flipud(rot90(fread(fid,[5424,5424],'float64')));
lonarray = rot90(fread(fid2,[5424,5424],'float64'));

%% compute min, max ranges of the map.  Exclude off-earth regions
% maxlat = max(latarray(latarray > -90 & latarray < 90));       % 81.1475
% minlat = min(latarray(latarray > -90 & latarray < 90));       % -81.1475
% maxlon = max(lonarray(lonarray > -180 & lonarray < 180));     % 6.1963
% minlon = min(lonarray(lonarray > -180 & lonarray < 180));     % -156.1963

%% Specify plotting area
% Test storm full
% maxlat = -28;
% minlat = -45;
% maxlon = -40;
% minlon = -70;

% Test storm zoomed
maxlat = -31;
minlat = -35;
maxlon = -61;
minlon = -69;

% North
% maxlat = 34;
% minlat = 30;
% maxlon = -67;
% minlon = -77;

% Equator
% maxlat = 2;
% minlat = -2;
% maxlon = -57;
% minlon = -67;

% South
% maxlat = -52;
% minlat = -56;
% maxlon = -46;
% minlon = -66;

% Full range
% maxlat = 81.1475;
% minlat = -81.1475;
% maxlon = 6.1963;
% minlon = -156.1963;
%% Get row/col of the max/min lat/lon (Geo)
latsize=size(latarray,1);
lonsize=size(latarray,2);

[rarray carray] = size(goes);

dlat = (latarray - minlat); % .^ 2;		% create array of lat variances
[dum latmin] = min(abs(dlat));	    % find min for each col
% Create vector array with pixel coordinates for lat
xdlat = [latmin; 1:carray]';        % latmin gives rows

dlon = (lonarray - minlon); % .^ 2;		% create array of lon variances
[dum, lonmin] = min(abs(dlon'));	    % find min for each row
% Create vector array with pixel coordinates for lon
xdlon = [1:rarray; lonmin]';        % lonmin gives colum
u = intersect2(xdlat,xdlon,'rows');

lrow = u(1,1);
fcol = u(1,2);

dlat = (latarray - maxlat); % .^ 2;		% create array of lat variances
[dum latmin] = min(abs(dlat));	    % find min for each col
% Create vector array with pixel coordinates for lat
xdlat = [latmin; 1:carray]';        % latmin gives rows

dlon = (lonarray - maxlon); % .^ 2;		% create array of lon variances
[dum, lonmin] = min(abs(dlon'));	    % find min for each row
% Create vector array with pixel coordinates for lon
xdlon = [1:rarray; lonmin]';        % lonmin gives colum
u = intersect2(xdlat,xdlon,'rows');

frow = u(1,1);
lcol = u(1,2);

minlatplot = latarray(lrow, fcol);
maxlatplot = latarray(frow, lcol);

minlonplot = lonarray(lrow, fcol);
maxlonplot = lonarray(frow, lcol);

% dlat = abs(maxlat - latarray);
% [dlat_max_values, dlat_max_rows] = min(dlat);
% [dlat_max_val, dlat_max_col] = min(dlat_max_values);
% dlat_max_row = dlat_max_rows(dlat_max_col);
%
% dlat = abs(minlat - latarray);
% [dlat_min_values, dlat_min_rows] = min(dlat);
% [dlat_min_val, dlat_min_col] = min(dlat_min_values);
% dlat_min_row = dlat_min_rows(dlat_min_col);
%
% dlon = abs(maxlon - lonarray);
% [dlon_max_values, dlon_max_rows] = min(dlon);
% [dlon_max_val, dlon_max_col] = min(dlon_max_values);
% dlon_max_row = dlon_max_rows(dlon_max_col);
%
% dlon = abs(minlon - lonarray);
% [dlon_min_values, dlon_min_rows] = min(dlon);
% [dlon_min_val, dlon_min_col] = min(dlon_min_values);
% dlon_min_row = dlon_min_rows(dlon_min_col);

% maxlatplot = latarray(dlat_max_row, dlat_max_col);
% maxlonplot = lonarray(dlon_max_row, dlon_max_col);
%
% minlatplot = latarray(dlat_min_row, dlat_min_col);
% minlonplot = lonarray(dlon_min_row, dlon_min_col);
%
% [frow, midcol] = find(lat == maxlatplot);
% [lrow, midcol] = find(lat == minlatplot);
% [midcol, fcol] = find(lon == minlonplot);
% [midcol, lcol] = find(lon == maxlonplot);

%% Cut data to fit our range (Geo)
outimage = goes(frow:lrow,fcol:lcol);
outlon = lonarray(frow:lrow, fcol:lcol);
outlat = latarray(frow:lrow, fcol:lcol);

%% Plot data  (Geo)
if strcmp(plot_geo,'Yes')
    outimage_plot = pcolor(outimage);
    set(outimage_plot, 'EdgeColor', 'none')
    
    [clat, hlat] = contour(outlat, -90:1:90, 'white');
    clabel(clat, -90:1:90,'FontSize',16,'Color','white');
    
    [clon, hlon] = contour(outlon, -180:1:180,  'white');
    clabel(clon, -180:1:180,'FontSize',16,'Color','white');
    %% Geostationary area calculation (Geo)
    if strcmp(calc_area, 'Yes')
        waitforbuttonpress
        cursor_point = get(gca, 'CurrentPoint');
        col_cursor = cursor_point(1,1);
        row_cursor = cursor_point(1,2);
        
        row = round(row_cursor);
        col = round(col_cursor);
        disp([row col])
        
        tic
        list_pix = floodFillScanlineStack(col, row, outimage(row, col), T_threshold, outimage, outlon, outlat, 1, 1);
        Flood_Fill_ScanLine_Stack = toc;
        
        fprintf('%d pixels in %f \n', size(list_pix, 1), Flood_Fill_ScanLine_Stack)
        plot(list_pix(:,2),list_pix(:,1),'.k', 'color', 'white');
        area_calc_geo_jose
        fprintf('Geo proj area is %7.6f km2\n', Area)
        
        % area_calc_geo_eliah
        
    end
else
    close(fig2)
end

%% Set up new plot (CPTEC)
scrsz = get(groot,'ScreenSize');
fig4 = figure('Position',[1 1 scrsz(3) scrsz(4)]);

% Configure axis labels
ax4 = axes('Parent', fig4, 'FontSize',16);
hold(ax4, 'on');
axis xy;
axis equal;

set(ax4,'xtick', -180:1:180, 'Layer','top');
set(ax4,'ytick', -90:1:90);
xlabel(ax4, 'Longitude (Degree)', 'FontSize', 16);
ylabel(ax4, 'Latitude (Degree)', 'FontSize', 16);

% Display grid
set(ax4, 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '-', 'GridColor', 'white', 'LineWidth', 0.1, 'GridAlpha', 1);

%% Define colormap and colorbar (CPTEC)
% The following sets the colorbar from 20C to -90C
cmin = 90;
cmax = 20;
% The following set gray scale for positive temperature, and jet colormap for
% negative temperatures
cm4 = colormap([jet(cmin+T_threshold); flipud(gray(cmax-T_threshold))]);
% Configure colorbar
cb4 = colorbar;
caxis([-(cmin) cmax ]);
caxis('manual')
title(cb4,'Cloud top temperature (C)')
title(ax4, ['Rectangular CPTEC projection ', '2018', '/', '12', '/', '13',' - ', '23', ':', '00'], 'FontSize', 16);
%% Define .nc files path (CPTEC)
% Folder with CPTEC .nc data has to be YYYY_nc, ie '2018_nc' or '2019_nc'

ktt_aux = 1;
YYYY{ktt_aux} = '2018';
MM{ktt_aux} =  '12';
DD{ktt_aux} = '13';
hh{ktt_aux} = '23';
mm{ktt_aux} = '00';

filepath_nc = strcat('C:/Users/sauli/Downloads/Soft_Tesis/OpenCV/CPTEC data/', YYYY{ktt_aux},'_nc/');
% Find every file in the folder
filenames_nc = dir(fullfile(filepath_nc, '*.nc'));
% Create a cell array with found filenames
files = {filenames_nc.name};
% Create full path for every found filename
path_nc = strcat(filepath_nc, files);
%% Format filename (CPTEC)
image_name = strcat('S10635346_', YYYY{ktt_aux}, MM{ktt_aux}, DD{ktt_aux}, hh{ktt_aux}, mm{ktt_aux});
file_nc = strcat(filepath_nc, image_name, '.nc');

%% Load/Save netcdf4 file into variables (CPTEC)
% Get the latitudes values from the NetCDF
lats = flipud(ncread(char(file_nc), 'lat'));
% Get the longitudes values from the NetCDF
lons = ncread(char(file_nc), 'lon')';
% Extract the Brightness Temperature values from the NetCDF
temp = ncread(char(file_nc), 'Band1');

% Flip the y axis, divide by 100 and subtract 273.15 to convert to celcius
temp = rot90(temp)/ 100 - 273.15;
% Mask data
temp(temp < -90) = NaN;
temp(temp > 20) = 255;

% Get corresponding index for extent values
% latitude lower and upper index
[latuv, latli] = min(abs(lats - maxlat));
[latlv, latui] = min(abs(lats - minlat));

% longitude lower and upper index
[lonlv, lonli] = min(abs(lons - minlon));
[lonuv, lonui] = min(abs(lons - maxlon));

% Prepare Temperature Data
% load less values for faster processing
skip = 1;
% load data within the set extent
plottedTemp = temp(latli:skip:latui, lonli:skip:lonui);
plottedLons = lons(lonli:skip:lonui);
plottedLats = lats(latli:skip:latui);


%% Plot Cloud Top Temperatures (CPTEC)
if strcmp(plot_CPTEC,'Yes')
    % temp_plot is the plot object for temperature data
    temp_plot = pcolor(plottedLons, plottedLats, plottedTemp);
    set(temp_plot, 'EdgeColor', 'none')

    % Set axis boundaries
    axis([minlon, maxlon, minlat, maxlat]);

    if strcmp(calc_area, 'Yes')
        waitforbuttonpress

        cursor_point = get(gca, 'CurrentPoint');
        lon_cursor = cursor_point(1,1);
        lat_cursor = cursor_point(1,2);
        disp([lon_cursor lat_cursor]);

        [delta_col, col] = min(abs(plottedLons - lon_cursor));
        [delta_row, row] = min(abs(plottedLats - lat_cursor));


        tic
        list_pix = floodFillScanlineStack(col, row, plottedTemp(row, col), T_threshold, plottedTemp, 1, 1, 1, 1);
        Flood_Fill_ScanLine_Stack = toc;

        fprintf('%d pixels in %f \n', size(list_pix, 1), Flood_Fill_ScanLine_Stack)
        plot(plottedLons(list_pix(:,2)),plottedLats(list_pix(:,1)),'.k', 'color', 'white');

        dArea = zeros(10000,1);
        list_pix = sortrows(list_pix,1);

        % distance between lats is always the same
        dlat = deltaAngleToArc(plottedLats(list_pix(1,1)),plottedLons(list_pix(1,2)),...
            plottedLats(list_pix(1,1)+1),plottedLons(list_pix(1,2)));

        % distance between lons has to be calculated every new lat

        prev_lat = plottedLats(list_pix(1,1));
        dlon = deltaAngleToArc(prev_lat ,plottedLons(list_pix(1,2)),...
            prev_lat ,plottedLons(list_pix(1,2)+1));
        for i = 1 : size(list_pix,1)
            current_lat = plottedLats(list_pix(i,1));
            if current_lat ~= prev_lat
                dlon = deltaAngleToArc(current_lat, plottedLons(list_pix(1,2)),...
                    current_lat ,plottedLons(list_pix(1,2)+1));
                prev_lat = current_lat;
            end

            dArea(i) = dlon *dlat;
        end
        Area = sum(dArea);
        fprintf('CPTEC Rect proj area is %f \n', Area)
    end
else
    close(fig4)
end
%% Set up new plot (rect)
scrsz = get(groot,'ScreenSize');
% fig = figure('Position',[1 scrsz(4)*1/5 scrsz(3)*2/3 scrsz(4)*2/3]);
% fig = figure('Position',[1 scrsz(4)*1/9 scrsz(3)*8/9 scrsz(4)*8/9]);
fig3 = figure('Position',[1 1 scrsz(3) scrsz(4)]);

% Configure axis labels
ax3 = axes('Parent', fig3, 'FontSize',16);
hold(ax3, 'on');
axis xy;
axis equal;

set(ax3,'xtick', -180:1:180, 'Layer','top');
set(ax3,'ytick', -90:1:90);
xlabel(ax3, 'Longitude (Degree)', 'FontSize', 16);
ylabel(ax3, 'Latitude (Degree)', 'FontSize', 16);

% Display grid
set(ax3, 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '-', 'GridColor', 'white', 'LineWidth', 0.1, 'GridAlpha', 1);

%% Define colormap and colorbar (rect)
% The following sets the colorbar from 20C to -90C
cmin = 90;
cmax = 20;
% The following set gray scale for positive temperature, and jet colormap for
% negative temperatures
cm3 = colormap([jet(cmin+T_threshold); flipud(gray(cmax-T_threshold))]);
% Configure colorbar
cb3 = colorbar;
caxis([-(cmin) cmax ]);
caxis('manual')
title(cb3,'Cloud top temperature (C)')
title(ax3, ['Rectangular projection ', '2018', '/', '12', '/', '13',' - ', '23', ':', '00'], 'FontSize', 16);

%% Geo to rectangular proj (rect)
% step = 0.018;

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
couttemp_plot = pcolor(lns,lts,couttemp);
set(couttemp_plot, 'EdgeColor', 'none')
axis([minlon, maxlon, minlat, maxlat]);

%% Calc Area rect projection (rect)
if strcmp(calc_area, 'Yes')
    waitforbuttonpress

    cursor_point = get(gca, 'CurrentPoint');
    lon_cursor = cursor_point(1,1);
    lat_cursor = cursor_point(1,2);
    disp([lon_cursor lat_cursor]);

    [delta_col, col] = min(abs(lns - lon_cursor));
    [delta_row, row] = min(abs(lts - lat_cursor));


    tic
    list_pix = floodFillScanlineStack(col, row, couttemp(row, col), T_threshold, couttemp, 1, 1, 1, 1);
    Flood_Fill_ScanLine_Stack = toc;

    fprintf('%d pixels in %f \n', size(list_pix, 1), Flood_Fill_ScanLine_Stack)
    plot(lns(list_pix(:,2)),lts(list_pix(:,1)),'.k', 'color', 'white');

    dArea = zeros(10000,1);
    list_pix = sortrows(list_pix,1);

    % distance between lats is always the same
    dlat = deltaAngleToArc(lts(list_pix(1,1)),lns(list_pix(1,2)),...
        lts(list_pix(1,1)+1),lns(list_pix(1,2)));

    % distance between lons has to be calculated every new lat

    prev_lat = lts(list_pix(1,1));
    dlon = deltaAngleToArc(prev_lat ,lns(list_pix(1,2)),...
        prev_lat ,lns(list_pix(1,2)+1));
    for i = 1 : size(list_pix,1)
        current_lat = lts(list_pix(i,1));
        if current_lat ~= prev_lat
            dlon = deltaAngleToArc(current_lat, lns(list_pix(1,2)),...
                current_lat ,lns(list_pix(1,2)+1));
            prev_lat = current_lat;
        end

        dArea(i) = dlon *dlat;
    end
    Area = sum(dArea);
    fprintf('Rect proj area is %f \n', Area)
end

%%
while 1

%     [dlat_geo, dlon_geo, dlat_rect, dlon_rect, dlat_CPTEC, dlon_CPTEC] = getPixelSize(-75, 34.99, coutrows, coutcols, outlat, outlon, outimage, lns, lts, couttemp, plottedLons, plottedLats, plottedTemp);
%     [dlat_geo, dlon_geo, dlat_rect, dlon_rect, dlat_CPTEC, dlon_CPTEC] = getPixelSize(-75, 0, coutrows, coutcols, outlat, outlon, outimage, lns, lts, couttemp, plottedLons, plottedLats, plottedTemp);
%     [dlat_geo, dlon_geo, dlat_rect, dlon_rect, dlat_CPTEC, dlon_CPTEC] = getPixelSize(-75, -55.99, coutrows, coutcols, outlat, outlon, outimage, lns, lts, couttemp, plottedLons, plottedLats, plottedTemp);
    
    waitforbuttonpress
    
    cursor_point = get(gca, 'CurrentPoint');
    lon_cursor = cursor_point(1,1);
    lat_cursor = cursor_point(1,2);
    disp([lon_cursor lat_cursor]);
    
    [dlat_geo, dlon_geo, dlat_rect, dlon_rect, dlat_CPTEC, dlon_CPTEC] = getPixelSize(lon_cursor, lat_cursor, coutrows, coutcols, outlat, outlon, outimage, lns, lts, couttemp, plottedLons, plottedLats, plottedTemp);
    
end
