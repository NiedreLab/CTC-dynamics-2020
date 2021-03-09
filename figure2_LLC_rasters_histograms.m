%% Plots figure 2, raster plots and respective histograms
% Input indices for the data to be plotted (3 files out of the 102 LLC files)
inds = [14 1 61]; %Indices of files to be plotted

% Path to find data files
data_path = 'LLC_processed_data\'; % Path to find processed data

%%
% Load file names and mean number of CTCs per minute
load('LLC_data.mat', 'avg_CTCs')
load('LLC_file_names.mat', 'LLC_file_names');

% Percents of the blood volume to use
percent_bloodVols = [1 5 10 20];
% Convert to time (of DiFC scan) assuming 50 uL per minute and 2000uL total blood volume
interval_lengths = percent_bloodVols .* 120 ./ 5;

line_colors = [ 0 .7 1 ; 0 0 .7; 1 0 0; 0 1 .7]; % Colors for each blood sample volume plot
titles = {'1% PBV (24 s)', '5% PBV (2 min)', '10% PBV (4 min)', '20% PBV (8 min)'}; % Titles of histogram columns
fs = 2000; % Sampling frequency of DiFC data

%%
figure('DefaultAxesFontSize',15);
for i = 1:length(inds)
    % Load '_out.mat' file
    file_name = strcat(data_path, LLC_file_names{inds(i)}, '_out');
    fprintf('%s\n', LLC_file_names{inds(i)});
    load(file_name, 'out_dat');
    % Plotting histograms first for no particular reason
    for j = 1:length(interval_lengths)
        subplot(length(inds), 6, (i-1)*6+j+2);
        % Load files containing "blood sample" info
        interval_length = interval_lengths(j);
        CTCs_per_interval = Count_CTCs_per_interval(out_dat.detections, interval_length, out_dat.scan_length, fs);
        % Plot histogram
        color_edge = [0 0 0];
        histogram(CTCs_per_interval,'Normalization','probability','BinWidth',1,'FaceColor',line_colors(j,:),'EdgeColor', color_edge, 'BinMethod', 'integers');
        ylim([0 1]);
        % Various labels
        if j == 1
            if i == 1
                text(0,0, 'Frequency', 'Fontsize', 14, 'Rotation', 90, 'Fontweight', 'bold');
            end
            if i == length(inds)
                xlabel('Number of CTCs Counted in Time Interval');
            end
        end
        if i == 1
            title(titles{j}, 'FontSize', 13);
        end
    end
    
    % Plot raster plot of CTCs
    subplot(length(inds), 3, i*3-2);
    hold on;
    plot([out_dat.detections/60 out_dat.detections/60]',[0 1]','k-');
    ylim([-0.13 1.13]);
    xlim([0 out_dat.scan_length/60 + 0.01]);
    set(gca,'ytick',[],'yticklabel',[])
    box on;
    % The next 5 lines assumed the last data set has the most detections
    % and thus the average value should be rounded differently. Change this
    % if desired.
    if i <length(inds)
        text(0,0, sprintf('%.2f CTCs/min\n%.2f CTCs/mL', avg_CTCs(inds(i)), round(avg_CTCs(inds(i))*20,3,'significant')), 'FontSize', 14, 'FontWeight','bold','Rotation',0);
    else
        text(0,0, sprintf('%.2f CTCs/min\n%.0f CTCs/mL', avg_CTCs(inds(i)), round(avg_CTCs(inds(i))*20,3,'significant')), 'FontSize', 14, 'FontWeight','bold','Rotation',0);
    end
    if i == 1
        title('CTC Detections');
        % Plot lines representing the length of each blood sample/time interval
        for j = 1:length(interval_lengths)
            interval_length = interval_lengths(j);
            plot([0 interval_length/60] , .2*(5-j)* [1 1], 'LineWidth', 2.5, 'Color', line_colors(j,:));
        end
    elseif i == length(inds)
        xlabel('Time (min)');
    end
end
