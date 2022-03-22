
% USAPixToLatLon convert outimage to lat-lon image. The resulting matrix will be a
% retangular/square image containing only pixels inside the latmax/latmin/lonmax/lonmin limits.
% The variables outrows and coutcols will be used in subsequent maps covering the
% same lat-lon area without having to recalculate them.

% Increment stepping: from minlatplot to maxlatplot
deltalatplot = -step;
lts = maxlatplot:deltalatplot:minlatplot;
lts = lts';

% Increment stepping: from minlonplot to maxlonplot
% deltalonplot = 0.018;
deltalonplot = step;
lns = minlonplot:deltalonplot:maxlonplot;
lns = lns';

coutrows = zeros(length(lts),length(lns));
coutcols = coutrows;

% Create matrices containing computed rows and columns
[rz, cz] = size(coutrows);			    % get size of coutimage
[rarray, carray] = size(outlat);
dlon = cell(1,5000);
xdlon = cell(1,5000);
for k1=1:rz,							% for each row (latitude)
    %     if isempty(olat) || lts(k1) ~= olat
    %         olat = lts(k1);
    dlat = (outlat - lts(k1)); % .^ 2;		% create array of lat variances
    [dum, latmin] = min(abs(dlat));	    % find min for each col
    
    % Create vector array with pixel coordinates for lat
    xdlat = [latmin; 1:carray]';        % latmin gives rows
    %     end
    for k2=1:cz,						% for each col (longitude)
        if k1 == 1
            dlon{k2} = (outlon - lns(k2)); % .^ 2;		% create array of lon variances
            [dum, lonmin] = min(abs(dlon{k2}'));	    % find min for each row
            
            % Create vector array with pixel coordinates for lon
            xdlon{k2} = [1:rarray; lonmin]';        % lonmin gives colum
        end
        
        u = intersect2(xdlat,xdlon{k2},'rows');
        if ~isempty(u),
            r = u(1,1);
            c = u(1,2);
        else
            r = nan;
            c = nan;
        end
        % end latlontopix
        if ~isempty(r) && ~isempty(c),	% if there is a solution
            coutrows(k1,k2) = r;
            coutcols(k1,k2) = c;
        end
    end
end
