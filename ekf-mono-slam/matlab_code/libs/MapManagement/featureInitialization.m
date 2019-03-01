function [ filter, features_info, uv ] = featureInitialization( step, cam, im_k, filter, features_info )

half_patch_size_when_initialized = 20;
half_patch_size_when_matching = 6;
excluded_band = half_patch_size_when_initialized + 1;
max_initialization_attempts = 1;
initializing_box_size = [60,40];
initializing_box_semisize = initializing_box_size/2;
initial_rho = 1;
std_rho = 1;

std_pxl = get_std_z(filter);

rand_attempt = 1;
not_empty_box = 1;
detected_new=0;

features_info = predictCameraMeasurements( get_x_k_k(filter), cam, features_info );

uv_pred = [];
for i=1:length(features_info)
    uv_pred = [uv_pred features_info(i).h'];
end

for i=1:max_initialization_attempts
    
    if ( detected_new )
        break;
    end
    
    search_region_center = rand(2,1);
    search_region_center(1) = round(search_region_center(1)*(cam.nCols-2*excluded_band-2*initializing_box_semisize(1)))...
        +excluded_band+initializing_box_semisize(1);
    search_region_center(2) = round(search_region_center(2)*(cam.nRows-2*excluded_band-2*initializing_box_semisize(2)))...
        +excluded_band+initializing_box_semisize(2);
    
    % Extract FAST corners
    cd fast-matlab-src
    cs = fast_corner_detect_9(double(im_k(search_region_center(2)-initializing_box_semisize(2):search_region_center(2)+initializing_box_semisize(2),...
        search_region_center(1)-initializing_box_semisize(1):search_region_center(1)+initializing_box_semisize(1))),... % the image,
        100);
    c = fast_nonmax(double(im_k(search_region_center(2)-initializing_box_semisize(2):search_region_center(2)+initializing_box_semisize(2),...
        search_region_center(1)-initializing_box_semisize(1):search_region_center(1)+initializing_box_semisize(1))),... % the image,
        100, cs);
    all_uv = c';
    cd ..
    
    if ~isempty(all_uv)
        all_uv = all_uv + [ (- initializing_box_semisize(1) + search_region_center(1) - 1)*ones(1,size(all_uv,2));...
            (- initializing_box_semisize(2) + search_region_center(2) - 1)*ones(1,size(all_uv,2))];
    end
    
    nPoints=size(all_uv,2);
    
    are_there_corners = not(isempty(all_uv));
    
    if ~isempty(uv_pred)
        total_features_number = size(uv_pred,2);
        features_in_the_box =...
            (uv_pred(1,:)>ones(1,total_features_number)*(search_region_center(1)-initializing_box_semisize(1)))&...
            (uv_pred(1,:)<ones(1,total_features_number)*(search_region_center(1)+initializing_box_semisize(1)))&...
            (uv_pred(2,:)>ones(1,total_features_number)*(search_region_center(2)-initializing_box_semisize(2)))&...
            (uv_pred(2,:)<ones(1,total_features_number)*(search_region_center(2)+initializing_box_semisize(2)));
        are_there_features = (sum(features_in_the_box)~=0);
    else
        are_there_features = false;
    end
    
    if(are_there_corners&&(~are_there_features))
        uv = all_uv;
        uv_integer = uv;
        uv = uv(:,1);% - [0.5,0.5]';
        detected_new = 1;
    else
        uv=[];
    end
    
    if(~isempty(uv))
        
       [ X_RES, P_RES, newFeature ] = addFeaturesToMapInInverseDepth( uv, get_x_k_k(filter),...
            get_p_k_k(filter), cam, std_pxl, initial_rho, std_rho );
        filter = set_x_k_k(filter, X_RES);
        filter = set_p_k_k(filter, P_RES);
        
        features_info = addFeatureInformation( uv, im_k, X_RES, features_info, step, newFeature );
        
    end
    
    for i=1:length(features_info)
        features_info(i).h = [];
    end
    
end