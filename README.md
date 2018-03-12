# Basketball-Tracker-and-Game-Analyzer

- Performs ball tracking on basketball footages utilizing mean shift tracking

- The "Expansion Algorithm" is created soley for this project, it solves the problem of the tracker losing the ball when it temporarily dissapears in the footage. The Expansion Algorithm is a far more easier concept to understand and to implement in this project than the likes of Kalman Filters.

- The concept details of mean shift tracking and the Expansion Algorithm are thoroughly documented in the PDF file.

### Instructions

**1.** Open the file **main.m**.

**2.** The test videos in the **videos** folder has three shoot around videos that has great tracking results. New videos can be added to the folder, just be sure to change the **str = 'miss_01_a'** in line 4 of **main.m** to the name of the new video.

**3.** Run **main.m**.

**4.** Crop the basketball on the first frame of the video.

**5.** Crop the rim on the first frame of the video. 

**6.** Wait patiently as it processes.
