function [medians, ranges] = Scatter_boxplot_variedMarkers(vals, labels, marker_color, opacity, box_whisker, binWidth, scatter_size, label_rotation, varargin)
% INPUTS:
% vals: Data values as a matrix. (#data points x #groups )
%           If groups have a different number of data points, fill extra
%           spaces with NaN
% labels: Cell of strings, labels of each data group. (#groups x 1) or
%           (1 x #groups)
% marker_color: Color of the scatter points. Either a 1x3 array of values between 
%           0 and 1. eg [.3 .2 0], or #groups x 3 (one color per group). If
%           The # of rows is < #groups, the first color is taken only.
% opacity: Opacity of the scatter points
% box_whisker: Set to 1 if you prefer to plot the matlab default boxplot.
%           Otherwise, set to 0 to identify Q1, median, and Q3 with simple
%           lines. Or set to -1 to only plot scatter points.
% binWidth: A value to distribute the scatter points when they are on top
%           of one another
% scatter_size: Size of the scatter points
% label_rotation: Degree of rotation of the x-axis labels of the groups
%           ('labels')
% Optional inputs:
% varargin{1}: matrix of 0s and 1s to indicate the values that should be
%           plotted with alternate colors, etc (#data points x #groups).
% varargin{2}: Plotting option (integer):
%           1 - Same marker color with black outline
%           2 - Alternate marker shape
%           3 - Alternate marker color (varargin{3})
%           4 - Alternate marker color with black outline
% varargin{3}: Alternate marker colors (same rules as marker_color)
%
% Example inputs: Scatter_boxplot(vals, ..., label_rotation, (vals > 0), 3, alternate_marker_color)

n_varargin = length(varargin);
if n_varargin >0
    inds = varargin{1};
    if n_varargin > 1
        plot_option = varargin{2};
        if n_varargin > 2
            alt_marker_color = varargin{3};
            if size(alt_marker_color,1) < size(vals, 2)
                alt_marker_color = repmat(alt_marker_color(1,:), size(vals, 2), 1);
            end
        end
    end
end

if size(marker_color,1) < size(vals, 2)
    marker_color = repmat(marker_color(1,:), size(vals, 2), 1);
end

medians = [];
ranges = [];
hold on;
n = size(vals,2);

vals( isinf(vals) ) = NaN;
for i = 1:n
    sorted = sort(vals(:,i));
    sorted = sorted(~isnan(sorted));

    if mod(length(sorted),2) == 1
        mid = floor(length(sorted)/2)+1;
        m = median(sorted);
        q1 = median(sorted(1:mid-1));
        q3 = median(sorted(mid+1:end));
    else
        m = median(sorted);
        q1 = median(sorted(1:length(sorted)/2));
        q3 = median(sorted(length(sorted)/2+1:end));
    end
    medians = [medians m];
    ranges = [ranges [min(sorted); max(sorted)]];
    
    [xLocs] = distribScatter(vals(:,i), binWidth, 0.5);
    if n_varargin > 0
        inds_sorted = logical(inds(:,i));
        if sum(inds_sorted) == 0
            scatter(i - 1 + xLocs, vals(:,i), scatter_size, 'filled','MarkerFaceColor', marker_color(i,:),'MarkerFaceAlpha',opacity);
        else
            scatter(i - 1 + xLocs(~inds_sorted), vals(~inds_sorted,i), scatter_size, 'filled','MarkerFaceColor', marker_color(i,:),'MarkerFaceAlpha',opacity);
            if plot_option == 1
                scatter(i - 1 + xLocs(inds_sorted), vals(inds_sorted,i), scatter_size, 'filled','MarkerFaceColor', marker_color(i,:),'MarkerFaceAlpha',opacity, 'MarkerEdgeColor', [0 0 0]);
            elseif plot_option == 2
                scatter(i - 1 + xLocs(inds_sorted), vals(inds_sorted,i), scatter_size, 'filled','MarkerFaceColor', marker_color(i,:),'MarkerFaceAlpha',opacity, 'Marker', 'diamond');
            elseif plot_option >= 3
                if n_varargin < 3
                    warning('Please input a second set of colors as a final input');
                    return;
                end
                if plot_option == 3
                    scatter(i - 1 + xLocs(inds_sorted), vals(inds_sorted,i), scatter_size, 'filled','MarkerFaceColor', alt_marker_color(i,:),'MarkerFaceAlpha',opacity);
                elseif plot_option == 4
                    scatter(i - 1 + xLocs(inds_sorted), vals(inds_sorted,i), scatter_size, 'filled','MarkerFaceColor', alt_marker_color(i,:),'MarkerFaceAlpha',opacity, 'MarkerEdgeColor', [0 0 0]);
                else
                    warning('Invalid plot option');
                    return;
                end
            else
                warning('Invalid plot option');
                return;
            end
        end
    else
        scatter(i - 1 + xLocs, vals(:,i), scatter_size, 'filled','MarkerFaceColor', marker_color(i,:),'MarkerFaceAlpha',opacity);
    end
    
    line_sizes = [3 3 4 1.5];
    if box_whisker == 0
        col1 = .1*[1 1 1];
        col2 = .1*[1 1 1];
%         plot(i + [-0.2 0.2], [q1 q1], 'Color', col1, 'LineWidth', line_sizes(1), 'HandleVisibility','off');
%         plot(i + [-0.2 0.2], [q3 q3], 'Color', col1',  'LineWidth', line_sizes(2), 'HandleVisibility','off');
%         plot(i + [-0.3 0.3], [m m], 'Color', col2, 'LineWidth', line_sizes(3), 'HandleVisibility','off');
        plot(i + [-0.3 0.3], [q1 q1], 'Color', col1, 'LineWidth', line_sizes(1), 'HandleVisibility','off');
        plot(i + [-0.3 0.3], [q3 q3], 'Color', col1',  'LineWidth', line_sizes(2), 'HandleVisibility','off');
        plot(i + [-0.4 0.4], [m m], 'Color', col2, 'LineWidth', line_sizes(3), 'HandleVisibility','off');
        plot([i i], [q1 q3], 'Color', col2, 'LineWidth', line_sizes(4), 'HandleVisibility','off');
        box on;
    end
    
end

if box_whisker == 1
    boxplot(vals, 'Labels', labels,'Whisker',100,'Widths',0.6);
end

xlim([0.5 n+0.5]);
set(gca, 'tickdir','in', 'xtick', [1:n], 'xticklabel',labels, 'XTickLabelRotation', label_rotation);

end