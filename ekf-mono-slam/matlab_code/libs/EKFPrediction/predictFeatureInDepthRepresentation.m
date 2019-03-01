function zi = predictFeatureInDepthRepresentation( yi, t_wc, r_wc, cam, features_info )

r_cw = inv( r_wc );
hci = r_cw*( yi - t_wc );

% Is in front of the camera?
if ((atan2( hci( 1, : ), hci( 3, : ) )*180/pi < -60) ||...
    (atan2( hci( 1, : ), hci( 3, : ) )*180/pi > 60) ||...
    (atan2( hci( 2, : ), hci( 3, : ) )*180/pi < -60) ||...
    (atan2( hci( 2, : ), hci( 3, : ) )*180/pi > 60))
    zi = [];
    return;
end

uv_u = projectToFrame( hci, cam );
uv_d = distortFeature( uv_u , cam );

% Is visible in the image?
if ( uv_d(1)>0 ) && ( uv_d(1)<cam.nCols ) && ( uv_d(2)>0 ) && ( uv_d(2)<cam.nRows )
    zi = uv_d;
    return;
else
    zi = [];
    return;
end