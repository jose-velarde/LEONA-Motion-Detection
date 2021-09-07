function [MM, DD, hh, mm] = addMinutes(MM, DD, hh, mm, minutes)
    mm = str2num(mm) + minutes;
    if mm == 60
        mm = '00';
        hh =  num2str(str2num(hh) + 1);
        if length(hh) == 1
            hh = strcat('0', hh);
        end
        if hh == '24'
            hh = '00';
            DD =  num2str(str2num(DD) + 1);
            if size(DD) == 1
                DD = strcat('0', DD);
            end
            if DD == '31'
                DD = '01';
                MM = '12';
            end
        end
    else
        mm = num2str(mm);
    end
end