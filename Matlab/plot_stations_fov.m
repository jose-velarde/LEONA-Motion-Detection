%% Night (1): 05:00 -> 06:00 150 Anillaco 2
% Night (1): 06:00 -> 08:00 155 Anillaco

current_time = str2double(strcat(YYYY{index}, MM{index}, DD{index}, hh{index}, mm{index}));

if isAfter(current_time, 201911130500)...
        && isBefore(current_time, 201911140500)
    origin = [stations_lon(2), stations_lat(2)];
    radius = 5 ;

    azimuth = 150;
    plot_fov(patch_fov, origin, azimuth, radius, 'red');
end

if isAfter(current_time, 201911140500)...
        && isBefore(current_time, 201911140600)
    origin = [stations_lon(2), stations_lat(2)];
    radius = 5 ;

    azimuth = 150;
    plot_fov(patch_fov, origin, azimuth, radius, 'green');
end

if isAfter(current_time, 201911140600)...
        && isBefore(current_time, 201911140800)
    origin = [stations_lon(2), stations_lat(2)];
    radius = 5 ;

    azimuth = 155;
    plot_fov(patch_fov, origin, azimuth, radius, 'green');
end
%% Night (2): 01:00 -> 04:00 195 SMS 1
% Night (2): 04:00 -> 08:00 180 SMS


if isAfter(current_time, 201911020100)...
        && isBefore(current_time, 201911020400)
    origin = [stations_lon(1), stations_lat(1)];
    radius = 10 ;   % 1 degree ~110km
    
    azimuth = 195;
    plot_fov(patch_fov, origin, azimuth, radius, 'green');
end

if isAfter(current_time, 201911020400)...
        && isBefore(current_time, 201911020800)
    origin = [stations_lon(1), stations_lat(1)];
    radius = 10 ;   % 1 degree ~110km

    azimuth = 180;
    plot_fov(patch_fov, origin, azimuth, radius, 'green');
end
%% Night (3) - SMS 1

% Night (3): 23:00 -> 01:00 180 SMS 1
if isAfter(current_time, 201910282300)...
        && isBefore(current_time, 201910290100)
    origin = [stations_lon(1), stations_lat(1)];
    radius = 10 ;   % 1 degree ~110km

    azimuth = 180;
    plot_fov(patch_fov, origin, azimuth, radius, 'green');
end
% Night (3): 01:00 -> 02:00 160 SMS
if isAfter(current_time, 201910290100)...
        && isBefore(current_time, 201910290200)
    origin = [stations_lon(1), stations_lat(1)];
    radius = 10 ;   % 1 degree ~110km

    azimuth = 160;
    plot_fov(patch_fov, origin, azimuth, radius, 'green');
end
% Night (3): 02:00 -> 02:30 180 SMS
if isAfter(current_time, 201910290200)...
        && isBefore(current_time, 201910290230)
    origin = [stations_lon(1), stations_lat(1)];
    radius = 10 ;   % 1 degree ~110km

    azimuth = 180;
    plot_fov(patch_fov, origin, azimuth, radius, 'green');
end
% Night (3): 02:30 -> 05:00 190 SMS
if isAfter(current_time, 201910290230)...
        && isBefore(current_time, 201910290500)
    origin = [stations_lon(1), stations_lat(1)];
    radius = 10 ;   % 1 degree ~110km

    azimuth = 190;
    plot_fov(patch_fov, origin, azimuth, radius, 'green');
end
% Night (3): 05:00 -> 08:30 235 SMS
if isAfter(current_time, 201910290500)...
        && isBefore(current_time, 201910290830)
    origin = [stations_lon(1), stations_lat(1)];
    radius = 10 ;   % 1 degree ~110km

    azimuth = 235;
    plot_fov(patch_fov, origin, azimuth, radius, 'green');
end
% Night (3) - La Maria 3
% Night (3): 04:00 -> 06:00 130 La Maria 3
if isAfter(current_time, 201910290400)...
        && isBefore(current_time, 201910290600)
    origin = [stations_lon(3), stations_lat(3)];
    radius = 4.5 ;   % 1 degree ~110km

    azimuth = 130;
    plot_fov(patch_fov, origin, azimuth, radius, 'green');
end
% Night (3): 06:00 -> 08:30 120 La Maria
if isAfter(current_time, 201910290600)...
        && isBefore(current_time, 201910290830)
    origin = [stations_lon(3), stations_lat(3)];
    radius = 4.5 ;   % 1 degree ~110km

    azimuth = 120;
    plot_fov(patch_fov, origin, azimuth, radius, 'green');
end
%% Night (4): 250 SMS 1
% Night (4): 00:30 -> 01:30 250 SMS 1
if isAfter(current_time, 201910270030)...
        && isBefore(current_time, 201910270130)
    origin = [stations_lon(1), stations_lat(1)];
    radius = 10 ;   % 1 degree ~110km

    azimuth = 250;
    plot_fov(patch_fov, origin, azimuth, radius, 'green');
end

% Night (5): La Maria 3
% Night (5): 05:00 -> 06:00 90 La Maria 3
if isAfter(current_time, 201910020500)...
        && isBefore(current_time, 201910020600)
    origin = [stations_lon(3), stations_lat(3)];
    radius = 4.5 ;   % 1 degree ~110km

    azimuth = 90;
    plot_fov(patch_fov, origin, azimuth, radius, 'green');
end
%% Night (6): Anillaco 2
% Night (6): 02:00 -> 05:00 125 Anillaco
if isAfter(current_time, 201812140200)...
        && isBefore(current_time, 201812140500)
    origin = [stations_lon(2), stations_lat(2)];
    radius = 3.6 ;   % 1 degree ~110km

    azimuth = 125;
    plot_fov(patch_fov, origin, azimuth, radius, 'green');
end
% Night (6): 05:00 -> 06:00 140 Anillaco
if isAfter(current_time, 201812140500)...
        && isBefore(current_time, 201812140600)
    origin = [stations_lon(2), stations_lat(2)];
    radius = 3.6 ;   % 1 degree ~110km

    azimuth = 140;
    plot_fov(patch_fov, origin, azimuth, radius, 'green');
end
% Night (6): 06:00 -> 07:30 130 Anillaco
if isAfter(current_time, 201812140600)...
        && isBefore(current_time, 201812140730)
    origin = [stations_lon(2), stations_lat(2)];
    radius = 3.6 ;   % 1 degree ~110km

    azimuth = 130;
    plot_fov(patch_fov, origin, azimuth, radius, 'green');
end
% Night (6): 06:30 -> 06:45 180 La Maria 3
if isAfter(current_time, 201812140630)...
        && isBefore(current_time, 201812140645)
    origin = [stations_lon(3), stations_lat(3)];
    radius = 4.5 ;   % 1 degree ~110km

    azimuth = 180;
    plot_fov(patch_fov, origin, azimuth, radius, 'green');
end

%% Night (7): Anillaco

%% Night (8): Anillaco 2
% Night (8): 02:00 -> 03:30 190 Anillaco 2
if isAfter(current_time, 201812010200)...
        && isBefore(current_time, 201812010330)
    origin = [stations_lon(2), stations_lat(2)];
    radius = 3.6 ;   % 1 degree ~110km

    azimuth = 190;
    plot_fov(patch_fov, origin, azimuth, radius, 'green');
end

%% Night (9): Anillaco
