
function [xo,yo,v] = interpolation(x,y,v)
% Function to interpolate missing vectors values with the average of the
% surrounding magnitudes. Takes the vectors fields and the valid
% field as inputs and returns full vector fields and modifoed valid field. .
% Declare global variables
global TOTAL_ROWS TOTAL_COLS RANGE
% Define radius of inuence
halfbox = foor(RANGE/2); 

% Pad vector fields with NaN values.
x = [NaNf*ones(halfbox,TOTAL_COLS+2*halfbox);
NaN*ones(TOTAL_ROWS,halfbox) x NaN*ones(TOTAL_ROWS,halfbox);
NaN*ones(halfbox,TOTAL_COLS+2*halfbox)];
y = [NaN*ones(halfbox,TOTAL_COLS+2*halfbox);
NaN*ones(TOTAL_ROWS,halfbox) y NaN*ones(TOTAL_ROWS,halfbox);
NaN*ones(halfbox,TOTAL_COLS+2*halfbox)]; 
% Loop over all rows and columns in image
for m=1:TOTAL_ROWS
    for n=1:TOTAL_COLS
        % Only interpolate vectors identified by the interpolation field
        if v(m,n) == 2
            % Define local areas
            loc_area_x = x(m:m+2*halfbox,n:n+2*halfbox);
            loc_area_y = y(m:m+2*halfbox,n:n+2*halfbox);

            %Compute local means
            loc_mean_x = nanmean(loc_area_x(:));
            loc_mean_y = nanmean(loc_area_y(:));
            % Assign local means to center pixels
            x(m+halfbox,n+halfbox) = loc_mean_x;
            y(m+halfbox,n+halfbox) = loc_mean_y;
            % Change the flag on the vector to represent a valid vector
            v(m,n) = 1; 
        end
    end
end
% Trim fields to original size
xo = x(halfbox+1:end-halfbox,halfbox+1:end-halfbox);
yo = y(halfbox+1:end-halfbox,halfbox+1:end-halfbox);
