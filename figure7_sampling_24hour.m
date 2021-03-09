%% Plots figure 7, comparing averaging multiple samples of 24-hour data
% No inputs needed

%%
% Load data
load('MM_24hour_data.mat', 'frac_obs_1_2_4_20_80', 'frac_obs_two_samples_1', 'frac_obs_four_samples_1_20');

opacity = 0.5; % Opacity of scatter points
% If box_whisker is set to 0, lines displaying first and third quartile,
% and median will be plotted. Set box_whisker to 1 to plot the default
% matlab boxplot
box_whisker = 0;

colors = [ 0 .7 1; 0 .45 .65; 0 .45 .65; 0 .18 .26; 0 .18 .26; 0 1 .7; .06 .35 .06; .06 .35 .06]; % Colors for each column of data

%% Plot fraction of observations with DFSM <= 25%
figure('DefaultAxesFontSize',14);
% Organize all data into one array
vals = [   frac_obs_1_2_4_20_80{1}(:, [1 2]) ...
                frac_obs_two_samples_1{1} ...
                frac_obs_1_2_4_20_80{1}(:,3) ...
                frac_obs_four_samples_1_20{1}(:,1) ...
                frac_obs_1_2_4_20_80{1}(:, [4 5]) ...
                frac_obs_four_samples_1_20{1}(:, 2)   ];

% The data for multiple samples will be plotted with a different marker
% than the single sample data
inds_differentMarkers = zeros(size(vals, 1), size(vals, 2));
inds_differentMarkers(:, [3 5 8]) = ones(size(vals, 1), 3);

subplot(1, 2, 1); hold on;
x_labels = {'(24s) 1%', '(48s) 2%', 'Two 1%', '(96s) 4%', 'Four 1%', '(8 min) 20%', '(32 min) 80%', 'Four 20%'};
plot([0.5 8.5], [1 1], 'k--');
[medians, ranges] = Scatter_boxplot_variedMarkers(vals, x_labels, colors, opacity, box_whisker, 0.02, 200, 30, inds_differentMarkers, 2);
ylim([0 1.05]);
ylabel(sprintf('Fraction of Observations\n%s', strcat('DFSM \leq ', sprintf(' %.0f%%', 25))), 'Interpreter', 'tex', 'FontSize', 18, 'FontWeight', 'bold');
box on;
set(gca,'linewidth',1, 'Position', [0.1047    0.1839    0.4593    0.7411]);

%% Plot paired difference in fraction of observations
% 2% - two 1%
one_larger_sample = frac_obs_1_2_4_20_80{1}(:, 2);
averaged_smaller_samples = frac_obs_two_samples_1{1};
dif_2 = averaged_smaller_samples - one_larger_sample;

% 4% - four 1%
one_larger_sample = frac_obs_1_2_4_20_80{1}(:, 3);
averaged_smaller_samples = frac_obs_four_samples_1_20{1}(:, 1);
dif_4 = averaged_smaller_samples - one_larger_sample;

% 80% - four 20%
one_larger_sample = frac_obs_1_2_4_20_80{1}(:, 5);
averaged_smaller_samples = frac_obs_four_samples_1_20{1}(:, 2);
dif_80 = averaged_smaller_samples - one_larger_sample;

subplot(1, 2, 2); hold on;
plot([0.5 3.5], [1 1], 'k--');
Scatter_boxplot([dif_2 dif_4 dif_80], {'2%', '4%' , '80%'}, colors([3 5 8],:), opacity, box_whisker, 0.02, 200,30)
ylabel(sprintf('Paired Difference in\nFraction of Observations'), 'FontSize', 18, 'FontWeight', 'bold');
ylim([0 1.05]);
set(gca,'linewidth',1, 'Position', [ 0.6951    0.1839    0.2490    0.7411 ]);

