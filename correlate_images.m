function [vec_valid, z3d, corr_matrix] = correlate_images(file1, file2)
% Function that performs local area correlation between �file1� and
% �file2�. Takes as inputs the full-path filenames and returns:
% �vec valid�, a matrix of locations flagging which resulted in valid
% correlations, which are invalid and which need to be interpolated; �z3d�,
% a 3D representation of the global-vector biased, limited search area,
% correlation surface at each pixel; and �corr matrix�, a row and column
% correction value to be applied to the raw locations of maximum
% correlation to determine displacement from center pixel.

% Declare Global Variables
global FILTER_ROWS FILTER_COLS MAX_SHIFT CORR_BOXSIZE WX_MIN
global RANGE SEARCH_RADIUS TOTAL_ROWS TOTAL_COLS HALFSIZE
% Prepare input files for global and local correlation analyses
[time1,time2,time1_pad,time2_pad,t2nf] = prepare_images(file1,file2);
% Check to ensure there is weather in the first image
if (sum(time1(:)) == 0) || (time1 == -9999)
    vec_valid = -9999; 
    z3d = 0;
    corr_matrix = 0;
    disp('Error encountered in files: forecasting process skipped')
    return
end
% Perform Global Correlation analysis
[corr_matrix,g_vec] = global_correlation(time1,time2);
% Clear unneeded variables 30
clear time1 time2
% Initialize variables
counter = 0;

vec_valid = zeros(TOTAL_ROWS, TOTAL_COLS);
z3d = zeros(TOTAL_ROWS,TOTAL_COLS, (2*SEARCH_RADIUS+1)^2);
% Loop over all rows and columns in input images
for row=1:TOTAL_ROWS
    for col=1:TOTAL_COLS 
        if t2nf(row,col) > 0
            % Designate all pixels who provide acceptable correlations as a
            % pixel to be interpolated later. If there is no problem with
            % the correlation, the flag is set to 1 which indicates the
            % point as a �good� vector.
            vec_valid(row,col) = 2;
            % Select region from second image to locate in the first image
            sample = time2_pad(row:row+2*HALFSIZE, col:col+2*HALFSIZE);

            % Select restricted search area from first image
            field = time1_pad(row:row+2*MAX_SHIFT, col:col+2*MAX_SHIFT);
            % Compute the percentage of the sub areas that �have weather�
            per_weather_field = sum(field(:)>0)/prod(size(field));
            per_weather_sample = sum(sample(:)>0)/prod(size(sample));
            % Only do correlations for pixels whose sub areas have weather
            % coverage exceeding the set threshold and have weather in the
            % second image to be advected. 60
            if (per_weather_field > WX_MIN) &&(per_weather_sample > WX_MIN)
                % Increment valid correlation counter
                counter = counter +1;
                % Adds noise to uniform sample pattern, as required by
                % normxcorr2
                if std(sample(:)) == 0
                    noise = (exp(0.25*randn(size(sample))));
                    sample = sample .* noise;
                end 
                % Correlate the two sub images (image processing toolbox
                % function)
                z = normxcorr2(sample, field);
                % Create global vector biased and limited search area
                if counter==1
                    % Find the coordinates of the center of the
                    % full correlation matrix

                    center = ceil(size(z)./2); 
                    % Define the center of a limited region of the full
                    % correlation surface within which a maximum will be
                    % identified. This center is offset from the full center
                    % by the global displacement center.
                    new_center = center-g_vec;
                    % Determine the beginning and ending rows and columns
                    % of the re-centered limited search area.
                    starts = new_center - SEARCH_RADIUS; 
                    ends = new_center + SEARCH_RADIUS;
                end
                % Check to ensure the edges of the limited search area are
                % within the unpadded correlation area (eliminates effects
                % of zero padded edges)
                if (ends(1) <= size(z,1)-2*HALFSIZE) && (starts(1) >= 2*HALFSIZE) && (ends(2) <= size(z,2)-2*HALFSIZE)&&(starts(2) >= 2*HALFSIZE) 
                    % Define the limited search area
                    z_t = z(starts(1):ends(1),starts(2):ends(2));
                    % Ensure that the limited search area is of proper size
                    if size(z_t)==[2*SEARCH_RADIUS+1,2*SEARCH_RADIUS+1]
                        % Define this pixel as a valid correlation location
                        vec_valid(row,col) = 1;

                        % Assign limited search area to output variable
                        z3d(row,col,:) = z_t(:);
                    end
                end
            end
        end
    end
end
