function [xLocs] = distribScatter(data, binWidth, plotWidth)
% Method of making a vertically distributed scatter

binLims = min(data):binWidth:max(data)+binWidth;
xLocs = zeros(size(data,1), size(data,2));
plotLims = [1-plotWidth/2 1+plotWidth/2];

for i = 1:size(data,2)
    for j = 1:length(binLims)-1
        inds = find( data(:,i) >= binLims(j) & data(:,i) < binLims(j+1) );
        if ~isempty(inds)
            locs = linspace(plotLims(1), plotLims(2), length(inds)+2);
            xLocs(inds,i) = locs(2:end-1);
        end
    end
end
