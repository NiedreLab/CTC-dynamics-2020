%% Plots figure 2, the probability of obtaining one or more CTCs in a blood sample
% No inputs needed

%%
% Load data
load('LLC_data', 'avg_CTCs', 'intervals_prob_1CTC')

% Percents of the blood volume to use
percent_bloodVols = [1 5 10 20]; % The subplot organization assumes only 4 values here

colors = [ 0 .7 1 ; 0 0 .7; 1 0 0; 0 1 .7]; % Colors of scatter points for each blood sample volume
opacity = 0.3; % Opacity of scatter points
time_labels = {'24 s', '2 min', '4 min', '8 min'};
pos1 = [0.1300    0.2189    0.1566    0.6489]; % Position of subfigures

%%
figure('DefaultAxesFontSize', 15);
for i = 1:4
    subplot(1,4, i);
    hold on;
    % Plot probability of detecting at least one CTC in a sample
    % *20 => x-axis is in CTCs per mL of blood (assuming DiFC scans 50uL/min)
    scatter(avg_CTCs*20, intervals_prob_1CTC(:,i), 200, 'filled','MarkerFaceColor', colors(i,:),'MarkerFaceAlpha', opacity);
    if i == 1
        ylabel(sprintf('Fraction of Samples\nwith 1 or More CTCs'));
    elseif i == 3
        xlabel('Number of CTCs per mL PB');
    end
    title(sprintf('%d%% PBV (%s)', percent_bloodVols(i), time_labels{i}));
    ylim([-0.01 1.1]);
    box on;
    set(gca,'linewidth',1)
    blah = get(gca, 'Position');
    set(gca, 'Position', blah + [0 0.03 0 0]);
    xl = xlim;
    xl = [-1 xl(2)+1];
    plot(xl, [1 1], 'k--');
    % Place second x-axis with units in CTCs/hr
    if i == 1
        set(gca, 'Position', pos1);
        b = axes('Position', [pos1(1) pos1(2)-0.0855 pos1(3) 1e-12]);
        set(b,'linewidth',1)
        xlim(xl/20);
        xlabel('CTCs/min');
    else
        b = get(gca, 'Position');
        b(2) = pos1(2); b(4) = pos1(4);
        set(gca, 'Position', b);
    end
end