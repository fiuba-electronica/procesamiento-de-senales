function features_info = predictFeaturesAppearance( features_info, x_k_k, cam )

r_wc = x_k_k( 1:3 );
R_wc = q2r(x_k_k(4:7));

x_k_k_rest_of_features = x_k_k(14:end);

for i=1:length(features_info)
    
    if strcmp(features_info(i).type, 'XYZ')
        XYZ_w = x_k_k_rest_of_features(1:3);
        x_k_k_rest_of_features = x_k_k_rest_of_features(4:end);
    end
    if strcmp(features_info(i).type, 'INVERSE_DEPTH')
        y = x_k_k_rest_of_features(1:6);
        x_k_k_rest_of_features = x_k_k_rest_of_features(7:end);
        XYZ_w = convertToDepth( y );
    end
    
    if ~isempty(features_info(i).h)
        
        features_info(i).patch_when_matching = predictedPatchFC( cam,...
            features_info(i), R_wc, r_wc, XYZ_w );
        
    end
    
end