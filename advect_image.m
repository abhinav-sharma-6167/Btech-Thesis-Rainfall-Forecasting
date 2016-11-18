function fcst_file=advect_image(initial_file,x_vec,y_vec,forecast_times,outputdir)
% Function that performs the actual forecasting step. Takes an original
% file, x- and y-direction vectors, a string of forecast times, and the
% directory for the outputted files as inputs and returns a list of files

% that the forecasted fields were written to. Calls file writer.
% Declare global variables
global X_RES Y_RES TOTAL_ROWS TOTAL_COLS TIME_SPACING
% Eliminate extraneous output to the screen 
warning off 'MATLAB:divideByZero'


% Load the initial file
initial_file_mat = load(initial_file);
% Determine number of forecasts to be made
d = size(forecast_times, 2);
% Convert forecast times (in min) to seconds
forecast_times_sec = forecast_times.*60; 
% Remove NaN values from vector fields
x_vec(isnan(x_vec)) = 0;
y_vec(isnan(y_vec)) = 0;
% Define the field to be advected
start = initial_file_mat;
% Compute incremental velocity field.
xv = x_vec.*(TIME_SPACING.*60./X_RES); 
yv = y_vec.*(TIME_SPACING.*60./X_RES);
% Loop over all forecast times greater than zero
for t=1:d
    if forecast_times(1,t) ~= 0
    % Initialize forecast, velocity and averaging fields
    forecast = zeros(TOTAL_ROWS,TOTAL_COLS);
    xv_new = zeros(TOTAL_ROWS,TOTAL_COLS);
    yv_new = zeros(TOTAL_ROWS,TOTAL_COLS); 
    check = zeros(TOTAL_ROWS,TOTAL_COLS);
    % Loop over all internal rows and columns in initial image
        for row = 2:TOTAL_ROWS-1
            for col = 2:TOTAL_COLS-1
            % Only advect pixels that have weather
                if start(row,col) > 0
                % Determine the index in the forecast for each point in
                % the initial file based on the initial index and the 50
                % displacement
                row_out = round(row + yv(row, col));
                col_out = round(col + xv(row, col));
                % Do not put weather outside of forecast area
                    if (row_out > 1) && (col_out > 1) && (row_out < TOTAL_ROWS) && (col_out < TOTAL_COLS)
                    % Translate each pixel and its neighborhood to the
                    % corresponding locations in the forecast or
                    % advected velocity fields.
                    forecast(row_out-1:row_out+1, col_out-1:col_out+1) = forecast(row_out-1:row_out+1,col_out-1:col_out+1)+start(row-1:row+1,col-1:col+1);
                    xv_new(row_out-1:row_out+1, col_out-1:col_out+1) = xv_new(row_out-1:row_out+1,col_out-1:col_out+1) +xv(row-1:row+1,col-1:col+1);
                    yv_new(row_out-1:row_out+1, col_out-1:col_out+1) = yv_new(row_out-1:row_out+1,col_out-1:col_out+1) +yv(row-1:row+1,col-1:col+1);
                    % Increment the counter for number of values placed
                    % in each pixel
                    check(row_out-1:row_out+1, col_out-1:col_out+1) = check(row_out-1:row_out+1, col_out-1:col_out+1)+ ones(3,3);
                    end
                end
            end
        end
% Average advected values
xv = xv_new./check;
yv = yv_new./check;
forecast = forecast./check;
% Remove any cells that had zero pixels advected there.
xv(isinf(xv)) = NaN; 
yv(isinf(yv)) = NaN;
forecast(isinf(forecast)) = NaN;
% Get forecast file name

fcst_file(t,:) = sprintf ('%s%s%s%03d%s', outputdir,'/f',initial_file(end-19:end-7), forecast_times(1,t),'.txt');
% Write forecast file
file_writer(forecast, fcst_file(t,:));

% Change the file to be advected in the next forecasting step
start = forecast;
else
% Do not do the advection for the \zero time" forecast
forecast = initial_file_mat;
% Determine file name and write zero time forecast to the file
fcst_file(t,:) = sprintf ('%s%s%s%03d%s', outputdir,'/f',initial_file(end-19:end-7), forecast_times(1,t),'.txt');
file_writer(forecast, fcst_file(t,:)); 
    end
end

