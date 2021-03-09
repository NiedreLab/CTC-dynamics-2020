%% Process MM 24-hour data
% For each set of data in this group, there are 4 DiFC scans.
% Inputs
processed_data_path = 'MM_24hour_processed_data\'; % Path to find and save processed data
save_files_flag = 0; % Set to 1 to save processed DiFC files (if processing raw files)
save_data_flag = 0; % Set to 1 to save a summary of the data (used for producing some figures)

%%
% Load file names
load('MM_24hour_file_names.mat', 'MM_24hour_file_names');

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

% Percents of blood volume to use for averaging multiple blood
% samples/intervals
percent_bloodVols_twoSamples = [1];
interval_lengths_twoSamples = percent_bloodVols_twoSamples .* 120 ./ 5;
percent_bloodVols_fourSamples = [1 20];
interval_lengths_fourSamples = percent_bloodVols_fourSamples .* 120 ./ 5;

%%
% Create structures that will hold all final information
avg_CTCs_per_min = zeros(size(MM_24hour_file_names, 1), size(MM_24hour_file_names, 2));
scan_lengths = avg_CTCs_per_min;
avg_CTCs_per_interv = zeros(length(interval_lengths), size(MM_24hour_file_names, 1));
interval_variance = avg_CTCs_per_interv;
frac_obs_1_2_4_20_80 = cell(1, length(percents));
frac_obs_two_samples_1 = cell(1, length(percents));
frac_obs_four_samples_1_20 = cell(1, length(percents));

