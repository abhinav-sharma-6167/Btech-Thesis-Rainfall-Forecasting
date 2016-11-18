function [filenames, filecount] = read_batch_file(batch_file_name)
% Function to obtain contents of a batch file of filenames. Takes the
% batch filename as an input and returns a list of filenames from within
% the batch file and a count of the number of filenames found.
% Open batch file
%batch_file_name
batch_fid = fopen(batch_file_name, 'r');
% Initialize file counter
filecount = 0; 
% Get number of lines (files) in batch file
while fgetl(batch_fid) ~= -1
    filecount = filecount + 1;
end

% Reset file position indicator
frewind(batch_fid);
% Get filenames from file 
for g=1:filecount
    filenames(g,:) = fgetl(batch_fid);
end