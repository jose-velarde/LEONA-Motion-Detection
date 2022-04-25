function plot_fov(patch_fov, origin, azimuth, radius, color)
circle = @(origin, azimuth, radius)  [origin(1) + radius*cosd(-azimuth+90); origin(2) + radius*sind(-azimuth+90)];         % Circle Function For Angles In Radians
    fov_left = azimuth+15;
    fov_right = azimuth-15;
    fov = fov_right:1:fov_left;
    
    arc = circle(origin, fov, radius);                                    % Matrix (2xN) Of (x,y) Coordinates
%     plot(arc(1,:), arc(2,:),'r', 'LineWidth', 1.5);
    right_fov = circle(origin, fov_right, radius);
    left_fov = circle(origin, fov_left, radius);
%     plot([origin(1), right_fov(1)],[origin(2), right_fov(2)], 'r', 'LineWidth', 1.5)  
%     plot([origin(1), left_fov(1)],[origin(2), left_fov(2)], 'r', 'LineWidth', 1.5)  

    poly_x =[[origin(1), right_fov(1)] arc(1,:) [origin(1), left_fov(1)]];
    poly_y =[[origin(2), right_fov(2)] arc(2,:) [origin(2), left_fov(2)]];
    
    set(patch_fov, 'XData', poly_x, 'YData', poly_y, 'visible', 'on', 'FaceColor', color);
