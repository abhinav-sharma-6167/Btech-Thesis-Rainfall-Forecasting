
function filtered_image = st_filt(z, filter_rows, filter_cols)
% Filters a 2-D image using an averaging filter. Takes image to be
% filtered and size of filter as inputs and returns filtered image.
% Define filter
weights = ones(filter_rows, filter_cols)/(filter_rows* filter_cols);

% Initialize output
filtered_image = z;

% Perform convolution filtering between input and filter. Returns a matrix
% with the same dimensions as the input.
filtered_image = conv2(z, weights, 'same');