hold on

[C,h] = contour(plottedLons,plottedLats,plottedTemp);

set(h, 'LevelList', [ 0.1 0.2 0.3]);
set(h,'ShowText','on','TextStep',get(h,'LevelStep')*2)
colormap cool

x = reshape(plottedLons,1,numel(plottedLons));
y = reshape(plottedLats,1,numel(plottedLats));
cm = get(h,'ContourMatrix');
index_start = 2;
index_end = cm(2,1)+1;

IN = inpolygon(x,y,cm(1,index_start:index_end),cm(2,index_start:index_end));

for i=2:numel(get(h,'LevelList'))
    index_start = index_end + 2;
    index_end = index_start + cm(2,index_start-1) - 1;
    tmp = inpolygon(x,y,cm(1,index_start:index_end),cm(2,index_start:index_end));
    IN = IN | tmp;
end
plot(x(IN),y(IN),'r+');
hold off
figure
hold on
index_start = 2;
index_end = cm(2,1)+1;
plot(cm(1,index_start:index_end),cm(2,index_start:index_end))
for i=2:numel(get(h,'LevelList'))
    index_start = index_end + 2;
    index_end = index_start + cm(2,index_start-1) - 1;
    plot(cm(1,index_start:index_end),cm(2,index_start:index_end))
end
plot(x(IN),y(IN),'r+')
hold off
