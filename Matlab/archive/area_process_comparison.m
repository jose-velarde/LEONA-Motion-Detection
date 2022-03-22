cursor_point = get(gca, 'CurrentPoint');
lon_cursor = cursor_point(1,1);
lat_cursor = cursor_point(1,2);
disp([lon_cursor lat_cursor]);
[delta_x,x] = min(abs(plottedLons - lon_cursor));
[delta_y,y] = min(abs(plottedLats - lat_cursor));
disp([x y])

tic
[region_area, xy] = area_temp_no_dialog_record(plottedTemp, plottedLons, plottedLats, x, y, -32, fig, writerObj);
%         [region_area, xy] = area_temp_no_dialog(plottedTemp, plottedLons, plottedLats, x, y, -32);

Eliah_Json = toc;
fprintf('%d pixels in %f \n', size(xy, 1), Eliah_Json)
saveas(fig,'eliah_area.png')
waitforbuttonpress

tic
list_pix = floodFillScanlineStack(x, y, plottedTemp(y,x), -32, plottedTemp, plottedLons, plottedLats, fig, writerObj);
Flood_Fill_ScanLine_Stack = toc;
fprintf('%d pixels in %f \n', size(list_pix, 1), Flood_Fill_ScanLine_Stack)
plot(plottedLons(list_pix(:,2)),plottedLats(list_pix(:,1)),'.k', 'color', 'blue');
saveas(fig,'jose_area.png')
waitforbuttonpress

tic
[list_pix, tempSelecionada] = floodfill_caio(writerObj,plottedTemp, [y x], -32, 2, plottedLons,plottedLats);
floodfill_caio = toc;
fprintf('%d pixels in %f \n', size(list_pix, 1), floodfill_caio)
plot(plottedLons(list_pix(:,2)),plottedLats(list_pix(:,1)),'.k', 'color', 'blue');
saveas(fig,'caio_area.png')
waitforbuttonpress
continue