__author__ = "Alvaro Joaquin Gaona"
__email__ = "alvgaona@gmail.com"

This SLAM problem is a very basic one. Where you have 7 points and 4 of them you know the exact location (absolute position with some error) and the rest you only can measure the distance the the vehicle with also some error. The error noise error is asummed to be gaussian noise.

Then using a EKF you can estimate the position at all times and the absolute postion of the 3 points you don't know the exact location.

----------------------------------------------------------------------------------------------------------------------------------------------

There are two files trying to estimate this, using two different Space State Models.

+ slam.m -> State vector consist of [px py vx vy z1x z1y z2x z2y z3x z3y] 
+ slam2.m ->  State vector consist of [px py vx vy ax ay z1x z1y z2x z2y z3x z3y] -> In this *.m you will find some modeling errors regarding the acceleration.

