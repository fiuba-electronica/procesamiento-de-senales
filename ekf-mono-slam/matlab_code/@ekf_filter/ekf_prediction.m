function [ f, features_info ] = ekf_prediction( f, features_info )

[ f.x_k_km1, f.p_k_km1 ] = predictStateAndCovariance( f.x_k_k, f.p_k_k, f.type, f.std_a, f.std_alpha );