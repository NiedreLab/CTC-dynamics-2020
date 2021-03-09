%% Plots figure 3, raster plot, moving averages, and histograms for one data set
% Inputs
processed_data_path = 'MM_35min_processed_data\'; % Path to find processed data
index_of_file = 4; % Index of file in the 18 MM 35-min files

%%
% Load data
load('MM_35min_file_names.mat', 'MM_35min_file_names');
data_file = MM_35min_file_names{index_of_file};
load(strcat(processed_data_path,data_file, '_out'), 'out_dat');

% Percents of the blood volume to use
percent_bloodVols = [1 5 10 20];
% Convert to time (of DiFC scan) assuming 50 uL per minute and 2000uL total blood volume
interval_lengths = percent_bloodVols .* 120 ./ 5;

time_labels = {'24 s', '2 min', '4 min', '8 min'}; % Interval lengths in string form to allow for different units
line_colors = [ 0 .7 1 ; 0 0 .7; 1 0 0; 0 1 .7]; % Colors for each blood sample volume plot
subplot_dimensions1 = [0.1300    0.6350    0.4706    0.1174]; % Position of subfigures
subplot_dimensions2 = [0.6832    0.6350    0.2313    0.1174]; % Position of subfigures

%% Identify CTC detections as cells moving in arterial direction (cells1)
detection_times = out_dat.detections;
avg_events = length(detection_times)./ (out_dat.scan_length/60);
fs = 2000;
time = linspace(0,out_dat.scan_length, out_dat.scan_length*fs)';

%% Raster plot of CTC detections
% figure('DefaultAxesFontSize',12);
figure('DefaultAxesFontSize',14);
subplot(length(interval_lengths) + 1, 2, 1);
hold on;
plot([detection_times/60 detection_times/60]',[0 1]','k-', 'HandleVisibility', 'off');
% Formatting the plot
ylim([-0.13 1.13]);
xlim([0 out_dat.scan_length/60 + 0.01]);
set(gca,'ytick',[],'yticklabel',[],'xticklabel',[],'xtick',[])
% ylabel('Detections', 'FontSize', 14, 'FontWeight', 'bold', 'Position', [-3.6241, 0.4771, -1]);
ylabel('CTC detections', 'Position', [-3.6241, 0.4771, -1]);
this_gca = get(gca, 'Position');
this_gca(1) = subplot_dimensions1(1);
this_gca(3) = subplot_dimensions1(3);
set(gca, 'Position', this_gca);

