%% Matlab configuration
% close all
% hold off;
beep off;
% set(0,'DefaultFigureWindowStyle','docked')
%% Define paths
filepath_nc = 'C:/Users/sauli/Downloads/Soft_Tesis/OpenCV/CPTEC data/2019_nc/';
filenames_nc = dir(fullfile(filepath_nc, '*.nc'));
files = {filenames_nc.name};
path_nc = strcat(filepath_nc, files);
filepath_shp = 'C:\Users\sauli\Downloads\Soft_Tesis\OpenCV\Shapefiles\';
countries_shp = strcat(filepath_shp, 'ne_10m_admin_0_countries.shp');
brstates_shp = strcat(filepath_shp, 'BRA_ADM1.shp');



%% Set the visualization extent (min lon, max lon, min lat, max lat)
% extent = [-115.98  -25.01  -55.98  34.98];
% extent = [-79, -30.01, -50.98, -11];

min_lon = -75;
max_lon = -45;
min_lat = -40;
max_lat = -25;


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

%% declare everything that repeats in the foor loop
fig = figure(1);
ax = axes('Parent', fig);
hold(ax, 'on');
axis xy;
axis equal;
set(ax, 'XGrid', 'on','xtick', -180:5:180, 'Layer','top');
set(ax,'YGrid', 'on','ytick', -90:5:90);
set(ax, 'GridLineStyle', '--', 'GridColor', 'magenta', 'LineWidth', 1, 'GridAlpha', 1);
cmin = 85;
cmax = 20;
% custom_cm = colormap(hot);
cm = colormap([jet(cmin/5); flipud(gray(cmax/5))]);
cb = colorbar;
caxis([-(cmin) cmax ]);
ylabel(cb,'cloud top temperature (C)')

YYYY = '2019';
DD = '28';
MM = '10';
hh = '18';
mm = '00';
ss = '00';

% while(1)
    %% Format filename and check if exists
    file = strcat(filepath_nc, 'S10635346_', YYYY,MM,DD,hh,mm,'.nc');
    if ~ismember(file, path_nc)
        [MM, DD, hh, mm] = addMinutes(MM, DD, hh, mm, 10);
        continue
    end
    %% Load netcdf4 file into variables
    % Get the latitudes
    lats = ncread(char(file), 'lat');
    % Get the longitudes
    lons = ncread(char(file), 'lon')';
    % Extract the Brightness Temperature values from the NetCDF
    temp = ncread(char(file), 'Band1');
    
    %% Flip the y axis, divide by 100 and subtract 273.15 to convert to celcius
    temp = flipud(rot90(temp))/ 100 - 273.15;
    %% Mask data
    temp(temp < -85) = NaN;
    temp(temp > 20) = NaN;
    
    %% Get corresponding index for extent values
    % latitude lower and upper index
    [latlv, latli] = min(abs(lats - min_lat));
    [latuv, latui] = min(abs(lats - max_lat));
    
    % longitude lower and upper index
    [lonlv, lonli] = min(abs(lons - min_lon));
    [lonuv, lonui] = min(abs(lons - max_lon));
    
    %% Prepare Temperature Data
    % load less values for faster processing
    skip = 1;
    % load data within the set extent
    plottedTemp = temp(latli:skip:latui, lonli:skip:lonui);
    plottedLons = lons(lonli:skip:lonui);
    plottedLats = lats(latli:skip:latui);
    % Filter out temperatures
    thresholdTemp = -68;
%     plottedTemp(plottedTemp > thresholdTemp) = NaN;
    %% Plot using the imagesc
    axis([lons(lonli), lons(lonui), lats(latli), lats(latui)]);
    
    imagesc(plottedLons, plottedLats, plottedTemp);
    %% Contour plot
    contourData = temp(latli:skip:latui, lonli:skip:lonui);
    % mask data to not show in the contour
    contourData(contourData > -0) = NaN;
    % Set contour bands
    % values = [-46 -52 -58 -64 -70 -76 -80];
%     values = [thresholdTemp -66 -72 -76 -85];
    values = [thresholdTemp -80];
    
    % plot the contour
%     [C,h] = contour(plottedLons,plottedLats,contourData, values, 'Fill', 'on','ShowText','on');
    [C,h] = contourf(plottedLons,plottedLats,contourData, values);


%     clabel(C, 'manual');
    plot(ax, stations_lon, stations_lat, 'pblack', 'MarkerSize', 15,'MarkerFaceColor', 'm')
    text(min_lon+3, min_lat+3,[YYYY, '/', MM, '/', DD,' - ', hh, ':', mm], 'BackgroundColor', 'white', 'FontSize', 15)
    
    
    pause(0.5);
    [MM, DD, hh, mm] = addMinutes(MM, DD, hh, mm, 10);
    % end
    %% Label isolated regions
    % need to set data as 0 or 1, 1 being pixels above the threshold
    thresholdTemp = -68;
    plottedTemp(plottedTemp > thresholdTemp) = 0;
    plottedTemp(plottedTemp < thresholdTemp) = 1;
    tic
    % Matrix L contains isolated regions
    L = bwlabel(plottedTemp,4);
    
%     CC = bwconncomp(plottedTemp);
%     stats = regionprops(CC, 'basic');
%     L = labelmatrix(CC);
    % Ignore small areas
    minPixelArea = 150;
    for group = 1 : length(unique(L))
        if nnz(L==group) < minPixelArea
            L(L==group)=0;
        end
    end
    
    isolatedRegions = unique(L);
    isolatedRegions = isolatedRegions(2:end);
    for nRegion = isolatedRegions'
        % find all the pixels of the n region:
        [r,c] = find(L==nRegion);
        % [lat,lon]
        rc = [r c];
        dArea = 0;
        for index = 1 : size(rc)
            % get distance from [lat(i) lon(i)] to [lat(i+1) lon(i)]
            dlat = haversineDist(...
                plottedLats(rc(index,1),1),...
                plottedLons(1,rc(index,2)),...
                plottedLats(rc(index,1)+1,1),...
                plottedLons(1,rc(index,2)));
            % get distance from [lat(i) lon(i)] to [lat(i) lon(i+1)]
            dlon = haversineDist(...
                plottedLats(rc(index,1),1),...
                plottedLons(1,rc(index,2)),...
                plottedLats(rc(index,1),1),...
                plottedLons(1,rc(index,2)+1));
            % calculate current pixel area as the product between deltas
            % add each pixel area to the isolated region area
            dArea = dArea + dlat*dlon;
        end
        %     fprintf('Region: %3d , Area: %6.0f km2, Pixels: \n',nRegion, dArea)
        fprintf('Pixels: %4d , Area: %6.0f km2, nRegion: %d\n',index, dArea, nRegion)
        
    end
    isolatedCalc = toc
% end

