function result=makeNormalizedQuaternionJacobian(q)

     qr=q(1);
     qi=q(2);
     qj=q(3);
     qk=q(4);

     result=(qr*qr+qi*qi+qj*qj+qk*qk)^(-3/2) * [qi*qi+qj*qj+qk*qk        -qr*qi         -qr*qj          -qr*qk;
                                                -qi*qr              qr*qr+qj*qj+qk*qk   -qi*qj          -qi*qj;
                                                -qj*qr                   -qj*qi      qr*qr+qi*qi+qk*qk  -qj*qk;
                                                -qk*qr                  -qk*qi         -qk*qj          qr*qr+qi*qi+qj*qj];

 return