%% Plot moving averages
times = cell(1,length(interval_lengths));
CTCs_per_interval_all = times;
legend_labels = times;
avgs = zeros(1, length(interval_lengths));
xl2 = avgs;
x_axis_span = [0.01 out_dat.scan_length/60 + 0.01];
subplot_nums = 2 * (1:length(interval_lengths)) + 1;
mov_avg_gca = cell(1, length(interval_lengths));
% Plot lines on the raster plot that identify the length of each time
% interval/blood sample
% Also collect info for moving averages/histograms
%
% (Trust me, trying to combine both loops below into one messes up the
% formatting so it's much easier to leave it as is)
for i = 1:length(interval_lengths)
    % Plotting lines on the raster plot to demonstrate the length of each
    % time interval/blood sample
    interval_length = interval_lengths(i);
    legend_labels{i} = sprintf('%.0f%% PBV (%s)',percent_bloodVols(i), time_labels{i});
    plot([0 interval_length/60] , .2*(5-i)* [1 1], 'LineWidth', 2.5, 'Color', line_colors(i,:));
    % Load the CTC counts per sample
    CTCs_per_interval = Count_CTCs_per_interval(detection_times, interval_length, out_dat.scan_length, fs);
    CTCs_per_interval_all{i} = CTCs_per_interval;
    
    times{i} = time(interval_length*fs/2:end-interval_length*fs/2)/60;
    avgs(i) = avg_events * interval_length / 60;
    num_bins = ceil(max(CTCs_per_interval_all{i}))+1;
    xl2(i) = 1.1*(num_bins-1);
end
% Final formatting of raster plot and a legend
box on;
plot([-2 -1], [.5 .5], 'k--', 'LineWidth', 2.5);
legend_labels{length(interval_lengths)+1} = 'Poisson';
legend(legend_labels, 'Location', 'southeast', 'Position', [0.6987, 0.7983, 0.1990, 0.1377]);
for i = 1:length(interval_lengths)
    % Plotting moving averages
    subplot(length(interval_lengths) + 1, 2, subplot_nums(i)); hold on;
    plot(x_axis_span, [avgs(i) avgs(i)], 'k-', 'LineWidth', 1.5);
    plot(times{i},CTCs_per_interval_all{i}','-','LineWidth', 1.5, 'Color', line_colors(i,:));
    % Various formatting
    ylim([0 xl2(i)]);
    xlim([0 out_dat.scan_length/60 + 0.01]);
    if i == 1 || i == length(interval_lengths)
        ylabel_pos = [-3.6241, 0.4771, -1];
    else
        ylabel_pos = [-5.7265, 9.2, -1];
    end
    ylabel(sprintf('%.0f%% PBV\n(%s)',percent_bloodVols(i), time_labels{i}), 'Position', ylabel_pos);
    if i < length(interval_lengths)
        set(gca,'xticklabel',[],'xtick',[]);
    end
    box on;
    mov_avg_gca{i} = gca;
end
xlabel('Time (minutes)');
text(-3.9677, 116.9835, 'Detections per interval', 'Rotation', 90);

%% Plot histograms
interval_lengths = percent_bloodVols .* 120 ./ 5;
histogram_gca = plot_histograms(CTCs_per_interval_all,avgs, percent_bloodVols, line_colors);

%%
for i = 1:length(interval_lengths)
    this_gca = get(mov_avg_gca{i}, 'Position');
    this_gca(1) = subplot_dimensions1(1);
    this_gca(3) = subplot_dimensions1(3);
    set(mov_avg_gca{i}, 'Position', this_gca);
    this_gca = get(histogram_gca{i}, 'Position');
    this_gca(1) = subplot_dimensions2(1);
    this_gca(3) = subplot_dimensions2(3);
    set(histogram_gca{i}, 'Position', this_gca);
end

%%
function [histogram_gca] = plot_histograms(CTCs_per_interval_all,avgs, percent_bloodVols, line_colors)
subplot_nums = [4 6 8 10];
histogram_gca = cell(1, 4);
interval_lengths = percent_bloodVols .* 120 ./ 5;
for i = 1:length(interval_lengths)
    subplot(5, 2, subplot_nums(i));
    hold on;
    avg = avgs(i);
    num_bins = ceil(max(CTCs_per_interval_all{i}))+1;
    color_edge = [0 0 0];
    % Plotting histogram
    h = histogram(CTCs_per_interval_all{i},'Normalization','probability','BinWidth',1,'FaceColor',line_colors(i,:),'EdgeColor', color_edge, 'BinMethod', 'integers');
    xl = xlim;
    if i ==1
        xl2 = xl(2);
    else
        xl2 = 1.1*(num_bins-1);
    end
    % Plotting Poisson distribution
    k = round(0:1:xl2);
    poiss = (avg).^(k) * exp(-avg)./factorial(k);
    plot(k, poiss,'--','LineWidth',2, 'Color',[.1 .1 .1]);
    ylim([0 1.1*max(max(h.Values),max(poiss))]);
    yl = ylim;
    plot([avg avg]',[0 yl(2)]','k-', 'LineWidth',2);
    % Various formatting
    xlim([0 xl2]);
    set(gca,'TickDir','out','TickLength',[.03 .03])
    box on;
    histogram_gca{i} = gca;
    if i == 4
        xlabel('Detections per interval');
    elseif i == 3
        ylabel('Frequency', 'Position', [-6.1844, 0.1233, -1]);
    end
end
end