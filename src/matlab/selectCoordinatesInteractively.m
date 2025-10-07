function coordinates = selectCoordinatesInteractively(scenario)
% selectCoordinatesInteractively  Visually pick coordinates from scenario plot
%
% Usage:
%   coords = selectCoordinatesInteractively(scenario)
%   
% Instructions:
%   1. Click on the plot to select feature locations
%   2. Press Enter when finished selecting
%
% Output:
%   coordinates - Nx3 array of [x, y, z] coordinates (z=0)

% Plot the scenario
figure;
plot(scenario);
title({'Interactive Coordinate Selection', ...
       'Click to select locations. Press Enter when done.'});
grid on;
axis equal;
xlabel('X (meters)');
ylabel('Y (meters)');

% Collect coordinates interactively
coordinates = [];
hold on;

fprintf('\n=== Interactive Coordinate Selection ===\n');
fprintf('Click on the plot to select feature locations.\n');
fprintf('Press Enter (without clicking) when finished.\n\n');

pointNumber = 1;
while true
    try
        [x, y] = ginput(1);  % Get one point from user click
        if isempty(x)
            break;  % User pressed Enter
        end
        
        % Mark the selected point
        plot(x, y, 'ro', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerFaceColor', 'yellow');
        text(x + 1, y + 1, sprintf('%d', pointNumber), 'FontSize', 12, 'FontWeight', 'bold');
        
        % Store coordinate
        coordinates(end+1,:) = [x, y, 0.0]; %#ok<AGROW>
        
        fprintf('Point %d: (%.2f, %.2f)\n', pointNumber, x, y);
        pointNumber = pointNumber + 1;
        
    catch ME
        if strcmp(ME.identifier, 'MATLAB:ginput:FigureDeletionPause')
            fprintf('Figure was closed. Selection cancelled.\n'); 
            coordinates = [];
            return;
        else
            rethrow(ME);
        end
    end
end

hold off;

% Summary
if isempty(coordinates)
    fprintf('\nNo coordinates selected.\n');
else
    fprintf('\n=== Selection Complete ===\n');
    fprintf('Total coordinates selected: %d\n', size(coordinates, 1));
    fprintf('\nCoordinates:\n');
    for i = 1:size(coordinates, 1)
        fprintf('  %d: (%.2f, %.2f, %.2f)\n', i, coordinates(i, 1), coordinates(i, 2), coordinates(i, 3));
    end
    
    % Save to workspace for convenience
    assignin('base', 'selectedCoordinates', coordinates);
    fprintf('\nCoordinates saved to workspace variable: selectedCoordinates\n');
end

end