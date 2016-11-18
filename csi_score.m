function [csi] = csi_score(forecast, actual, window_size, thresh)
% Function to compare a forecast file with the actual file at that time.
% Takes as inputs the forecast file, the actual file, the size of the
% verification area and the rainfall rate threshold and returns the CSI
% score for that file pair. The window size input can be either a single
% integer (for a square verification area), the string 'cross' (for a cross
% verification area), or the string 'rect' (for a 3 row by 5 column
% rectangle verification area).
% Check to ensure that the window exists 10
if window_size < 1
    disp('window_size must be greater than or equal to 1')
    csi_area = NaN;
    return
end

% Load files
fcst = load(forecast);
act = load(actual);

% Determine size of files, assumes they are the same size
[n,m] = size(act);
% Eliminate NaN locations in the forecast and actual file
fcst(isnan(fcst)) = 0;
act = act > thresh;
% Define verication area weighting functions
if sum(size(window_size)) == 2
    weights = ones(window_size)/ window_size^2; 
elseif strcmp(window_size, 'cross')
    weights = [0 0.2 0 ; 0.2 0.2 0.2; 0 0.2 0];
elseif strcmp(window_size, 'rect')
    weights = (1/15).*ones(3,5);
end
% Initialize convolution variable
sz = act;
% If the verification area is larger than 1x1, smooth the binary actual 
% field by the verification area
if size(weights)~=[1 1]
    sz = conv2(act, weights, 'same');
end
% Initialize counters
correct_no = 0;
hit = 0;
miss = 0;
false_alarm = 0; 
% Loop over all rows and columns in the images
for x=1:m
    for y=1:n
        % If there was actually rain within a \window size" area around the
        % pixel in question, sz will be greater than zero, and if fcst is
        % also greater than that threshold, increment the hit counter
        if sz(y,x) > 0 && fcst(y,x) > thresh
            hit = hit + 1;
            % If both the actual and the forecast are less than the 60

            % threshold, increment the correct no counter
            elseif act(y,x) == 0 && fcst(y,x) <= thresh
            correct_no = correct_no +1;
            % if the actual is less than the threshold and the forecast is
            % greater than the threshold, increment the false alarm counter
        elseif act(y,x) == 0 && fcst(y,x) > thresh
            false_alarm = false_alarm + 1;
            % If the actual exceeds the threshold but the forecast does
            % not, increment the miss counter
            else 
            %act(y,x) == 1 & fcst(y,x) <= thresh
            miss = miss + 1;
        end
    end
end
% The CSI is the ratio of the hits to the total of the hits, misses and
% false alarms
csi = hit/(hit+miss+false_alarm);