function Hi = makeFeatureDepthJacobianHi( Xv_km1_k, yi, camera, i, features_info )

zi = features_info(i).h;

number_of_features = size( features_info, 2 );
inverse_depth_features_index = zeros( number_of_features, 1 );
xyz_features_index = zeros( number_of_features, 1 );

for j=1:number_of_features
    if strncmp(features_info(j).type, 'INVERSE_DEPTH', 1)
        inverse_depth_features_index(j) = 1;
    end
    if strncmp(features_info(j).type, 'XYZ', 1)
        xyz_features_index(j) = 1;
    end
end

Hi = zeros(2, 13+3*sum(xyz_features_index)+6*sum(inverse_depth_features_index));

Hi(:,1:13) = dh_dxv( camera, Xv_km1_k, yi, zi );

index_of_insertion = 13 + 3*sum(xyz_features_index(1:i-1)) + 6*sum(inverse_depth_features_index(1:i-1))+1;
Hi(:,index_of_insertion:index_of_insertion+2) = dh_dy( camera, Xv_km1_k, yi, zi );

return



function result = dh_dy( camera, Xv_km1_k, yi, zi )

    result = dh_dhci( camera, Xv_km1_k, yi, zi ) * dhci_dy( Xv_km1_k );
    
return



function result = dhci_dy( Xv_km1_k )

    result = inv( q2r( Xv_km1_k( 4:7 ) ) );
    
return



function result = dh_dxv( camera, Xv_km1_k, yi, zi )

    result = [ dh_drwc( camera, Xv_km1_k, yi, zi )  dh_dqwc( camera, Xv_km1_k, yi, zi ) zeros( 2, 6 )];

return



function result = dh_dqwc( camera, Xv_km1_k, yi, zi )

    result = dh_dhci( camera, Xv_km1_k, yi, zi ) * dhci_dqwc( Xv_km1_k, yi );
    
return



function result = dhci_dqwc( Xv_km1_k, yi )

    result = makeQuaternionToRotationMatrixJacobian( conjugateQuaternion(Xv_km1_k( 4:7 )), (yi - Xv_km1_k( 1:3 )) )*makeQuaternionDiagMatrix;
    
return



function result = dh_drwc( camera, Xv_km1_k, yi, zi )

    result = dh_dhci( camera, Xv_km1_k, yi, zi ) * dhci_drwc( Xv_km1_k );

return



function result = dhci_drwc( Xv_km1_k )

    result = -( inv( q2r( Xv_km1_k(4:7) ) ) );

return



function result = dh_dhci( camera, Xv_km1_k, yi, zi )

    result = dhd_dhu( camera, zi ) * dhu_dhci( camera, Xv_km1_k, yi );

return



function result = dhd_dhu( camera, zi_d )

    result = inv(makeUndistortFunctionJacobian( camera, zi_d ));
    
return
  
    
function result = dhu_dhci( camera, Xv_km1_k, yi )
    
    f = camera.f;
    ku = 1/camera.dx;
    kv = 1/camera.dy;
    rWC = Xv_km1_k( 1:3 );
    RCW = inv(q2r( Xv_km1_k( 4:7 ) ));
    hci = RCW*( yi - rWC );
    hcix = hci(1);
    hciy = hci(2);
    hciz = hci(3);
    result = [f*ku/(hciz)       0           -hcix*f*ku/(hciz^2);
        0               f*kv/(hciz)    -hciy*f*kv/(hciz^2)];
    
return