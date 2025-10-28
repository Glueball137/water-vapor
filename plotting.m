% Tags
tag_names = {'000','075','150','225','300','375','450','525','600','675','750','825','900'};
x = cellfun(@(x) str2double(x), tag_names);

% Recycling ratios from your first dataset (e.g., weighted avg evap_dist)
ratios_avg = [0.7069, 0.7812, 0.3445, 0.2850, 0.4707, 0.7365, 0.6908, 0.5781, 0.5071, 0.5721, 0.5966, 0.5428, 0.6017];

% Recycling ratios from your second dataset (e.g., F/P mask)
ratios_fp = [0.5019, 0.6603, 0.3760, 0.4059, 0.4800, 0.5403, 0.5538, 0.4756, 0.4937, 0.4907, 0.5063, 0.4912, 0.5003];

% Plot
figure;
hold on;
bar(x - 2, ratios_avg, 3, 'FaceColor', [0 0.4470 0.7410], 'DisplayName', 'Avg Evap Dist');
bar(x + 2, ratios_fp, 3, 'FaceColor', [0.8500 0.3250 0.0980], 'DisplayName', 'F/P Mask');
hold off;

xlabel('PRECT\_pnt Tag (Latitude)');
ylabel('Recycling Ratio');
title('Comparison of Recycling Ratios for PRECT\_pnt000 to PRECT\_pnt900');
xticks(x);
xticklabels(tag_names);
legend('Location', 'best');
grid on;
