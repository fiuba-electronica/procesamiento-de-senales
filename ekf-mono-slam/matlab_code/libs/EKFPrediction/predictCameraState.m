function X_k_km1=predictCameraState(X_k_k,delta_t, type, std_a, std_alpha)

rWC =X_k_k(1:3,1);
qWC=X_k_k(4:7,1);
vW =X_k_k(8:10,1);
wW =X_k_k(11:13,1);

if strcmp(type,'constant_velocity')
    X_k_km1=[rWC+vW*delta_t;
        reshape(multiplyQuaternions(qWC,transformAnglesToQuaternion(wW*delta_t)),4,1);
        vW;
        wW];
end