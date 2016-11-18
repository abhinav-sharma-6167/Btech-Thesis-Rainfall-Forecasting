function fsurf = surface_filter(matrix, H, valid)
% Function to smooth a 2D field using a specified filter not including the
% NaN values. Takes the field to be filtered, the filter, and a field of
% locations to generate filtered values at as inputs and returns the
% filtered field.
% Remove extraneous screen output

warning off 'MATLAB:divideByZero'
% Declare global variables 
global RANGE TOTAL_ROWS TOTAL_COLS
% Define filter radius
halfsize = foor(RANGE/2);
% Initialize output variable
fsurf = zeros(TOTAL_ROWS,TOTAL_COLS);
% Turn negative and zero correlation coecients into NaNs
matrix( matrix<=0 ) = NaN; 
% Loop over all interior points in field
for r= halfsize+1 : TOTAL_ROWS-halfsize
    for c= halfsize+1 : TOTAL_COLS-halfsize
        % Only filter points where valid correlations were made
        if valid(r,c)== 1
        % Define area of infuence
        sub_matrix = matrix(r-halfsize:r+halfsize,c-halfsize:c+halfsize);
        
        % Multiply by filter
        z = H.*sub_matrix;
        % Compute mean of positive values within filter weighted
        % infuential area
        numer = nansum(z(:));
        t = z>0;
        w = H.*t;
        denom = sum(w(:));

            % Do not return innite mean values
            if denom==0
                fsurf(r,c) = 0;
            else
                fsurf(r,c) = numer/denom;
            end
        end
    end
end
