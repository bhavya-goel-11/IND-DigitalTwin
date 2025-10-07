function out = placeFeatureAtCoordinate(scenario, featureType, x, y, varargin)
% placeFeatureAtCoordinate  Place a feature at exact coordinates
%
% Usage:
%   out = placeFeatureAtCoordinate(scenario, 'pothole', 25.5, 10.2)
%   out = placeFeatureAtCoordinate(scenario, 'pothole', 25.5, 10.2, 'z', 0.1)
%   out = placeFeatureAtCoordinate(scenario, 'barricadeCluster', [30.1, 15.7])
%
% Inputs:
%   scenario    - MATLAB drivingScenario object
%   featureType - String: feature type ('pothole', 'barricadeCluster', etc.)
%   x, y        - Coordinates (meters in scenario coordinate system)
%   varargin    - Optional: 'z', zValue (default: 0.0)
%
% Output:
%   out.scenario        - Original scenario (unchanged)
%   out.appliedFeatures - Feature placement information
%   out.featureCoords   - [x, y, z] coordinates used

% Parse inputs
p = inputParser;
addRequired(p, 'scenario');
addRequired(p, 'featureType', @ischar);
addRequired(p, 'x', @isnumeric);
addRequired(p, 'y', @isnumeric);
addParameter(p, 'z', 0.0, @isnumeric);
parse(p, scenario, featureType, x, y, varargin{:});

% Handle coordinate arrays
if length(x) > 1 || length(y) > 1
    if length(x) ~= length(y)
        error('X and Y coordinate arrays must have same length');
    end
    coordinates = [x(:), y(:), repmat(p.Results.z, length(x), 1)];
else
    coordinates = [x, y, p.Results.z];
end

% Create feature structure compatible with augmentScenario
feature = struct();
feature.type = featureType;
feature.rule = 'exactCoordinates';
feature.count = size(coordinates, 1);
feature.positions = coordinates;

% Prepare output
out.scenario = scenario;
out.appliedFeatures = feature;
out.featureCoords = coordinates;
out.notes = {sprintf('Manually placed %d %s feature(s) at exact coordinates', ...
    feature.count, featureType)};

% Display placement info
fprintf('Placed %s at coordinates:\n', featureType);
for i = 1:size(coordinates, 1)
    fprintf('  (%.2f, %.2f, %.2f)\n', coordinates(i, 1), coordinates(i, 2), coordinates(i, 3));
end

end