function [latPix, lonPix] = latlontopix(lat, lon)
% converts lat lon to pixel coordinates of image file
% lat: 0S -> 55S
% lon: 115W -> 25W
% 117, 117 pixels between 5 degrees S, W

lat = lat / 5;
lon = (115 - lon) / 5 ;
latPix = 926 + lat * 117;
lonPix = 70 + lon * 117;
end