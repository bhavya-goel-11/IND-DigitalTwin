function scenario = buildScenarioFromOSM(osmPath)
% buildScenarioFromOSM  Stub for importing OSM into drivingScenario.
%   scenario = buildScenarioFromOSM('data/osm/sample_map.osm')
% NOTE: This is a placeholder. Real implementation would use:
%   drivingScenarioDesigner or helper functions to parse OSM and
%   construct roads with lanes. For hackathon skeleton we create an empty
%   scenario with stored metadata.

if ~isfile(osmPath)
    error('OSM file not found: %s', osmPath);
end

scenario = drivingScenario; %#ok<NASGU>
scenario = drivingScenario('StopTime',300); % default horizon placeholder
scenario.UserData.osmSource = osmPath;

% TODO: parse OSM (future iteration):
%  - Extract ways with highway tags
%  - Build road center arrays
%  - Add lane specifications
%  - Detect junction nodes

end
