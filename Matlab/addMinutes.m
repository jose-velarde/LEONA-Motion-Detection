function [MM, DD, hh, mm] = addMinutes(MM, DD, hh, mm, minutes)
    mm = str2double(mm) + str2double(minutes);
    if mm == 60
        mm = '00';
        hh =  num2str(str2double(hh) + 1);
        if length(hh) == 1
            hh = strcat('0', hh);
        end
        if strcmp(hh, '24')
            hh = '00';
            DD =  num2str(str2double(DD) + 1);
            if size(DD) == 1
                DD = strcat('0', DD);
            end
            if strcmp(DD, '31')
                DD = '01';
                MM = '12';
            end
        end
    else
        mm = num2str(mm);
    end
end