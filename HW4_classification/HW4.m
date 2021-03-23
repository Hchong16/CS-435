% Author: Harry Chong
% Date: 3/2/2021
clc, clear, close all

%% Set Seed to 0
rng(0);

%% 1a. Data Setup using Grayscale Histograms
% Parse out three categories: 
% X = feature vector, Y = class label (1 = car/ 0 = not car), and filenames
directory = 'CarData/TrainImages';
files = dir(directory);

X = [];
Y = [];
N = {};

for f = files'
    if ~f.isdir
        im = imread(sprintf("%s/%s", directory, f.name));
        % Generate feature  vector 
        X(end+1,:) = generate_features(im);
        Y(end+1,1) = ~strcmp(f.name(1:3),'neg');
        N = [N f.name];
    end
end

% Set seed to 0
% Shuffle and divide the data into training and validation subsets
inds = randperm(size(X,1));
num = size(X,1)/3;

X = X(inds,:);
Y = Y(inds,:);
N = N(inds);

Xtrain = X(1:2*num,:);
Ytrain = Y(1:2*num,:);
Ntrain = N(1:2*num);

Xvalid = X(2*num+1:end,:);
Yvalid = Y(2*num+1:end,:);
Nvalid = N(2*num+1:end);

[num_images, bins] = size(Xvalid);

%% 1b. Classifying an Image using Grayscale Histograms
correct = 0; % Correct Predictions

for i = 1:num_images
    % Prediction = 0 (Not Car) | Prediction = 1 (Car)
    prediction = predict_class(Xvalid(i,:), Xtrain, Ytrain); 
    
    if prediction == Yvalid(i)
        correct = correct + 1;
    end
    
    % Retrieve index for correctly/incorrectly labeled image
    if prediction == 1 && Yvalid(i) == 1
        correct_car_idx = i;       % Image correctly labeled as a car
    elseif prediction == 0 && Yvalid(i) == 0
        correct_not_car_idx = i;   % Image correctly labeled as not a car
    elseif prediction == 1 && Yvalid(i) == 0
        incorrect_car_idx = i;     % Image incorrectly labeled as a car
    elseif prediction == 0 && Yvalid(i) == 1
        incorrect_not_car_idx = i; % Image incorrectly labeled as not a car
    end
end

% Display and save image for each correctly and incorrectly labeled image
figure('Name', sprintf('K-NN using Grayscale Histograms - Image Correctly Labeled as a Car'));
im = imread(sprintf("CarData/TrainImages/%s", string(Nvalid(correct_car_idx))));
imshow(im)
imwrite(im, sprintf('results/knn_histograms/correct_car.png'));

figure('Name', sprintf('K-NN using Grayscale Histograms - Image Correctly Labeled as a Not Car'));
im = imread(sprintf("CarData/TrainImages/%s", string(Nvalid(correct_not_car_idx))));
imshow(im)
imwrite(im, sprintf('results/knn_histograms/correct_not_car.png'));

figure('Name', sprintf('K-NN using Grayscale Histograms - Image Incorrectly Labeled as a Car'));
im = imread(sprintf("CarData/TrainImages/%s", string(Nvalid(incorrect_car_idx))));
imshow(im)
imwrite(im, sprintf('results/knn_histograms/incorrect_car.png'));

figure('Name', sprintf('K-NN using Grayscale Histograms - Image Inorrectly Labeled as a Not Car'));
im = imread(sprintf("CarData/TrainImages/%s", string(Nvalid(incorrect_not_car_idx))));
imshow(im)
imwrite(im, sprintf('results/knn_histograms/incorrect_not_car.png'));

% Calculate prediction accuracy
accuracy = correct/num;
fprintf("Accuracy with K-NN using Grayscale Histograms: %f%%\n", accuracy*100)

%% 2a. Data Setup using HOGs (histogram of oriented gradients)
% Parse out three categories: 
% X = feature vector, Y = class label (0 = not car/ 1 = car), and filenames
directory = 'CarData/TrainImages';
files = dir(directory);

X = [];
Y = [];
N = {};

for f = files'
    if ~f.isdir
        im = imread(sprintf("%s/%s", directory, f.name));
        % Generate feature  vector 
        X(end+1,:) = generate_hist_hog(im);
        Y(end+1,1) = ~strcmp(f.name(1:3),'neg');
        N = [N f.name];
    end
end

% Shuffle and divide the data into training and validation subsets
inds = randperm(size(X,1));
num = size(X,1)/3;

X = X(inds,:);
Y = Y(inds,:);
N = N(inds);

Xtrain = X(1:2*num,:);
Ytrain = Y(1:2*num,:);
Ntrain = N(1:2*num);

Xvalid = X(2*num+1:end,:);
Yvalid = Y(2*num+1:end,:);
Nvalid = N(2*num+1:end);

[num_images, bins] = size(Xvalid);

%% 2b. Classifying an Image using Gists
correct = 0; % Correct Predictions

for i = 1:num_images
    % Prediction = 0 (Not Car) | Prediction = 1 (Car)
    prediction = predict_class(Xvalid(i,:), Xtrain, Ytrain); 
    
    if prediction == Yvalid(i)
        correct = correct + 1;
    end
    
    % Retrieve index for correctly/incorrectly labeled image
    if prediction == 1 && Yvalid(i) == 1
        correct_car_idx = i;       % Image correctly labeled as a car
    elseif prediction == 0 && Yvalid(i) == 0
        correct_not_car_idx = i;   % Image correctly labeled as not a car
    elseif prediction == 1 && Yvalid(i) == 0
        incorrect_car_idx = i;     % Image incorrectly labeled as a car
    elseif prediction == 0 && Yvalid(i) == 1
        incorrect_not_car_idx = i; % Image incorrectly labeled as not a car
    end
