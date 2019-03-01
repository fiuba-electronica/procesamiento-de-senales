function result=makeQuaternionToRotationMatrixJacobian(q,di)

  result=zeros(3,4);
  
  TempR = dR_dqr(q);
  Temp31 = TempR * di;
  result(1:3,1)=Temp31;

  TempR = dR_dqi(q);
  Temp31 = TempR * di;
  result(1:3,2)=Temp31;

  TempR = dR_dqj(q);
  Temp31 = TempR * di;
  result(1:3,3)=Temp31;

  TempR = dR_dqk(q);
  Temp31 = TempR * di;
  result(1:3,4)=Temp31;
  
 return

 
function result=dR_dqr(q)
  qr = q(1);
  qi = q(2);
  qj = q(3);
  qk = q(4);

  result=[2*qr, -2*qk,  2*qj;
		        2*qk,  2*qr, -2*qi;
		       -2*qj,  2*qi,  2*qr];
 
  return;


function result=dR_dqi(q)

  qr = q(1);
  qi = q(2);
  qj = q(3);
  qk = q(4);

  
  result=[2*qi, 2*qj,   2*qk;
		        2*qj, -2*qi, -2*qr;
		        2*qk, 2*qr,  -2*qi];
 
return



function result=dR_dqj(q)
    
  qr = q(1);
  qi = q(2);
  qj = q(3);
  qk = q(4);


  result=[-2*qj, 2*qi,  2*qr;
		         2*qi, 2*qj,  2*qk;
		        -2*qr, 2*qk, -2*qj];
 
return

function result=dR_dqk(q)
  qr = q(1);
  qi = q(2);
  qj = q(3);
  qk = q(4);


  result=[-2*qk, -2*qr, 2*qi;
		         2*qr, -2*qk, 2*qj;
		         2*qi,  2*qj, 2*qk];
 
  return
