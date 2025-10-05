function plotAppliedFeatures(scenario, features)
% plotAppliedFeatures  Overlay feature markers on existing scenario plot.
%   plotAppliedFeatures(scenario, out.features)
% Assumes plot(scenario) already called or creates a new plot.

if nargin < 2 || isempty(features); warning('No features to plot.'); return; end

holdState = ishold; plotCreated = false;
try
    if isempty(scenario.Plots)
        plot(scenario); plotCreated = true;
    end
catch
    plot(scenario); plotCreated = true;
end
hold on;

colors = lines(numel(features));
legendEntries = {};
for i=1:numel(features)
    f = features(i);
    if ~isfield(f,'positions'); continue; end
    P = f.positions;
    scatter3(P(:,1), P(:,2), P(:,3)+0.2, 40, 'MarkerFaceColor', colors(i,:), 'MarkerEdgeColor','k');
    legendEntries{end+1} = sprintf('%s (%d)', f.type, f.count); %#ok<AGROW>
end
if ~isempty(legendEntries)
    legend(legendEntries,'Location','bestoutside');
end
if ~holdState && ~plotCreated
    hold off;
end
end
