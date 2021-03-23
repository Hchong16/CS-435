% Author: Harry Chong
% Date: 1/30/2021
clc, clear, close all

%% 1. Dataset Setup
filename = fopen(append('memorial/','images.txt'));
data = textscan(filename, '%s%f', 'HeaderLines', 1);
fclose(filename);

image_names = data(:,1);
image_names = string(image_names{1,1});

exposures = data(:,2);
exposures = exposures{1,1};

%% 2. Plotting pixel value vs log exposure
% Initialize matrix of 0s
pixels = zeros(length(exposures),3);

% Image Size: 768 (Height) x 512 (Width)
% Selected Pixel 1: (100,150)
% Selected Pixel 2: (250,500)
% Selected Pixel 3: (350,450)

for i = 1:length(image_names)
    im = imread(append('memorial/',image_names(i)));
    pixels(i,1) = im(100,150,1);
    pixels(i,2) = im(250,500,1);
    pixels(i,3) = im(350,450,1);
end
figure('Name', 'Observed Red Intensity vs Exposure Length');
title('Observed Red Intensity vs Exposure Length')
plot(exposures, pixels, '-o'); 
xlabel('Exposure Length'); 
ylabel('Z');
legend('Pixel 1', 'Pixel 2', 'Pixel 3');
saveas(gcf(), 'images/red_intensity_vs_exposure.png', 'png');

%% 3. Finding and Plotting a Log Irradance Function
colors = ["Red", "Green", "Blue"];
for channel = 1:3
    % Create log irradiance curve, mapping pixel values z into log exposure
    g = create_lookup_table(channel, image_names, exposures);
    
    % Initialize matrix of 0s
    pixel_log = zeros(length(exposures), 3); 

    % Determine the true irradiance of pixel defined pixel for each image
    for i = 1:length(image_names)
        im = imread(append('memorial/', image_names(i)));
        % Add one to each lookup table since g(0) is undefined 
        pixel_log(i,1) = g(im(100,150,channel) + 1) - log(exposures(i)); 
        pixel_log(i,2) = g(im(250,500,channel) + 1) - log(exposures(i));
        pixel_log(i,3) = g(im(350,450,channel) + 1) - log(exposures(i));
    end
    figure();
    plot(exposures, pixel_log, '-o'); legend('pixel 1', 'pixel 2', 'pixel 3');
    title('Log Irradiance for ' + colors(channel) + ' Color Channel')
    xlabel('Exposure Length'); 
    ylabel('Log Irradiance');
    saveas(gcf(), 'images/' + lower(colors(channel)) + '_log_irradiance_vs_exposure.png', 'png');
end

%% 4a. Generate HDR Image
% Create irradiance curve (lookup table) for each color channel
red_g = create_lookup_table(1, image_names, exposures);
green_g = create_lookup_table(2, image_names, exposures);
blue_g = create_lookup_table(3, image_names, exposures);

% Retrieve information regarding image dimensions/channels
[height, width, channels] = size(im);

% Initialize matrix of 0s for each channel
hdr = zeros(height, width, channels);

% For each image, compute each channel’s irradiance using formula from
% Lecture 2 (HDR): Slide 30
red_sum = 0;
green_sum = 0;
blue_sum = 0;

for j = 1:length(image_names)
    im = imread(append('memorial/', image_names(j)));
    % Add one to each lookup table since g(0) is undefined 
    red_sum = red_sum + red_g(im(:,:,1) + 1) - log(exposures(j));
    green_sum = green_sum + green_g(im(:,:,2) + 1) - log(exposures(j));
    blue_sum = blue_sum + blue_g(im(:,:,3) + 1) - log(exposures(j));
end

% Take the average log irradience image over all images
red_log_irradiance = red_sum/length(image_names);
green_log_irradiance = green_sum/length(image_names);
blue_log_irradiance = blue_sum/length(image_names);

% Now we can easily obtain the irradiance from each channel using e
hdr(:,:,1) = exp(red_log_irradiance);
hdr(:,:,2) = exp(green_log_irradiance);
hdr(:,:,3) = exp(blue_log_irradiance);

% Display and save HDR image
figure('Name', 'HDR Image'); 
imshow(hdr);
imwrite(hdr, 'images/hdr.png');

%% 4b. Generate Tonemapping (SDR) Image
% Retrieve information regarding image dimensions/channels
[y, x, channels] = size(im);

% Initialize matrix of 0s for each channel
hdr_prime = zeros(y, x, channels);
tone_mapping = zeros(y, x, channels);

% Compute HDR' using formula from Lecture 2 (HDR): Slide 35 on the HDR
% image generated in 4a.
for channel = 1:3
    for i = 1:y
        for j = 1:x
            hdr_prime(i,j,channel) = hdr(i,j,channel)/(1 + hdr(i,j,channel));
        end
    end
end

% Compute SDR using formula from Lecture 2 (HDR): Slide 35
for channel = 1:3
    min_hdr_prime = min(hdr_prime(:,:,channel));
    max_hdr_prime = max(hdr_prime(:,:,channel));
    for i = 1:y
        for j = 1:x
            tone_mapping(i,j,channel) = 255*((hdr_prime(i,j,channel) - min_hdr_prime)/(max_hdr_prime - min_hdr_prime));
        end
    end
end

% Convert to uint8
tone_mapping = uint8(tone_mapping);

% Display and save Tone Mapping (SDR) image
figure('Name', 'Tonemapping (SDR) Image'); 
imshow(tone_mapping);
imwrite(tone_mapping, 'images/tonemapping.png');

%% Helper Functions
% create_lookup_table: Takes in a color channel, a list of image names, and 
% a list of exposure lengths to generate a responsive curve g.
function g = create_lookup_table(channel, image_names, exposures)
    % Reference: Lecture 2 (HDR): Slide 27-28
    D = 256; % Number of possible values for z
    N = 510; % Number of locations to use
    L = length(image_names); % Number of images
    E = exposures; % Set of exposure lengths (L of them)
    Z = get_matrix_values(N, L, image_names, channel); % N by L matrix of 
    % values obtained from each images for the current color channel.
    A = zeros(N*L+1, D+N); % Initialize A as a NL+1 by D+N matrix of zeros
    b = zeros(N*L+1); % Initialize b with same number of rows as A (NL+1)
    
    k = 1; % Current equation number
    % Go through each location of each image to populate A and b
    for loc = 1:N
        for exposure = 1:L
            z = Z(loc, exposure);
            A(k, z+1) = 1; % Assign a one to the location in g for z
            A(k, D+loc) = -1; % Mark this location as -1 for pixel location
            b(k) = log(E(exposure)); % This pixel's exposure length

            k = k + 1;
        end
    end
    
    A(k, 127) = 1;
    b(k) = 0;
    x = A\b;
    g = x(1:256); % First 256 values in x
end

% get_matrix_values: Create an N by L matrix of values obtained from each 
% image for a specific color channel. 
% N = Number of Locations 
% L = Number of Images
function Z = get_matrix_values(N, L, images, channel)
    % Initialize matrix of 0s
    Z = zeros(N, L);
    
    for i = 1:L
        im = imread(append('memorial/', images(i)));
        
        % Extract color channel layer
        color = im(:,:,channel);

        for j = 1:N
            Z(j,i) = color(j,j);
        end
    end
end
