function [error, w] = nlms(N, D, input, desired, w, mu, error, epsilon)
    for i=N+D:length(input)
        x = input(i-D-N+1:i-D);
        d = desired(i);

        e = d - x'*w;
        energy = norm(x)^2;
        w = w + mu/(epsilon+energy)*x*e;
        
        error(i) = e;
    end
end