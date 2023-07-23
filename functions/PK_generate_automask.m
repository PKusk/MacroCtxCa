function [masked_image_data, mask] = PK_generate_automask(image_data)
% [masked_image_data, mask] = PK_generate_automask(image_data)
% 2023.05.15 - P.Kusk function to automatically generate and apply a mask encompassing the Cortex. 
% Takes raw image data (only tested on uint16 tiff stacks) and outputs binary mask and masked image data.
% Code adapted from Mauro Dinuzzo's original GCaMP7 pipeline.

tic;

fprintf('Automatic generating mask from image data ... ');

image_data = single(image_data); % Convert image data to single precision.

MI = mean(image_data,3); % Generate stack mean image
I = uint16(imgaussfilt(MI,10)); % Gaussian blurr mean image
level = graythresh(I); % Apply Otsu method automatic histogram threshold to determine mask outline.
BW = imbinarize(I, level*0.9); % Apply treshold to blurred mean image to generate mask. 
mask = single(BW); 

% multiply
try
    masked_image_data = image_data.*repmat(mask, [1, 1, frames]);
catch
    % out of memory
    for f=1:size(image_data,3)
        masked_image_data(:, :, f) = squeeze(image_data(:, :, f)).*mask;
    end
end

fprintf(['done (', num2str(toc),' s).\n']);
return
end

