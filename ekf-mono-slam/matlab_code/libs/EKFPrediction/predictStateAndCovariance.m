function [ X_km1_k, P_km1_k ] = predictStateAndCovariance( X_k, P_k, type, SD_A_component_filter, SD_alpha_component_filter )


delta_t = 1;

Xv_km1_k = predictCameraState( X_k(1:13,:), delta_t, type, SD_A_component_filter, SD_alpha_component_filter  );

X_km1_k = [ Xv_km1_k; X_k( 14:end,: ) ];

F = sparse( makeCameraJacobian( X_k(1:13,:),zeros(6,1),delta_t, type ) );

linear_acceleration_noise_covariance = (SD_A_component_filter*delta_t)^2;
angular_acceleration_noise_covariance = (SD_alpha_component_filter*delta_t)^2;
Pn = sparse (diag( [linear_acceleration_noise_covariance linear_acceleration_noise_covariance linear_acceleration_noise_covariance...
        angular_acceleration_noise_covariance angular_acceleration_noise_covariance angular_acceleration_noise_covariance] ) );

Q = makeProcessNoiseMatrix( X_k(1:13,:), zeros(6,1), Pn, delta_t, type);

size_P_k = size(P_k,1);

P_km1_k = [ F*P_k(1:13,1:13)*F' + Q         F*P_k(1:13,14:size_P_k);
            P_k(14:size_P_k,1:13)*F'        P_k(14:size_P_k,14:size_P_k)];