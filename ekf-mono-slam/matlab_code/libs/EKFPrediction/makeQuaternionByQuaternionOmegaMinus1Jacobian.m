function result=makeQuaternionByQuaternionOmegaMinus1Jacobian(qomegam1dt)

 q2.r=qomegam1dt(1); 
 q2.i=qomegam1dt(2);
 q2.j=qomegam1dt(3);
 q2.k=qomegam1dt(4);
 
 result = [q2.r, -q2.i, -q2.j, -q2.k,
           q2.i,  q2.r, -q2.k,  q2.j,
           q2.j,  q2.k,  q2.r, -q2.i,
           q2.k, -q2.j,  q2.i,  q2.r];
 return
