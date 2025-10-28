clear; load CESM_aqua_john.mat

size_P = size(P); % Assuming the dimensions are [lat, lon, days]
timesteps = size_P(3);
dt=30;

% Generate dates and month strings
dates = datenum('18791231', 'yyyymmdd') + (ceil(dt/2):dt:dt*timesteps); % Adjust indexing
datemon = datestr(dates, 'mm');

% Check sizes
disp(['Size of P: ', num2str(size_P)]);
disp(['Number of timesteps: ', num2str(timesteps)]);
disp(['Length of datemon: ', num2str(length(datemon))]);

% Define months to include
months_to_include = {'01','02','03','04','05','06','07','08','09','10','11','12'};
%months_to_include = {'12','01,'02','03'};
%months_to_include = {'06','07,'08','09'};


% Create logical index for the desired months
is_desired_month = ismember(datemon, months_to_include);

% Check logical indices
disp(['Length of is_desired_month: ', num2str(length(is_desired_month))]);
disp(['Number of true values: ', num2str(sum(is_desired_month))]);

% Ensure logical indexing is correct
% Ensure logical indexing is correct
if length(is_desired_month) == timesteps
    % Filter data for the desired months
    P_filtered = P(:,:,is_desired_month);
    PRECTdist_filtered = PRECTdist(:,:,is_desired_month);
    PRECT_pnt000_filtered = PRECT_pnt000(:,:,is_desired_month);
else
    error('The length of logical indices does not match the data dimensions.');
end

% Calculate weighted averages for the filtered data
weighted_avg_PRECT_pnt000 = mean(PRECT_pnt000_filtered,3);


% Tag we want to inspect
tag = '000';
varname = ['PRECT_pnt' tag];
data = eval(varname);
data_filtered = data(:,:,is_desired_month);

% Compute weighted average
weighted_avg = mean(data_filtered,3);
% Get tag latitude (e.g. 600 → -60)
source_lat = -str2double(tag);
source_lon = 0;

% Recompute great circle distances from correct origin
d = greatCircleDistance(source_lat, source_lon, lat2, lon2);

% Compute evaporation-weighted distance
evap_dist = sum(sum(d .* weighted_avg .* cosd(lat2))) / sum(sum(weighted_avg .* cosd(lat2)));

% Create mask
mask = double(d <= 3000);%evap_dist);  % Convert logical to double for plotting (0 or 1)

% Optional: move Prime Meridian discontinuity if needed
mask_plot = cat(1, mask((end/2 + 1):end,:), mask(1:end/2,:));
lon_plot = [lon((end/2 + 1):end); lon(1:end/2)];

% Plot the mask using your plotting function
figure; make_figure_pcolor(mask_plot, lat, lon_plot, [-90 90], [-180 180], linspace(0, 1, 3), 1);
clim([0 1]);
xlabel('Longitude');
ylabel('Latitude');
title(['Mask for PRECT\_pnt' tag ' (d ≤ evap\_dist)']);