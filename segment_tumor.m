% shady nikooei

function [tumor_mask, highlighted_image] = segment_tumor(original_img)
    % This function performs a two-step segmentation to isolate the tumor.


    % isolate the entire brain from the black background
    % morphological operation
    g_img = im2gray(original_img);
    thresh = graythresh(g_img);
    brain_mask = imbinarize(g_img, thresh);
    brain_mask = imfill(brain_mask, 'holes');

    % keep only the largest object (the brain)
    brain_mask = bwareaopen(brain_mask, 500); 

    % mask brain pixels
    brain_only_img = g_img;
    brain_only_img(~brain_mask) = 0; % set background to black

    % find the tumor within the brain region using a more robust threshold
    if ~any(brain_only_img(:))
        tumor_mask = [];
        highlighted_image = [];
        return;
    end
    
    % save intensity of the brain pixels (ignore the black background)
    brain_intensity_values = g_img(brain_mask);
    
   
    % finds optimal threshold
    tumor_threshold_normalized = graythresh(brain_intensity_values);
    
    % binarize the brain-only (more specific threshold)
    tumor_mask = imbinarize(brain_only_img, tumor_threshold_normalized);
    
    % clean up the final tumor mask
    tumor_mask = bwareaopen(tumor_mask, 200);
    se = strel('disk', 5);
    tumor_mask = imclose(tumor_mask, se);
    
    % highlighted image for visualization
    red_channel = g_img;
    green_channel = g_img;
    blue_channel = g_img;
    red_channel(tumor_mask) = 255;
    green_channel(tumor_mask) = 0;
    blue_channel(tumor_mask) = 0;
    highlighted_image = cat(3, red_channel, green_channel, blue_channel);
end
