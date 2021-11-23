%% Matlab configuration
beep off;
warning('off');
clear all

%% Set up figure
scrsz = get(groot,'ScreenSize');
fig = figure('Position',[1 scrsz(4)*1/5 scrsz(3)*2/3 scrsz(4)*2/3]);

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
cmin = 80;
cmax = 20;
% custom_cm = colormap(hot);
% grayColormap = flipud(gray);
% grayColormap = grayColormap(21:40,1:3);
cm = colormap([jet(cmin); flipud(gray(cmax))]);
cb = colorbar;
caxis([-(cmin) cmax ]);
caxis('manual')
title(cb,'Cloud top temperature (C)')

%% Set the visualization extent (min lon, max lon, min lat, max lat)
min_lon = [-75    -70    -70    -65    -70    -70    -70    -70    -70];
max_lon = [-50    -25    -25    -40    -25    -35    -45    -55    -50];
min_lat = [-40    -40    -40    -40    -50    -45    -45    -40    -45];
max_lat = [-25    -25    -25    -20    -20    -25    -20    -25    -25];

%% Observation dates start and end time
% 9 observations days
station = { 2    , 1    , 1/3  , 1    , 3/(1),  2   , 2    , 2    , 2/3  };
YYYY    = {'2019','2019','2019','2019','2019','2018','2018','2018','2018'};
MM      = {'11'  ,'11'  ,'10'  ,'10'  ,'10'  ,'12'  ,'12'  ,'11'  ,'11'  };
DD      = {'13'  ,'01'  ,'28'  ,'26'  ,'01'  ,'13'  ,'10'  ,'30'  ,'25'  };
hh      = {'15'  ,'21'  ,'13'  ,'19'  ,'04'  ,'01'  ,'16'  ,'09'  ,'16'  };
mm      = {'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  };
ss      = {'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  };
DDEnd   = {'14'  ,'03'  ,'31'  ,'29'  ,'03'  ,'15'  ,'13'  ,'01'  ,'27'  };
hhEnd   = {'22'  ,'14'  ,'00'  ,'05'  ,'00'  ,'08'  ,'05'  ,'23'  ,'11'  };
mmEnd   = {'10'  ,'10'  ,'10'  ,'10'  ,'10'  ,'15'  ,'15'  ,'15'  ,'15'  };
night   = { 1    , 2    , 3    , 4    , 5    ,  6   , 7    , 8    , 9    };
%% OBSERVATION NIGHT %%
index = 1;

%% Define .nc files path
filepath_nc = strcat('C:/Users/sauli/Downloads/Soft_Tesis/OpenCV/CPTEC data/', YYYY{index},'_nc/');
filenames_nc = dir(fullfile(filepath_nc, '*.nc'));
files = {filenames_nc.name};
path_nc = strcat(filepath_nc, files);

n = 1;
%% SAVE/LOAD VARIABLES
% Set to 'Yes' to save netcdf data to .mat files (do every time new limits are set)
% Set to 'No' to load netcdf data from .mat files
load_data = 'Yes';
% load_data = 'no';
%% Video writer object 
writerObj = 0;

% aviFilename = strcat(YYYY{index},'-', MM{index},'-', DD{index},'-', hh{index}, mm{index},'.avi');
% writerObj = VideoWriter(aviFilename);
% writerObj.FrameRate = 60;
% open(writerObj);

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
        temp(temp < -80) = NaN;
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
        axis([plottedLons(1), plottedLons(end)+0.1, plottedLats(1), plottedLats(end)+0.1]);
    else
        set(temp_plot, 'XData', plottedLons, 'YData', plottedLats, 'CData', plottedTemp);
%         set(cb, 'visible', 'off')
    end
    %% Plot title and country outlines
    % Draw title
    title(ax, [YYYY{index}, '/', MM{index}, '/', DD{index},' - ', hh{index}, ':', mm{index}], 'FontSize', 16);
    
    fprintf('\n Press 4: Select all T above clicked pixel \n Press 5: Set T \n Press 5: View selection process and recording \n')

    waitforbuttonpress
    fprintf('-------------------------------------------------------- \n')
 
    if fig.CurrentCharacter == '4'
        fprintf('Pressed %s, searching for pixels with T above the selected pixel \n',fig.CurrentCharacter)
        fprintf('Click the figure twice, if the the region extends to the border of the figure it crashes \n')

        waitforbuttonpress
        cursor_point = get(gca, 'CurrentPoint');
        lon_cursor = cursor_point(1,1); 
        lat_cursor = cursor_point(1,2);
%         disp([lon_cursor lat_cursor]);
        [delta_x,x] = min(abs(plottedLons - lon_cursor));
        [delta_y,y] = min(abs(plottedLats - lat_cursor));
        disp([x y])

        T = plottedTemp(y,x);
        area_temp_no_dialog
%         [area, xy] = area_temp_no_dialog(plottedTemp, plottedLons,plottedLats, x, y, T);
        fprintf('lon: %.2f , lat: %.2f , T: %.2f, area: %.2f km2\n',lon_cursor, lat_cursor, T, area)
%         waitforbuttonpress
    end
    %%
    if fig.CurrentCharacter == '5'
        fprintf('Pressed %s, set threshold, then click the figure and press enter \n',fig.CurrentCharacter)

%         lon: -54.67 , lat: -29.19 , T: -50.00, area: 17558.56 km2
        [area, xy] = area_temp(plottedTemp, plottedLons,plottedLats, fig, writerObj);
    end
    
    if fig.CurrentCharacter == '6'
        fprintf('Showing fill process \n')
        fprintf('To record a video uncomment video related code lines (72-75 and  \n')
        fprintf('Pressed %s, set threshold, then click the figure and press enter \n',fig.CurrentCharacter)
%         lon: -54.67 , lat: -29.19 , T: -50.00, area: 17558.56 km2
        [area, xy] = area_temp_record(plottedTemp, plottedLons,plottedLats, fig, writerObj);
    end
    %% Next/Previous data scan
    if fig.CurrentCharacter ~= 'q'
        n = n + 1;
    end
    %% Write to video
%     frame = getframe(fig);
%     writeVideo(writerObj,frame);

    if fig.CurrentCharacter == 'q'
        close all
        close(writerObj);
        break
    end
    
end
