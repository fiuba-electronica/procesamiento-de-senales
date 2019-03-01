function [x_k_k, p_k_k] = stateAndCovarianceInitialization()

% Initial velocity values
v_0 = 0;
std_v_0 = 0.025;
w_0 = 1e-15;
std_w_0 = 0.025; 

% Initial state vector and covariance matrix
x_k_k = [0 0 0 1 0 0 0 v_0 v_0 v_0 w_0 w_0 w_0]';
p_k_k = zeros(13,13);
p_k_k(1,1)=eps;
p_k_k(2,2)=eps;
p_k_k(3,3)=eps;
p_k_k(4,4)=eps;
p_k_k(5,5)=eps;
p_k_k(6,6)=eps;
p_k_k(7,7)=eps;
p_k_k(8,8)=std_v_0^2;
p_k_k(9,9)=std_v_0^2;
p_k_k(10,10)=std_v_0^2;
p_k_k(11,11)=std_w_0^2;
p_k_k(12,12)=std_w_0^2;
p_k_k(13,13)=std_w_0^2;
end
