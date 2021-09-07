%% Matlab configuration
% close all
% hold off;
beep off;
warning('off');
% set(0,'DefaultFigureWindowStyle','docked')
%% Define paths
filepath_jpg = 'C:/Users/sauli/Downloads/Soft_Tesis/OpenCV/CPTEC data/2019_hd/';
filenames_jpg = dir(fullfile(filepath_jpg, '*.jpg'));
files = {filenames_jpg.name};
path_jpg = strcat(filepath_jpg, files);
%% declare everything that repeats in the foor loop
% fig = figure(1);
% ax = axes('Parent', fig);
% hold(ax, 'on');
% axis equal;
% 
%% 25/11/2018 16:00 -> 27/11/2018 11:00 25S -> 45S 70W -> 50W
% 40S 
%% 30/11/2018 09:00 -> 01/12/2018 20:00 25S -> 40S 70W -> 55W
%% 10/12/2018 16:00 -> 15/12/2018 08:00 20S -> 45S 70W -> 35W
%10/12/2018 17:00 -> 13/12/2018 05:00 20S -> 45S 70W -> 45W
%13/12/2018 01:00 -> 15/12/2018 08:00 25S -> 45S 70W -> 35W
%% 01/10/2019 04:00 -> 02/10/2019 16:00 20S -> 45S 70W -> 40W
%% 26/10/2019 19:00 -> 30/10/2019 00:00 20S -> 40S 70W -> 25W
%26/10/2019 19:00 -> 29/10/2019 05:00 20S -> 40S 65W -> 40W
%28/10/2019 13:00 -> 30/10/2019 00:00 25S -> 40S 70W -> 25W
%% 01/11/2019 21:00 -> 03/11/2019 14:00 25S -> 40S 70W -> 25W
%% 13/11/2019 15:00 -> 14/11/2019 12:00 25S -> 40S 75W -> 55W

YYYY = '2019';
MM = '11';
DD = '13';
hh = '15';
mm = '00';
ss = '00';

DDEnd = '14';
hhEnd = '12';
mmEnd = '10';

minLat = 25;
maxLat = 40;
minLon = 70;
maxLon = 55;
%% 
[minLatPix, minLonPix] = latlontopix(minLat, minLon);
[maxLatPix, maxLonPix] = latlontopix(maxLat, maxLon);

gifFilename = strcat(YYYY,'-', MM,'-', DD,'-', hh, mm,'.gif');
n = 1;
while(1)
    %% Format filename and check if exists
    file = strcat(filepath_jpg, 'S11635388_', YYYY, MM, DD, hh, mm,'.jpg');
    
    if ~ismember(file, path_jpg)
        [MM, DD, hh, mm] = addMinutes(MM, DD, hh, mm, 10);
        continue
    end
    fig = figure(1);
    imgFile = imread(file);
    imshow(imgFile(minLatPix:maxLatPix, minLonPix:maxLonPix, :))
    axis on
    axis([1, maxLonPix-minLonPix+1, 1, maxLatPix-minLatPix+1]);
    set(gca, 'ytick', 1:117:117*15+1);
    set(gca,'XTickLabels', minLon:-5:maxLon)
    set(gca, 'xtick', 1:117:117*15+1);
    set(gca,'YTickLabels',minLat:5:maxLat)
    text(maxLonPix-minLonPix-175, 20,[YYYY, '/', MM, '/', DD,' - ', hh, ':', mm], 'BackgroundColor', 'white', 'FontSize', 15)
    
    % Capture the plot as an image
    frame = getframe(fig);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    % Write to the GIF File
    if n == 1
        imwrite(imind,cm,gifFilename,'gif', 'Loopcount',inf);
    else
        imwrite(imind,cm,gifFilename,'gif','WriteMode','append');
    end
    n = n + 1;
    pause(0.2);
    [MM, DD, hh, mm] = addMinutes(MM, DD, hh, mm, 10);
    if strcmp(string(DD), DDEnd) && strcmp(string(hh), hhEnd) && strcmp(string(mm), mmEnd)
        break
    end
end

