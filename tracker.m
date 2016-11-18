function [av_csi] = tracker(input, outputdir, actdir)
% Main function for MATLAB based, short term extrapolation rainfall
% forecasting. Takes a batch file of input files and generates a series of
% forecast files for each pair of initial files. Also requires directory
% names for the forecast files to be written to as well as the location of
% the verification files for comparison. Calls correlate images,
% quality control, get vectors, interpolation, continuity and advect image
% to do velocity vector generation, quality control, interpolation,
% conversion, and image advection. Files are written into the directory
% specified by outputdir. Please use full directory/file names for all 
% inputs.
% Initialize timer and close all open figure windows.
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%'='

for j=1:length(values)
    assign = sprintf('%s%s%f%s', char(params(j)), '=',values(j),';'); 
    fprintf(assign)
    %eval(assign);
end
% Define variables that are dependent on global variables
HALFSIZE = floor(CORR_BOXSIZE/2);
ANGLE_TOL_RAD = ANGLE_TOL*pi/180;
% Desired forecast times (min)
forecast_times = [0 15 30 45 60 75 90 105 120];

% Get list of filenames to be used in forecast
[file_names,file_count] = read_batch_file(input);
% Initialize total forecast counter.
n=0;
% Determine number of input file pairs to be analyzed
TOTAL_PAIRS = file_count-1;
% Start generating forecasts with second file 50
for h=2:file_count
    % Display progress
    PAIR_NUMBER = (h-1);
    tag = sprintf('%s%d%s%d', 'This is pair ', PAIR_NUMBER,' out of ', TOTAL_PAIRS);
    disp(tag)
    % Define first and second files to be used in correlation analysis
    file1 = file_names(h-1, :);
    file2 = file_names(h, :); 
    % Perform correlation analysis on pair of images
    disp('Starting Correlation Analysis')
    [vec_valid, z3d, corr_matrix] = correlate_images(file1, file2);
    % Display correlation meta surface (CMS) surrounding selected pixel (optional).
    create meta surface(z3d,100,225);
    % vec valid will equal -9999 when the first of the two images has no
    % weather in it. Forecasts will not be generated and the csi scores 
    % will not effect the average.
    if vec_valid ~= -9999

        %Increment total forecast counter
        n = n+1;
        % Filter the CMS to bias maximum displacement towards local average
        % location
        disp('Starting Quality Control (Meta-Surface Filtering)')
        [z3d] = quality_control(vec_valid, z3d); 
        % Display filtered CMS around selected pixel (optional)
        create meta surface(z3d,90,225);
        % Convert vectors and remove errant vectors
        disp('Converting vectors')
        [x_vectors, y_vectors, vec_valid] = get_vectors(z3d,corr_matrix, vec_valid);
        % Interpolate the removed vectors 90
        disp('Interpolating Missing Vectors')
        [x_vectors,y_vectors, vec_valid] = interpolation(x_vectors,y_vectors,vec_valid);
        % Advect the image and write forecasts to files
        disp('Generating Forecasts')
        fcsts = advect_image(file2, x_vectors, y_vectors, forecast_times, outputdir);
        % Evaluate forecast accuracy with CSI scoring
        csi(h-1,:) = score_forecasts(fcsts, 1, 0, actdir); 
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
csi_outfile = sprintf('%s%s', outputdir, '/average_scores.csi');
fid = fopen(csi_outfile,'w');
for i=1:size(av_csi,2)

    fprintf(fid, '%d %f\n',forecast_times(i),av_csi(1,i));
end
fclose(fid); 
% Determine and display elapsed time
elapsed time = etime(clock,start)