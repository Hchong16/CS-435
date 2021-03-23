% Author: Harry Chong
% Date: 1/20/2021
clc, clear, close all

%% 2. Dataset Setup
filename = "mountain.jpg";
im = imread(filename);

% Convert image to matrix of doubles
im_double = double(im);

% Display original image
figure('Name', 'Original'); imshow(im);

%% 3. RGB -> Grayscale
% Grayscale conversion using formula and Scalar-matrix multiplication
im2_grayscale = 0.2989*im_double(:,:,1) + 0.5870*im_double(:,:,2) + ...
                0.1140*im_double(:,:,3);

% Convert to a unsigned integers (uint8) 
im2_grayscale = uint8(im2_grayscale);

% Display and save grayscale image
figure('Name', 'Grayscaled Image'); imshow(im2_grayscale); 
saveas(gcf(), 'images/grayscaled.png', 'png');

%% 4. RGB -> Binary
% Create three binary images from the grayscaled version using a threshold 
% percentage of 25%, 50%, and 75% of the maximum intensity (255)
percentages = [0.25, 0.50, 0.75];
for percentage = percentages
    % Initialize matrix of 0s
    im3_binary = zeros(size(im2_grayscale));
    
    % Set any pixel value above threshold to 255
    im3_binary(im2_grayscale > percentage * 255) = 255;
    
    % Convert to a unsigned integers (uint8) 
    im3_binary = uint8(im3_binary);
    
    % Display and save binary image
    figure('Name', 'Binary Image (Threshold = ' + string(percentage) + ')'); 
    imshow(im3_binary);
    
    percentage_name = percentage * 100;
    saveas(gcf(), 'images/binary_threshold_' + string(percentage_name) ...
    + '.png', 'png');
end

%% 5. Gamma Correction
% Convert range from 1 to 255 range to 0 to 1
im4(:,:,1) = im_double(:,:,1)/255;
im4(:,:,2) = im_double(:,:,2)/255;
im4(:,:,3) = im_double(:,:,3)/255;

% Create three gamma correction images from the original image using a gamma 
% of 0,2, 1, and 50 
gammas = [0.2, 1, 50];

for gamma = gammas
    % Initialize matrix of 0s
    im4_gamma = zeros(size(im4));
    
    for i = 1:size(im4,1)
        for j = 1:size(im4,2)
            % Calculate each pixel's intensity using formula (s = cr^γ), 
            % where c = 1
            R = 1 * (im4(i,j,1).^(gamma));
            G = 1 * (im4(i,j,2).^(gamma));
            B = 1 * (im4(i,j,3).^(gamma));
            
            % Update values
            im4_gamma(i,j,1) = R;
            im4_gamma(i,j,2) = G;
            im4_gamma(i,j,3) = B;
        end
    end
    
    % Convert range back to 255
    im4_gamma(:,:,1) = im4_gamma(:,:,1)*255;
    im4_gamma(:,:,2) = im4_gamma(:,:,2)*255;
    im4_gamma(:,:,3) = im4_gamma(:,:,3)*255;
    
    % Convert to a unsigned integers (uint8) 
    im4_gamma = uint8(im4_gamma);
    
    % Display binary image
    figure('Name', 'Gamma Correction Image (Gamma = ' + string(gamma) + ')'); 
    imshow(im4_gamma);
end

%% 6. Changing Hue
% Convert range from 1 to 255 range to 0 to 1
im5_RGB(:,:,1) = im_double(:,:,1)/255;
im5_RGB(:,:,2) = im_double(:,:,2)/255;
im5_RGB(:,:,3) = im_double(:,:,3)/255;

% Initialize matrix of 0s
im5_HSV = zeros(size(im5_RGB));

