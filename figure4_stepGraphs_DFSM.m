%% Plots figure 4, example MM 24-hour data sets and maximum-to-minimum ratios
% Inputs
i_notPoiss = 4; % Index number of data set that does not appear consistent with Poisson
i_poiss = 11; % Index number of data set that appears consistent with Poisson

% Path to find data files
data_path = 'MM_35min_processed_data\';

%%
% Load data
load('MM_35min_data', 'frac_obs_within_X_percent', 'percents');

% Load file names
load('MM_35min_file_names.mat', 'MM_35min_file_names');

% X-axis labels
x_labels1 = {'(24 s) 1% PBV', '(2 min) 5%', '(4 min) 10%', '(8 min) 20%'};
x_labels2 = {'1% PBV', '5%', '10%', '20%'};
line_colors = [ 0 .7 1 ; 0 0 .7; 1 0 0; 0 1 .7]; % Colors for each blood sample volume plot

figure('DefaultAxesFontSize',14);

%% Data set that is NOT consistent with Poisson
% Load data of i_notPoiss
data_file = strcat(MM_35min_file_names{i_notPoiss});
load(strcat(data_path,data_file, '_out'), 'out_dat');

subplot(2,2,1);
step_graph(out_dat.detections, out_dat.scan_length, 1, 1, 2);
set(gca,'linewidth',1);
ylabel('Fraction of observations', 'FontSize', 16);
xlabel('Deviation from scan mean (%)', 'FontSize', 16);
set(gca, 'XTick', [0 25 50 75 100]);
%% Data set that is consistent with Poisson
% Load data of i_poiss
data_file = strcat(MM_35min_file_names{i_poiss});
load(strcat(data_path,data_file, '_out'));

subplot(2,2,2);
step_graph(out_dat.detections, out_dat.scan_length, 1, 1, 2);
set(gca,'linewidth',1);
set(gca, 'XTick', [0 25 50 75 100], 'yticklabel', {});

%% Deviation from scan mean (DFSM) plots for all data sets
color = [0 0 .7]; % Color of scatter points
opacity = 0.4; % Opacity of scatter points
% If box_whisker is set to 0, lines displaying first and third quartile,
% and median will be plotted. Set box_whisker to 1 to plot the default
% matlab boxplot
box_whisker = 0;
dfsm_gca = cell(1, 2);

for i = 1:length(percents)
    subplot(2,2,i+2); hold on;
    if i == 1
        x_labels = x_labels1;
    else
        x_labels = x_labels2;
    end
    plot([0.5 4.5], [1 1], 'k--');
    [medians, ranges] = Scatter_boxplot(frac_obs_within_X_percent{i}, x_labels, line_colors, opacity, box_whisker, 0.02, 150,30);
    ylim([0 1.1]);
    ylabel(sprintf( 'Fraction of observations\n%s' , strcat('DFSM \leq ', sprintf(' %.0f%%', percents(i)))), 'Interpreter', 'tex', 'FontSize', 16);
    box on;
    set(gca,'linewidth',1);
    dfsm_gca{i} = gca;
end
