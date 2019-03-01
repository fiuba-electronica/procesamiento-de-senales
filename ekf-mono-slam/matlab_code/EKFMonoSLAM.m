clear variables; close all; clc;
rand('state',0)

cam = cameraInitialization;
setPlots;

[x_k_k, p_k_k] = stateAndCovarianceInitialization;

sigma_linear_accel = 0.007; 
sigma_angular_accel = 0.007; 
sigma_image_noise = 1.0;
filter = ekf_filter(x_k_k, p_k_k, sigma_linear_accel, sigma_angular_accel, sigma_image_noise, 'constant_velocity');

% d=dir('../sequences/ic/*.png');
% d=dir('../sequences/s3/*.png');
d=dir('../sequences/rawseeds/indoor/FRONTAL/*.png');

initIm = 1;
lastIm = 2169;

features_info = [];
trajectory = zeros(7, lastIm - initIm);

min_number_of_features_in_image = 100;
generate_random_6D_sphere;

im=imread(strcat(d(initIm).folder,'/',d(initIm).name));

for step=initIm+1:lastIm    
    [ filter, features_info ] = mapManagement(filter, features_info, cam, im, min_number_of_features_in_image, step);
    [ filter, features_info ] = ekf_prediction(filter, features_info);    
    im=imread(strcat(d(step).folder,'/',d(step).name));
    features_info = searchICMatches(filter, features_info, cam, im);    
    features_info = ransac(filter, features_info, cam);    
    filter = ekf_update_li_inliers(filter, features_info);    
    features_info = rescue_hi_inliers( filter, features_info, cam);    
    filter = ekf_update_hi_inliers(filter, features_info);
    plots; display(step);
    saveas(figure_all, sprintf('%s/image%06d.fig', directory_storage_name, step), 'fig');
end

% fig2avi;