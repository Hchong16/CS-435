% Author: Harry Chong
% Date: 2/20/2021
clc, clear, close all

%% 1. Data Setup
filename = "background1";
%filename = "background2";

% Create result folder for input image
[~, ~, ~] = mkdir('results/' + filename); 

% Initialize image
im = imread('images/' + filename + '.jpg');
[h, w, c] = size(im);

%% 2. Image Resizing
for i = 1:2
    % Best results when using the image width/height divided by 1/2, 1/4, or 1/8.
    w_prime = input("Enter a new width: ");
    h_prime = input("Enter a new height: ");

    % Nearest Neightbor Sampling
    nearest_im = uint8(nn_sampling(h, w, h_prime, w_prime, im));
    
    % Display and save results
    figure('Name', sprintf('%s - Nearest Neighbor Sampling (%d x %d)', filename, w_prime, h_prime));
    imshow(nearest_im)
    imwrite(nearest_im, sprintf('results/%s/nn_sampling_%d_x_%d.png', filename, w_prime, h_prime));
    
    % Interpolation
    interpolation_im = uint8(interpolation(h, w, h_prime, w_prime, im));
    
    % Display and save results
    figure('Name', sprintf('%s - Linear Interpolation (%d x %d)', filename, w_prime, h_prime));
    imshow(interpolation_im)
    imwrite(interpolation_im, sprintf('results/%s/linear_interpolation_%d_x_%d.png', filename, w_prime, h_prime));
end
    
%% 3. Energy Function
grayscale_im = rgb2gray(im);

% Using a 3 x 3 Gaussian Filter Function:
% G(x,y) = (1/2pi * sigma^2) * e^-(x^2 + y^2/2 * sigma^2)
% where sigma = 1 and all the elements sum up to one.
gaussian = [.07511 .12380 .07511;
            .12380 .20410 .12380;
            .07511 .12380 .07511;];

% Smooth grayscale image
smooth_grayscale_im = conv2(grayscale_im, gaussian, 'same');

% Compute energy function
E = calculate_energy(smooth_grayscale_im);
energy_im = uint8(E);

% Display and save results
figure('Name', sprintf('%s - Energy Function', filename));
imshow(energy_im)
imwrite(energy_im, sprintf('results/%s/energy_function.png', filename));
    
%% 4. Optimal Seam
% Calculate optimal seam path
M = calculate_seam(E);

% Backtrack and store choices along path
optimal_seam = backtrack(M);

% Overlap optimal seam path with image
optimal_seam_im = overlay(im, optimal_seam);

% Display and save results
figure('Name', sprintf('%s - Optimal Seam', filename));
imshow(optimal_seam_im)
imwrite(optimal_seam_im, sprintf('results/%s/optimal_seam.png', filename));

%% 5. Seam Carving
v = VideoWriter(sprintf('results/%s/seam_carving', filename), 'MPEG-4');
open(v)

% Using a 3 x 3 Gaussian Filter Function:
% G(x,y) = (1/2pi * sigma^2) * e^-(x^2 + y^2/2 * sigma^2)
% where sigma = 1 and all the elements sum up to one.
gaussian = [.07511 .12380 .07511;
            .12380 .20410 .12380;
            .07511 .12380 .07511;];

% Reduce image width down to one pixel wide in each iteration
for cur_width = w:-1:2
    grayscale_im = rgb2gray(im);
    smooth_grayscale_im = conv2(grayscale_im, gaussian, 'same');

    % Utilize all the functins in part 3 and 4
    E = calculate_energy(smooth_grayscale_im);
    M = calculate_seam(E);
    optimal_seam = backtrack(M);
    optimal_seam_im = overlay(im, optimal_seam);

    % Generate frame using original image size containing the optimal seam overlay
    frame = uint8(generate_frame(h, w, optimal_seam_im));
    writeVideo(v,frame);

    % Remove optimal seam from image. Next iteration will generate the
    % video frame with a new optimal seam. 
    im = uint8(delete_seam(im, optimal_seam));
    fprintf("[Seam Carving]: %d of %d frames generated!\n", w-cur_width, w-2)
end
close(v);