end

% Display and save image for each correctly and incorrectly labeled image
figure('Name', sprintf('K-NN using Gist - Image Correctly Labeled as a Car'));
im = imread(sprintf("CarData/TrainImages/%s", string(Nvalid(correct_car_idx))));
imshow(im)
imwrite(im, sprintf('results/knn_gists/correct_car.png'));

figure('Name', sprintf('K-NN using Gist - Image Correctly Labeled as a Not Car'));
im = imread(sprintf("CarData/TrainImages/%s", string(Nvalid(correct_not_car_idx))));
imshow(im)
imwrite(im, sprintf('results/knn_gists/correct_not_car.png'));

figure('Name', sprintf('K-NN using Gist - Image Incorrectly Labeled as a Car'));
im = imread(sprintf("CarData/TrainImages/%s", string(Nvalid(incorrect_car_idx))));
imshow(im)
imwrite(im, sprintf('results/knn_gists/incorrect_car.png'));

figure('Name', sprintf('K-NN using Gist - Image Inorrectly Labeled as a Not Car'));
im = imread(sprintf("CarData/TrainImages/%s", string(Nvalid(incorrect_not_car_idx))));
imshow(im)
imwrite(im, sprintf('results/knn_gists/incorrect_not_car.png'));

% Calculate prediction accuracy
accuracy = correct/num;
fprintf("Accuracy with K-NN using Gist: %f%%\n", accuracy*100)

%% Helper Functions
% generate_features: Take in a grayscale image and compute its histogram with
% 256 bins. Histogram of intensities is the feature.
function bins = generate_features(im)
    data = reshape(im, 1, numel(im));
    bins = zeros(1,256);
    for val = 0:255
        bins(val+1) = sum(data == val);
    end
    bins = bins/256;
end

%% generate_hist_hog: 
% generate_hist_hog: Divide an image into sub-regions. Then, within each 
% sub-region, apply a derivative kernel to obtain the gradient matrices. 
% Compute the angle of 8 different possible orientations (0°,45°,90°,135°,
% 180°,225°,270°,315°) of the element. Using all this, we can compute the
% histogram of 8 bins and put it together for a feature vector with 
% 10∗8=80 values in it. In other words, a histogram of 8 bins. 

%Classification Lecture - Slide 7 to 10
function hog = generate_hist_hog(im)
    hog = [];
    
    % Divide image into 10 non-overlapping 20x20 sub-images
    regions = mat2cell(im,[20 20], [20 20 20 20 20]);
    [x, y] = size(regions);
    
    for i = 1:x
        for j = 1:y
            % Convert cell array to ordinary array
            cur_region = cell2mat(regions(i,j));
            
            % Use derivative kernels from Edges Lecture - Slide 10
            dx = [1/2 0 -1/2;
                  1/2 0 -1/2;
                  1/2 0 -1/2;];

            dy = [1/2 1/2 1/2;
                   0   0   0;
                 -1/2 -1/2 -1/2;];
             
            % Overlay and convolve to obtain directional gradients
            gx = conv2(cur_region, dx, 'same');
            gy = conv2(cur_region, dy, 'same');
            
            % Calculate angle taking the inverse tan of the gradients. 
            % Classification Lecture - Slide 8
            angles = zeros(size(cur_region));
            angles(:,:) = atan2d(gy(:,:), gx(:,:));
            
            % Iterate each angle along flat array
            condensed_angles = reshape(angles, 1, numel(angles));
            
            % 8 angles = 8 bins
            bins = zeros(1,8);
            
            % Possible Orientations: (0°,45°,90°,135°,180°,225°,270°,315°) 
            % Classification Lecture - Slide 10
            for angle = 1:400
                value = condensed_angles(angle);
                if (value >= 0 && value < 45)
                    bins(1) = bins(1) + 1;
                elseif (value >= 45 && value < 90)
                    bins(2) = bins(2) + 1; 
                elseif (value >= 90 && value < 135)
                    bins(3) = bins(3) + 1;
                elseif (value >= 135 && value < 180)
                    bins(4) = bins(4) + 1;
                elseif (value >= 180 && value < 225)
                    bins(5) = bins(5) + 1;
                elseif (value >= 225 && value < 270)
                    bins(6) = bins(6) + 1;
                elseif (value >= 270 && value < 315)
                    bins(7) = bins(7) + 1;
                elseif (value >= 315 && value <= 360)
                    bins(8) = bins(8) + 1;
                end
            end
            bins = bins/8;   
            
            % Concatenate the 10 8-bins to hog array
            hog = [hog bins];
        end
    end
end

% predict class: Compute the distance/similarity of the current validation
% histogram (A) to all the training observations' histograms (B). Following 
% steps  in the Classification Lecture - Slide 21 and using the formula 
% on the HW.
function prediction = predict_class(A, B, labels) % A = Validation, B = train, labels = train labels
    [num_trains, bins] = size(B);
    sims = zeros(num_trains, 1);
    
    % For the validation histogram, compute the summation of the
    % distance/similarity against all the training observations'
    % histograms.
    for i = 1:num_trains
        summation = 0;
        for j = 1:bins
            summation = summation + min(A(j), B(i,j));
        end
        sims(i) = summation; 
    end
    
    % Select the k best ones, and allow them to vote for the class (k = 5)
    [~, I] = maxk(sims, 5);
    voters = zeros(5,1);
    voters(:) = labels(I(:));
    vote = sum(voters);
    
    if vote >= 3
        prediction = 1; % Prediction: Car
    else
        prediction = 0; % Prediction: Not Car
    end
end
    