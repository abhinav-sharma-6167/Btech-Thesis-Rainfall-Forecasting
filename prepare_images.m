function [time1,time2,time1_pad,time2_pad,time2_nf]=prepare_images(file1,file2)
% Function that takes in the two files to be correlated

% and prepares them for the correlation procedure. Outputs
% from this function are the two filtered numerical fields,
% the two numerical fields filtered and padded with zeros,
% and the second field in its original form.
% Declare global variables
global FILTER_ROWS FILTER_COLS RAIN_THRESH TOTAL_ROWS
global TOTAL_COLS HALFSIZE MAX_SHIFT 
% Load input files
time1 = load(file1);
time2_nf = load(file2);
% Filter the images prior to correlation
time1 = st_filt(time1, FILTER_ROWS, FILTER_COLS);
time2 = st_filt(time2_nf, FILTER_ROWS, FILTER_COLS);
% Eliminate the non-exceeding rainfall values. 20
time1(time1 < RAIN_THRESH) = 0;
time2(time2 < RAIN_THRESH) = 0;
% Check to ensure that the input files are of the same size
if (size(time1) ~= size(time2))
    disp('Files not the same size')
    return
end
% Define global variables dealing with the size of the data 30
[TOTAL_ROWS,TOTAL_COLS] = size(time1);
% Pad fields with zeros so that the correct sizes of sub-regions
% can be made without errors due to exceeding size of the matrix.
time2_pad = padarray(time2,[HALFSIZE HALFSIZE],0,'both');
time1_pad = padarray(time1,[MAX_SHIFT MAX_SHIFT],0,'both');