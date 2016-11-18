function [corr_matrix,g_vec] = global_correlation(time1,time2)
% Function to determine global displacement between two images. Takes
% image pair as input and returns the correction matrix, which is the
% coordinate transform required to turn a pixel location in global
% displacement biased, limited search area into a displacement from the
% center pixel, and the global vector.
% Declare global variables
global THETA_GLOBAL SEARCH_RADIUS

% Correlate the second image with the first
z = normxcorr2(time2, time1);
% Find the location of the maximum correlation value.
[m_g, imax] = max(z(:));
% Turn the vector index into a matrix subscript location
[dy_g, dx_g] = ind2sub(size(z),imax);
% Find the coordinates of the center of the correlation matrix 20
center = ceil(size(z)./2);
% Convert from the location within the correlation vector to the actual
% displacement vector
g_vec(1) = -(dy_g-center(1));
g_vec(2) = -(dx_g-center(2));
% Find the \global angle" between 0 and 2pi
THETA_GLOBAL = atan2(g_vec(1), g_vec(2));
if THETA_GLOBAL < 0
    THETA_GLOBAL = THETA_GLOBAL + 2*pi;
end
% Determine coordinate transform vector
corr_matrix = -(g_vec+SEARCH_RADIUS+1);