% shady nikooei

function main
    % this is a function for calaulate feature, classification and display
    % MRI image of brain to detecte tumor
    
    clc;
    clear;
    close all;
    
    image_filename = 'Y1.jpg'; 
    original_img = imread(image_filename);
    
    % segmentation: isolate the tumor using a more robust method
    [binary_mask, segmented_tumor_img] = segment_tumor(original_img);
    
    if isempty(binary_mask)
        disp('No tumor detected after segmentation.');
        return;
    end
    
    % feature extraction (segmented tumor)
    
    boundaries = bwboundaries(binary_mask);
    if isempty(boundaries)
        disp('Could not find tumor boundary.');
        return;
    end
    
    % largest boundary corresponds to the tumor
    props = regionprops(binary_mask, 'Centroid', 'Area');
    [~, idx] = max([props.Area]); % find the largest component
    tumor_boundary = boundaries{idx}; 
    center = props(idx).Centroid;
    
    x_boundary = tumor_boundary(:, 2);
    y_boundary = tumor_boundary(:, 1);
    radial_distances = sqrt((x_boundary - center(1)).^2 + (y_boundary - center(2)).^2);
    
    margin_variance = var(radial_distances);
    
    % classification
    variance_threshold = 50; 
    
    if margin_variance < variance_threshold
        classification = 'Benign';
    else
        classification = 'Malignant';
    end
    disp(['Result: Tumor classified as ', classification, ' (Variance = ', num2str(margin_variance), ')']);
    
    % display
    figure;
    
    subplot(2, 2, 1);
    imshow(original_img);
    title('Original MRI Image');
    
    subplot(2, 2, 2);
    imshow(binary_mask);
    title('Segmented Tumor Mask');
    
    subplot(2, 2, 3);
    imshow(segmented_tumor_img);
    title('Highlighted Tumor');
    
    % simplified radial distance signature
    subplot(2, 2, 4);
    plot(radial_distances);
    title(['Radial Distance Variance: ', num2str(margin_variance, '%.2f')]);
    xlabel('Boundary Points');
    ylabel('Distance from Center (pixels)');
    grid on;
    
    % show the true scale of variations(y-axis start = 0)
    max_dist = max(radial_distances);

    padding = max_dist * 0.1; % add 10% padding to the top
    ylim([0, max_dist + padding]);
    
    sgtitle(['Tumor Analysis Result: ', classification], 'FontSize', 14, 'FontWeight', 'bold');
end