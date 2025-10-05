function pkg = prepareHackathonPackage(configPath, outDir)
% prepareHackathonPackage  Generate a bundle of artifacts for submission.
%   pkg = prepareHackathonPackage('configs/examples/delhi_sample_canonical.json','dist')
%
% Artifacts:
%  - scenario_report.md
%  - variation_reports/variant_X.md
%  - features_plot.png
%  - summary.json

if nargin < 2; outDir = fullfile(pwd,'dist'); end
if ~isfolder(outDir); mkdir(outDir); end

% Generate base scenario
out = generateScenarioFromConfig(configPath);
exportScenarioReport(out, fullfile(outDir,'scenario_report.md'));

% Plot features
try
    fig = figure('Visible','off'); %#ok<LFIG>
    plot(out.scenario); hold on; plotAppliedFeatures(out.scenario, out.features);
    saveas(fig, fullfile(outDir,'features_plot.png'));
    close(fig);
catch ME
    warning('Feature plot failed: %s', ME.message);
end

% Variations
varsDir = fullfile(outDir,'variation_reports'); if ~isfolder(varsDir); mkdir(varsDir); end
vars = generateScenarioSet(configPath);
for i=1:numel(vars)
    exportScenarioReport(vars{i}, fullfile(varsDir, sprintf('variant_%02d.md', i)));
end

% Summary JSON
summary = struct();
summary.configPath = configPath;
summary.baseScenario = out.config.id;
summary.variants = numel(vars);
summary.timestamp = datestr(now,'yyyy-mm-dd HH:MM:SS');
summary.features = {out.features.type};
jsonText = jsonencode(summary);
fid = fopen(fullfile(outDir,'summary.json'),'w'); fprintf(fid,'%s',jsonText); fclose(fid);

pkg = struct('dir',outDir,'summary',summary);
fprintf('Hackathon package prepared at %s\n', outDir);
end
