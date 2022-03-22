function [MM, DD, hh, mm] = subMinutes(MM, DD, hh, mm, minutes)
mm = str2double(mm) - str2double(minutes);
if mm == -10 || mm == -15
    if mm == -10
        mm = '50';
    else
        mm = '45';
    end
    hh =  num2str(str2double(hh) - 1);
    if length(hh) == 1
        hh = strcat('0', hh);
    end
    if strcmp(hh, '-1')
        hh = '23';
        DD =  num2str(str2double(DD) - 1);
        if size(DD) == 1
            DD = strcat('0', DD);
        end
        if strcmp(DD, '00')
            DD = '31';
            MM = '11';
        end
    end
else
    mm = num2str(mm);
    if length(mm) == 1
        mm = strcat('0', mm);
    end
end
end