%% Helper Functions
% nn_sampling: Resize image using nearest neighbor sampling. Go through
% each location in the target image and assign it the value of the nearest 
% pixel. Return an image of size h' x w', while retaining all color channels. 
function new_im = nn_sampling(h, w, h_prime, w_prime, im)
    % Initialize matrix of 0s
    new_im = zeros(h_prime, w_prime, 3);

    for channel = 1:3
        for i = 1:h_prime % Row
            fprintf("[Nearest Neighbor Sampling]: %d of %d rows converted!\n", i , h_prime)
            for j = 1:w_prime % Col
                x = round(i * (w/w_prime));
                % Edge case for value exceeding boundaries
                if x > h
                    x = h;
                end
                
                y = round(j * (h/h_prime));
                % Edge case for value exceeding boundaries
                if y > w
                    y = w;
                end
               
                % Update image 
                new_im(i,j,channel) = im(x,y,channel);
            end
        end
    end
end

% interpolation: Resize image using interpolation. Go through each location
% in the target image and compute the ideal floating point. Then compute 
% using the values of the four pixel nearest using Euclidean Distance. 
% Return an image of size h' x w', while retaining all color channels. 
function new_im = interpolation(h, w, h_prime, w_prime, im)
    % Initialize matrix of 0s
    new_im = zeros(h_prime, w_prime, 3);
    
    for i = 1:h_prime % Row
        fprintf("[Interpolation]: %d of %d rows converted!\n", i , h_prime)
        for j = 1:w_prime % Col
            % Calculate ideal point
            x = i * (w/w_prime);
            y = j * (h/h_prime);

            % Edge case for value exceeding boundaries
            if x > h
                x = h;
            end

            if y > w
                y = w;
            end

            x1 = floor(x);
            x2 = ceil(x);

            y1 = floor(y);
            y2 = ceil(y);

            possible_nearest = [];
            
            % Case 1: Pixel is between four different values, where all x and y values are different 
            % Take the four corner pixels.
            %(x1,y1) (x2,y1)
            %  A ----- B 
            %  |       |
            %  |   p   |
            %  |       |
            %  C ----- D
            %(x1,y2) (x2,y2)
            if x1 ~= x && x2 ~= x && y1 ~= y && y2 ~= y
                possible_nearest = [possible_nearest; [x1, y1]];
                possible_nearest = [possible_nearest; [x2, y1]];
                possible_nearest = [possible_nearest; [x1, y2]];
                possible_nearest = [possible_nearest; [x2, y2]];
            % Case 2: Pixel is between two different y values, where floor(x) = ceil(x) = x 
            % Look for other two nearest pixel on the left or right column depending on 
            % ideal pixel x coordinate 
            %    (x,y1)
            % ?    A    ? 
            %      |
            %      p    
            %      |
            % ?    C    ?
            %   (x,y2)
            elseif x1 == x && x2 == x && y1 ~= y && y2 ~= y
                % Left Edge Boundary (Take the right column)
                if x == 1 
                    possible_nearest = [possible_nearest; [x, y1]];
                    possible_nearest = [possible_nearest; [x, y2]];
                    possible_nearest = [possible_nearest; [x+1, y1]];
                    possible_nearest = [possible_nearest; [x+1, y2]];
                % Right Edge Boundary (Take the left column)
                elseif x == h 
                    possible_nearest = [possible_nearest; [x, y1]];
                    possible_nearest = [possible_nearest; [x, y2]];
                    possible_nearest = [possible_nearest; [x-1, y1]];
                    possible_nearest = [possible_nearest; [x-1, y2]];
                % Right and Left columns valid. 6 possible points
                else
                    possible_nearest = [possible_nearest; [x, y1]];
                    possible_nearest = [possible_nearest; [x, y2]];
                    possible_nearest = [possible_nearest; [x+1, y1]];
                    possible_nearest = [possible_nearest; [x+1, y2]];
                    possible_nearest = [possible_nearest; [x-1, y1]];
                    possible_nearest = [possible_nearest; [x-1, y2]];
                end
            % Case 3: Pixel is between two different x values, where floor(y) = ceil(y) = y 
            % Look for other two nearest pixel on the above or below row depending on 
            % ideal pixel y coordinate 
            %        ?           ?
            %      
            % (x1,y) A --- p --- C (x2,y)   
            %        
            %        ?           ?
            elseif y1 == y && y2 == y && x1 ~= x && x2 ~= x
                % Top Edge Boundary (Take the below row)
                if y == 1 
                    possible_nearest = [possible_nearest; [x1, y]];
                    possible_nearest = [possible_nearest; [x2, y]];
                    possible_nearest = [possible_nearest; [x1, y+1]];
                    possible_nearest = [possible_nearest; [x2, y+1]];
                % Bottom Edge Boundary (Take the above row)
                elseif y == w 
                    possible_nearest = [possible_nearest; [x1, y]];
                    possible_nearest = [possible_nearest; [x2, y]];
                    possible_nearest = [possible_nearest; [x1, y-1]];
                    possible_nearest = [possible_nearest; [x2, y-1]];
                % Above and Below rows valid. 6 possible points
                else
                    possible_nearest = [possible_nearest; [x1, y]];
                    possible_nearest = [possible_nearest; [x2, y]];
                    possible_nearest = [possible_nearest; [x1, y+1]];
                    possible_nearest = [possible_nearest; [x2, y+1]];
                    possible_nearest = [possible_nearest; [x1, y-1]];
                    possible_nearest = [possible_nearest; [x2, y-1]];
                end
            % Case 4: Pixel is on actual coordinate (not a float value)
            % Coordinates:
            %     o
            %   o o o
            % o o p o o
            %   o o o
            %     o
            else
                % ex. If x is equal to 0, we want x to equal the max width (wrap around)
                % Formula only works with zero indexed matrices. temp_x and temp_y are
                % the zero out coordinates.
                temp_x = x - 1;
                temp_y = y - 1;

                x1 = mod(temp_x + h - 1, h) + 1;
                x2 = mod(temp_x + h - 2, h) + 1;
                x3 = mod(x + 1, h);
                x4 = mod(x + 2, h);

                y1 = mod(temp_y + w - 1, w) + 1;
                y2 = mod(temp_y + w - 2, w) + 1;
                y3 = mod(y + 1, w);
                y4 = mod(y + 2, w);

                % Coordinates:
                %   o
                % o o o
                %   p
                possible_nearest = [possible_nearest; [x1, y1]]; % (x-1, y-1)
                possible_nearest = [possible_nearest; [x, y1]];   % (x, y-1)
                possible_nearest = [possible_nearest; [x, y2]];  % (x, y-2)
                possible_nearest = [possible_nearest; [x3, y1]]; % (x+1, y-1)


                % Coordinates:
                % o o p o o
                possible_nearest = [possible_nearest; [x2, y]]; % (x-2, y)
                possible_nearest = [possible_nearest; [x1, y]]; % (x-1, y)
                possible_nearest = [possible_nearest; [x3, y]]; % (x+1, y)
                possible_nearest = [possible_nearest; [x4, y]]; % (x+2, y)

                % Coordinates:
                %   p
                % o o o
                %   o
                possible_nearest = [possible_nearest; [x1, y3]]; % (x-1, y+1)
                possible_nearest = [possible_nearest; [x, y3]];  % (x, y+1)
                possible_nearest = [possible_nearest; [x, y4]];  % (x, y+2)
                possible_nearest = [possible_nearest; [x3, y3]]; % (x+1, y+1)
            end
            % Use Euclidean Distance to calculate distance from ideal pixel to all possible 
            % nearest pixels.
            distances = sqrt((possible_nearest(:,1) - x).^2 + (possible_nearest(:,2) - y).^2);

            % Return the 4 nearest pixels
            [closest, indices] = mink(distances, 4);

            dA = closest(1);
            dB = closest(2);
            dC = closest(3);
            dD = closest(4);

            A = possible_nearest(indices(1), :);
            B = possible_nearest(indices(2), :);
            C = possible_nearest(indices(3), :);
            D = possible_nearest(indices(4), :);
            
            % Use interpolating formula from Retargetting Lecture - Slide 13
            % Retrieve all color value of each pixel
            fA = im(A(1), A(2), :);
            fB = im(B(1), B(2), :);
            fC = im(C(1), C(2), :);
            fD = im(D(1), D(2), :);
            
            dA = 1/dA;
            dB = 1/dB;
            dC = 1/dC;
            dD = 1/dD; 
            
            fp_a = fA .* (dA / (dA + dB + dC + dD));
            fp_b = fB .* (dB / (dA + dB + dC + dD));
            fp_c = fC .* (dC / (dA + dB + dC + dD));
            fp_d = fD .* (dD / (dA + dB + dC + dD));
            
            fp = fp_a + fp_b + fp_c + fp_d;
            
            new_im(i,j,:) = fp;
        end
    end
