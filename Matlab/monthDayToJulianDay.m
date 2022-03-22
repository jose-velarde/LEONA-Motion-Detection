function julian_day = monthDayToJulianDay(month, day)
% Valid only for non-bisiest years

day = str2double(day);

if strcmp(month, '01')
  julian_day = day;
elseif strcmp(month, '02')
  julian_day = day + 31;
elseif strcmp(month, '03')
  julian_day = day +  (31+28);
elseif strcmp(month, '04')
  julian_day = day + (31+28+31);
elseif strcmp(month, '05')
  julian_day = day + (31+28+31+30);
elseif strcmp(month, '06')
  julian_day = day + (31+28+31+30+31);
elseif strcmp(month, '07')
  julian_day = day + (31+28+31+30+31+30);
elseif strcmp(month, '08')
  julian_day = day + (31+28+31+30+31+30+31);
elseif strcmp(month, '09')
  julian_day = day + (31+28+31+30+31+30+31+31);
elseif strcmp(month, '10')
  julian_day = day + (31+28+31+30+31+30+31+31+30);
elseif strcmp(month, '11')
  julian_day = day + (31+28+31+30+31+30+31+31+30+31);
elseif strcmp(month, '12')
  julian_day = day + (31+28+31+30+31+30+31+31+30+31+30);
end

julian_day = num2str(julian_day);

end