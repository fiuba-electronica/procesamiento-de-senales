function filter = ekf_update_li_inliers( filter, features_info )

z = [];
h = [];
H = [];

for i=1:length( features_info )
    
    if features_info(i).low_innovation_inlier == 1
        z = [z; features_info(i).z(1); features_info(i).z(2)];
        h = [h; features_info(i).h(1); features_info(i).h(2)];
        H = [H; features_info(i).H];
    end
    
end

R = eye(length(z));

[ filter.x_k_k, filter.p_k_k ] = updateFilter( filter.x_k_km1, filter.p_k_km1, H,...
    R, z, h );