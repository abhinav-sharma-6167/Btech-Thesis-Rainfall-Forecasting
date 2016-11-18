function [actual_weather] = get_actual_file(text_input, actdir)
% Takes a forecast file produced by the MATLAB Storm Tracker and determines
% the actual file that corresponds to the forecast. Takes as input the
% forecast file and the directory name where the file should be located and
% returns the full path name of the actual file. Does not test if increase
% in time goes into another month or year(yet)
% Extract the initial year from the forecast file
year_str = text_input(end-15:end-12);
year = str2num(year_str); 
% Extract the initial month from the forecast file
month_str = text_input(end-19:end-18);
month = str2num(month_str);
% Extract the initial day from the forecast file
day_str = text_input(end-17:end-16);
day = str2num(day_str);
% Extract the initial hour from the forecast file 
hour_str = text_input(end-11:end-10);
hour = str2num(hour_str);
% Extract the initial minute from the forecast file
min_str = text_input(end-9:end-8);
min = str2num(min_str);
% Extract the forecast lead time from the forecast file
t_f = text_input(end-6:end-4);
t_f = str2num(t_f); 
% Increment the initial minute by the forecast time
min_out = min+t_f;

% Determine the house increment
hour_inc =floor(min_out/60);
% Determine the output minute
if min_out >=60
    min_out = mod(min_out,60); 
end
% Increment the hour by the minute excess
hour_out = hour + hour_inc;
% Determine the day increment
day_inc =foor(hour_out/24);
% Determine the output hour
if hour_out>=24 
    hour_out = mod(hour_out,24);
end
% Determine the output day
day_out = day+day_inc;
% Write the full path name for the actual file into a string
actual_weather = sprintf ('%s%s%02d%02d%s%02d%02d%s', actdir,'/w',month,day_out,year_str,hour_out,min_out,'.001.txt');