end

% calculate_energy: Apply convolution on smoothed grayscaled image to
% obtain the directional gradients. Use the absolute values of the gradient
% to calculate and return the energy matrix
function E = calculate_energy(smooth_grayscale_im)
    % Use derivative kernels from Edges Lecture - Slide 10
    dx = [1/2 0 -1/2;
          1/2 0 -1/2;
          1/2 0 -1/2;];

    dy = [1/2 1/2 1/2;
           0   0   0;
         -1/2 -1/2 -1/2;];

    % Overlay and convolve to obtain directional gradients
    gx = conv2(smooth_grayscale_im, dx, 'same');
    gy = conv2(smooth_grayscale_im, dy, 'same');

    % Take the sum of the absolute value of the gradients to obtain the
    % gradient-based energy E(I). Retargetting Lecture - Slide 22
    E = abs(gx) + abs(gy);
end

% calculate_seam: Find optimal vertical seam in energy function matix using 
% dynamic programming from Retargetting Lecture - Slide 26
function M = calculate_seam(E)
    % Retrieve all possible coordinates
    [x, y] = size(E);

    % Initialize matrix of 0s
    M = zeros(x, y);
    for i = 1:x % Row
        for j = 1:y % Column
            % Base case - Top most row
            if i == 1
                M(1, j) = E(1, j);
                continue 
            end

            % Determine the values on the row above current row
            if j-1 < 1
                topLeft = inf;
            else
                topLeft = M(i-1, j-1);
            end

            if i-1 < 1
                topMiddle = inf;
            else
                topMiddle = M(i-1, j);
            end
            
            if j+1 > y
                topRight = inf;
            else
                topRight = M(i-1, j+1);
            end

            % Take the minimum value of the 3 pixels above the current pixel
            value = min([topLeft topMiddle, topRight]);
            M(i, j) = E(i, j) + value;
        end
    end
