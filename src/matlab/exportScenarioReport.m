function exportScenarioReport(outStruct, reportPath)
% exportScenarioReport  Write a markdown summary of a generated scenario.
%   exportScenarioReport(out, 'report.md')

if nargin < 2
    reportPath = fullfile(pwd, 'scenario_report.md');
end

m = collectMetrics(outStruct);
lines = {};
lines{end+1} = sprintf('# Scenario Report: %s', outStruct.config.id);
lines{end+1} = '';
lines{end+1} = '## Feature Counts';
if isempty(fieldnames(m.featureCounts))
    lines{end+1} = '_None_';
else
    fn = fieldnames(m.featureCounts);
    for i=1:numel(fn)
        lines{end+1} = sprintf('- %s: %d', fn{i}, m.featureCounts.(fn{i}));
    end
end
lines{end+1} = '';
lines{end+1} = '## Vehicle Classes';
if isempty(fieldnames(m.vehicleClassCounts))
    lines{end+1} = '_None_';
else
    fn = fieldnames(m.vehicleClassCounts);
    for i=1:numel(fn)
        lines{end+1} = sprintf('- %s: %d', fn{i}, m.vehicleClassCounts.(fn{i}));
    end
end
lines{end+1} = sprintf('\nTotal Vehicles: %d', m.totalVehicles);
lines{end+1} = '\n## Notes';
for i=1:numel(outStruct.notes)
    lines{end+1} = ['- ' outStruct.notes{i}];
end

fid = fopen(reportPath,'w');
for i=1:numel(lines)
    fprintf(fid,'%s\n',lines{i});
end
fclose(fid);

fprintf('Scenario report written: %s\n', reportPath);
end
