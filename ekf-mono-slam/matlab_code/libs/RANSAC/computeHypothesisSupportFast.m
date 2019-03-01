function [hypothesis_support, positions_li_inliers_id, positions_li_inliers_euc] = computeHypothesisSupportFast( xi, cam, state_vector_pattern, z_id, z_euc, threshold )

hypothesis_support = 0;

if ~isempty(z_id)
    
    n_id = size(z_id,2);
    
    ri = xi(logical(state_vector_pattern(:,1)));
    anglesi = xi(logical(state_vector_pattern(:,2)));
    rhoi = xi(logical(state_vector_pattern(:,3)));
    
    ri = reshape(ri,3,n_id);
    anglesi = reshape(anglesi,2,n_id);
    mi = makeDirectionalVector(anglesi);
    
    rwc = xi(1:3);
    rwc = repmat(rwc,1,n_id);
    
    rotwc = q2r(xi(4:7));
    rotcw = rotwc';
    
    ri_minus_rwc = ri - rwc;
    xi_minus_xwc_by_rhoi = ri_minus_rwc(1,:)*diag(rhoi);
    yi_minus_xwc_by_rhoi = ri_minus_rwc(2,:)*diag(rhoi);
    zi_minus_xwc_by_rhoi = ri_minus_rwc(3,:)*diag(rhoi);
    ri_minus_rwc_by_rhoi = [xi_minus_xwc_by_rhoi; yi_minus_xwc_by_rhoi; zi_minus_xwc_by_rhoi];
    
    hc = rotcw*(ri_minus_rwc_by_rhoi + mi);
    
    h_norm = [hc(1,:)./hc(3,:);hc(2,:)./hc(3,:)];
    
    u0 = cam.Cx;
    v0 = cam.Cy;
    f  = cam.f;
    ku = 1/cam.dx;
    kv = 1/cam.dy;
    h_image = f*ku*h_norm + [u0*ones(1,n_id);v0*ones(1,n_id)];
    
    h_distorted = distortFeature( h_image , cam );
    
    nu = z_id - h_distorted;
    residuals = sqrt(nu(1,:).^2+nu(2,:).^2);
    positions_li_inliers_id = residuals<threshold;
    hypothesis_support = hypothesis_support + sum(positions_li_inliers_id);
    
else
    
    positions_li_inliers_id = [];
    
end

if ~isempty(z_euc)
    
    n_euc = size(z_euc,2);
    
    xyz = xi(logical(state_vector_pattern(:,4)));
    xyz = reshape(xyz,3,n_euc);
    
    rwc = xi(1:3);
    rwc = repmat(rwc,1,n_euc);
    
    rotwc = q2r(xi(4:7));
    rotcw = rotwc';
    
    xyz_minus_rwc = xyz - rwc;
    
    hc = rotcw*xyz_minus_rwc;
    
    h_norm = [hc(1,:)./hc(3,:);hc(2,:)./hc(3,:)];
    
    u0 = cam.Cx;
    v0 = cam.Cy;
    f  = cam.f;
    ku = 1/cam.dx;
    kv = 1/cam.dy;
    h_image = f*ku*h_norm + [u0*ones(1,n_euc);v0*ones(1,n_euc)];
    
    h_distorted = distortFeature( h_image , cam );
    
    nu = z_euc - h_distorted;
    residuals = sqrt(nu(1,:).^2+nu(2,:).^2);
    positions_li_inliers_euc = residuals<threshold;
    hypothesis_support = hypothesis_support + sum(positions_li_inliers_euc);
    
else
    
    positions_li_inliers_euc = [];
    
end