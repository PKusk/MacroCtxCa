function [coordinates, custom_ACCF]= PK_custom_ACCF_map(mask ,pixSize)
%[coordinates, custom_ACCF]= PK_custom_ACCF_map(mask ,pixSize)
% 2023.05.15 - P.Kusk - Function for generating a custom allen brain atlas
% cortical map based on an aligned cortex mask generated from PK_generate_automask.m 
% and PK_align_to_bregma_lambda and a mm pr. pixel size. Function outputs
% both [X Y] vector coordinates for each region and a numbered mask image
% for each region in custom_ACCF.

im_size = size(mask);
bregma = [im_size(1)*0.5 im_size(2)*0.5];
ccfbregma = [540 0 570]/100/pixSize;
load(fullfile(fileparts(mfilename('fullpath')), 'ctxOutlines.mat'));

coordinates = []; regions = [];
hold on;
for q = 1:numel(coords) % coords is from ctxOutlines.mat
    % these are in 10um voxel coordinates, so first convert to mm, then to
    % pixels
    cx = coords(q).x/100/pixSize; cy = coords(q).y/100/pixSize;
    cx = cx-ccfbregma(3); cy = cy-ccfbregma(1);
    cx = cx+bregma(2); cy = cy+bregma(1);
   % plot(cx,cy, 'LineWidth', 1.0, 'Color', 'r');
   % hold on;
    % coordinates{q} = [cx, cy];
    
    % Generate mask pr. region coordinates and crop it to input mask
    BW = poly2mask(cx,cy,im_size(1),im_size(2));
    custom_BW = (BW+mask)-1;
    custom_BW(custom_BW<0) =0;
    regions = cat(3,regions,custom_BW*q);
    
    % Generate custom coordinates based on above mask.
    active_coords = bwboundaries(custom_BW);
    if isempty(active_coords)
        coordinates{q} = {};
    else
        coordinates{q} = active_coords{1};
    end
    
end

custom_ACCF = max(regions,[],3);
end