% Convert RGB to HSV and also update hue value by 50 degrees 
for i = 1:size(im5_RGB,1)
    for j = 1:size(im5_RGB,2)
        R = im5_RGB(i,j,1);
        G = im5_RGB(i,j,2);
        B = im5_RGB(i,j,3);
        
        maximum = max([R,G,B]);
        minimum = min([R,G,B]);
        delta = maximum - minimum;
        
        % Hue
        % Determine the piecewise-function for the hue and add 50
        if delta == 0
            H = 0 + 50;
        elseif maximum == R
            H = 60 * ((G - B)/delta) + 50;
        elseif maximum == G
            H = 120 + (60 * ((B - R)/delta)) + 50;
        else
            H = 240 + (60 * ((R - G)/delta)) + 50;
        end
       
        % Handle negative hue values 
        if H < 0
            H = 360 + H;
        end
        
        % Handle hue value greater than 360
        if H > 360
            H = mod(H,360);
        end
        
        % Saturation
        S = delta/maximum;
        
        % Brightness
        V = maximum;
       
        % Update values
        im5_HSV(i,j,1) = H;
        im5_HSV(i,j,2) = S;
        im5_HSV(i,j,3) = V;
    end
end

% Convert HSV back to RGB
% Initialize matrix of 0s
im5_RGB_updated = zeros(size(im5_RGB));
for i = 1:size(im5_HSV,1)
    for j = 1:size(im5_HSV,2)
        H = im5_HSV(i,j,1);
        S = im5_HSV(i,j,2);
        V = im5_HSV(i,j,3);
        
        delta = S * V ;
        minimum = V - delta;
        
        if (0 <= H) && (H < 60)
            R = V;
            G = ((H/60)*delta) + V - delta;
            B = V - delta;
        elseif (60 <= H) && (H < 120)
            R = V - delta - (((H-120)*delta)/60);
            G = V;
            B = V - delta;
        elseif (120 <= H) && (H < 180)
            R = V - delta;
            G = V;
            B = (((H-120)*delta)/60) + V - delta;
        elseif (180 <= H) && (H < 240)
            R = V - delta;
            G = V - delta - (((H-240)*delta)/60);
            B = V;
        elseif (240 <= H) && (H < 300)
            R = (((H-240)*delta)/60) + V - delta;
            G = V - delta;
            B = V;
        else
            R = V;
            G = V - delta;
            B = V - delta - (((H-360)*delta)/60);
        end
        
        % Update values
        im5_RGB_updated(i,j,1) = R * 255;
        im5_RGB_updated(i,j,2) = G * 255;
        im5_RGB_updated(i,j,3) = B * 255;
    end
end

% Convert to a unsigned integers (uint8) 
im5_hue = uint8(im5_RGB_updated);      

% Display and save hue image
figure('Name', 'Image with Hue increased by 50'); 
imshow(im5_hue);
saveas(gcf(), 'images/hue_50.png', 'png');

%% 7. Histograms
% Return 1D array for each original color channel + gray image
flatGray = reshape(im2_grayscale, 1, numel(im2_grayscale));
flatR = reshape(im(:,:,1), 1, numel(im(:,:,1)));
flatG = reshape(im(:,:,2), 1, numel(im(:,:,2)));
flatB = reshape(im(:,:,3), 1, numel(im(:,:,3)));

% Create histograms
create_histogram(flatGray, "Grayscale")
create_histogram(flatR, "Red")
create_histogram(flatG, "Green")
create_histogram(flatB, "Blue")

%% Helper Functions
% Takes in a 1D array and creates a histogram based on pixel values.
function create_histogram(flatX, channel)
    % Reference: Lecture 1: Slide 65
    bins = zeros(1,256);
    for val = 0:255
           bins(val+1) = sum(flatX==val);
    end
    bins = bins/sum(bins);
    
    % Display and save histogram
    figure; bar(1:256,bins); 
    title('Histogram of the ' + channel + ' Channel');
    xlabel('bins'); 
    ylabel('Frequency');
    saveas(gcf(), 'images/histogram_' + channel + '.png', 'png');
end
