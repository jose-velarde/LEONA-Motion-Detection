path = 'campos\';
hora = '012327'; %hora principal do evento
k = 30; %número de campos para somar
n_f = 203; %número do último campo anterior ao evento
n_i = n_f-k;
if n_i < 100
    bmp = imread(strcat(path,strcat(hora,'_wide_az_10'),num2str(n_i),'.bmp'));
elseif n_i <10
    bmp = imread(strcat(path,strcat(hora,'_wide_az_100'),num2str(n_i),'.bmp'));
else
    bmp = imread(strcat(path,strcat(hora,'_wide_az_1'),num2str(n_i),'.bmp'));
end
for i=n_i:n_f
    if i < 100
        bmp = bmp + imread(strcat(path,strcat(hora,'_wide_az_10'),num2str(i),'.bmp'));
    elseif i <10
        bmp = bmp + imread(strcat(path,strcat(hora,'_wide_az_100'),num2str(i),'.bmp'));
    else
        bmp = bmp + imread(strcat(path,strcat(hora,'_wide_az_1'),num2str(i),'.bmp'));
    end
    
end
fig = imshow(bmp);
saveas(fig, strcat('mapaestelar_',hora,'_',num2str(k),'campos'),'bmp');
