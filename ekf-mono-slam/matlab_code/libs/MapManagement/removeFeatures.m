function [filter, features_info ] = removeFeatures( filter, features_info )

feature_to_remove_indexes = [];
for i = 1:length(features_info)
    if ( features_info(i).times_measured < 0.5*features_info(i).times_predicted ) &&...
            ( features_info(i).times_predicted > 5 )
        feature_to_remove_indexes = [feature_to_remove_indexes; i];
    end
end

if size(feature_to_remove_indexes,1)~=0

    for i=size(feature_to_remove_indexes,1):-1:1
            [ x_k_k, p_k_k ] = removeFeature( get_x_k_k(filter),...
                get_p_k_k(filter), feature_to_remove_indexes(i), features_info );
            filter = set_x_k_k(filter,x_k_k);
            filter = set_p_k_k(filter,p_k_k);

        if feature_to_remove_indexes(i)==1
            features_info = features_info(2:end);
        end

        if feature_to_remove_indexes(i)==size(features_info,2)
            features_info = features_info(1:end-1);
        end

        if (feature_to_remove_indexes(i)~=size(features_info,2))&&(feature_to_remove_indexes(i)~=1)
            features_info = [features_info(1:feature_to_remove_indexes(i)-1) features_info(feature_to_remove_indexes(i)+1:end)];
        end
    end

end