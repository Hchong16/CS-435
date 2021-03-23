### CS435-Final-Project
(CS 435) Computational Photography Final Project - Morphology

## Author: Harry Chong (hjc39) and Willow Livengood (wgl28)
Date: 3/13/2021

## i. Features of the program
The program is broken up into 6 sections: 
1. Dataset
  + Pull the correct images from a specific data directory and setup the output folder.
  + All files will be pulled from a folder in the 'data' directory. 
    + **The selected folder is specified on line 8 in the 'main.m' file.
	  + **This subfolder must contain the following files: 
	    + 'img1.jpg'
		+ 'img2.jpg'
		+ 'correspondences.csv'.
	  + Image related outputs from the program will appear in the 'results' directory under a folder named 
	  after the folder in the 'data' directory. The rest will be under a specified folder name in the 'results'
	  directory.
		
2. Scan-fill a Triangle 
  + Scan-fill a specified triangle with vertices (20,30),(100,50), and (50,80). 
  + Save and display a figure of all points at each location within the triangle.
  + Plot will be saved in the 'results' directory under '1.scanned_filled_triangle'.
		
3. Finding a Transformation
  + Determine a transformation matrix that does the following transformation in order:
    + Rotates by 20 degrees
	+ Translates by tx = 10 and ty = 20
	+ Scales uniformly by a factor of 2
  + Apply transformation matrix to the vertices specified in part 2.
  + Determine the transformation matrix to take the new vertices back to the original locations.
  + Apply the transformed vertices back to the original locations
		
  + This section will output the two matrices (Transformation and Learned Matrix) in the Command Window.
  + Save and display three plots: Original Vertices, Transformed Vertices, and Recovered Vertices in the
  'results' directory under '2.finding_a_transformation'.
		
4. Cross Dissolve
  + Create a video demonstrating cross-dissolve based on the initial two images defined in Section 1.
  + Display two images when alpha is 0.3 and 0.7.
  + All results will be saved under the 'results' directory within the folder named after the one
  selected in the 'data' directory under '3.cross_dissolve'.
	
5. Visualize Point and Triangle Correspondences
  + Generate triangles from the 'correspondences.csv' file defined in Section 1.
  + Utilized Delaunay Triangle implementation to generate triangles peratining to the FIRST image's points.
  + Display two images with the points and the triangles superimposed.
  + All results will be saved under the 'results' directory within the folder named after the one
  selected in the 'data' directory under '4.visualize_correspondences'.
	
6. Morphing
  + Create a video demonstrating morphing based on the initial two images defined in Section 1.
  + Display two images when alpha is 0.3 and 0.7.
  + All results will be saved under the 'results' directory within the folder named after the one
  selected in the 'data' directory under '5.morphing'.

## ii. Name of entry-point script: main.m

## iii. Instructions to run the script
** A folder containing the following files with the exact names should be dropped into the 'data' folder:
+ 'img1.jpg'
+ 'img2.jpg'
+ 'correspondences.csv'.

**You must alter the 'data_dir' variable located on line 8 in the 'main.m' file to test for a specific image pair.

Once all the steps above are completed, you can proceed to 'run all' in the 'main.m' file.

Image related results will be overwritten and saved in a sub-folder named after the folder dropped in the 'data' 
directory located under the 'results' directory.. The rest of the results will be saved under a specific file name 
in the 'results' directory. Please refer to i. for all the specific output folders.

**As a side note, we have taken the example images in the assignment PDF and all those results will be located in 
'Assignment_Example'. The actual test cases shown in the project writeup are located under 'Set1' and 'Set2'.
