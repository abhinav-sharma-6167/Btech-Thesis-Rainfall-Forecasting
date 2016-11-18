function file_writer(matrix, outputfile)
% Function that takes in a matrix and writes it to a file. Takes matrix
% and output file name as input and has no outputs.
% Open output file
out_fid = fopen(outputfile, 'w');
% Get size of input field
[rows, cols] = size(matrix);

% Loop over all rows and columns.
for r=1:rows
    for c=1:cols
    % Write each pixel to output file
        fprintf(out_fid,' %6.3f ', matrix(r,c));
    end
    % Move to new row
    fprintf(out_fid, '\n');
end

% Close output file
fclose(out_fid);