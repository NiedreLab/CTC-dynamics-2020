%% Process reposition data
% Inputs
processed_data_path_1op = 'One_Op_with_Repos_processed_data\'; % Path to find and save processed data (one operator w/reposition)
processed_data_path_2ops = 'Two_Ops_with_Repos_processed_data\'; % Path to find and save processed data (two operators w/reposition)

save_data_flag = 0; % Set to 1 to save a summary of the data (used for producing some figures)
save_files_flag = 0; % Set to 1 to save processed DiFC files (if processing raw files)

%% Variability of One operator with reposition
% Load file names
load('One_Op_with_Repos_file_names.mat', 'One_Op_with_Repos_file_names');

% Create structures that will hold all final information
One_Op_CTC_rates = zeros(size(One_Op_with_Repos_file_names, 1), 2);
scan_lengths = zeros(size(One_Op_with_Repos_file_names,1), 2);
for i = 1:size(One_Op_with_Repos_file_names, 1)
    for j = 1:size(One_Op_with_Repos_file_names, 2)
        % Load '_out.mat' file
        load(strcat(processed_data_path_1op, One_Op_with_Repos_file_names{i, j}, '_out'), 'out_dat');
        % Calculate the detection rate (CTCs/min)
        One_Op_CTC_rates(i, j) = length(out_dat.detections) / (out_dat.scan_length / 60);
        scan_lengths(i, j) = out_dat.scan_length / 60;
    end
end
% Calculate the max:min ratio
max_min_ratio_OneOpRepos = max(One_Op_CTC_rates, [], 2) ./ min(One_Op_CTC_rates, [], 2);

%% Variability of Two operators with reposition
% Load file names
load('Two_Ops_with_Repos_file_names.mat', 'Two_Ops_with_Repos_file_names');

% Create structures that will hold all final information
Two_Ops_CTC_rates = zeros(size(Two_Ops_with_Repos_file_names, 1), 2);
scan_lengths = zeros(size(Two_Ops_with_Repos_file_names,1), 2);
for i = 1:size(Two_Ops_with_Repos_file_names, 1)
    for j = 1:size(Two_Ops_with_Repos_file_names, 2)
        % Load '_out.mat' file
        load(strcat(processed_data_path_2ops, Two_Ops_with_Repos_file_names{i, j}, '_out'), 'out_dat');
        % Calculate the detection rate (CTCs/min)
        Two_Ops_CTC_rates(i, j) = length(out_dat.detections) / (out_dat.scan_length / 60);
        scan_lengths(i, j) = out_dat.scan_length / 60;
    end
end
% Calculate the max:min ratio
max_min_ratio_TwoOpsRepos = max(Two_Ops_CTC_rates, [], 2) ./ min(Two_Ops_CTC_rates, [], 2);

%% Save data
if save_data_flag == 1
    save('Max_min_ratios_Repos', 'max_min_ratio_OneOpRepos', 'max_min_ratio_TwoOpsRepos');
end

