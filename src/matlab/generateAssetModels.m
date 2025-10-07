function generateAssetModels()
% generateAssetModels - Create 3D models for all micro-features
% Run this function in MATLAB to generate the missing 3D model files

fprintf('=== Generating 3D Asset Models ===\n');

% Create models directory if it doesn't exist
modelsDir = fullfile('src', 'assets', 'models');
if ~exist(modelsDir, 'dir')
    mkdir(modelsDir);
end

%% 1. Pothole Depression Model
fprintf('Creating pothole depression model...\n');
[X, Y] = meshgrid(-0.6:0.1:0.6, -0.4:0.1:0.4);
Z = -0.15 * exp(-(X.^2/0.36 + Y.^2/0.16)) + 0.02*randn(size(X)); % Depression with noise
pothole_model.vertices = [X(:), Y(:), Z(:)];
pothole_model.faces = delaunay(X(:), Y(:));
pothole_model.metadata = struct('type', 'surface_depression', 'created', datestr(now));
save(fullfile(modelsDir, 'pothole_depression.mat'), 'pothole_model');

%% 2. Enhanced Barricade Cuboid
fprintf('Creating barricade cuboid model...\n');
% Create a more detailed barricade with reflective strips
x = [-0.75, 0.75, 0.75, -0.75, -0.75, 0.75, 0.75, -0.75];
y = [-0.2, -0.2, 0.2, 0.2, -0.2, -0.2, 0.2, 0.2];
z = [0, 0, 0, 0, 1.2, 1.2, 1.2, 1.2];
faces = [1,2,6,5; 2,3,7,6; 3,4,8,7; 4,1,5,8; 1,2,3,4; 5,6,7,8]; % Cuboid faces
barricade_model.vertices = [x', y', z'];
barricade_model.faces = faces;
barricade_model.colors = [1.0, 0.5, 0.0]; % Orange color
barricade_model.metadata = struct('type', 'traffic_barrier', 'created', datestr(now));
save(fullfile(modelsDir, 'barricade_cuboid.mat'), 'barricade_model');

%% 3. Traffic Cone STL (simple)
fprintf('Creating traffic cone STL model...\n');
theta = linspace(0, 2*pi, 16);
r_base = 0.2; r_top = 0.05; h = 0.7;
% Bottom circle
x_bot = r_base * cos(theta); y_bot = r_base * sin(theta); z_bot = zeros(size(theta));
% Top circle  
x_top = r_top * cos(theta); y_top = r_top * sin(theta); z_top = h * ones(size(theta));
% Combine vertices
vertices = [[x_bot, x_top]', [y_bot, y_top]', [z_bot, z_top]'];
% Simple triangulation for cone shape
faces = [];
n = length(theta);
for i = 1:n-1
    faces = [faces; i, i+1, i+n; i+1, i+n+1, i+n]; % Side triangles
end
faces = [faces; n, 1, n+n; 1, 1+n, n+n]; % Close the cone
cone_model.vertices = vertices;
cone_model.faces = faces;
cone_model.metadata = struct('type', 'traffic_cone', 'created', datestr(now));
% Note: For STL, we'd need to write binary format. For now, save as MAT
save(fullfile(modelsDir, 'cone_model.mat'), 'cone_model');

%% 4. Enhanced Parked Vehicle Model
fprintf('Creating parked vehicle model...\n');
% Create a simple car/rickshaw shape
car_x = [-2.25, 2.25, 2.25, -2.25, -2.25, 2.25, 2.25, -2.25];
car_y = [-0.9, -0.9, 0.9, 0.9, -0.9, -0.9, 0.9, 0.9];
car_z = [0, 0, 0, 0, 1.6, 1.6, 1.6, 1.6];
car_faces = [1,2,6,5; 2,3,7,6; 3,4,8,7; 4,1,5,8; 1,2,3,4; 5,6,7,8];
vehicle_model.vertices = [car_x', car_y', car_z'];
vehicle_model.faces = car_faces;
vehicle_model.colors = [0.6, 0.6, 0.7]; % Gray color
vehicle_model.metadata = struct('type', 'parked_vehicle', 'created', datestr(now));
save(fullfile(modelsDir, 'parked_vehicle.mat'), 'vehicle_model');

%% 5. Create additional Indian-specific models
fprintf('Creating additional Indian micro-feature models...\n');

% Street vendor cart
cart_x = [-1.0, 1.0, 1.0, -1.0, -1.0, 1.0, 1.0, -1.0];
cart_y = [-0.6, -0.6, 0.6, 0.6, -0.6, -0.6, 0.6, 0.6];
cart_z = [0, 0, 0, 0, 1.4, 1.4, 1.4, 1.4];
cart_faces = [1,2,6,5; 2,3,7,6; 3,4,8,7; 4,1,5,8; 1,2,3,4; 5,6,7,8];
vendor_cart.vertices = [cart_x', cart_y', cart_z'];
vendor_cart.faces = cart_faces;
vendor_cart.colors = [0.8, 0.4, 0.2]; % Brown color
vendor_cart.metadata = struct('type', 'vendor_cart', 'created', datestr(now));
save(fullfile(modelsDir, 'vendor_cart.mat'), 'vendor_cart');

% Construction debris pile
[X, Y] = meshgrid(-0.8:0.2:0.8, -0.6:0.2:0.6);
Z = 0.3 * exp(-(X.^2/0.64 + Y.^2/0.36)) + 0.1*randn(size(X)); % Debris mound
debris_model.vertices = [X(:), Y(:), Z(:)];
debris_model.faces = delaunay(X(:), Y(:));
debris_model.metadata = struct('type', 'construction_debris', 'created', datestr(now));
save(fullfile(modelsDir, 'construction_debris.mat'), 'debris_model');

fprintf('=== Model Generation Complete ===\n');
fprintf('Generated models in: %s\n', modelsDir);
fprintf('Models created:\n');
fprintf('  - pothole_depression.mat (surface depression)\n');
fprintf('  - barricade_cuboid.mat (enhanced traffic barrier)\n');
fprintf('  - cone_model.mat (traffic cone)\n');
fprintf('  - parked_vehicle.mat (generic vehicle)\n');
fprintf('  - vendor_cart.mat (street vendor cart)\n');
fprintf('  - construction_debris.mat (debris pile)\n');

end