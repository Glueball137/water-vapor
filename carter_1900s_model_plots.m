clear;

% Load the data
load('CESM_data_coupled_1900s.mat', 'P', 'lon', 'lat','PRECTdist');

% Check dimensions of the data arrays
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
else
    error('The length of logical indices does not match the data dimensions.');
end

% Calculate weighted averages for the filtered data
weighted_avg_PRECTdist = sum(PRECTdist_filtered .* P_filtered, 3, 'omitnan') ./ ...
    sum((PRECTdist_filtered.*0+1).*P_filtered, 3, 'omitnan');

%Get rid of weird Prime Meridian line
weighted_avg_PRECTdist = cat(1,weighted_avg_PRECTdist((size(weighted_avg_PRECTdist,1)/2+1):end,:),weighted_avg_PRECTdist(1:size(weighted_avg_PRECTdist,1)/2,:));
lon=[lon((length(lon)/2+1):end);lon(1:length(lon)/2)];


% Plot
figure;

% Plot weighted average of d_transport
subplot(1, 1, 1);
make_figure_pcolor(weighted_avg_PRECTdist, lat, lon, [-90 90], [-180 180], linspace(-15, 15, 100), 1);
clim([0 20000]);
xlabel('Longitude Index');
ylabel('Latitude Index');
title('Weighted Average of d_transport (1900s) (JJAS)');