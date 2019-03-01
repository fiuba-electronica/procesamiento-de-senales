function q=transformAnglesToQuaternion(v)
% angle2quaternion(R) converts rotation vector to quaternion.
%
%     The resultant quaternion(s) 
%          v_n=v/norm(v);
%          theta=norm(v);
%

theta=norm(v);
if (theta <eps)
    q=[1 0 0 0];
else
    v_n=v/norm(v);
    q=makeQuaternion(v_n,theta);
end
end