%% Process LLC data
% Use this script to process the LLC data, calculate the moving
% averages/blood sample counts, and/or obtain a summary of the data
%% Process LLC data
% Inputs
processed_data_path = 'LLC_processed_data\'; % Path to find and save processed data
save_files_flag = 0; % Set to 1 to save processed DiFC files (if processing raw files)
save_data_flag = 0; % Set to 1 to save a summary of the data (used for producing some figures)

% Load file names
load('LLC_file_names.mat', 'LLC_file_names');

%%
% Sampling frequency (used for counting number of possible blood samples)
fs = 2000;
% Percents of the blood volume to use for most plots
percent_bloodVols = [1 5 10 20];
% Convert to time (of DiFC scan) assuming 50 uL per minute and 2000uL total blood volume
interval_lengths = percent_bloodVols .* 120 ./ 5;

%% Calculations
% Initializing variables
scan_lengths = zeros(length(LLC_file_names), 1);
avg_CTCs = scan_lengths;
num_CTCs = scan_lengths;
intervals_prob_1CTC = zeros(length(LLC_file_names), length(interval_lengths));
for i = 1:length(LLC_file_names)
    file_name = LLC_file_names{i};
    fprintf('%s\n', file_name);
    
    % Load '_out.mat' file
    output_file_name = strcat(processed_data_path, LLC_file_names{i}, '_out');
    load(output_file_name, 'out_dat');
    
    scan_lengths(i) = out_dat.scan_length/60;
    % Identify the CTC detections
    % (For now we take the channel with the most detections)
    detections = out_dat.detections;
    avg_CTCs(i) = length(detections) / (out_dat.scan_length / 60); % Rate of CTC detections per minute
    num_CTCs(i) = length(detections); % Total number of CTCs
    
    % Identify odds of obtaining at least one peak (CTC) in a blood sample
    for j = 1:length(interval_lengths)
        interval_length = interval_lengths(j);
        interval_string = strrep(num2str(interval_length), '.', '_');
        fprintf('\t%s\n', interval_string);
        % Count the number of CTCs in every possible interval
        CTCs_per_interval = Count_CTCs_per_interval(detections, interval_length, out_dat.scan_length, fs);
        % Odds of obtaining at least one peak (CTC) in a blood sample
        intervals_prob_1CTC(i, j) = sum(CTCs_per_interval > 0) / length(CTCs_per_interval);
    end
end

%% Save data
if save_data_flag == 1 % Save summary of data
    save(strcat('LLC_data'), 'intervals_prob_1CTC', 'num_CTCs', 'scan_lengths', 'avg_CTCs');
end
