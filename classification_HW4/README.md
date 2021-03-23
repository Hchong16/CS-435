### Author: Harry Chong
Date: 3/2/2021

## i. Features of the program
The program is broken up into 2 sections with 2 subsections: 
1. Classifying an Image using Grayscale Histograms 
  1. Setup the dataset and feature vectors using Grayscale Histograms
  2. Predict labels and save/display predictions for each correct/incorrect labels (4 images total).
2. Classifying an Image using Gists 
  1. Setup the dataset and feature vectors using Gists
  2. Predict labels and save/display predictions for each correct/incorrect labels (4 images total).
		
Accuracy for both will be printed in the Command Window.

A set of correctly/incorrectly classified images for both classification method (8 images total) 
will be saved in the 'results' folder under the respective sub-folder ('knn_gists' and 'knn_grayscale').

## ii. Name of entry-point script: HW4.m

## iii. Instructions to run the script
I assume I shouldn't upload the CarData zip file.

**Please extract the data zip folder and ensure the 'CarData' and 'results' folder is in the same directory as 'HW4.m'. 
You can then open 'HW4.m' and run all. This will replicate the results I have outlined in the writeup. 

If you choose to run a specific classification method, you will first need to run the subsection that sets the 
seed to 0. You can then run the paired sections together (1a and 1b or 2a and 2b). 

**If you choose to run the 2nd section pairs first and then the 1st section pairs, you may receive different results 
to what is shown in the writeup.

All results will be overwritten and saved in a sub-folder named after the classification type 
('knn_gists' and 'knn_grayscale').
