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

% Meshgrid of original lat/lon
[lat2, lon2] = meshgrid(lat, lon);  % (lon, lat) shape

% Precompute shifted longitude and how to reorder
lon_half = length(lon) / 2;
lon_shifted = [lon(lon_half+1:end); lon(1:lon_half)];
[~, lon_order] = sort([lon(lon_half+1:end); lon(1:lon_half)]);  % for shifting arrays

% Earth radius in km
R_earth = 6371;

% Create figure
figure;
colormap('parula');
set(gcf, 'Position', [100, 100, 1200, 900]); % Larger figure

for i = 1:num_tags
    tag = tag_names{i};
    varname = ['PRECT_pnt' tag];
    
    if exist(varname, 'var')
        data = eval(varname);
        data_filtered = data(:,:,is_desired_month);
        
        % Mean over time
        weighted_avg = mean(data_filtered, 3, 'omitnan');
        
        % Shift data along longitude (Prime Meridian at center)
        weighted_avg_shifted = cat(1, ...
            weighted_avg((size(weighted_avg,1)/2 + 1):end, :), ...
            weighted_avg(1:size(weighted_avg,1)/2, :));

        % Subplot
        subplot(4, 4, i);
        make_figure_pcolor(weighted_avg_shifted, lat, lon_shifted, ...
            [-90 90], [-180 180], linspace(-15, 15, 100), 1);
        clim([0 0.009]);
        title(['PRECT\_pnt' tag]);
        xlabel('Longitude');
        ylabel('Latitude');

        hold on;

        % Compute source location (corrected)
        source_lat = -str2double(tag)/10;
        source_lon = 0;
        fprintf('Source latitude for PRECT_pnt%s: %.1f\n', tag, source_lat);

        % Generate geodesic circle using reckon
        radius_km = 1000;
        az = linspace(0, 360, 200);
        [circle_lat, circle_lon] = reckon(source_lat, source_lon, ...
            radius_km / R_earth, az, 'degrees');

        % Wrap longitude and apply same shift
        circle_lon_wrapped = mod(circle_lon + 180, 360) - 180;
        [~, lon_idx_circle] = min(abs(lon - 0)); % index of lon=0 in original lon
        if lon_idx_circle <= lon_half
            circle_lon_shifted = mod(circle_lon + 180, 360) - 180;
        else
            circle_lon_shifted = mod(circle_lon + 180, 360) - 180;
        end

        % Plot circle on shifted map
        plot(circle_lon_shifted, circle_lat, 'k-', 'LineWidth', 1.5);

        % Shift source point longitude (0 stays at center after shift)
        plot(0, source_lat, 'ro', 'MarkerSize', 6, 'LineWidth', 1.5);

        hold off;
    else
        warning(['Variable ' varname ' not found. Skipping.']);
    end
end

sgtitle('PRECT\_pntXXX Footprints with Accurate 1000 km Great Circles (Shifted)');
