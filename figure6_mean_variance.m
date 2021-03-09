%% Plots figure 6, standard deviations and difference in probabilities (Poisson vs
% true) for MM, Phantom, and Simulated data
% No inputs needed

%%
colors = [ .7 0 0; .7 0 0; 0 0 .5; .7 0 0; 0 0 .5; 0 0 .5];
label_positions = [-6.4 5; -26 20; -7 5; -7 5; -8 6];
figure('DefaultAxesFontSize',12);

%% Plotting

% Get MM Single-scan data
load('MM_35min_data.mat', 'avg_CTCs_per_interv', 'interval_variance');
ranges = [0 10; 0 70; 0 200; 0 600];
text_positions = [5.3, 1; 36, 7.5; 106 22; 316 58];
plot_scatter(avg_CTCs_per_interv, interval_variance, colors(1,:), 'MM 35-min', 0, 6, label_positions(1,:), text_positions, ranges, 100, 'o', 1, .3);

% Get MM-Diurnal data
load('MM_24hour_data.mat', 'avg_CTCs_per_interv', 'interval_variance');
ranges = [0 40; 0 800; 0 3000; 0 10500];
text_positions = [21.5 4; 368 83; 1370 318; 4942 1158];
plot_scatter(avg_CTCs_per_interv, interval_variance, colors(2,:), 'MM 24-hours', 1, 6, label_positions(2,:), text_positions, ranges, 100, 'o', 1, .3);

% Get Simulation data
load('Simulations_Poisson_data', 'avg_CTCs_per_interv', 'interval_variance');
ranges = [0 10; 0 50; 0 100; 0 250];
text_positions = [5.2 1; 26 5; 52 10; 134 28.5];
plot_scatter(avg_CTCs_per_interv, interval_variance, colors(3,:), sprintf('Poisson\nSimulations'), 2, 6, label_positions(3,:), text_positions, ranges, 100, 'o', 1, .3);

% Get Phantom data
load('Phantom_data.mat', 'avg_CTCs_per_interv', 'interval_variance');
ranges = [0 10; 0 50; 0 100; 0 250];
text_positions = [5.2 1; 26 5; 52 10; 134 28.5];
plot_scatter(avg_CTCs_per_interv, interval_variance, colors(4,:), sprintf('Phantom\nwith \\muspheres'), 3, 6, label_positions(4,:), text_positions, ranges, 80, 'o', 0, .3);

% Get Simulation Changing Mean Data
load('Simulations_ChangingMeanPoissons_data.mat', 'avg_CTCs_per_interv', 'interval_variance');
% ranges = [0 10; 0 80; 0 250; 0 850];
ranges = [0 12; 0 170; 0 600; 0 2000];
text_positions = [5.2 1; 42 9; 132 27; 447 102];
plot_scatter(avg_CTCs_per_interv, interval_variance, colors(5,:), sprintf('Changing Mean\nSimulations'), 4, 6, label_positions(5,:), text_positions, ranges, 100, 'o', 1, .3);

% Get Simulation Mixed Poissons
load('Simulations_MergedPoissons_data', 'avg_CTCs_per_interv', 'interval_variance');
ranges = [0 10; 0 70; 0 150; 0 300];
text_positions = [5.2 1; 36, 7.5; 80 16; 170 35];
plot_scatter(avg_CTCs_per_interv, interval_variance, colors(6,:), sprintf('Merged Poissons\nSimulations'), 5, 6, label_positions(1,:), text_positions, ranges, 100, 'o', 1, .3);
xlabel('Mean detections per interval');

%%
function [a, b, GOF] = plot_scatter(x, y, color, label, subplot_set, num_sets, label_position, text_positions, ranges, marker_size, marker, filled_flag, opacity)
rows = 1;

percent_bloodVols = [1 5 10 20];
time_labels = {'24 s', '2 min', '4 min', '8 min'};
label_fontsize = 10;
interval_lengths = percent_bloodVols .* 120 ./ 5;
xticks = ranges;
a = zeros(1, length(interval_lengths));
b = a;
GOF = a;
for i = 1:length(interval_lengths)
    if rows == 1
        subplot(num_sets, 4, i + 4*subplot_set);
    else
        subplot(4, num_sets, 1+(i-1)*num_sets+subplot_set);
    end
    
    hold on;
    
    if filled_flag == 1
        scatter(x(i,:), y(i,:), marker_size, 'filled', 'Marker', marker,'MarkerFaceColor', color,'MarkerFaceAlpha',opacity);
    else
        scatter(x(i,:), y(i,:), marker_size, 'Marker', marker,'MarkerEdgeColor', color);
    end
    
    range = ranges(i, :);
    plot(range, range, 'k--','HandleVisibility','off','LineWidth',1.5);
    
    
    %%%%
    X = x(i,:);
    Y = y(i,:);
    dlm = fitlm(X,Y,'Intercept',false);
    Rsq = dlm.Rsquared.Ordinary;
    slp = dlm.Coefficients.Estimate;
    plot_line = slp * [0 range(2)];
    plot([0 range(2)], plot_line, 'k', 'LineWidth', 2);
    text(text_positions(i,1), text_positions(i,2), sprintf('y = %.1fx', slp));
    
    
    axis equal;
    xlim(range); ylim(range);
    box on;
    if rows == 1
        
        if subplot_set == 0
            title(sprintf('%d%% PBV (%s)', percent_bloodVols(i), time_labels{i}));
        end
        if i == 1
            text(label_position(1), range(2)/2, label, 'FontSize',label_fontsize, 'FontWeight', 'bold', 'Rotation', 90, 'HorizontalAlignment', 'center');
            if subplot_set == 0
                ylabel(' Variance of Intervals', 'Rotation', 90, 'FontSize',10);
            end
        end
        xtick = xticks(i,:);
        set(gca, 'XTick', xtick, 'XTickLabel', {num2str(xtick(1)) num2str(xtick(2))}, 'YTick', xtick, 'YTickLabel', {num2str(xtick(1)) num2str(xtick(2))},  'TickLength', [0.05 0.05]);
        
    else
        if subplot_set == 0
            text(label_position(1), range(2)/2,sprintf('%d%% PBV (%s)', percent_bloodVols(i), time_labels{i}), 'FontSize', 10, 'FontWeight', 'bold', 'Rotation', 90, 'HorizontalAlignment', 'center');
        end
        if i == 1
            title(label, 'FontSize',label_fontsize);
            if subplot_set == 0
                ylabel(' Variance of Intervals', 'Rotation', 90);
            end
        end
        xtick = xticks(i,:);
        set(gca, 'XTick', xtick, 'XTickLabel', {num2str(xtick(1)) num2str(xtick(2))}, 'YTick', xtick, 'YTickLabel', {num2str(xtick(1)) num2str(xtick(2))},  'TickLength', [0.05 0.05]);
    end
end

end