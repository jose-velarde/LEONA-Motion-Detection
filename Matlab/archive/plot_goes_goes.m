%% Matlab configuration
beep off;
warning('off');
clear all
%%  Set station coordinates
%  1. SMS 		    -29.442333, -53.821917
%  2. Anillaco      -28.812507, -66.937308
%  3. La Maria      -28.023238, -64.230930
%  4. Chamical      -30.507962, -66.120539
%  5. Fraiburgo     -26.989072, -50.715612
%  6. Jatai         -17.881116, -51.726366
%  7. Cuiaba        -15.555339, -56.070155
%  8. CCST          -23.211277, -45.860655

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
% Configure plot size
scrsz = get(groot,'ScreenSize');
% fig = figure('Position',[1 scrsz(4)*1/5 scrsz(3)*2/3 scrsz(4)*2/3]);
% fig = figure('Position',[1 scrsz(4)*1/9 scrsz(3)*8/9 scrsz(4)*8/9]);
fig = figure('Position',[1 1 scrsz(3) scrsz(4)]);

% Configure axis labels
ax = axes('Parent', fig, 'FontSize',16);
hold(ax, 'on');
axis xy;
axis equal;
set(ax,'xtick', -180:5:180, 'Layer','top');
set(ax,'ytick', -90:5:90);
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
cm = colormap([jet(cmin); flipud(gray(cmax))]);

% Subtract and add to displace the grayscale/jetcolormap division
% With the following line the division is set at 32C
% cm = colormap([jet(cmin-32); flipud(gray(cmax+32))]);

% Configure colorbar
cb = colorbar;
caxis([-(cmin) cmax ]);
caxis('manual')
title(cb,'Cloud top temperature (C)')
%% Plot coastlines
% Read and plot country/state lines
filepath_shp = 'C:\Users\sauli\Downloads\Soft_Tesis\OpenCV\Shapefiles\';
countries_shp = strcat(filepath_shp, 'ne_10m_admin_0_countries.shp');
brstates_shp = strcat(filepath_shp, 'BRA_ADM1.shp');

% The plot objects are 'States' and 'Countries'
states = shaperead(brstates_shp,'UseGeoCoords',true);
States = geoshow([states.Lat], [states.Lon],'Color','white');
countries = shaperead(countries_shp,'UseGeoCoords',true);
Countries = geoshow([countries.Lat], [countries.Lon],'Color','white', 'LineWidth', 1.5);
%% Plot LEONA station markers
% The plot object is 'Stations'
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
%% OBSERVATION NIGHT %%
% Select observation night 1 to 9
index = 6;
%% Observation dates start and end time
% Set the date and times for observation start and end for the 9 observations
% nights

% Variable station indicates which stations where active that night, stations
% coordinates to determine the station number
station = { 2    , 1    , 1/3  , 1    , 3/(1),  2   , 2    , 2    , 2/3  };

