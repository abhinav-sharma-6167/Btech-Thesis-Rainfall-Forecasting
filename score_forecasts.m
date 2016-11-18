function csi = score_forecasts(file_names,va,th,actdir)
% Function to take forecast files and determine their CSI score as compared
% to the actual file at that time. Takes a list of forecast files, a
% verification area side length, a rainfall threshold and the directory
% where the verification files are located as inputs and returns a vector
% of csi scores.
% Determine the number of forecasts to be scored.
file_count = size(file_names,1);

for h=1:file_count
    % Determine the actual file corresponding to the forecast file
    actual_file(h,:) = get_actual_file(file_names(h,:), actdir);
    % Score the forecast file
    csi(h,1) = csi_score(file_names(h,:),actual_file(h,:),va,th);
end