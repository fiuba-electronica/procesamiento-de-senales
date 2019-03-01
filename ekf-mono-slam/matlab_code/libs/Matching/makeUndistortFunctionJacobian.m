function result=makeUndistortFunctionJacobian(camera,uvd)

Cx=camera.Cx;
Cy=camera.Cy;
k1=camera.k1;
k2=camera.k2;
dx=camera.dx;
dy=camera.dy;
  
ud=uvd(1);
vd=uvd(2);
xd=(uvd(1)-Cx)*dx;
yd=(uvd(2)-Cy)*dy;
  
rd2=xd*xd+yd*yd;
rd4=rd2*rd2;
     
uu_ud=(1+k1*rd2+k2*rd4)+(ud-Cx)*(k1+2*k2*rd2)*(2*(ud-Cx)*dx*dx);
vu_vd=(1+k1*rd2+k2*rd4)+(vd-Cy)*(k1+2*k2*rd2)*(2*(vd-Cy)*dy*dy);
    
uu_vd=(ud-Cx)*(k1+2*k2*rd2)*(2*(vd-Cy)*dy*dy);
vu_ud=(vd-Cy)*(k1+2*k2*rd2)*(2*(ud-Cx)*dx*dx);
     
result=[uu_ud uu_vd;vu_ud vu_vd];