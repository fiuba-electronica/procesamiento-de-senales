function newFeature = retroProjectFeature( uvd, Xv, camera, initial_rho )

  fku =  camera.K(1,1);
  fkv =  camera.K(2,2);
  U0  =  camera.K(1,3);
  V0  =  camera.K(2,3);
  
  uv = undistortFeature( uvd, camera );
  u = uv(1);
  v = uv(2);
  
  r_WC = Xv(1:3);
  q_WC = Xv(4:7);
  
  hicx=-(U0-u)/fku;
  hicy=-(V0-v)/fkv;
  hicz=1;
  
  h_LR=[hicx; hicy; hicz];
  
  n=q2r(q_WC)*h_LR;
  nx=n(1);
  ny=n(2);
  nz=n(3);
  
  newFeature = [ r_WC; atan2(nx,nz); atan2(-ny,sqrt(nx*nx+nz*nz)); initial_rho ];
  
return
end