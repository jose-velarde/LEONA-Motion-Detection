
function [pixarea, k, listpix, kp] = newtryneighboors(pixarea, k, listpix, kp, outtemp, rc, T)

% neighboors checks all neighboors around pixel with position rc.

    % 'rc' pixel is initialy chosen as a specific point on the map.
    % 'pixarea' variable is used to store pixels position that have never
    % been analysed and has value lower than T. 
    % 'listpix' is a feedback variable. If one of the neighboors of 'rc' pixel 
    % is a border pixel (has value higher than T) than 'listpix' will store
    % those neigboors (except border pixel(s)). These will guarantee the algorithm
    % to surround the border pixel. Each time it finds a border pixel, it uses 
    % the last added pixel on 'listpix' variable as the 'rc' pixel. If no border 
    % pixel is found, all rows on 'listpix' stored on 'delrow' variable are deleted.
    % 'kp' variable represents the number of possible positions that 'rc' still 
    % can assume.
    
r = rc(1);
c = rc(2);
value = []; row = [];
ik = 1; delrow = [];
kb = 1; border = [];

for kr=r-1:r+1
    for kc=c-1:c+1
        rc = [kr kc];
        value = intersect2(pixarea, rc, 'rows');        % ck if pixarea = rc
        if isempty(value)& outtemp(kr,kc) <= T           
            pixarea(k,:) = [kr kc];
            listpix(kp,:) = [kr kc];
            k = k+1;
            kp = kp+1;
        elseif ~isempty(value)                          % for an already chosen pixel
            [dum,row] = intersect(listpix, rc, 'rows'); % intersect ???
            if ~isempty(row)
                delrow(ik) = row;                       % row index from listpix
                ik = ik+1;
            end
        elseif outtemp(kr,kc) >= T 
               border(kb,:) = rc;
               kb = kb+1;
        end
    end    
end 

if isempty(border)
   listpix(delrow,:) = [];
   kp = size(listpix,1) + 1;
end
