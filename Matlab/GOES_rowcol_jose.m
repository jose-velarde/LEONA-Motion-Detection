%% Matlab configuration
beep off;
warning('off');
clear all
try
    fclose(fileID);
    close(writerObj);
catch
end
%% 
% Pixel Area -> 3.4047
% lon: deltaAngleToArc(32,64,32,64.018) _> 1.6992
% lat: deltaAngleToArc(32,64,32.018,64) -> 2.0037
% Sprite 1
% deltaAngleToArc(-28.812507, -66.937308, -33.835, -64.489)

%
% Rectangular Projectiong Grid size (degrees)
step = 0.018;
% Yes: Load lightnings position. No: Read lightnings position
load_cg_data = 'No';
% Yes: Load rectangular projection. No: Calculate projection
load_rect_proj = 'Yes';
% Get regions?
t_cover = 'Yes';
t_core = 'Yes';
t_most = 'Yes';
%% OBSERVATION NIGHT %%
% Select observation night 1 to 9
index = 1;
%% Set temperature, area and distance thresholds for tracking
% colors
hot = [.85, .41, .09];
warmer = [.87, .42, .06];
warm = [.96, .83, .16];
tepid = [.44, .75, .25];
breeze = [0, .99, 1];
cool = [0, .57, .58];
chilly = [.32, .65, .98];
cold = [.02, .20, 1];

% Cloud cover
T_cover = -34;
% min_pix_cover = 300;
min_pix_cover = 5;
dist_cover = 4000;

% Cloud convection cores
T_core = -54;
% min_pix_core = 30;
min_pix_core = 5;
dist_core = 4000;

% Cloud most convective cores
T_most = -70;
min_pix_most = 2;
dist_most = 4000;
%% Set colorbar threshold, temperatures above are shown in grayscale
T_cb_threshold = T_cover;
%% Observation dates start and end time
% Set the date and times for observation start and end for the 9 observations
% nights

