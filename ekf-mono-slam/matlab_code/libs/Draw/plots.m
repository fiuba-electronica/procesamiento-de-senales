chi_095_2 = 5.9915;
% chi_099_2 = 9.2103;
chi_095_3 = 7.8147;
% chi_099_3 = 11.3449;

figure(figure_all);
subplot(im_fig);
hold off;
imagesc(im);
colormap gray;
hold on;
title('Rojo: inliers. Magenta: outliers. Azul: sin match.');

predicted_index = 0;
predicted_measurements = get_predicted_measurements(filter);
S_predicted = get_S_predicted(filter);

for i=1:length(features_info)

    if (~isempty(features_info(i).h)&&~isempty(features_info(i).S))

        imagesc( features_info(i).h(1) - features_info(i).half_patch_size_when_matching,...
            features_info(i).h(2) - features_info(i).half_patch_size_when_matching, features_info(i).patch_when_matching);

        if features_info(i).low_innovation_inlier
            plotUncertainEllip2D( features_info(i).S,...
                features_info(i).h, chi_095_2, 'r', 4 )
            plot( features_info(i).h(1), features_info(i).h(2),'r+','Markersize',10);
        end
        if features_info(i).high_innovation_inlier
            plotUncertainEllip2D( features_info(i).S,...
                features_info(i).h, chi_095_2, 'r', 2 )
            plot( features_info(i).h(1), features_info(i).h(2),'r+','Markersize',10);
        end
        if (features_info(i).individually_compatible)&&(features_info(i).high_innovation_inlier==0)&&(features_info(i).low_innovation_inlier==0)
            plotUncertainEllip2D( features_info(i).S,...
                features_info(i).h, chi_095_2, 'm', 2 )
            plot( features_info(i).h(1), features_info(i).h(2),'m+','Markersize',10);
        end
        
        if ~features_info(i).individually_compatible
            plotUncertainEllip2D( features_info(i).S,...
                features_info(i).h, chi_095_2, 'b', 2 )
            plot( features_info(i).h(1), features_info(i).h(2),'b+','Markersize',10);
        end
        
        if features_info(i).individually_compatible
            plot( features_info(i).z(1), features_info(i).z(2),'g+','Markersize',10);
        end

    end

end

% plot predicted and measured
% which_are_predicted = predicted_measurements(:,1)>0;
% plot( predicted_measurements(which_are_predicted,1), predicted_measurements(which_are_predicted,2),'r+','Markersize',10);
% which_are_measured = measurements(:,1)>0;
% plot( measurements(which_are_measured,1), measurements(which_are_measured,2),'g+');

axes_handler = get(gcf,'CurrentAxes');
set(axes_handler,'XTick',[],'YTick',[]);

% plot 3D stuff
figure(figure_all);
subplot(near3D_fig);
hold off;

x_k_k = get_x_k_k(filter);
p_k_k = get_p_k_k(filter);

drawCamera( [x_k_k(1:3); x_k_k(4:7)], 'k' );
hold on;

trajectory(:,step - initIm) = x_k_k(1:7);
plot3( trajectory(1, 1:step - initIm), trajectory(2, 1:step - initIm),...
    trajectory(3, 1:step - initIm), 'k', 'LineWidth', 2 );
xlabel('X Position [m]')
ylabel('Y Position [m]')
zlabel('Z Position [m]')

x_k_k_features_plots = x_k_k(14:end);
p_k_k_features_plots = p_k_k(14:end,14:end);

for i=1:length(features_info)

    if strcmp(features_info(i).type, 'XYZ')
        XYZ = x_k_k_features_plots(1:3);
        p_XYZ = p_k_k_features_plots(1:3,1:3);
        x_k_k_features_plots = x_k_k_features_plots(4:end);
        p_k_k_features_plots = p_k_k_features_plots(4:end,4:end);
        plotUncertainEllip3D(  p_XYZ, XYZ, chi_095_3, 'r', 1  );
        plot3(XYZ(1),XYZ(2),XYZ(3),'r+','Markersize',10)
    end
    if strcmp(features_info(i).type, 'INVERSE_DEPTH')
        y_id = x_k_k_features_plots(1:6);
        XYZ = convertToDepth( y_id );
        p_id = p_k_k_features_plots(1:6,1:6);
        x_k_k_features_plots = x_k_k_features_plots(7:end);
        p_k_k_features_plots = p_k_k_features_plots(7:end,7:end);
        if y_id(6)-3*sqrt(p_id(6,6))<0
            if ( y_id(6)>0)
                ray = 8*makeDirectionalVector(y_id(4),y_id(5));
                minimum_distance = convertToDepth([y_id(1:5); y_id(6)+3*sqrt(p_id(6,6))]);
                vectarrow([minimum_distance(1) 0 minimum_distance(3)],[ray(1) 0 ray(3)],'r')
                plot3(XYZ(1),XYZ(2),XYZ(3),'r+','Markersize',10)
            end
        else
            if ( y_id(6)>0)
                plotUncertainSurfaceXZ( p_id, y_id, 0, [1 0 0], randSphere6D, nPointsRand );
                plot3(XYZ(1),XYZ(2),XYZ(3),'r+','Markersize',10)
            end
        end

    end

end

axes_handler = get(gcf,'CurrentAxes');
% axis([-4 4 -1 1 -1 7]);
grid on;
view(-360,0);
% view(3);

% plot 2D Trajectory
figure(2);
subplot(1,3,1)
hold off;
x_k_k = get_x_k_k(filter);
p_k_k = get_p_k_k(filter);


trajectory(:,step - initIm) = x_k_k(1:7);
plot( trajectory(1, 1:step - initIm), trajectory(2, 1:step - initIm), 'r', 'LineWidth', 2 );
grid on
title('XY Plane.');
xlabel('X Position [m]')
ylabel('Y Position [m]')

subplot(1,3,2)
hold off;
x_k_k = get_x_k_k(filter);
p_k_k = get_p_k_k(filter);


trajectory(:,step - initIm) = x_k_k(1:7);
plot( trajectory(1, 1:step - initIm), trajectory(3, 1:step - initIm), 'g', 'LineWidth', 2 );
grid on
title('XZ Plane.');
xlabel('X Position [m]')
ylabel('Z Position [m]')

subplot(1,3,3)
hold off;
x_k_k = get_x_k_k(filter);
p_k_k = get_p_k_k(filter);


trajectory(:,step - initIm) = x_k_k(1:7);
plot( trajectory(2, 1:step - initIm), trajectory(3, 1:step - initIm), 'b', 'LineWidth', 2 );
grid on
title('YZ Plane.');
xlabel('Y Position [m]')
ylabel('Z Position [m]')