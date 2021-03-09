%% Process Phantom data
% Inputs
process_data_path = 'Phantom_processed_data\'; % Path to find and save processed data
process_flag = 0; % Set to 1 to process raw DiFC files
save_files_flag = 0; % Set to 1 to save processed DiFC files (if processing raw files)
save_data_flag = 0; % Set to 1 to save a summary of the data (used for producing some figures)

%%
% Load file names
load('Phantom_file_names.mat', 'Phantom_file_names');

% Sampling frequency (used for counting number of possible blood samples)
fs = 2000;
% Percents of the blood volume to use for most plots
percent_bloodVols = [1 5 10 20];
% Convert to time (of DiFC scan) assuming 50 uL per minute and 2000uL total blood volume
interval_lengths = percent_bloodVols .* 120 ./ 5;

%%
% Create structures that will hold all final information
avg_CTCs_per_min = zeros(length(Phantom_file_names), 1);
avg_CTCs_per_interv = zeros(length(interval_lengths), length(Phantom_file_names));
interval_variance = avg_CTCs_per_interv;

% Run through each phantom DiFC data set
for i = 1:length(Phantom_file_names)
    % Load '_out.mat' file
    fprintf('%s\n', Phantom_file_names{i});
    load(strcat(process_data_path, Phantom_file_names{i}, '_out'), 'out_dat');
    avg_CTCs_per_min(i) = length(out_dat.detections) ./ (out_dat.scan_length ./ 60);
    
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
    end
end

%% Save data
if save_data_flag == 1
    save('Phantom_data', 'avg_CTCs_per_min', 'avg_CTCs_per_interv', 'interval_variance');
end