% SMS = 1
% Anillaco = 2
% La Maria = 3

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
hh      = {'20'  ,'21'  ,'01'  ,'19'  ,'04'  ,'01'  ,'16'  ,'09'  ,'16'  };
mm      = {'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  };
ss      = {'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  ,'00'  };
DDEnd   = {'14'  ,'03'  ,'31'  ,'29'  ,'03'  ,'15'  ,'13'  ,'01'  ,'27'  };
hhEnd   = {'12'  ,'14'  ,'00'  ,'05'  ,'00'  ,'04'  ,'05'  ,'23'  ,'11'  };
mmEnd   = {'10'  ,'10'  ,'10'  ,'10'  ,'10'  ,'15'  ,'15'  ,'15'  ,'15'  };
%% Set the visualization extent (min lon, max lon, min lat, max lat)
minlon = [-70    -70    -70    -65    -70    -70    -70    -70    -70];
maxlon = [-56    -40    -40    -40    -25    -40    -45    -55    -50];
minlat = [-36    -50    -40    -40    -50    -45    -45    -40    -45];
maxlat = [-28    -25    -25    -20    -20    -28    -20    -25    -25];
%% Set up new plot (rect)
scrsz = get(groot,'ScreenSize');
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
% set(ax3, 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '-', 'GridColor', 'white', 'LineWidth', 0.1, 'GridAlpha', 1);

%% Define colormap and colorbar (rect)
% The following sets the colorbar from 20C to -90C
cmin = 90;
cmax = 20;
% The following set gray scale for positive temperature, and jet colormap for
% negative temperatures
custom_gray = gray(80);
cm3 = colormap([jet(cmin+T_cb_threshold); flipud(custom_gray(end+1-(cmax-T_cb_threshold):end, :))]);
% cm3 = colormap([jet(cmin+T_threshold); flipud(gray(cmax-T_threshold))]);
% Configure colorbar
cb3 = colorbar;
caxis([-(cmin) cmax ]);
caxis('manual')
title(cb3,'Cloud top temperature (C)')
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
%% Plot LEONA station markers
% The plot object is 'Stations'
Stations = plot(ax3, stations_lon, stations_lat, 'pblack', 'MarkerSize', 15,'MarkerFaceColor', 'm');

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
%% Define .nc files path (Geo)
% Folder with GOES .nc data, folder tree structure by goes-downloader
filepath_nc = strcat('C:\Users\sauli\Downloads\Soft_Tesis\OpenCV\GOES data\noaa-goes16\ABI-L2-CMIPF');
% Set file prefix
if strcmp(YYYY{index}, '2018')
    nc_file_prefix = 'OR_ABI-L2-CMIPF-M3C13_G16_s';
elseif strcmp(YYYY{index}, '2019')
    nc_file_prefix = 'OR_ABI-L2-CMIPF-M6C13_G16_s';
end
%% Set color mask for temperature analysis
% Because Imagesc is used to plot, plot colors depend on the temperature value
% so the temperature matrix is divided by ranges and each range is assigned to a
% value, ie, a value of 5 is the color gray, a value of -42 is the color green.

% Warm mask: 20C -> T_general_cover, gray colored
warm_mask = 5;
% General cover mask: T_general_cover -> T_convective_core,
% light green and darker green
T_cover_mask = -42;         % green
tcoverIn_color = warm; % darker green
tcoverOut_color = hot; % darker green

% Convective cores mas: T_core -> T_most_convective_core
T_core_mask = -52;          % red
tcoreIn_color = breeze;    % red
tcoreOut_color = cool;   % yellow

% Most convective cores mask: T_most_convective_core -> -90C
T_most_mask = -72;          % blue
tmostIn_color = cold;    % blue
tmostOut_color = chilly;   % cyan
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
%% Video writer object
% record = 'Yes';
fig3.CurrentCharacter = '0';
record = 'Yes';
if strcmp(record, 'Yes')
    aviFilename = strcat(YYYY{index},'-', MM{index},'-', DD{index},'-', hh{index}, mm{index},'.avi');
    writerObj = VideoWriter(aviFilename);
    writerObj.FrameRate = 1;
    open(writerObj);
    fig.CurrentCharacter = '4';
end
%% Initialize Aux variables
julian_day = cell(1000);
ktt_aux = 1;
%% Hardcoded
% Custom start time
% DD{index} = '14';
% hh{index} = '05';
% mm{index} = '00';

while 1
    %% Format filename
    julian_day{ktt_aux} = monthDayToJulianDay(MM{index}, DD{index});
    image_name = strcat(nc_file_prefix, YYYY{index}, julian_day{ktt_aux}, hh{index}, mm{index});
    file = dir(fullfile(filepath_nc, YYYY{index}, julian_day{ktt_aux}, hh{index},strcat(image_name, '*.nc')));
    
    % Check if it exists in the filenames cell array (data folder)
    if isempty(file)
        [MM{index}, DD{index}, hh{index}, mm{index}] = addMinutes(MM{index}, DD{index}, hh{index}, mm{index}, mmEnd{index});
        continue
    end
    
    filename = fullfile(filepath_nc, YYYY{index}, julian_day{ktt_aux}, hh{index},file.name);
    title(ax3, ['Rectangular projection ', YYYY{index}, '/', MM{index}, '/', DD{index},' - ', hh{index}, ':', mm{index}], 'FontSize', 16);
    %% Read data from files (Geo)
    goes = flipud(rot90(ncread(filename, 'CMI')-273.15));
    if ktt_aux == 1
        %% Load geo grid data
        fid = fopen('goes16_2km_lat.bin');
        fid2 = fopen('goes16_2km_lon.bin');

        latarray = flipud(rot90(fread(fid,[5424,5424],'float64')));
        lonarray = rot90(fread(fid2,[5424,5424],'float64'));
        
        
        %% Get row/col of the max/min lat/lon (Geo)
        latsize = size(latarray,1);
        lonsize = size(latarray,2);

        [rarray carray] = size(goes);

        dlat = (latarray - minlat(index)); % .^ 2;		% create array of lat variances
        [dum latmin] = min(abs(dlat));	    % find min for each col
        % Create vector array with pixel coordinates for lat
        xdlat = [latmin; 1:carray]';        % latmin gives rows

        dlon = (lonarray - minlon(index)); % .^ 2;		% create array of lon variances
        [dum, lonmin] = min(abs(dlon'));	    % find min for each row
        % Create vector array with pixel coordinates for lon
        xdlon = [1:rarray; lonmin]';        % lonmin gives colum
        u = intersect2(xdlat,xdlon,'rows');

        lrow = u(1,1);
        fcol = u(1,2);

        dlat = (latarray - maxlat(index)); % .^ 2;		% create array of lat variances
        [dum latmin] = min(abs(dlat));	    % find min for each col
        % Create vector array with pixel coordinates for lat
        xdlat = [latmin; 1:carray]';        % latmin gives rows

        dlon = (lonarray - maxlon(index)); % .^ 2;		% create array of lon variances
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
        
        outlon = lonarray(frow:lrow, fcol:lcol);
        outlat = latarray(frow:lrow, fcol:lcol);
    end
    %% Set temperature data between extremes
    outimage = goes(frow:lrow,fcol:lcol);
    
    %% Geo to rectangular proj (rect)
    % Load/Generate rectangular projection grid
    if strcmp(load_rect_proj, 'Yes')
        load(strcat('./data_mat/', 'OR_ABI-L2-CMIPF-M3C13_G16_s', YYYY{index}, julian_day{1}, '_rect_proj', '.mat'));
    else
        fprintf('Processing data to calculate rectangular grid projection\n')
        USAPixToLatLon
        save(strcat('./data_mat/', 'OR_ABI-L2-CMIPF-M3C13_G16_s', YYYY{index}, julian_day{1}, '_rect_proj', '.mat'), 'coutrows', 'coutcols','lns', 'lts');
        fprintf('Finished saving rect grid\n')
        % Exit the script.
        return
    end
    % Map Geo pixels to Rectangular grid
    coutimage = -inf*ones(size(coutrows));          % create new image matrix
    [rz, cz] = size(coutrows);
    
    for k1 = 1:rz,
        for k2 = 1:cz,
            rr = coutrows(k1,k2);   	             % get row value
            cc = coutcols(k1,k2);		             % get col value
            if rr ~= 0 && cc ~= 0,			         % check for valid (non-zero)
                coutimage(k1,k2) = outimage(rr,cc);   % fill with values from original image
            end
        end
    end
    %% Plot Cloud Top Temperatures
    couttemp = coutimage;
    if ktt_aux == 1
        % couttemp_plot is the plot object for temperature data
        couttemp_plot = pcolor(lns,lts,couttemp);
        set(couttemp_plot, 'EdgeColor', 'none')
        % patch_fov is the plot object for the camera fov display
        patch_fov = patch([1,1], [2,2], 'red', 'FaceAlpha', 0.2, 'visible', 'off');
        patch_fov2 = patch([1,1], [2,2], 'red', 'FaceAlpha', 0.2, 'visible', 'off');
        
        % Set axis boundaries
        axis([minlon(index), maxlon(index), minlat(index), maxlat(index)]);
    else
        % temperature data plot is not generated on a new scan, instead the
        % original plot object data is updated
        set(couttemp_plot, 'XData', lns, 'YData', lts, 'CData', couttemp);
        % Show the temperature colobar
%         set(cb, 'visible', 'off')
    end
    
    %% Plot camera observation lines
    % Plot stations fov script
    plot_stations_fov
    uistack(Countries, 'top')    
    %% Wait for  input
    if fig3.CurrentCharacter ~= '4'
        waitforbuttonpress
    end
    
    if fig3.CurrentCharacter == '4'
        getIsolatedAreas_goes
        light_spr_goes_custom
        
        all_temperature{ktt_aux} = couttemp;
        all_core_regions{ktt_aux} = current_labels(~cellfun(@isempty, {current_labels.label}));
        all_most_regions{ktt_aux} = current_labels3(~cellfun(@isempty, {current_labels3.label}));
        all_cover_regions{ktt_aux} = current_labels2(~cellfun(@isempty, {current_labels2.label}));

        all_sprites{ktt_aux} = sprites_temp;
        all_pos_lightning{ktt_aux} = pos_lightning;
        all_neg_lightning{ktt_aux} = neg_lightning;
        all_lightning{ktt_aux} = tot_lightning;

%         pause(0.00001)
%         waitforbuttonpress

        [MM{index}, DD{index}, hh{index}, mm{index}] = addMinutes(MM{index}, DD{index}, hh{index}, mm{index}, mmEnd{index});
        ktt_aux = ktt_aux + 1;
    end

    if fig3.CurrentCharacter == 'q'
        break
    end
    if fig3.CurrentCharacter == 'd'
        [MM{index}, DD{index}, hh{index}, mm{index}] = addMinutes(MM{index}, DD{index}, hh{index}, mm{index}, mmEnd{index});
        ktt_aux = ktt_aux + 1;
    end
    if fig3.CurrentCharacter == 'a'
        [MM{index}, DD{index}, hh{index}, mm{index}] = subMinutes(MM{index}, DD{index}, hh{index}, mm{index}, mmEnd{index});
        ktt_aux = ktt_aux - 1;
        if ktt_aux == 0
            break
        end
    end
    %% Write to video.           
    uistack(patch_fov, 'top')    
    uistack(patch_fov2, 'top')    
    uistack(Stations, 'top')

    
    if strcmp(record, 'Yes')
        pause(0.01)
        frame = getframe(fig3);
        writeVideo(writerObj,frame);
        imwrite(frame.cdata, strcat('png\', num2str(current_time), '.png'));
    end
    
   
    if strcmp(strcat(DD{index}, hh{index}, mm{index}), strcat(DDEnd{index}, hhEnd{index}, mmEnd{index}))
        break
    end
end
fclose(fileID);
close(writerObj);
%% Save workspace
save(strcat('C:\Users\sauli\Downloads\Soft_Tesis\OpenCV\Matlab\workspace_',DD{index},'-',MM{index},'-',YYYY{index},'.mat'), '-v7.3')

%% Close file objects
% Closes the text and video file objects after processing all scans.
% If the script is manually terminated, i.e. with ctrl+c, the following commands
% must be run manually on the Command Window.
% fclose(fileID);
% close(writerObj);
