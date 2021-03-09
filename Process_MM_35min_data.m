%% Process MM 35-min data
% Inputs
process_data_path = 'MM_35min_processed_data\'; % Path to find and save processed data
save_files_flag = 0; % Set to 1 to save processed DiFC files (if processing raw files)
save_data_flag = 0; % Set to 1 to save a summary of the data (used for producing some figures)

%%
% Load file names
load('MM_35min_file_names.mat', 'MM_35min_file_names');

% Sampling frequency (used for counting number of possible blood samples)
fs = 2000;
% Percents of the blood volume to use for most plots
percent_bloodVols = [1 5 10 20];
% Convert to time (of DiFC scan) assuming 50 uL per minute and 2000uL total blood volume
interval_lengths = percent_bloodVols .* 120 ./ 5;

% Percents of blood volume to use for figure 7
percent_bloodVols_fracObs = [1 2 4 20 80];
interval_lengths_fracObs = percent_bloodVols_fracObs .* 120 ./ 5;
% Deviation from scan mean (DFSM) for figure 7 
percents = [25 50];
percents_dec = percents/100; % Convert %DFSM to decimal form

%%
% Create structures that will hold all final information
avg_CTCs_per_min = zeros(18,1);
avg_CTCs_per_interv = zeros(length(interval_lengths), length(MM_35min_file_names));
interval_variance = avg_CTCs_per_interv;
frac_obs_within_X_percent = cell(1, length(percents_dec));
cell_rate_15min = zeros(size(MM_35min_file_names,1), 2);

% Run through each 35-min DiFC data set
for i = 1:length(MM_35min_file_names)
    % Load '_out.mat' file
    fprintf('%s\n', MM_35min_file_names{i});
    load(strcat(save_to_path, MM_35min_file_names{i}, '_out'), 'out_dat');
    avg_CTCs_per_min(i) = length(out_dat.detections) ./ (out_dat.scan_length ./ 60);
    
    % Count the number of CTCs in the first and last 15 minutes (for the
    % max:min ratio calculation later)
    cell_rate_15min(i, 1) = sum(out_dat.detections < 15*60) / 15;
    cell_rate_15min(i, 2) = sum(out_dat.detections > out_dat.scan_length -15*60) / 15;
    
    for j = 1:length(interval_lengths)
        interval_length = interval_lengths(j);
        % Count the number of CTCs in every possible interval
        CTCs_per_interval = Count_CTCs_per_interval(out_dat.detections, interval_length, out_dat.scan_length, fs);
        
        % Calculate the mean number of CTCs per interval (using the scan
        % mean)
        avg_CTCs_per_interv(j,i) = avg_CTCs_per_min(i)* interval_length/60;
        % Calculate the variance of the CTC counts over all intervals
        interval_variance(j,i) = var(CTCs_per_interval);
        avg = avg_CTCs_per_min(i) * interval_length/60;
        
        for m = 1:length(percents_dec)
            percent = percents_dec(m);
            num_intervals = sum((CTCs_per_interval >= avg * (1-percent)) & (CTCs_per_interval <= avg * (1+percent)));
            % Odds of being within X percent DFSM
            frac_obs_within_X_percent{m}(i,j) = num_intervals / length(CTCs_per_interval);
        end
    end
end
% Calculate the max:min ratio
max_min_ratio_MM_35min = max(cell_rate_15min, [], 2) ./ min(cell_rate_15min, [], 2);

%% Save data
if save_data_flag == 1
    save('MM_35min_data', 'avg_CTCs_per_min', 'avg_CTCs_per_interv', 'interval_variance', 'frac_obs_within_X_percent', 'percents', 'max_min_ratio_MM_35min');
end
