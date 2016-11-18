
function [z3d_out] = quality_control(vec_valid, z3d)
% Perform filtering on the correlation meta surface (CMS) to bias the
% location of the maximum correlation coecient toward the local average.
% Takes the vec valid flag matrix and the 3D representation of the
% correlation surfaces as inputs and returns the filtered 3D correlation
% surface representation.
% Declare global variables
global RANGE SIGMA Z_THRESH

% Determine the number of pixels in each individual correlation surface
% (CS)
c = size(z3d,3);
% Generate Gaussian weighted filter using an image processing toolbox
% function.
H = fspecial(gaussian, RANGE, SIGMA);
% Loop over total number of elements in the correlation surfaces
for g=1:c 
    % Extract same relative pixel from each surface for ltering
    temp = z3d(:,:,g);
    % Filter the field with the Gaussian filter
    output = surface_filter(temp, H, vec_valid);
    % Eliminate correlation surface values below Z THRESH
    output(output<Z_THRESH) = 0;
    % Assign filtered field to output variable 
    z3d_out(:,:,g) = output;
end