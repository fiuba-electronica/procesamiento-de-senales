function features_info = searchICMatches( filter, features_info, cam, im)

features_info = predictCameraMeasurements( get_x_k_km1(filter), cam, features_info );
features_info = makeFeaturesJacobians( get_x_k_km1(filter), cam, features_info );
for i=1:length(features_info)
    if ~isempty(features_info(i).h)
        features_info(i).S = features_info(i).H*get_p_k_km1(filter)*features_info(i).H' + features_info(i).R;
    end
end

features_info = predictFeaturesAppearance( features_info, get_x_k_km1(filter), cam );
features_info = matching( im, features_info, cam );