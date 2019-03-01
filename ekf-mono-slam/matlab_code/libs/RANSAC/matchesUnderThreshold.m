function hypothesis_support = matchesUnderThreshold( features_info )

hypothesis_support = 0;
threshold = 0.5;

for i=1:length(features_info)
    
    if ~isempty(features_info(i).z)
        nu = features_info(i).z - features_info(i).h';
        if sqrt(nu'*nu)<threshold
            hypothesis_support = hypothesis_support + 1;
        end
    end
    
end