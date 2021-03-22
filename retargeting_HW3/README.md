## Author: Harry Chong
Date: 2/16/2021

### i. Features of the program
The program will setup the image inputs based on the variable name on line 6-7 and will perform the 
following in order:
+ Resize the input image using Nearest Neighbor Sampling and Linear Interpolation. The program will 
require the user to input a width and height.
  + This section will run twice in order to generate 4 images:
    + 2 image resized using Nearest Neighbor Sampling.
    + 2 image resized using Linear Interpolation.
+ Calculate and show the Energy Function on the image.
+ Calculate and show the Optimal Seam on the image.
+ Create video to demonstrate Seam Carving.

All videos and images will be displayed and saved in the 'results' folder under the respective sub-folder 
named after the image.  

### ii. Name of entry-point script: HW3.m

### iii. Instructions to run the script
Ensure the 'images' and 'results' folder is in the same directory as 'HW3.m'. You can then open 'HW3.m' 
and run all. All results will be overwritten and saved in a sub-folder named after the image in the 
'results' folder. 

The way the script is programmed, it will perform all the operations on one image. This image is defined 
on line 6 and 7. Uncomment/comment the respective lines to test against my test images. 

If you wish to test on a new image, put that image in the 'images' folder and change the variable name
on line 6 and 7 to the name of the image.

**NOTE 1: Before resizing the image, the program will ask the user to input a width and height value. 
This prompt will appear again after the first two sets of images finishes resizing. 

For the width and height, the best result will be generated if the user give the appropriate ratio size 
based on the original image size. You can find the appropriate ratios below for my test images (width x
height) below:
Image 1: background1.jpg
	- Original Ratio: 960 x 540
	- 75% = 720 x 405
	- 50% = 480 x 270
	- 25% = 240 x 135
	
Image 2: background2.jpg
	- Original Ratio: 1024 x 640
	- 75% = 768 x 480
	- 50% = 512 x 320
	- 25% = 256 x 160
	
**NOTE 2: Depending on the width/height of the image, the video generation may take a while. I have printed 
out the debug statements to indicate the progression. For reference, a video generated on a 960 x 540 image 
will take around 2 minutes.