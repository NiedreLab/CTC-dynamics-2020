%% Plots figure 5, example MM 24-hour data sets and maximum-to-minimum ratios
% Inputs
processed_data_path = 'MM_24hour_processed_data\'; % Path to find processed data
sets_to_plot = [8 2]; % Indeces of the mouse sets to plot of the 14 MM 24-hour data sets

% Identify which blood sample size of the standard 4 (1%, 5%, 10%, or 20%
% PBV) for plotting the moving average
blood_sample_size = 2;

%%
% Load data
load('MM_24hour_file_names.mat', 'MM_24hour_file_names');
load('MM_24hour_data.mat', 'avg_CTCs_per_min');
load('MM_24hour_extra_info.mat', 'sort_inds', 'time_of_day_sorted');

percent_bloodVols = [1 5 10 20]; % The standard 4 blood volumes used
percent_bloodVol = percent_bloodVols(blood_sample_size); % Use the blood volume indentified above
% Convert to time (of DiFC scan) assuming 50 uL per minute and 2000uL total blood volume
interval_length = percent_bloodVol .* 120 ./ 5;

num_of_scans = 4; % The number of scans per 24-hour set
colors = [ 0 0 .65 ; 1 .5 .5]; % Colors of the two example data sets
mov_avgs_pos = [0.1300    0.7968    0.7750    0.1601; 0.1300    0.5544    0.7750    0.1601]; % Position of subfigures

%%
figure('DefaultAxesFontSize', 15);
mean_24hrs = cell(1,2);
for j = 1:2
    mouse_session = sets_to_plot(j);
    session_files = MM_24hour_file_names(mouse_session, :);
    session_files = session_files(sort_inds(mouse_session, :));
    fs = 2000;
    mov_avgs = cell(1,num_of_scans);
    times = mov_avgs;
    min_range = [];
    max_range = [];
    total_num_CTCs = 0;
    total_length_time = 0;
    for i = 1:num_of_scans
        data_file = session_files{i};
        load(strcat(processed_data_path, data_file, '_out'), 'out_dat');
        detection_times = out_dat.detections;
        total_num_CTCs = total_num_CTCs + length(detection_times);
        total_length_time = total_length_time + (out_dat.scan_length / 60);
        mov_avgs{i} = Count_CTCs_per_interval(detection_times, interval_length, out_dat.scan_length, fs);
        time = linspace(0,out_dat.scan_length, out_dat.scan_length*fs)';
        times{i} = time(interval_length*fs/2:end-interval_length*fs/2);
        if i == 1
            min_range = min(mov_avgs{i});
            max_range = max(mov_avgs{i});
        else
            if min(mov_avgs{i}) < min_range
                min_range = min(mov_avgs{i});
            end
            if max(mov_avgs{i}) > max_range
                max_range = max(mov_avgs{i});
            end
        end
    end
    subplot(4, 1, j);
    hold on;
        
    tbs = 10; 
    x_axis_labels = cell(1, 2*num_of_scans);
    
    
    x = repmat([50*3+tbs*3+tbs / 2], max_range+10, 1);
    histogram(x, 'BinWidth', (50*2+tbs*2), 'FaceColor', .8*[1 1 1], 'EdgeColor', .8*[1 1 1], 'FaceAlpha', .5); 
    
    for i = 1:num_of_scans
        plot(times{i} / 60 + (50 +tbs)*(i-1), mov_avgs{i}, 'Color', colors(j, :), 'LineWidth', 1.5);
        plot([50*(i-1)+tbs*(i-1) 50*i+tbs*(i-1)], avg_CTCs_per_min(mouse_session, i) * interval_length / 60 * [1 1], '--', 'Color', colors(j, :), 'LineWidth', 1);
        time_tmp = num2str(time_of_day_sorted(mouse_session, i) + 10);
        time_tmp2 = num2str(time_of_day_sorted(mouse_session, i) + 60);
        if str2num(time_tmp(end-1:end)) >= 60
            time_tmp = round((time_of_day_sorted(mouse_session, i) + 10) ./ 100)*100 + str2num(time_tmp(end-1:end)) - 60;
            time_tmp = num2str(time_tmp);
        end
        if str2num(time_tmp2(end-1:end)) >= 60
            time_tmp2 = round((time_of_day_sorted(mouse_session, i) + 60) ./ 100)*100 + str2num(time_tmp2(end-1:end)) - 60;
            time_tmp2 = num2str(time_tmp2);
        end
        if str2num(time_tmp) >= 2400
            time_tmp = num2str( str2num(time_tmp) - 2400 );
        end
        if str2num(time_tmp2) >= 2400
            time_tmp2 = num2str( str2num(time_tmp2) - 2400 );
        end
            
            
        time_tmp = strcat('0000', time_tmp);
        time_tmp2 = strcat('0000', time_tmp2);
        x_axis_labels{2*i-1} = time_tmp(end-3:end);
        x_axis_labels{2*i} = time_tmp2(end-3:end);
    end
    end_time = (tbs + 50) * 4 - tbs;
    mean_24hrs{j} = (total_num_CTCs / total_length_time) * interval_length / 60;
    plot([0 end_time], mean_24hrs{j} * [1 1], 'Color', colors(j, :), 'LineWidth', 1);
    xlim([0 end_time]);
    set(gca, 'xtick', [0 50 50+tbs 50*2+tbs 50*2+tbs*2 50*3+tbs*2 50*3+tbs*3 50*4+tbs*3], 'xticklabels', x_axis_labels, 'XTickLabelRotation', 45);
    box on;
    
    ylim([min_range, max_range]);
    
    set(gca, 'FontSize', 12);
    if j == 1
        ylabel('CTCs per Interval', 'FontSize', 16);
    else
        xlabel('Time', 'FontSize', 16)
    end
    set(gca, 'Position', mov_avgs_pos(j, :));
