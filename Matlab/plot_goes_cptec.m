%% Matlab configuration
beep off;
warning('off');
clear all
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

%% Set up figure
scrsz = get(groot,'ScreenSize');
% fig = figure('Position',[1 scrsz(4)*1/5 scrsz(3)*2/3 scrsz(4)*2/3]);
fig = figure('Position',[1 scrsz(4)*1/9 scrsz(3)*8/9 scrsz(4)*8/9]);

ax = axes('Parent', fig, 'FontSize',16);
hold(ax, 'on');
axis xy;
axis equal;
set(ax,'xtick', -180:5:180, 'Layer','top');
set(ax,'ytick', -90:5:90);
xlabel(ax, 'Longitude (C)', 'FontSize', 16);
ylabel(ax, 'Latitude (C)', 'FontSize', 16);
% set(ax, 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '--', 'GridColor', 'white', 'LineWidth', 0.1, 'GridAlpha', 1);
%% Define colormap and colorbar
cmin = 90;
cmax = 20;
% custom_cm = colormap(hot);
% grayColormap = flipud(gray);
% grayColormap = grayColormap(21:40,1:3);
cm = colormap([jet(cmin); flipud(gray(cmax))]);
cb = colorbar;
caxis([-(cmin) cmax ]);
caxis('manual')
title(cb,'Cloud top temperature (C)')
%% Plot coastlines
filepath_shp = 'C:\Users\sauli\Downloads\Soft_Tesis\OpenCV\Shapefiles\';
countries_shp = strcat(filepath_shp, 'ne_10m_admin_0_countries.shp');
brstates_shp = strcat(filepath_shp, 'BRA_ADM1.shp');

states = shaperead(brstates_shp,'UseGeoCoords',true);
States = geoshow([states.Lat], [states.Lon],'Color','white');
countries = shaperead(countries_shp,'UseGeoCoords',true);
Countries = geoshow([countries.Lat], [countries.Lon],'Color','white', 'LineWidth', 1.5);
%% Plot LEONA station markers
Stations = plot(ax, stations_lon, stations_lat, 'pblack', 'MarkerSize', 15,'MarkerFaceColor', 'm');

%% BrasilDat range                            7N -> 40S 77W -> 31W
%%  10/12/2018  16:00 ->    15/12/2018 08:00 20S -> 45S 70W -> 35W
%%  26/10/2019  19:00 ->    30/10/2019 00:00 20S -> 40S 70W -> 25W

%%  25/11/2018  16:00 ->    27/11/2018 11:00 25S -> 45S 70W -> 50W
%%  30/11/2018  09:00 ->    01/12/2018 20:00 25S -> 40S 70W -> 55W
%   10/12/2018  17:00 ->    13/12/2018 05:00 20S -> 45S 70W -> 45W
%   13/12/2018  01:00 ->    15/12/2018 08:00 25S -> 45S 70W -> 35W
%%  01/10/2019  04:00 ->    02/10/2019 16:00 20S -> 45S 70W -> 40W
%   26/10/2019  19:00 ->    29/10/2019 05:00 20S -> 40S 65W -> 40W
%   28/10/2019  13:00 ->    30/10/2019 00:00 25S -> 40S 70W -> 25W
%%  01/11/2019  21:00 ->    03/11/2019 14:00 25S -> 40S 70W -> 25W
%%  13/11/2019  15:00 ->    14/11/2019 12:00 25S -> 40S 75W -> 55W
%% Set the visualization extent (min lon, max lon, min lat, max lat)
% extent = [-115.98  -25.01  -55.98  34.98];
% extent = [-79, -30.01, -50.98, -11];

min_lon = [-75    -70    -70    -65    -70    -70    -70    -70    -70];
max_lon = [-50    -25    -25    -40    -25    -35    -45    -55    -50];
min_lat = [-40    -50    -40    -40    -50    -45    -45    -40    -45];
max_lat = [-25    -25    -25    -20    -20    -25    -20    -25    -25];

% min_lon = [-75    -70    -70    -65    -70    -60    -70    -70    -70];
% max_lon = [-50    -25    -25    -40    -25    -45    -45    -55    -50];
% min_lat = [-40    -50    -40    -40    -50    -35    -45    -40    -45];
% max_lat = [-25    -25    -25    -20    -20    -25    -20    -25    -25];


