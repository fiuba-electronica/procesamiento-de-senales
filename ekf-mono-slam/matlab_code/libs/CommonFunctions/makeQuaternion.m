function q=makeQuaternion(v,theta)
    q=[cos(theta/2)  sin(theta/2)*reshape(v,1,3)/norm(v)];
end