% Variable night is just an indicator
night   = { 1    , 2    , 3    , 4    , 5    ,  6   , 7    , 8    , 9    };
% The following set the start time as YYYY-MM-DD-hh:mm:ss and the end time as
% YYYY-MM-DDEnd-hhEnd-mmEnd
YYYY    = {'2019','2019','2019','2019','2019','2018','2018','2018','2018'};
MM      = {'11'  ,'11'  ,'10'  ,'10'  ,'10'  ,'12'  ,'12'  ,'11'  ,'11'  };
DD      = {'13'  ,'01'  ,'28'  ,'26'  ,'01'  ,'13'  ,'10'  ,'30'  ,'25'  };
hh      = {'15'  ,'21'  ,'01'  ,'19'  ,'04'  ,'01'  ,'16'  ,'09'  ,'16'  };
mm      = {'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  };
ss      = {'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  };
DDEnd   = {'14'  ,'03'  ,'31'  ,'29'  ,'03'  ,'15'  ,'13'  ,'01'  ,'27'  };
hhEnd   = {'22'  ,'14'  ,'00'  ,'05'  ,'00'  ,'08'  ,'05'  ,'23'  ,'11'  };
mmEnd   = {'10'  ,'10'  ,'10'  ,'10'  ,'10'  ,'15'  ,'15'  ,'15'  ,'15'  };

%% Set the visualization extent (min lon, max lon, min lat, max lat)
% maximum plot extent is => [-115.98  -25.01  -55.98  34.98];

%% ZOOMED 2 (1: -70 -45 -40 -25)
% min_lon = [-75    -70    -70    -65    -70    -70    -70    -70    -70];
% max_lon = [-50    -25    -25    -40    -25    -40    -45    -55    -50];
% min_lat = [-40    -50    -40    -40    -50    -45    -45    -40    -45];
% max_lat = [-25    -25    -25    -20    -20    -28    -20    -25    -25];

%% ZOOMED 1
% min_lon = [-75    -70    -70    -65    -70    -60    -70    -70    -70];
% max_lon = [-50    -25    -25    -40    -25    -45    -45    -55    -50];
% min_lat = [-40    -50    -40    -40    -50    -35    -45    -40    -45];
% max_lat = [-25    -25    -25    -20    -20    -25    -20    -25    -25];
%% Original zoom
min_lon = [-75    -70    -70    -65    -70    -70    -70    -70    -70];
max_lon = [-50    -25    -25    -40    -25    -35    -45    -55    -50];
min_lat = [-40    -50    -40    -40    -50    -45    -45    -40    -45];
max_lat = [-25    -25    -25    -20    -20    -25    -20    -25    -25];

%% Hardcoded for testing a particular time
% hh{6} = '04';
% mm{6} = '30';
% min_lon(6) = -69.5;
% max_lon(6) = -66;
% min_lat(6) = -40.5;
% max_lat(6) = -37.7;

%% Define .nc files path
% Folder with CPTEC .nc data has to be YYYY_nc, ie '2018_nc' or '2019_nc'
filepath_nc = strcat('C:/Users/sauli/Downloads/Soft_Tesis/OpenCV/GOES data/', YYYY{index},'_nc/');
% Find every file in the folder
filenames_nc = dir(fullfile(filepath_nc, '*.nc'));
% Create a cell array with found filenames
files = {filenames_nc.name};
% Create full path for every found filename
path_nc = strcat(filepath_nc, files);


%% SAVE/LOAD VARIABLES
% Set to 'Yes' to load netcdf data from .mat files
% load_data = 'Yes';

% Set to 'No' to save netcdf data from .mat files, has to be run at least one
% time when new lat/lon limits are set.
load_data = 'no';

% Set to 'Yes' to load lightning location data from .mat files
load_cg_data = 'Yes';

% Set 'No' to save lightning location data to .nat files, has to be run at
% least one time when new lat/lon limits are set.
% load_cg_data = 'no';

%% Video writer object
% record = 'Yes';
record = 'No';
if strcmp(record, 'Yes')
    aviFilename = strcat(YYYY{index},'-', MM{index},'-', DD{index},'-', hh{index}, mm{index},'.avi');
    writerObj = VideoWriter(aviFilename);
    writerObj.FrameRate = 1;
    open(writerObj);
    fig.CurrentCharacter = '4';
end

%% Set temperature, area and distance thresholds
% Cloud cover
T_cover = -32;
min_pix_cover = 500;
dist_cover = 500;

% Cloud convection cores
T_core = -52;
min_pix_core = 250;
dist_core = 500;

% Cloud most convective cores
T_most = -72;
min_pix_most = 10;
dist_most = 500;

%% Set color mask for temperature analysis
% Because Imagesc is used to plot, plot colors depend on the temperature value
% so the temperature matrix is divided by ranges and each range is assigned to a
% value, ie, a value of 5 is the color gray, a value of -42 is the color green.

% Warm mask: 20C -> T_general_cover, gray colored
warm_mask = 5;

% General cover mask: T_general_cover -> T_convective_core,
% light green and darker green
T_cover_mask = -42;         % green
tcoverIn_color = [0 0.6 0]; % darker green

% Convective cores mas: T_core -> T_most_convective_core
T_core_mask = -52;          % red
tcoreIn_color = [1 0 0];    % red
tcoreOut_color = [1 1 0];   % yellow

% Most convective cores mask: T_most_convective_core -> -90C
T_most_mask = -72;          % blue
tmostIn_color = [0 0 1];    %blue
tmostOut_color = [0 1 1];   %cyan
%% Open text file object
% Create text file to record parameters for each scan.
% For each scan, isolated regions of tempreature T are found and parameterized.
% Number of pixels, area, distance to station, minimum temperature, coordinate
% of the minumum temperature pixel, mean temperature
textFilename = strcat(YYYY{index},'-', MM{index},'-', DD{index},'-', hh{index},...
    '.txt');

fileID = fopen(textFilename,'w');
fprintf(fileID,strcat('%-25s %3dC %6d pixels \n',...
    '%-25s %3dC %6d pixels \n',...
    '%-25s %3dC %6d pixels,\n'), ...
    'Cover threshold' ,T_cover, min_pix_cover, ...
    'Core threshold' ,T_core, min_pix_core, ...
    'Most convective threshold' ,T_most, min_pix_most);
% Insert first row
fprintf(fileID,'%03s, %6s, %6s, %6s, %6s, %6s, %6s\n', ...
    'region', '#pixels', 'area(km2)', 'distance(km)',...
    'minimum_temperature', 'min_temp_pixel_coord','mean_temperature');

%% Main program, reads/loads and process temperature/lat/lon data from cptec files
% Start loop counter
n = 1;
while(1)
    %% Format filename
%     image_name = strcat('S10635346_', YYYY{index}, MM{index}, DD{index}, hh{index}, mm{index});
%     file_nc = strcat(filepath_nc, image_name, '.nc');

    image_name = path_nc{n};
    file_nc{n} = image_name;
    % Check if it exists in the filenames cell array (data folder)
%     plotnetcdf(file_nc{n},  'titulo', [-115.98 -25.01  -55.98  34.98], 'asd', -32, 0)
    plotnetcdf
    break
    
    if ~ismember(file_nc{n}, path_nc)
        [MM{index}, DD{index}, hh{index}, mm{index}] = addMinutes(MM{index}, DD{index}, hh{index}, mm{index}, mmEnd{index});
        continue
    end
    
    %% Load/Save netcdf4 file into variables
    if strcmp(load_data, 'Yes')
        load(strcat('./data_mat/', image_name, '.mat'));
    else
        % Get the latitudes values from the NetCDF
        lats = ncread(char(file_nc), 'lat');
        % Get the longitudes values from the NetCDF
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
        fprintf('Netcdf Data saved to .mat\n')
    end
    
    %% Plot Cloud Top Temperatures
    if n == 1
        % temp_plot is the plot object for temperature data
        temp_plot = imagesc('XData', plottedLons, 'YData', plottedLats, 'CData', plottedTemp);
        % patch_fov is the plot object for the camera fov display
        patch_fov = patch([1,1], [2,2], 'red', 'FaceAlpha', 0.2, 'visible', 'off');
        % Set axis boundaries
        %         axis([plottedLons(1), plottedLons(end)+0.1, plottedLats(1), plottedLats(end)+0.1]);
        axis([min_lon(index), max_lon(index), min_lat(index), max_lat(index)]);
        %% Mode flag
        area_mode = false;
    else
        % temperature data plot is not generated on a new scan, instead the
        % original plot object data is updated
        set(temp_plot, 'XData', plottedLons, 'YData', plottedLats, 'CData', plottedTemp);
        % Show the temperature colobar
        %         set(cb, 'visible', 'off')
    end
    %% Plot title and country outlines
    % Draw title with current scan time
    title(ax, [YYYY{index}, '/', MM{index}, '/', DD{index},' - ', hh{index}, ':', mm{index}], 'FontSize', 16);
    
    % Move countries and states lines up
    % Plot objects are not generated again on a new scan, instead they are moved
    % on top of other plot objects
    
    % uistack(Countries, 'top')
    % uistack(States, 'top')
    uistack(Stations, 'top')
    
    %% Plot camera observation lines
    % Plot stations fov script
    plot_stations_fov
    %% Stop script and wait for input
    if fig.CurrentCharacter ~= '4'
        area_mode = false;
    end
    
    if not(area_mode)
        waitforbuttonpress
        disp(strcat('key pressed: ', fig.CurrentCharacter))
    end
    
    %% Input options
    %% '4' - Run scripts
    % run area calc script, lightning script and go to next scan.
    if fig.CurrentCharacter == '4'
        area_mode = true;
        
        % Script to show area calculation processes
        % area_process_comparison

        % Run cloud area and temp script, the temperature values/colors are:
        % Temperature: Meets requirements (tresholds), does not meet req.
        % -32: green, light green; 
        % -52: red, yellow; 
        % -72: blue, cyan
        getIsolatedAreas_custom
        
        % Display CG lightning location 
        % light_spr_goes
        
        % Move station fov display on top
        uistack(patch_fov, 'top');
        
        % Hide station fov display 
        % set(patch_fov, 'visible', 'off')
        waitforbuttonpress
    end
    
    % If pressed '4' go to next scan 
    if fig.CurrentCharacter == '4'
        n = n + 1;
        [MM{index}, DD{index}, hh{index}, mm{index}] = addMinutes(MM{index}, DD{index}, hh{index}, mm{index}, mmEnd{index});
    end
    %% 'd' Next data scan
    % go to next scan 
    if fig.CurrentCharacter == 'd'
        %         getIsolatedAreas_custom
        %         light_spr_goes
        n = n + 1;
        [MM{index}, DD{index}, hh{index}, mm{index}] = addMinutes(MM{index}, DD{index}, hh{index}, mm{index}, mmEnd{index});
    end
    %% 'a' Previous data scan
    % go back to previous scan 
    if fig.CurrentCharacter == 'a'
        %         getIsolatedAreas_custom
        %         light_spr_goes
        n = n - 1;
        [MM{index}, DD{index}, hh{index}, mm{index}] = subMinutes(MM{index}, DD{index}, hh{index}, mm{index}, mmEnd{index});
    end
    
    %% Write to video
    if strcmp(record, 'Yes')
        pause(0.01)
        frame = getframe(fig);
        writeVideo(writerObj,frame);
    end
    %% End script
    % End script at the end date/time
    if strcmp(DD{index}, DDEnd{index}) && strcmp(hh{index}, hhEnd{index}) && strcmp(mm{index}, mmEnd{index})
        break
    end
    
end
%% Close file objects
% Closes the text and video file objects after processing all scans.
% If the script is manually terminated, i.e. with ctrl+c, the following commands
% must be run manually on the Command Window.
fclose(fileID);
close(writerObj);