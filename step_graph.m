function [odds25, odds50, odds25P, odds50P, sum_odds, sum_oddsP] = step_graph(detection_times, scan_length, plot_on, plot_points, varargin)
% data_path: The data path where the data file is found (string)
% data_file: Name of the data file (string)
% simulated_data_flag: Set to 1 if the data is simulated (has to do with
%       the naming scheme of simulated data compared to MM or Phantom data
%       If MM or Phantom data, set to 0.
% plot_on: Set to 1 to plot the step graph
% vargin: Can include an extra input to specify the line width of the
%       resulting plot (double)

percent_bloodVols = [1 5 10 20];
fs = 2000;

if length(varargin) >= 1
    line_width = varargin{1};
else
    line_width = 2;
end

time = linspace(0,scan_length, scan_length*fs)';
avg_events = length(detection_times)./(scan_length/60);


line_colors = [ 0 .7 1 ; 0 0 .7; 1 0 0; 0 1 .7]; % 08/07/2019

interval_lengths = percent_bloodVols .* 120 ./ 5;
avgs = zeros(1, length(interval_lengths));
xl2 = avgs;
CTCs_per_interval_all = cell(1, length(interval_lengths));
times = CTCs_per_interval_all;
for i = 1:length(interval_lengths)
    interval_length = interval_lengths(i);
    CTCs_per_interval = Count_CTCs_per_interval(detection_times, interval_length, scan_length, fs);
    CTCs_per_interval_all{i} = CTCs_per_interval;
    times{i} = time(interval_length*fs/2:end-interval_length*fs/2)/60;
    avgs(i) = avg_events * interval_length / 60;
    num_bins = ceil(max(CTCs_per_interval_all{i}))+1;
    xl2(i) = 1.1*(num_bins-1);
end



% Plot
percents = [.01:.01:1]';

% probs = cell(1, length(percents));
% probs_Poiss = probs;
% sum_probs = probs;


probs_temp = [zeros(length(percents),length(interval_lengths))];
probs_Poiss_temp = probs_temp;

odds25 = zeros(1,length(interval_lengths));
odds50 = odds25;
odds25P = odds25;
odds50P = odds25;
sum_odds = odds25;
sum_oddsP = odds25;

if (plot_on > 0) && (plot_points > 0)
    hold on;
    plot([50 50], [0 1], '-', 'LineWidth',2,'Color',[1 1 1]*.5);
    plot([25 25], [0 1], '-', 'LineWidth',2,'Color',[1 1 1] * .5);
    plot([0 100], [1 1], 'k--');
end

for i = 1:length(interval_lengths)
    avg = avgs(i);
    for j = 1:length(percents)
        percent = percents(j);
        % Number of intervals within percent% of mean
        num_intervals = sum((CTCs_per_interval_all{i} >= avg * (1-percent)) & (CTCs_per_interval_all{i} <= avg * (1+percent)));
        % Probability of being within percent% of mean
        probs_temp(j,i) = num_intervals / length(CTCs_per_interval_all{i});
        
        % Poisson estimation (based on eq for CDF of a Poisson)
        a = floor(avg*(1-percent));
        b = floor(avg*(1+percent));
        k = a+1:b;
        % Poisson probability of being within percent% of mean
        probs_Poiss_temp(j,i) = sum(poisspdf(k,avg));
    end
    odds25(i) = probs_temp( percents == .25, i);
    odds50(i) = probs_temp( percents == .5, i);
    odds25P(i) = probs_Poiss_temp( percents == .25, i);
    odds50P(i) = probs_Poiss_temp( percents == .5, i);
    sum_odds(i) = sum(probs_temp(:,i));
    sum_oddsP(i) = sum(probs_Poiss_temp(:,i));
    if plot_on > 0
        hold on;
        plot(percents*100, probs_temp(:,i), 'LineWidth',line_width,'Color', line_colors(i,:));
        plot(percents*100, probs_Poiss_temp(:,i),'--', 'LineWidth',line_width,'Color', line_colors(i,:),'HandleVisibility','off');
        set(gca,'TickDir','in','TickLength',[.02 .02])
    end
end
if plot_on > 0
    if plot_points > 0
        scatter(50*ones(1,length(interval_lengths)), odds50, 100, 'k', 'o');
        scatter(25*ones(1,length(interval_lengths)), odds25, 100, 'k', 'o');
    end
    plot([-2 -1], [.5 .5], 'k--', 'LineWidth', line_width);
    ylim([0 1.1]);
    xlim([0 100]);
    box on;
end