end

%%
subplot(2,2,3); hold on;

x = repmat([100; 1900; 2500], 100, 1);
h = histogram(x, 'BinWidth', 1200, 'FaceColor', .8*[1 1 1], 'EdgeColor', .8*[1 1 1], 'BinLimits', [-500 3100], 'FaceAlpha', .5, 'HandleVisibility', 'off');

for k = 1:2
    mouse_session = sets_to_plot(k);
    plot(time_of_day_sorted(mouse_session,:)+10, avg_CTCs_per_min(mouse_session,sort_inds(mouse_session,:))*interval_length/60, 'LineWidth',3, 'Color', colors(k,:));
    for j = 1:num_of_scans
        scatter_marker = 'o';
        scatter(time_of_day_sorted(mouse_session,j)+10, avg_CTCs_per_min(mouse_session,sort_inds(mouse_session,j)) * interval_length/60, 100,'Marker', scatter_marker, 'MarkerFaceColor', colors(k,:), 'MarkerEdgeColor', colors(k, :), 'MarkerFaceAlpha', 1, 'HandleVisibility','off');
        plot([700 2700], mean_24hrs{k} * [1 1], 'LineWidth',1.5, 'Color', colors(k,:), 'HandleVisibility','off');
    end
end
ylim([0 80]);
ylabel('CTCs per Interval');
xlabel('Time');
set(gca, 'xtick', [0700 1300 1900 0100+2400], 'xticklabels', {'0700', '1300', '1900', '0100'});
xlim([400 2800]);
legend_labels = {'Ex 1', 'Ex 2'};
legend(legend_labels, 'Location', 'northwest', 'FontSize', 10);
box on;
set(gca, 'Position', [ 0.1300    0.1100    0.3347    0.3412], 'TickLength', [0.025 0.025]);

%%
subplot(2,2,4);
marker_color = [ 0 0 1; 0 .13 .62; 1 0 0; 1 .3 0; .73 .29 .1];
load('MM_24hour_data.mat', 'max_min_ratio_MM_24hour');
load('MM_35min_data.mat', 'max_min_ratio_MM_35min');
load('Max_min_ratios_Repos.mat', 'max_min_ratio_OneOpRepos', 'max_min_ratio_TwoOpsRepos');
max_min_ratio_Reposit = [ max_min_ratio_OneOpRepos; max_min_ratio_TwoOpsRepos ];

data = [mean(max_min_ratio_MM_24hour) mean(max_min_ratio_MM_35min) mean(max_min_ratio_OneOpRepos) mean(max_min_ratio_TwoOpsRepos) mean(max_min_ratio_Reposit)];
stds = [std(max_min_ratio_MM_24hour) std(max_min_ratio_MM_35min) std(max_min_ratio_OneOpRepos) std(max_min_ratio_TwoOpsRepos) std(max_min_ratio_Reposit)];


hold on;
for i = 1:length(data)
    bar(i, data(i), 'FaceColor', marker_color(i,:), 'FaceAlpha', .3);
    er = errorbar(i, data(i), [0], stds(i), 'LineWidth', 1);
    er.Color = [0 0 0];
    er.LineStyle = 'none';
end


max_num_data = max( [length(max_min_ratio_MM_24hour) length(max_min_ratio_MM_35min) length(max_min_ratio_OneOpRepos) length(max_min_ratio_TwoOpsRepos) length(max_min_ratio_Reposit)] );
vals = NaN(max_num_data, 5);
vals(1:length(max_min_ratio_MM_24hour), 1) = max_min_ratio_MM_24hour;
vals(1:length(max_min_ratio_MM_35min), 2) = max_min_ratio_MM_35min;
vals(1:length(max_min_ratio_OneOpRepos), 3) = max_min_ratio_OneOpRepos;
vals(1:length(max_min_ratio_TwoOpsRepos), 4) = max_min_ratio_TwoOpsRepos;
vals(1:length(max_min_ratio_Reposit), 5) = max_min_ratio_Reposit;
opacity = 0.5;
box_whisker = 0;
binWidth = 1;
scatter_size = 100;
label_rotation = 45;
labels = {'24-hour', '35-min', '1 Op. w/Repos.', '2 Ops. w/Repos.', '1 or 2 Ops. w/Repos.'};
[medians, ranges] = Scatter_boxplot(vals, labels, marker_color, opacity, 2, binWidth, scatter_size, label_rotation);
xlim([.4 5.6])
ylim([0 1000]);

set(gca, 'FontSize', 12);
ylabel('Max:Min Ratio', 'FontSize', 16)
set(gca, 'Position', [0.5703    0.1652    0.3347    0.2860]);
set(gca,'yscale','log');
box on;

%%
disp('24-hour vs 35-min');
[~, p] = kstest2(max_min_ratio_MM_24hour, max_min_ratio_MM_35min)
disp('24-hour vs 1 Op');
[~, p] = kstest2(max_min_ratio_MM_24hour, max_min_ratio_OneOpRepos)
disp('24-hour vs 2 Op');
[~, p] = kstest2(max_min_ratio_MM_24hour, max_min_ratio_TwoOpsRepos)
disp('24-hour vs Repos');
[~, p] = kstest2(max_min_ratio_MM_24hour, max_min_ratio_Reposit)