end

% backtrack: Backtrack and store choices along the path in M.
% Return optimal path seam. Retargetting Lecture - Slide 27
function path = backtrack(M)
    % Retrieve all possible coordinates
    [x, y] = size(M);

    % Initialize matrix of 0s. Replace 0s with 1s to indicate seam path.
    path = zeros(x, y);

    % Loop backwards from M, finding least value in each row
    for i = x:-1:2 % Row
        % Handle starting value by finding minimum value in last row of M
        if i == x
            lastRow = M(x, :);
            [~, j] = min(lastRow);
            path(x, j) = 1;
        end
        
        % Determine the 3 values above the current value
        if j-1 < 1
            topLeft = inf;
        else
            topLeft = M(i-1, j-1);
        end

        if i-1 < 1
            topMiddle = inf;
        else
            topMiddle = M(i-1, j);
        end

        if j+1 > y
            topRight = inf;
        else
            topRight = M(i-1, j+1);
        end

        % Find the minimum value y coordinate
        values = [topLeft topMiddle, topRight];
        col_coordinates = [j-1 j j+1];
        
        [val, index] = min(values);
        j = col_coordinates(index);
        
        % Update optimal path
        path(i-1, j) = 1;
    end
end

% overlap: Overlay optimal seam path in red onto color image.
function optimal_seam_im = overlay(im, seam)
    % Retrieve all possible coordinates
    [x, y] = size(seam);
    
    % Alter original pixel value in red if coordinate value in optimal seam 
    % is equal to 1.
    for i = 1:x % Row 
        for j= 1:y  % Column
            if(seam(i, j) == 1)
               im(i, j, 1) = 255; % R
               im(i, j, 2) = 0; % G
               im(i, j, 3) = 0; % B
            end
        end
    end
    optimal_seam_im = im;
end

% delete_seam: Delete optimal seam from image and reduce the current image 
% width by one pixel.
function new_im = delete_seam(im, seam)
    % Retrieve size of current image
    [x, y, c] = size(im);
    
    % Initialize new image matrix, removing one column
    new_im = zeros(x, y-1, c);

    for i = 1:x % Row
        % Retrieve all values for one row in the optimal seam and find the
        % seam coordinate
        seam_row = seam(i,:);
        [row, col] = find(seam_row == 1);

        % Remove the optimal pixel from the image color channel
        r_channel = im(i, :, 1);
        g_channel = im(i, :, 2);
        b_channel = im(i, :, 3);

        r_channel(col) = [];
        g_channel(col) = [];
        b_channel(col) = [];

        % Write the values to the new image matrix
        new_im(i, :, 1) = r_channel;
        new_im(i, :, 2) = g_channel;
        new_im(i, :, 3) = b_channel;
    end
end

% generate_frame: Generate padded frame of the original image size. Return 
% frame to be used for render.
function frame = generate_frame(h, w, im)
    % Initialize frame of size h x w for all 3 color channel
    frame = zeros(h, w, 3);
    
    % Retrieve all possible pixel coordinates and write to video frame
    [x, y, c]= size(im);
    frame(1:x,1:y,:) = im(:,:,:);
end
