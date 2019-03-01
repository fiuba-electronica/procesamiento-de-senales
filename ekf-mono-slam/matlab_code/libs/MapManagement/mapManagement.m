function [ filter, features_info ] = mapManagement( filter,...
    features_info, cam, im,  min_number_of_features_in_image, step )

[ filter, features_info ] = removeFeatures( filter, features_info );

measured = 0;
for i=1:length(features_info)
    if (features_info(i).low_innovation_inlier || features_info(i).high_innovation_inlier)
        measured = measured + 1;
    end
end

features_info = updateMapFeatures( features_info );

[ filter, features_info ] = convertMapFeaturesInverseDepthToDepth( filter, features_info );

if measured == 0
    [ filter, features_info ] = featuresInitialization( step, cam,...
        filter, features_info, min_number_of_features_in_image, im );
else
    if measured < min_number_of_features_in_image
        [ filter, features_info ] = featuresInitialization( step, cam,...
            filter, features_info, min_number_of_features_in_image - measured, im );
    end
end

end