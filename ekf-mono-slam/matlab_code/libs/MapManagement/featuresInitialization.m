function [ filter, features_info ] = featuresInitialization( step, cam, filter,...
    features_info, num_features_to_initialize, im )

max_attempts = 50;
attempts = 0;
initialized = 0;

while ( initialized < num_features_to_initialize ) && ( attempts<max_attempts )
    
    attempts = attempts+1;
    
    [ filter, features_info, uv ] = featureInitialization( step, cam, im, filter, features_info );
    
    if size(uv,1)~=0
        initialized = initialized + 1;
    end
    
end