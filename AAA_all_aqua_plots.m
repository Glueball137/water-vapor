%Ok, new plots. . .
% Preliminary aquaplanet plots for all PRECT_pntXXX
clear;

% Load the data
load('CESM_aqua_john2.mat');

% Define tag names
tag_names = {'000','075','150','225','300','375','450','525','600','675','750','825','900'};
num_tags = length(tag_names);

% Time setup
[~, ~, timesteps] = size(P);
dt = 30;
dates = datenum('18791231', 'yyyymmdd') + (ceil(dt/2):dt:dt*timesteps);
datemon = datestr(dates, 'mm');

% Months to include
months_to_include = {'01','02','03','04','05','06','07','08','09','10','11','12'};
is_desired_month = ismember(datemon, months_to_include);

% Precompute lon shift
lon_shifted = [lon((length(lon)/2+1):end); lon(1:length(lon)/2)];

% Create figure
figure;
colormap('parula');
set(gcf, 'Position', [100, 100, 1200, 900]); % Larger figure

% Loop through each tag and plot
for i = 1:num_tags
    tag = tag_names{i};
    varname = ['PRECT_pnt' tag];
    
    % Check variable exists
    if evalin('base', ['exist(''' varname ''', ''var'')'])
        data = eval(varname);
        data_filtered = data(:,:,is_desired_month);
        
        % Mean over time
        weighted_avg = mean(data_filtered, 3, 'omitnan');
        
        % Shift Prime Meridian
        weighted_avg_shifted = cat(1, ...
            weighted_avg((size(weighted_avg,1)/2 + 1):end, :), ...
            weighted_avg(1:size(weighted_avg,1)/2, :));

        % Subplot
        subplot(4, 4, i);
        make_figure_pcolor((weighted_avg_shifted), lat, lon_shifted, ...
            [-90 90], [-180 180], linspace(-15, 15, 100), 1);
        clim([-3 1]);
        title(['PRECT\_pnt' tag]);
        xlabel('Lon');
        ylabel('Lat');
    else
        warning(['Variable ' varname ' not found. Skipping.']);
    end
end

sgtitle('Weighted Average of PRECT\_pntXXX Fields');

