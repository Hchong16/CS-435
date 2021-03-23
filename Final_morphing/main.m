% Authors: Harry Chong and Willow Livengood
% Date: 3/5/2021
clc, clear, close all

%% Dataset Setup
% [USER PARAMETER]: Change this to the folder name containing the image and correspondence files.
% Folder be put into the 'data' folder and must contain the following: 'img1.jpg', 'img2.jpg', and 'correspondences.csv'.
data_dir = "Set1";
%data_dir = "Set2";
%data_dir = "Assignment_Example";

% Read main files
im1 = imread(sprintf("./data/%s/%s", data_dir, 'img1.jpg'));
im2 = imread(sprintf("./data/%s/%s", data_dir, 'img2.jpg'));
correspondence = readmatrix(sprintf("./data/%s/%s", data_dir, 'correspondences.csv'));

% Create respective result folder for data_dir
[~, ~, ~] = mkdir(sprintf("./results/%s", data_dir));

%% 1. Scan-fill a Triangle
% Triangle with vertices (x,y): (30, 20), (50, 100), (80, 50)
x = [30, 50, 80]; y = [20, 100, 50];
min_x = min(x); max_x = max(x);
min_y = min(y); max_y = max(y);

% Retrieve all Line Segments
vertices = [x' y'];
num_vertices = length(vertices);
segments = retrieve_segments(x, y, vertices, num_vertices);

[num_segments, ~] = size(segments);

figure('Name','Scanned Filled Triangle')
for y = ceil(min_y):floor(max_y)
    % For each line segment making up the triangle
    bound_x = []; % Track all x values on the current y axis
    for i = 1:num_segments 
        line = segments(i, :);
        
        x1 = line(1); 
        x2 = line(3);
        y1 = line(2); 
        y2 = line(4);
        
        % Compute the x-value for the line using the current value of y from
        % the point-slope form of a line.
        m = (y2-y1)/(x2-x1);
        x = ((y - y1)/m) + x1;
        
        % Plot edge boundary of triangle
        if not(x > max_x) && not(x < min_x)
            bound_x = [bound_x x];
            hold on
            plot(x,y,'ro')
        end
    end
   
    min_bound_x = min(bound_x);
    max_bound_x = max(bound_x);
    
    % Plot in-between values in the triangle
    for x = floor(min_bound_x):ceil(max_bound_x)
        hold on
        plot(x,y,'ro')
    end
end

% Save results
[~, ~, ~] = mkdir("./results/1.scanned_filled_triangle");
saveas(gcf, './results/1.scanned_filled_triangle/scan_filled_triangle.png')

%% 2. Finding a Transformation
[~, ~, ~] = mkdir("./results/2.finding_a_transformation");

% Triangle with vertices (x,y): (30, 20), (50, 100), (80, 50)
x = [30, 50, 80]; y = [20, 100, 50];

% Add first vertex to x and y to close off the triangle
x = [x x(1)];
y = [y y(1)];

% Display Original Vertices
figure('Name','Original Vertices');
plot(x,y,'r-')
axis([min(x) max(x) min(y) max(y)])

% Save results
saveas(gcf, './results/2.finding_a_transformation/original_vertices.png')

% Tranform via Perform via homogenous coordinates. 
temp = [x' y'];
vertices = [temp, ones(size(temp,1),1)]; % Add a 3rd coordinate equal to 1 (w)

num_vertices = length(vertices);
[num_segments, ~] = size(vertices);

% Transformation matrix that rotates by 20 degrees, translate tx = 10, ty = 20, scales uniformly by a factor of 2.
% Starts on Rightmost
fprintf("Tranformation Matrix: ")
T = [2 0 0; 0 2 0; 0 0 1]*[1 0 10; 0 1 20; 0 0 1]*[cosd(20) -sind(20) 0; sind(20) cosd(20) 0; 0 0 1]

