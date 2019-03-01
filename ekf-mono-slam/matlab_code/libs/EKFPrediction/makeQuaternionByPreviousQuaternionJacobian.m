function result=makeQuaternionByPreviousQuaternionJacobian(qtm1)

q1.r=qtm1(1);
q1.i=qtm1(2);
q1.j=qtm1(3);
q1.k=qtm1(4);

result = [q1.r, -q1.i, -q1.j, -q1.k,
          q1.i,  q1.r,  q1.k, -q1.j,
          q1.j, -q1.k,  q1.r,  q1.i,
          q1.k,  q1.j, -q1.i,  q1.r];

return