%% Observation dates start and end time
% 9 observations days
station = { 2    , 1    , 1/3  , 1    , 3/(1),  2   , 2    , 2    , 2/3  };
YYYY    = {'2019','2019','2019','2019','2019','2018','2018','2018','2018'};
MM      = {'11'  ,'11'  ,'10'  ,'10'  ,'10'  ,'12'  ,'12'  ,'11'  ,'11'  };
DD      = {'13'  ,'01'  ,'28'  ,'26'  ,'01'  ,'13'  ,'10'  ,'30'  ,'25'  };
hh      = {'15'  ,'21'  ,'01'  ,'19'  ,'04'  ,'01'  ,'16'  ,'09'  ,'16'  };
mm      = {'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  };
ss      = {'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  };
DDEnd   = {'14'  ,'03'  ,'31'  ,'29'  ,'03'  ,'15'  ,'13'  ,'01'  ,'27'  };
hhEnd   = {'22'  ,'14'  ,'00'  ,'05'  ,'00'  ,'08'  ,'05'  ,'23'  ,'11'  };
mmEnd   = {'10'  ,'10'  ,'10'  ,'10'  ,'10'  ,'15'  ,'15'  ,'15'  ,'15'  };
night   = { 1    , 2    , 3    , 4    , 5    ,  6   , 7    , 8    , 9    };
%% OBSERVATION NIGHT %%
index = 6;

%% Define .nc files path
filepath_nc = strcat('C:/Users/sauli/Downloads/Soft_Tesis/OpenCV/CPTEC data/', YYYY{index},'_nc/');
filenames_nc = dir(fullfile(filepath_nc, '*.nc'));
files = {filenames_nc.name};
path_nc = strcat(filepath_nc, files);

%% Video writer object 
aviFilename = strcat(YYYY{index},'-', MM{index},'-', DD{index},'-', hh{index}, mm{index},'.avi');
writerObj = VideoWriter(aviFilename);
writerObj.FrameRate = 1;
open(writerObj);
fig.CurrentCharacter = '4';

%% SAVE/LOAD VARIABLES
% Set to 'Yes' to save netcdf data to .mat files (do every time new limits are set)
% Set to 'No' to load netcdf data from .mat files
load_data = 'Yes';
% load_data = 'no';
load_cg_data = 'Yes';
% load_cg_data = 'no';
%% Label mode
label_mode = false;
label_names = [];
load labels
area_mode = false;
% DD{1} = '14';
% hh{1} = '03';
%% Set temperature, area and distanet thresholds
T_cover = -32;
min_pix_cover = 500;
dist_cover = 2000;

T_core = -52;
min_pix_core = 250;
dist_core = 2000;

T_most = -72;
min_pix_most = 10;
dist_most = 2000;

T_cover_mask = -42; % 
tcoverIn_color = [0 0.6 0]; %

T_core_mask = -52; %
tcoreIn_color = [1 0 0]; % red 
tcoreOut_color = [1 1 0]; % yellow

T_most_mask = -72; %
tmostIn_color = [0 0 1]; %blue
tmostOut_color = [0 1 1]; %cyan

warm_mask = 5;
%% Open text file object 
textFilename = strcat(YYYY{index},'-', MM{index},'-', DD{index},'-', hh{index},...
    '.txt');
%     '_', num2str(T_cover),num2str(T_core),num2str(T_most),...

fileID = fopen(textFilename,'w');
fprintf(fileID,strcat('%-25s %3dC %6d pixels \n',...
    '%-25s %3dC %6d pixels \n',...
    '%-25s %3dC %6d pixels,\n'), ...
    'Cover threshold' ,T_cover, min_pix_cover, ...
    'Core threshold' ,T_core, min_pix_core, ...
    'Most convective threshold' ,T_most, min_pix_most);
fprintf(fileID,'%03s, %6s, %6s, %6s\n', 'region', '#pixels', 'area(km2)', 'distance(km)');

%%
n = 1;
while(1)
    %% Format filename and check if exists
    image_name = strcat('S10635346_', YYYY{index}, MM{index}, DD{index}, hh{index}, mm{index});
    file_nc = strcat(filepath_nc, image_name, '.nc');
    if ~ismember(file_nc, path_nc)
        [MM{index}, DD{index}, hh{index}, mm{index}] = addMinutes(MM{index}, DD{index}, hh{index}, mm{index}, mmEnd{index});
        continue
    end
        
    %% Load netcdf4 file into variables
    if strcmp(load_data, 'Yes')
        load(strcat('./data_mat/', image_name, '.mat'));
    else
        % Get the latitudes
        lats = ncread(char(file_nc), 'lat');
        % Get the longitudes
        lons = ncread(char(file_nc), 'lon')';
        % Extract the Brightness Temperature values from the NetCDF
        temp = ncread(char(file_nc), 'Band1');
        
        % Flip the y axis, divide by 100 and subtract 273.15 to convert to celcius
        temp = flipud(rot90(temp))/ 100 - 273.15;
        % Mask data
        temp(temp < -90) = NaN;
        temp(temp > 20) = 255;
        
        % Get corresponding index for extent values
        % latitude lower and upper index
        [latlv, latli] = min(abs(lats - min_lat(index)));
        [latuv, latui] = min(abs(lats - max_lat(index)));
        
        % longitude lower and upper index
        [lonlv, lonli] = min(abs(lons - min_lon(index)));
        [lonuv, lonui] = min(abs(lons - max_lon(index)));
        
        % Prepare Temperature Data
        % load less values for faster processing
        skip = 1;
        % load data within the set extent
        plottedTemp = temp(latli:skip:latui, lonli:skip:lonui);
        plottedLons = lons(lonli:skip:lonui);
        plottedLats = lats(latli:skip:latui);
        
        save(strcat('./data_mat/', image_name, '.mat'), 'plottedTemp', 'plottedLons', 'plottedLats', 'lonli', 'lonui', 'latli', 'latui');
    end

    %% Plot Cloud Top Temperatures
    if n == 1
        temp_plot = imagesc('XData', plottedLons, 'YData', plottedLats, 'CData', plottedTemp);
        patch_fov = patch([1,1], [2,2], 'red', 'FaceAlpha', 0.2, 'visible', 'off');
        axis([plottedLons(1), plottedLons(end)+0.1, plottedLats(1), plottedLats(end)+0.1]);
                
    else
        set(temp_plot, 'XData', plottedLons, 'YData', plottedLats, 'CData', plottedTemp);
%         set(cb, 'visible', 'off')
    end
    %% Plot title and country outlines
    % Draw title
    title(ax, [YYYY{index}, '/', MM{index}, '/', DD{index},' - ', hh{index}, ':', mm{index}], 'FontSize', 16);
    % Move Coastlines up
%     uistack(Countries, 'top')
%     uistack(States, 'top')
    uistack(Stations, 'top')
    

    %% Plot camera observation lines
    plot_stations_fov
    %% Label isolated regions
%     getIsolatedAreas
    
    if fig.CurrentCharacter ~= '4'
        area_mode = false;
    end
%     pause(0.001);
    if not(area_mode)
        waitforbuttonpress
        disp(strcat('key pressed: ', fig.CurrentCharacter))
    end
    date_time = strcat(YYYY{index},'-', MM{index},'-', DD{index},'-', hh{index},':', mm{index});

    if fig.CurrentCharacter == '4'
        area_mode = true;
        
%         cursor_point = get(gca, 'CurrentPoint');
%         lon_cursor = cursor_point(1,1); 
%         lat_cursor = cursor_point(1,2);
%         disp([lon_cursor lat_cursor]);
%         [delta_x,x] = min(abs(plottedLons - lon_cursor));
%         [delta_y,y] = min(abs(plottedLats - lat_cursor));
%         disp([x y])
% 
%         tic
%         [area, xy] = area_temp_no_dialog(plottedTemp, plottedLons, plottedLats, x, y, -32);
%         Eliah_Json = toc;
%         fprintf('%d pixels in %f \n', size(xy, 1), Eliah_Json)
%         waitforbuttonpress
% 
%         tic
%         list_pix = floodFillScanlineStack(x, y, plottedTemp(y,x), -32, plottedTemp, plottedLons, plottedLats, fig, writerObj);
%         Flood_Fill_ScanLine_Stack = toc;
%         fprintf('%d pixels in %f \n', size(list_pix, 1), Flood_Fill_ScanLine_Stack)
%         plot(plottedLons(list_pix(:,2)),plottedLats(list_pix(:,1)),'.k', 'color', 'blue');
%         waitforbuttonpress
        
%         -32: dark green, green; -52: red, yellow; -72: blue, cyan
        getIsolatedAreas

%         light_spr_goes
%         [area, xy] = area_temp(plottedTemp, plottedLons,plottedLats, fig, writerObj);
%         waitforbuttonpress
%         continue
        pause(0.01)
    end

    %% Next/Previous data scan
    if fig.CurrentCharacter == 'd' || fig.CurrentCharacter == '0'
        getIsolatedAreas
        n = n + 1;
        [MM{index}, DD{index}, hh{index}, mm{index}] = addMinutes(MM{index}, DD{index}, hh{index}, mm{index}, mmEnd{index});
    end
    if fig.CurrentCharacter == '4'
        n = n + 1;
        [MM{index}, DD{index}, hh{index}, mm{index}] = addMinutes(MM{index}, DD{index}, hh{index}, mm{index}, mmEnd{index});    
    end
    if fig.CurrentCharacter == 'a'
%         area_mode = true;
%         getIsolatedAreas
        light_spr_goes
        n = n - 1; 
        [MM{index}, DD{index}, hh{index}, mm{index}] = subMinutes(MM{index}, DD{index}, hh{index}, mm{index}, mmEnd{index});
    end
    
    if strcmp(DD{index}, DDEnd{index}) && strcmp(hh{index}, hhEnd{index}) && strcmp(mm{index}, mmEnd{index})
        break
    end

%     set(patch_fov, 'visible', 'off')
    %% Write to video
    frame = getframe(fig);
    writeVideo(writerObj,frame);

    % end

end
fclose(fileID);
% save labels.mat labels
close(writerObj);