transformed_vertices = [];
for idx = 1:num_segments + 1 % +1 to create line segment from first vertice to last vertice
    if idx ~= num_segments + 1
        % Apply Tranformation Matrix
        transformed_vertices = [transformed_vertices; (T * vertices(idx,:)')'];
    else
        % Copy first row of coordinates to draw the last line segment
        transformed_vertices = [transformed_vertices; transformed_vertices(1,:)];
    end
end

% Display Transformed Vertices
transformed_x = transformed_vertices(:,2);
transformed_y = transformed_vertices(:,1);
figure('Name','Transformed Vertices')
plot(transformed_x,transformed_y,'r-')
axis([min(transformed_x) max(transformed_x) min(transformed_y) max(transformed_y)])

% Save results
saveas(gcf, './results/2.finding_a_transformation/tranformed_vertices.png')

% Take inverse of the transformation matrix (learned matrix) to revert back to original
% locations
fprintf("Learned Matrix: ")
inverse_T = inv(T)

recovered_vertices = [];
for idx = 1:num_segments + 1 % +1 to create line segment from first vertice to last vertice
    if idx ~= num_segments + 1
        % Apply Learned Matrix
        recovered_vertices = [recovered_vertices; (inverse_T * transformed_vertices(idx,:)')'];
    else
        % Copy first row of coordinates to draw the last line segment
        recovered_vertices = [recovered_vertices; recovered_vertices(1,:)];
    end
end

% Display Recovered Vertices
recovered_x = recovered_vertices(:,1);
recovered_y = recovered_vertices(:,2);
figure('Name','Recovered Vertices')
plot(recovered_x,recovered_y,'r-')
axis([min(x) max(x) min(y) max(y)])

% Save results
saveas(gcf, './results/2.finding_a_transformation/recovered_vertices.png')

%% 3. Cross Dissolve
% Extract corner correspondence points for im1 and im2
im1_correspondence = correspondence(:, 1:2);
img1_x1 = min(im1_correspondence(:,1)); % Left Edge
img1_x2 = max(im1_correspondence(:,1)); % Right Edge
img1_y1 = min(im1_correspondence(:,2)); % Top Edge 
img1_y2 = max(im1_correspondence(:,2)); % Bottom Edge

im2_correspondence = correspondence(:, 3:4);
img2_x1 = min(im2_correspondence(:,1)); % Left Edge
img2_x2 = max(im2_correspondence(:,1)); % Right Edge
img2_y1 = min(im2_correspondence(:,2)); % Top Edge 
img2_y2 = max(im2_correspondence(:,2)); % Bottom Edge

% Determine the smallest rectangle bounding based on area
img1_bounding_area = ((img1_x2 - img1_x1) * (img1_y2 - img1_y1));
img2_bounding_area = ((img2_x2 - img2_x1) * (img2_y2 - img2_y1));

% Use im1 correspondence points if its area is greater, else use im2
% correspondence points.
if img1_bounding_area > img2_bounding_area
    final_x1 = img1_x1;
    final_x2 = img1_x2;
    final_y1 = img1_y1;
    final_y2 = img1_y2;
else
    final_x1 = img2_x1;
    final_x2 = img2_x2;
    final_y1 = img2_y1;
    final_y2 = img2_y2;
end
    
% Turning pixels outside the smallest rectangle bounding to white.
cropped_im1 = im1;
cropped_im2 = im2;

% Convert pixels outside smallest rectangle bounding the correspondence
% points to white for image 1 and image 2.
for i = 1:size(im1,1)
    for j = 1:size(im1,2)
        % If inside bounded rectangle, pass. Else, change pixel to white
        if (i > final_x1 && i < final_x2) && (j > final_y1 && j < final_y2)
            continue
        else
            cropped_im1(j,i,:) = 255;
        end
    end
end

for i = 1:size(im2,1)
    for j = 1:size(im2,2)
        % If inside bounded rectangle, pass. Else, change pixel to white
        if (i > final_x1 && i < final_x2) && (j > final_y1 && j < final_y2)
            continue
        else
            cropped_im2(j,i,:) = 255;
        end
    end
end

% Generate video for 100 frames
[~, ~, ~] = mkdir(sprintf("./results/%s/3.cross_dissolve", data_dir));
v = VideoWriter(sprintf('./results/%s/3.cross_dissolve/video', data_dir), 'MPEG-4');
open(v)

alpha = 0;
tol = eps(12); % Tolerance for floating-point alpha
for i = 1:100
    morphed_im = uint8((1-alpha)*double(cropped_im1(:,:,:)) + alpha*double(cropped_im2(:,:,:)));
    % Save image pair if alpha equals 0.3 or 0.7(Have to use tolerance since MATLAB float is weird)
    if abs(alpha-0.3) < tol*max(alpha, 0.3)
        figure('Name',sprintf('Cross Dissolve (Alpha = 0.3)'));
        imshow(morphed_im)
        saveas(gcf, sprintf('./results/%s/3.cross_dissolve/alpha_0.3.png', data_dir))
    elseif abs(alpha-0.7) < tol*max(alpha, 0.7)
        figure('Name',sprintf('Cross Dissolve (Alpha = 0.7)'));
        imshow(morphed_im)
        saveas(gcf, sprintf('./results/%s/3.cross_dissolve/alpha_0.7.png', data_dir))
    end  
    writeVideo(v, morphed_im);
    alpha = alpha + 0.01;
end
close(v);

%% 4. Visualize Point and Triangle Correspondences
% Extract all correspondence points for im1 and im2
im1_correspondence_x = correspondence(:, 1);
im1_correspondence_y = correspondence(:, 2);

im2_correspondence_x = correspondence(:, 3);
im2_correspondence_y = correspondence(:, 4);

% Visualize triangulations for Image 1
T = delaunay(im1_correspondence_x, im1_correspondence_y);
figure('Name', sprintf('Image 1 Point and Triangulation Correspondences'));
imagesc(im1)
set(gca,'visible','off')
hold on
triplot(T, im1_correspondence_x, im1_correspondence_y, 'r');

% Setup results directory
[~, ~, ~] = mkdir(sprintf("./results/%s/4.visualize_correspondences", data_dir));

% Save results
saveas(gcf, sprintf('./results/%s/4.visualize_correspondences/image1_triangulations.png', data_dir))

% Visualize triangulations for Image 2 pertaining to the FIRST image's points
T = delaunay(im1_correspondence_x, im1_correspondence_y);
figure('Name', sprintf('Image 2 Point and Triangulation Correspondences'));
imagesc(im2)
set(gca,'visible','off')
hold on
triplot(T, im2_correspondence_x, im2_correspondence_y, 'r');

% Save results
saveas(gcf, sprintf('./results/%s/4.visualize_correspondences/image2_triangulations.png', data_dir))

%% 5. Morphing
% Extract all correspondence points: im1(Column 1(x) and 2(y)) and im2 (Column 3(x) and 4(y))
im1_correspondence_x = correspondence(:, 1);
im1_correspondence_y = correspondence(:, 2);
im1_points = [im1_correspondence_x im1_correspondence_y;];

im2_correspondence_x = correspondence(:, 3);
im2_correspondence_y = correspondence(:, 4);
im2_points = [im2_correspondence_x im2_correspondence_y;];

% Retrieve all triangulations using image 1 points
tri = delaunay(im1_correspondence_x, im1_correspondence_y);
num_tri = size(tri,1); % Number of triangles

alpha = 0;
tol = eps(12); % Tolerance for floating-point alpha

% Generate video for 100 frames
[~, ~, ~] = mkdir(sprintf("./results/%s/5.morphing", data_dir));
v = VideoWriter(sprintf('./results/%s/5.morphing/video', data_dir), 'MPEG-4');
open(v)

[h, w, c] = size(im1); % Size shouldn't matter since im1 and im2 are the same
for i = 1:100
    % Set background of image to white
    morphed_im = zeros(h, w, 3); % Output image
    morphed_im(:,:,:) = 255;
    
    [h, w, c] = size(im1);
    
    % i. Compute the vertex location of the new destination triangle by 
    % linearly interpolating the vertex locations of the triangles 
    % according to alpha (Destination Triangle)
    target_vertices = (1-alpha)*im1_points + alpha*im2_points;

    % For each triangle
    for t = 1:num_tri
        % ii. Compute the two affine transformation matrices needed to go from 
        % each source triangles to the destination triangle. Transformation Lecture - Slide 27
        T_im1 = zeros(3,3,size(tri,1));
        T_im2 = zeros(size(T_im1));
        
        % Convert delaunay indices to the original vertices values
        im1_vertice_1 = correspondence(tri(t,1),1:2);
        im1_vertice_2 = correspondence(tri(t,2),1:2);
        im1_vertice_3 = correspondence(tri(t,3),1:2);
        
        im2_vertice_1 = correspondence(tri(t,1),3:4);
        im2_vertice_2 = correspondence(tri(t,2),3:4);
        im2_vertice_3 = correspondence(tri(t,3),3:4);
        
        target_vertice_1 = [target_vertices(tri(t,1), :)];
        target_vertice_2 = [target_vertices(tri(t,2), :)];
        target_vertice_3 = [target_vertices(tri(t,3), :)];
        
        % T = X*A^-1
        A_1 = [im1_vertice_1(1) im1_vertice_2(1) im1_vertice_3(1);
               im1_vertice_1(2) im1_vertice_2(2) im1_vertice_3(2);
                     1                1                1         ;];
                
        A_2 = [im2_vertice_1(1) im2_vertice_2(1) im2_vertice_3(1);
               im2_vertice_1(2) im2_vertice_2(2) im2_vertice_3(2);
                     1                1                1         ;];
             
        X = [target_vertice_1(1) target_vertice_2(1) target_vertice_3(1);
             target_vertice_1(2) target_vertice_2(2) target_vertice_3(2);
                      1                   1                   1         ;];
                 
        % Affine Tranformation going from source to destination
        T1 = X*inv(A_1);
        T2 = X*inv(A_2);
        
        % Validation  
        %destination_im1 = T1 * A_1 % source to destination
        %source_im1 =  inv(T1) * X % destination to source
        %destination_im2 = T2 * A_2 % source to destination
        %source_im2 =  inv(T2) * X % destination to source
        
        % iii. For each pixel in the destination triangle     
        target_x = [target_vertice_1(1) target_vertice_2(1) target_vertice_3(1)];
        target_y = [target_vertice_1(2) target_vertice_2(2) target_vertice_3(2)];
        min_x = min(target_x); max_x = max(target_x);
        min_y = min(target_y); max_y = max(target_y);
       
        % Retrieve all Line Segments
        vertices = [target_x' target_y'];
        num_vertices = length(vertices);
        segments = retrieve_segments(target_x, target_y, vertices, num_vertices);

        [num_segments, ~] = size(segments);
        for y = ceil(min_y):round(max_y)
            % For each line segment making up the triangle
            bound_x = []; % Track all x values on the current y axis
            for idx = 1:num_segments
                line = segments(idx, :);

                x1 = line(1); 
                x2 = line(3);
                y1 = line(2); 
                y2 = line(4);

                % Compute the x-value for the line using the current value of y from
                % the point-slope form of a line.
                m = (y2-y1)/(x2-x1);
                x = ((y - y1)/m) + x1;

                % Edge boundary of triangle
                if not(x > max_x) && not(x < min_x)
                    bound_x = [bound_x x];
                end
            end

            min_bound_x = min(bound_x);
            max_bound_x = max(bound_x);
            
            % Alter in-between values in the triangle
            for x = floor(min_bound_x):ceil(max_bound_x)
                % A. Use the inverse of the transformation matrices to find the 
                % corresponding destination locations to the source triangles
                im1_source = round(inv(T1)*[x y 1]');
                im2_source = round(inv(T2)*[x y 1]');

                % Remove any negative points
                im1_source(im1_source < 1) = 1;
                im2_source(im2_source < 1) = 1;
                
                % If any points exceed image size, set to max
                if im1_source(2) > h
                    im1_source(2) = h;
                end
                    
                if im1_source(1) > w
                    im1_source(1) = w;
                end
                    
                if im2_source(2) > h
                    im2_source(2) = h;
                end
                    
                if im2_source(1) > w
                    im2_source(1) = w;
                end
                        
                % B. Blend the values from the sources triangles according to alpha, 
                % and assign that value to the current pixel at the destination triangle.
                morphed_im(y,x,:) = (1-alpha)*im1(im1_source(2), im1_source(1), :) + ...
                    alpha*im2(im2_source(2), im2_source(1), :);
            end
        end
    end  
    
    morphed_im = uint8(morphed_im);

    % Save image pair if alpha equals 0.3 or 0.7 (Have to use tolerance since MATLAB float is weird)
    if abs(alpha-0.3) < tol*max(alpha, 0.3)
        figure('Name',sprintf('Morphing (Alpha = 0.3)'));
        imshow(morphed_im)
        set(gca,'visible','off')
        saveas(gcf, sprintf('./results/%s/5.morphing/alpha_0.3.png', data_dir))
    elseif abs(alpha-0.7) < tol*max(alpha, 0.7)
        figure('Name',sprintf('Morphing (Alpha = 0.7)'));
        imshow(morphed_im)
        set(gca,'visible','off')
        saveas(gcf, sprintf('./results/%s/5.morphing/alpha_0.7.png', data_dir))
    end  

    writeVideo(v, morphed_im)
    alpha = alpha + 0.01;
    
    fprintf("[Morphing]: %d of 100 frames generated!\n", i)
end
fprintf("[Morphing]: Done!\n");
close(v);

%% Helper Functions
% retrieve_segments: Passing in a matrix of x and y coordinates, create a
% matrix of rows indicating the two pair vertices [x1 x2 y1 y2]
function segments = retrieve_segments(x, y, vertices, num_vertices)
    segments = [];

    for i = 1:num_vertices + 1 % +1 to include line segment from first to last vertice
        if i ~= num_vertices + 1
            x1 = vertices(1+mod(i-1, num_vertices),1);
            x2 = vertices(1+mod(i, num_vertices),1);

            y1 = vertices(1+mod(i-1, num_vertices),2);
            y2 = vertices(1+mod(i, num_vertices),2);

            segments = [segments; [x1 y1 x2 y2]];
        else
            segments = [segments; segments(1,:)];     
        end
    end
end