% Run through each 24-hour set
for i = 1:size(MM_24hour_file_names, 1)
    fprintf('%s\n', MM_24hour_file_names{i,1}(1:end-2));
    
    % Load each of the 4 processed DiFC files
    fprintf('\tLoad processed data and calculate detection rate per minute\n');
    for j = 1:size(MM_24hour_file_names, 2)
        % Load '_out.mat' file
        load(strcat(processed_data_path, MM_24hour_file_names{i,j}, '_out'), 'out_dat');
        avg_CTCs_per_min(i,j) = length(out_dat.detections) / (out_dat.scan_length / 60);
        scan_lengths(i,j) = out_dat.scan_length;
    end
    
    % Count the number of CTCs in each possible interval (of each size) and
    % calculate the variance of that number
    % 1%, 2%, 4%, 8% intervals
    fprintf('\tAvg detection rate and interval variance\n');
    for j = 1:length(interval_lengths)
        CTCs_per_interval = [];
        total_num_CTCs = 0;
        total_length_time = 0;
        interval_length = interval_lengths(j);
        % Compile the information for all 4 scans per 24-hour set
        for n = 1:size(MM_24hour_file_names, 2)
            data_file = MM_24hour_file_names{i, n};
            load(strcat(processed_data_path, data_file, '_out'), 'out_dat');
            CTCs_per_interval_tmp = Count_CTCs_per_interval(out_dat.detections, interval_length, out_dat.scan_length, fs);
            CTCs_per_interval = [CTCs_per_interval; CTCs_per_interval_tmp];
            total_num_CTCs = total_num_CTCs + length(out_dat.detections);
            total_length_time = total_length_time + out_dat.scan_length;
        end
        avg_CTCs_per_interv(j, i) = (total_num_CTCs / total_length_time) * interval_length;
        interval_variance(j, i) = var(CTCs_per_interval);
    end
    
    % Calculate the fraction of intervals/observations that are within
    % 'percents'% of the scan mean detection rate (<= 25% and 50% DFSM)
    % 1%, 2%, 4%, 20%, 80% intervals
    fprintf('\tFraction of observations\n');
    for j = 1:length(interval_lengths_fracObs)
        CTCs_per_interval = [];
        num_cells = 0;
        scan_length = 0;
        interval_length = interval_lengths_fracObs(j);
        % Compile the information for all 4 scans per 24-hour set
        for n = 1:size(MM_24hour_file_names, 2)
            data_file = MM_24hour_file_names{i, n};
            load(strcat(processed_data_path, data_file, '_out'), 'out_dat');
            CTCs_per_interval_tmp = Count_CTCs_per_interval(out_dat.detections, interval_length, out_dat.scan_length, fs);
            CTCs_per_interval = [CTCs_per_interval; CTCs_per_interval_tmp];
            num_cells = num_cells + length(out_dat.detections);
            scan_length = scan_length + out_dat.scan_length;
        end
        % Detection rate accross the whole scan (mean CTC rate)
        avg = (num_cells / (scan_length/60)) * interval_length/60;
        for m = 1:length(percents_dec)
            percent = percents_dec(m);
            num_intervals = sum((CTCs_per_interval >= avg * (1-percent)) & (CTCs_per_interval <= avg * (1+percent)));
            % Odds of being within X DFSM
            frac_obs_1_2_4_20_80{m}(i,j) = num_intervals / length(CTCs_per_interval);
        end
    end
    
    % Average several intervals/observations/blood samples and calculate
    % the fraction of averaged intervals that are within 'percents'% of the
    % scan mean detection rate (<= 25% and 50% DFSM)
    % two 1%, four 1%, four 20% intervals
    fprintf('\tFraction of observations of two averaged samples\n');
    num_samples = 2;
    for j = 1:length(interval_lengths_twoSamples)
        CTCs_per_interval = cell(1, size(MM_24hour_file_names,2));
        num_cells = 0;
        scan_length = 0;
        interval_length = interval_lengths_twoSamples(j);
        % Compile the information for all 4 scans per 24-hour set
        for n = 1:size(MM_24hour_file_names, 2)
            data_file = MM_24hour_file_names{i, n};
            file_name = strcat(processed_data_path, data_file, '_out');
            load(file_name, 'out_dat');
            CTCs_per_interval{n} = Count_CTCs_per_interval(out_dat.detections, interval_length, out_dat.scan_length, fs);
            num_cells = num_cells + length(out_dat.detections);
            scan_length = scan_length + (out_dat.scan_length /60);
            if n == 1
                num_intervals = length(CTCs_per_interval{n});
            elseif length(CTCs_per_interval{n}) < num_intervals
                num_intervals = length(CTCs_per_interval{n});
            end
        end
        % Convert 24-hour CTC detection rate from CTCs/min to CTCs/interval
        avg = (num_cells / scan_length) * interval_length/60;
        
        length_inds = num_intervals - mod(num_intervals, 6);
        inds = randi([1 num_intervals], num_samples, length_inds);
        
        samples_rates = zeros(num_samples, length_inds);
        possible_sample_combos = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4];
        for n = 1:size(possible_sample_combos, 1)
            inds_per_sample = ((length_inds/6)*(n-1)+1) : (round(length_inds/6)*n);
            samples_rates(1, inds_per_sample) = CTCs_per_interval{possible_sample_combos(n,1)}(inds(1, inds_per_sample))';
            samples_rates(2, inds_per_sample) = CTCs_per_interval{possible_sample_combos(n, 2)}(inds(2, inds_per_sample))';
        end
        % Average the sets of 2 samples
        avgeraged_sub_samples = mean(samples_rates);
        for m = 1:length(percents_dec)
            num_windows = sum((avgeraged_sub_samples >= avg * (1-percents_dec(m))) & (avgeraged_sub_samples <= avg * (1+percents_dec(m))));
            frac_obs_two_samples_1{m}(i,j) = num_windows / length(avgeraged_sub_samples);
        end
    end
    
    fprintf('\tFraction of observations of four averaged samples\n');
    num_samples = 4;
    for j = 1:length(interval_lengths_fourSamples)
        CTCs_per_interval = cell(1, size(MM_24hour_file_names,2));
        num_cells = 0;
        scan_length = 0;
        interval_length = interval_lengths_fourSamples(j);
        % Compile the information for all 4 scans per 24-hour set
        for n = 1:size(MM_24hour_file_names, 2)
            data_file = MM_24hour_file_names{i, n};
            file_name = strcat(processed_data_path, data_file, '_out');
            load(file_name, 'out_dat');
            CTCs_per_interval{n} = Count_CTCs_per_interval(out_dat.detections, interval_length, out_dat.scan_length, fs);
            num_cells = num_cells + length(out_dat.detections);
            scan_length = scan_length + (out_dat.scan_length / 60);
            if n == 1
                num_intervals = length(CTCs_per_interval{n});
            elseif length(CTCs_per_interval{n}) < num_intervals
                num_intervals = length(CTCs_per_interval{n});
            end
        end
        % Convert 24-hour CTC detection rate from CTCs/min to CTCs/interval
        avg = (num_cells / scan_length) * interval_length/60;
        
        % Identify many sets of 4 intervals (randomly chosen from all
        % possible intervals accross the 24-hours)
        inds = randi([1 num_intervals], num_samples, num_intervals);
        
        samples_rates = zeros(num_samples, num_intervals);
        for n = 1:num_samples
            samples_rates(n, :) = CTCs_per_interval{n}(inds(n, :))';
        end
        % Average the sets of 4 samples
        avg_sub_samples = mean(samples_rates);
        for m = 1:length(percents_dec)
            num_windows = sum((avg_sub_samples >= avg * (1-percents_dec(m))) & (avg_sub_samples <= avg * (1+percents_dec(m))));
            frac_obs_four_samples_1_20{m}(i,j) = num_windows / length(avg_sub_samples);
        end
    end
end

% Take the max and mim detection rates from the 4 scans
avgs_tmp = avg_CTCs_per_min;
for i = 1:size(avgs_tmp, 1)
    avgs_row = avgs_tmp(i,:);
    index_0 = find(avgs_row == 0);
    if ~isempty(index_0)
        avgs_other = avgs_row;
        avgs_other(index_0) = [];
        avgs_row(index_0) = min(avgs_other);
        avgs_tmp(i,:) = avgs_row;
    end
end
% Calculate the max:min ratio
max_min_ratio_MM_24hour = max(avgs_tmp, [], 2) ./ min(avgs_tmp, [], 2);


%% Save data
if save_data_flag == 1
    save('MM_24hour_data', 'avg_CTCs_per_min', 'max_min_ratio_MM_24hour', 'avg_CTCs_per_interv', 'interval_variance',...
        'frac_obs_1_2_4_20_80', 'frac_obs_two_samples_1', 'frac_obs_four_samples_1_20', 'percents');
end
