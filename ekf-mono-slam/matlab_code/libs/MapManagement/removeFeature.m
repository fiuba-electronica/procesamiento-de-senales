function [X_km1_km1_new,P_km1_km1_new] = removeFeature( X_km1_km1,P_km1_km1,featToDelete,features_info )


if strcmp(features_info(featToDelete).type,'XYZ')
    parToDelete = 3;
else
    parToDelete = 6;
end

index_to_remove_from = 14;

for i=1:featToDelete-1
    if strcmp(features_info(i).type, 'INVERSE_DEPTH')
        index_to_remove_from = index_to_remove_from + 6;
    end
    if strcmp(features_info(i).type, 'XYZ')
        index_to_remove_from = index_to_remove_from + 3;
    end
end

X_km1_km1_new = [X_km1_km1(1:index_to_remove_from-1); X_km1_km1(index_to_remove_from+parToDelete:end)];
    

P_km1_km1_new = [P_km1_km1(:,1:index_to_remove_from-1) P_km1_km1(:,index_to_remove_from+parToDelete:end)];
P_km1_km1_new = [P_km1_km1_new(1:index_to_remove_from-1,:); P_km1_km1_new(index_to_remove_from+parToDelete:end,:)];