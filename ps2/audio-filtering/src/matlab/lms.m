function [error, w] = lms(N, D, input, desired, w, mu, error)

    for i=N+D:length(input)
        
        x = input(i-D-N+1:i-D);
        d = desired(i);

        e = d - x'*w;  
        w = w + mu*x*e;

        error(i) = e;
        
    end
    
end
