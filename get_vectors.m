function [u,v, vec_valid] = get_vectors(z3d, corr_matrix,vec_valid)
% Function to convert correlation surfaces to vectors in meters per second.
% Also incorporates several quality control tests. Takes the all the
% correlation surfaces, the correction matrix, the valid vector eld and
% the interpolation field as inputs and returns the x- and y-direction
% velocities, and the adjusted valid vector field.
% Declare global variables.
global X_RES Y_RES TIME_SPACING SPEED_LIMIT TOTAL_ROWS
global TOTAL_COLS ANGLE_TOL_RAD THETA_GLOBAL 
% Define other variable that are function of the global variables
del_t = TIME_SPACING*60; %seconds
% Initialize variables
x_shift = NaN*ones(TOTAL_ROWS,TOTAL_COLS);
y_shift = NaN*ones(TOTAL_ROWS,TOTAL_COLS);
theta_loc = NaN*ones(TOTAL_ROWS,TOTAL_COLS);
% Determine number of pixels in each CS 
c = size(z3d,3);
% Loop over all rows and columns in the second image
for row=1:TOTAL_ROWS
    for col=1:TOTAL_COLS
        % Only generate velocities for valid correlations
        if vec_valid(row,col) == 1
            % Find the maximum correlation values and the maximum row index 30
            % over all the rows for each pixel.
            [m(row,col), imax] = max(z3d(row,col,:));
            % Retrieve the maximum column index for its associated row
            [y,x] = ind2sub([sqrt(c) sqrt(c)], imax);
            % Transform the returned maximum correlation location into a
            % displacement from the center of the full correlation surface
            x_shift(row, col) = -(x + corr_matrix(1,2));
            y_shift(row, col) = -(y + corr_matrix(1,1)); 
            % Get local vector angle between 0 and 2*pi
            theta_loc(row,col) = atan2(y_shift(row,col),x_shift(row,col));
    
            if theta_loc(row,col) < 0
                theta_loc(row,col) = theta_loc(row,col) + 2*pi;
            end
            % Get local magnitude
            r_local(row,col) = sqrt(x_shift(row,col)^2 + y_shift(row,col)^2);

            % Compute deviation from global angle
            angle_diff = abs(theta_loc(row,col)-THETA_GLOBAL);
            angle_diff  = min([angle_diff abs(angle_diff -2*pi) (angle_diff+2*pi)]);
            % Remove vectors that fail tests on angle deviation, local
            % magnitude, and maximum correlation coecient value and
            % specify them to be interpolated (vec valid = 2)
            if (angle_diff > ANGLE_TOL_RAD) || (r_local(row,col) > SPEED_LIMIT)||   (m(row,col) == 0) || (isnan(m(row,col))) 
                vec_valid(row,col) = 2;
                x_shift(row,col) = NaN;
                y_shift(row,col) = NaN;
                m(row,col) =NaN;
                theta_loc(row,col) = NaN;
                r_local(row,col) = NaN;
            end
        end % End if statement
    end % End Column loop
end % End Row loop 70
% Convert from displacements to velocities in meters per second
u = x_shift .*(X_RES/del_t);
v = y_shift .*(Y_RES/del_t);