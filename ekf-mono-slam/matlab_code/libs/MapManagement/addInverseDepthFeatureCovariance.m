function P_RES = addInverseDepthFeatureCovariance( P, uvd, Xv, std_pxl, std_rho, cam )

fku =  cam.K(1,1);
fkv =  cam.K(2,2);
U0  =  cam.K(1,3);
V0  =  cam.K(2,3);

q_wc = Xv(4:7);
R_wc = q2r(q_wc);

uvu = undistortFeature( uvd, cam );
uu = uvu(1);
vu = uvu(2);

X_c = -(U0-uu)/fku;
Y_c = -(V0-vu)/fkv;
Z_c = 1;

XYZ_c = [X_c; Y_c; Z_c];

XYZ_w = R_wc*XYZ_c;
X_w = XYZ_w(1);
Y_w = XYZ_w(2);
Z_w = XYZ_w(3);

% Derivatives

dtheta_dgw = [ Z_w/(X_w^2+Z_w^2) 0 -X_w/(X_w^2+Z_w^2) ];
dphi_dgw = [ (X_w*Y_w)/((X_w^2+Y_w^2+Z_w^2)*sqrt(X_w^2+Z_w^2))...
        -sqrt(X_w^2+Z_w^2)/(X_w^2+Y_w^2+Z_w^2) (Z_w*Y_w)/((X_w^2+Y_w^2+Z_w^2)*sqrt(X_w^2+Z_w^2)) ];
dgw_dqwc = makeQuaternionToRotationMatrixJacobian( q_wc, XYZ_c );

dtheta_dqwr = dtheta_dgw*dgw_dqwc;
dphi_dqwr = dphi_dgw*dgw_dqwc;
dy_dqwr = sparse( [ zeros(3,4); dtheta_dqwr; dphi_dqwr; zeros(1,4) ] );
dy_drw = sparse( [ eye(3); zeros(3,3) ] );

dy_dxv = sparse( [ dy_drw dy_dqwr zeros(6,6) ] );

dyprima_dgw = sparse( [ zeros(3,3); dtheta_dgw; dphi_dgw ] );
dgw_dgc = R_wc;
dgc_dhu = sparse( [ +1/fku      0       0;
                0   +1/fkv      0]' );
dyprima_dhd = dyprima_dgw*dgw_dgc*dgc_dhu*makeUndistortFunctionJacobian( cam , uvd );

dy_dhd = sparse( [ dyprima_dhd zeros(5,1);
            zeros(1,2)      1 ] );

Ri = speye(2)*std_pxl^2;

Padd = sparse( [Ri  zeros(2,1);
    zeros(1,2)  std_rho^2] );

%
P_xv = P( 1:13, 1:13 );
P_yxv = P( 14:end, 1:13 );
P_y = P( 14:end, 14:end );
P_xvy = P( 1:13, 14:end );
P_RES = [ P_xv          P_xvy                       P_xv*dy_dxv';
          P_yxv         P_y                         P_yxv*dy_dxv';
          dy_dxv*P_xv   dy_dxv*P_xvy                dy_dxv*P_xv*dy_dxv'+...
                                                    dy_dhd*Padd*dy_dhd'];