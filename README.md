# Mouseforce Repository
This repository contains code for modifying extrinsic calibration parameters and analyzing mouse keypoints. The mouse keypoints can be either hand clicked labels, or detected using APT.

## Updating Extrinsic Camera Calibration Parameters
The [calibrate_jumping_arena](https://github.com/iskwak/calibrate_jumping_arena) repository contains code for calibrating Jason's hind leg extension rig using Opencv's camera calibration tools. Unfortunately, the extrinsic parameters computed by the calibrate_jumping_arena repository has produced poor reprojection errors on keypoints labeled by humans on the mouse. This repository has tools for improving the estimated extrinsinc parameters using bundle adjustment. This section will describe how to improve the calibration.

Normally, the hind leg extension project has 12 keypoints on the mouse to label, described [here](https://docs.google.com/document/d/1TboLJyQ6C4moLsUtfWShGujO1C6Q62Wa1x0dXuzfnm8/edit). To improve the calibration, we will only labelling 7 of the 12 keypoints. Although only 7 of the 12 keypoints are being labeled, I have been labeling the full 12 keypoints. I chose to do this because we can always use more labels for the tracker. 

### Prerequisite Data
1) CalRigNPairwiseCalibrated object created by the calibrate_jumping_arena code base.
* This will be the initial starting point for the bundle adjustment.
2) Sampled checkerboards used by the calibrate_jumping_arena code base for stereo calibration. This is an output from the code base.
* The sampled checkerboard points are used to help make sure the dimensions of the calibrated rig stays consistent with reality.

### Example Calibration Folder


## Calibration Steps
1) Find or create an APT project with the movie day for calibration. Find and label 20 frames.

Keypoints to label:
* 1: base of the tail
* 2: nose
* 3: mouth
* 4: right paw
* 5: right leg toe
* 8: left paw
* 9: left leg toe

2) Export the labels as a table. APT has an option (File->Import/Export->Advanced->Export Labels as Table).
This will create a mat file with a table of APT data.

3) Create/modify a script to update the extrinsic parameters.

4) Run the extrinsic parameters. This process will take SOME amount of time.

5) Evaluate the calibration. 