function [zi,position,num_IC_matches] = selectRandomMatch(features_info)

map_size = length(features_info);
individually_compatible = zeros(map_size,1);

for i=1:map_size
    if features_info(i).individually_compatible
        individually_compatible(i) = 1;
    end
end

random_match_position = floor(rand(1)*sum(individually_compatible))+1;

positions_individually_compatible = find(individually_compatible);

position = positions_individually_compatible(random_match_position);

zi = features_info(position).z;

num_IC_matches = sum(individually_compatible);
    