%% Plots figure 1
% Inputs for LLC mouse
processed_data_path_LLC = 'LLC_processed_data\'; % Path to find processed data
reprocess_LLC = 0; % Set to 1 to reprocess raw file
raw_data_path_LLC = 'LLC_raw_data\'; % Path to find raw data (needed if reprocess_LLC is set to 1)

% Inputs for MM mouse
processed_data_path_MM = 'MM_35min_processed_data\'; % Path to find processed data
reprocess_MM = 0; % Set to 1 to reprocess raw file
raw_data_path_MM = 'MM_35min_raw_data\'; % Path to find raw data (needed if reprocess_MM is set to 1)
    
%% Tumor size, DiFC image (LLC)
% Tumor size info (input by hand here)
tumor_vol = [138 205 459 709 2185 2814];
tumor_vol_days = [12 13 18 21 25 28];
% Days of DiFC scans
difc_days_LLC = [28 25 18 13 5];
difc_day_labels_LLC = {'28' '25' '18' '13' '5'};

% Y-axis colors for the tumor size/DiFC detections plot
left_color = [0 0 .7]; % Tumor volume
right_color = [1 .4 .4]; % DiFC CTC detections

fig = figure('DefaultAxesFontSize',16);
set(fig,'defaultAxesColorOrder',[left_color; right_color]);

% Collect DiFC data from the files in order
scan_lengths = zeros(1,length(difc_days_LLC));
detection_times = cell(1,length(difc_days_LLC));
avgs = scan_lengths;
for i = 1:length(difc_days_LLC)
    fprintf('Day: %d\n',difc_days_LLC(i));
    data_file = strcat('LLC_Example_Day', difc_day_labels_LLC{i});
    if reprocess_LLC == 1 % Reprocess data
        DiFC_LLC_process_Amber_2020_05_15(raw_data_path_LLC, data_file, 1, processed_data_path_LLC);
    end
    load(strcat(processed_data_path_LLC, data_file, '_out'), 'out_dat');
    avgs(i) = 20 * length(out_dat.detections) / (out_dat.scan_length/60); %Avg cells per mL (if DiFC detects 50uL per min)
    detection_times{i} = out_dat.detections;
    scan_lengths(i) = out_dat.scan_length/60;
end
trial_length = max(scan_lengths);

% Raster plots
subplot(1,2,1);
rasterplot(detection_times, trial_length,difc_day_labels_LLC, 'Time (min)', 'Days after LLC Inoculation');
set(gca, 'linewidth',1.5)

% Plot of Tumor volume and DiFC CTC detections
subplot(1,2,2);
yyaxis left;
plot(tumor_vol_days, tumor_vol, 's-','MarkerFaceColor',left_color, 'MarkerSize', 12, 'LineWidth', 3);
ylabel('Tumor Volume (mm^3)', 'FontSize', 24);
yyaxis right;
plot(fliplr(difc_days_LLC), fliplr(avgs),'o-','MarkerFaceColor',right_color, 'MarkerSize', 10, 'LineWidth', 3);
xlabel('Days after LLC Inoculation', 'FontSize', 24);
ylabel('Estimated CTCs per mL PB', 'FontSize', 24);
xlim([0 40]); % Edit this if there is data past 40 days
set(gca, 'linewidth',1.5)


%% BLI, DiFC, MM Data set
% Bioluminsecence imaging (BLI) info (input by hand here)
bli = [5.56E+02 4.28E+02 1.41E+03 2.63E+04 2.12E+05];
bli_days = [1 8 15 23 29];
% Days of DiFC scans
difc_days_MM = [35 31 28 24 21 17 14 7]; % Batch 2
difc_day_labels_MM = {'35' '31' '28' '24' '21' '17' '14' '7'};

fig = figure('DefaultAxesFontSize',16);
set(fig,'defaultAxesColorOrder',[left_color; right_color]);
fprintf('MM_35min_Example data');
detection_times = cell(1,length(difc_days_MM));
scan_lengths = zeros(1,length(difc_days_MM));
avgs = scan_lengths;
trial_length = 0;
for i = 1:length(difc_days_MM)
    fprintf('Day: %d\n',difc_days_MM(i));
    data_file = strcat('MM_35min_Example_Day', difc_day_labels_MM{i});
    if reprocess_MM == 1 % Reprocess data
        DiFC_process(raw_data_path_MM, data_file, 1, processed_data_path_MM, [75 75], 1, 1, 35 );
    end
    load(strcat(processed_data_path_MM, data_file, '_out'), 'out_dat');
    avgs(i) = 20 * length(out_dat.detections) / (out_dat.scan_length/60);
    detection_times{i} = out_dat.detections;
    scan_lengths(i) = out_dat.scan_length/60;
end
trial_length = max(scan_lengths);

% Raster plots
subplot(1,2,1);
rasterplot(detection_times, trial_length, difc_day_labels_MM, 'Time (min)', 'Days after MM Injection');
set(gca, 'linewidth',1.5)

% Plot of BLI and DiFC CTC detections
subplot(1,2,2);
yyaxis left;
plot(bli_days, bli, 's-','MarkerFaceColor',left_color, 'MarkerSize', 12, 'LineWidth', 3);
ylabel('BLI Signal (counts/sec)', 'FontSize', 24);
yyaxis right;
plot(fliplr(difc_days_MM), fliplr(avgs),'o-','MarkerFaceColor',right_color, 'MarkerSize', 10, 'LineWidth', 3);
xlabel('Days after MM Injection', 'FontSize', 24);
ylabel('Estimated CTCs per mL PB', 'FontSize', 24);
xlim([0 40]); % Edit this if there is data past 40 days
set(gca, 'linewidth',1.5)