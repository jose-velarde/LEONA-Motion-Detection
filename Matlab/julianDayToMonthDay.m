function [month, day] = julianDayToMonthDay(year, julian_day)
% Valid only for non-bisiest years

julian_day = str2double(julian_day);

if julian_day <= 31
  day = julian_day;
  month = '01';
elseif julian_day >= 31 && julian_day <= (31+28)
  day = julian_day - 31;
  month = '02';
elseif julian_day >= (31+28) && julian_day <= (31+28+31)
  day = julian_day -  (31+28);
  month = '03';
elseif julian_day >= (31+28+31) && julian_day <= (31+28+31+30)
  day = julian_day - (31+28+31);
  month = '04';
elseif julian_day >= (31+28+31+30) && julian_day <= (31+28+31+30+31)
  day = julian_day - (31+28+31+30);
  month = '05';
elseif julian_day >= (31+28+31+30+31) && julian_day <= (31+28+31+30+31+30)
  day = julian_day - (31+28+31+30+31);
  month = '06';
elseif julian_day >= (31+28+31+30+31+30) && julian_day <= (31+28+31+30+31+30+31)
  day = julian_day - (31+28+31+30+31+30);
  month = '07';
elseif julian_day >= (31+28+31+30+31+30+31) && julian_day <= (31+28+31+30+31+30+31+31)
  day = julian_day - (31+28+31+30+31+30+31);
  month = '08';
elseif julian_day >= (31+28+31+30+31+30+31+31) && julian_day <= (31+28+31+30+31+30+31+31+30)
  day = julian_day - (31+28+31+30+31+30+31+31);
  month = '09';
elseif julian_day >= (31+28+31+30+31+30+31+31+30) && julian_day <= (31+28+31+30+31+30+31+31+30+31)
  day = julian_day - (31+28+31+30+31+30+31+31+30);
  month = '10';
elseif julian_day >= (31+28+31+30+31+30+31+31+30+31) && julian_day <= (31+28+31+30+31+30+31+31+30+31+30)
  day = julian_day - (31+28+31+30+31+30+31+31+30+31);
  month = '11';
elseif julian_day >= (31+28+31+30+31+30+31+31+30+31+30) && julian_day <= (31+28+31+30+31+30+31+31+30+31+30+31)
  day = julian_day - (31+28+31+30+31+30+31+31+30+31+30);
  month = '12';
end

day = double2str(day);

end