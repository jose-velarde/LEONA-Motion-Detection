function [stormarea, pixarea] = area_temp_no_dialog(temp, lons, lats, x, y, T)

fprintf('Processing...\n')

outimage = temp;
cr = [x y];

listpix = zeros(1,2);
pixarea = zeros(1,2);

k = 1;
kp = 1;
s = 1;

v(1) = cr(2);
v(2) = cr(1);

[pixarea k listpix kp] = newtryneighboors(pixarea, k, listpix, kp, outimage, v, T);

v = listpix(kp-1,:);
listpix(kp-1,:) = [];
kp = kp - 1;

while kp>1 %~isempty(listpix)
    [pixarea k listpix kp] = newtryneighboors(pixarea, k, listpix, kp, outimage, v, T);

    if kp>1
        kp = kp - 1;
        v = listpix(kp,:);
        listpix(kp,:) = [];
    end
    if k>= s*1000 && k<=(s+1)*1000
        ih = k;
        s=s+1;
    end
end

plot(lons(pixarea(:,2)), lats(pixarea(:,1)),'.k', 'Color', 'blue');

area_per_pixel = 2*2;
stormarea = area_per_pixel * size(pixarea,1);
% for k=1:size(pixarea,1)
%     stormarea = stormarea + sum(sum( dA(pixarea(k,1),pixarea(k,2)) ));
% end
end