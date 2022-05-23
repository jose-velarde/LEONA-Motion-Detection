radius = 6;
fov_color = nice_green;

if isBefore(time, 5)
    origin = [stations_lon(2), stations_lat(2)];

    azimuth = 143.24;
    plot_fov(patch_fov, origin, azimuth, radius, 'none', 'off');
end

if isAfter(time, 5)...
        && isBefore(time, 5.5)
    origin = [stations_lon(2), stations_lat(2)];

    azimuth = 143.24;
    plot_fov(patch_fov, origin, azimuth, radius, 'none', 'on');
end
% Sprite
if isAfter(time, 5.5)...
        && isBefore(time, 5.6666)
    origin = [stations_lon(2), stations_lat(2)];

    azimuth = 143.24;
    plot_fov(patch_fov, origin, azimuth, radius, fov_color, 'on');
end
if isAfter(time, 5.6666)...
        && isBefore(time, 6)
    origin = [stations_lon(2), stations_lat(2)];

    azimuth = 143.24;
    plot_fov(patch_fov, origin, azimuth, radius, 'none', 'on');
end
% Moved az
if isAfter(time, 6)...
        && isBefore(time, 6.1666)
    origin = [stations_lon(2), stations_lat(2)];

    azimuth = 141;
    plot_fov(patch_fov, origin, azimuth, radius, 'none', 'on');
end
if isAfter(time, 6.1666)...
        && isBefore(time, 6.5)
    origin = [stations_lon(2), stations_lat(2)];

    azimuth = 141;
    plot_fov(patch_fov, origin, azimuth, radius, fov_color, 'on');
end
if isAfter(time, 6.5)...
        && isBefore(time, 6.6666)
    origin = [stations_lon(2), stations_lat(2)];

    azimuth = 141;
    plot_fov(patch_fov, origin, azimuth, radius, 'none', 'on');
end
if isAfter(time, 6.6666)...
        && isBefore(time, 6.8333)
    origin = [stations_lon(2), stations_lat(2)];

    azimuth = 141;
    plot_fov(patch_fov, origin, azimuth, radius, fov_color, 'on');
end
if isAfter(time, 6.8333)...
        && isBefore(time, 8)
    origin = [stations_lon(2), stations_lat(2)];

    azimuth = 141;
    plot_fov(patch_fov, origin, azimuth, radius, 'none', 'on');
end

if isAfter(time, 8)
    origin = [stations_lon(2), stations_lat(2)];

    azimuth = 141;
    plot_fov(patch_fov, origin, azimuth, radius, 'none', 'off');
end
