function [av_csi] = global_tracker(input, outputdir, actdir)
% Main function for MATLAB based, short term extrapolation rainfall
% forecasting with a single vector derived from correlation analysis
% between whole images. Takes a batch file of input files and generates a
% series of forecast files for each of the pairs of files. Also requires
% destination directory for the forecast files as well as the location of
% the files for verification. Calls global correlation, and advect image
% to do velocity vector generation and image advection. Files are written
% into the directory specified by outputdir. Please use full
% directory/file names for all input files. 10
% Initialize timer and close all open figure windows
start = clock;
close all
% Declare Global Variables: Defined in file st.params
global FILTER_ROWS FILTER_COLS MAX_SHIFT CORR_BOXSIZE
global X_RES Y_RES TIME_SPACING ANGLE_TOL RAIN_THRESH
global WX_MIN RANGE SIGMA Z_THRESH SPEED_LIMIT SEARCH_RADIUS

% These global variable are defined within the following function calls
global TOTAL_ROWS TOTAL_COLS HALFSIZE THETA_GLOBAL
global MARGIN ANGLE_TOL_RAD
% Read parameters from external parameter file
[params, values] = textread('st.params', '%s %n', 'delimiter','\t','commentstyle','matlab');
for j=1:length(values)
    assign = sprintf('%s%s%f%s', char(params(j)), '=',values(j),';');
    eval(assign); 
end
% Define variables that are dependent on global variables
HALFSIZE = floor(CORR_BOXSIZE/2);
ANGLE_TOL_RAD = ANGLE_TOL*pi/180;

del_t = TIME_SPACING*60;
% Desired forecast times (min)
forecast_times = [0 15 30 45 60 75 90 105 120];

% Get list of filenames to be used in forecast
[file_names,file_count] = read_batch_file(input);
% Initialize total forecast counter
n=0;
% Determine number of input pairs to be analyzed
TOTAL_PAIRS = file_count-1;
% Start generating forecasts with second file 50
for h=2:file_count
    % Display progress
    PAIR NUMBER = (h-1);
    tag = sprintf('%s%d%s%d', 'This is pair ', PAIR_NUMBER,' out of ', TOTAL_PAIRS);
    disp(tag)
    % Define first and second files to be used in correlation analysis
    file1 = file_names(h-1, :);
    file2 = file_names(h, :); 
    % Prepare images for correlation analysis
    [time1,time2,time1_pad,time2_pad,t2nf] = prepare_images(file1,file2);
    if sum(time1(:))~=0
    % Increment total forecast counter
    n=n+1;
    % Perform global correlation analysis
    [corr_matrix,g_vec] = global_correlation(time1,time2); 
    % Clear unneeded variables
    clear time1 time2 time1pad time2pad
    % Turn pixel displacements into velocities in meters per second
    x_vectors = (g_vec(2)*X_RES/del_t);
    y_vectors = (g_vec(1)*X_RES/del_t);
    % Advect input file and score and write forecasts to files
    disp('Generating Forecasts') 
    
    csi(h-1,:) = advect_global(file2, x_vectors, y_vectors, forecast_times, outputdir, actdir);
    else
        disp('Empty input field: forecasting process skipped')
    end
end
% Plot average forecast accuracy against lead time
av_csi = sum(csi,1)./n;
figure 
plot(forecast_times,av_csi.*100,'-*')
title('Average CSI v. Lead Time')
xlabel('Lead Time (min)')
ylabel('CSI (%)')
% Store forecast accuracy
outfile = sprintf('%s%s',outputdir, '/aprglobal.csi');
fid = fopen(outfile,'w');
for i=1:size(av_csi,2)
    fprintf(fid, '%d %f\n',forecast_times(i),av_csi(1,i)); 
end
fclose(fid);
% Determine and display elapsed time.
elapsed time = etime(clock,start)