function csi=advect_global(initial_file,x_vec,y_vec,forecast_times,outputdir,actdir)
% Function that performs the actual forecasting step. Takes an original
% file, x- and y-direction vectors, a string of forecast times, the
% directory to write the forecasts to and the directory where the
% verification files can be found as inputs and returns an array of CSI
% scores for the forecasts. Calls file writer and csi score.
% Declare global variables
global TOTAL_ROWS TOTAL_COLS X_RES Y_RES

% Load the initial file
initial_file_mat = load(initial_file);
% Determine number of forecasts to be made
d = size(forecast_times, 2);
% Convert forecast times (in min) to seconds
forecast_times_sec = forecast_times .*60;
% Loop over all positive forecast times 20
for t=1:d
    if forecast_times(1,t) ~= 0
        % Compute displacements in pixels for each forecast time

        x_vec_appl = x_vec .* (forecast_times_sec(1, t)./X_RES);
        y_vec_appl = y_vec .* (forecast_times_sec(1, t)./Y_RES);
        % Initialize forecast field
        forecast = NaN.*ones(TOTAL_ROWS,TOTAL_COLS);
        % Loop over all rows and columns in initial image 30
        for row = 1:TOTAL_ROWS
            for col = 1:TOTAL_COLS
                % Only advect pixels that have weather
                if initial_file_mat(row,col) > 0
                    % Determine the index in the forecast for each point in
                    % the initial le based on the initial index and the
                    % displacement
                    row_out = round(row + y_vec_appl);
                    col_out = round(col + x_vec_appl); 
                        % Do not put weather outside of forecast area
                        if (row_out > 0) && (col_out > 0) && (row_out<=TOTAL_ROWS)&& (col_out <=TOTAL_COLS)
                            % Translate each pixel to its corresponding point
                            % in the forecast image.
                            forecast(row_out, col_out) = initial_file_mat(row, col);
                        end
                end 
            end
        end
        % Get forecast file name
        fcst_file(t,:) = sprintf ('%s%s%s%03d%s', outputdir,'/f',initial_file(end-19:end-7), forecast_times(1,t), '.txt');
        % Write forecast field to file
        file_writer(forecast, fcst_file(t,:));
    else 
        forecast = initial_file_mat;
        % Get forecast file name
        fcst_file(t,:) = sprintf ('%s%s%s%03d%s' , outputdir,'/f',   initial_file(end-19:end-7), forecast_times(1,t),'.txt');
        % Write forecast field to file
         file_writer(forecast, fcst_file(t,:));
    end

    % Get actual file name to compare forecast to
    actual = get_actual_file(fcst_file(t,:), actdir); 
    % Score forecast with CSI
    csi(1,t) = csi_score(fcst_file(t,:), actual, 1,0);
end