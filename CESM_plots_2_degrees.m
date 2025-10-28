%Seasonal Decomposition of CESM
% Load the data
load('CESM_data_john_2deg.mat', 'P', 'PRECT_d18Oec', 'PRECTdist', 'PRECTlat','lat','lon','QFLX','PRECTocn');
%load('CESM_59vars_7day.mat','lat2','lon2')
% Check dimensions of the data arrays
size_P = size(P); % Assuming the dimensions are [lat, lon, days]
num_days = size_P(3);

% Generate dates and month strings
dates = datenum('19791231', 'yyyymmdd') + (0:num_days-1); % Adjust indexing
datemon = datestr(dates, 'mm');

% Check sizes
disp(['Size of P: ', num2str(size_P)]);
disp(['Number of days: ', num2str(num_days)]);
disp(['Length of datemon: ', num2str(length(datemon))]);

% Define months to include
months_to_include = {'01','02','03','12'};


% Create logical index for the desired months
is_desired_month = ismember(datemon, months_to_include);

% Check logical indices
disp(['Length of is_desired_month: ', num2str(length(is_desired_month))]);
disp(['Number of true values: ', num2str(sum(is_desired_month))]);

% Ensure logical indexing is correct
if length(is_desired_month) == num_days
    % Filter data for the desired months
    P_filtered = P(:,:,is_desired_month);
    QFLX_filtered = QFLX(:,:,is_desired_month);
    dO18ec_filtered = PRECT_d18Oec(:,:,is_desired_month);
    PRECTdist_filtered = PRECTdist(:,:,is_desired_month);
    PRECTocn_filtered =PRECTocn(:,:,is_desired_month);
    PRECTlat_filtered = PRECTlat(:,:,is_desired_month);
else
    error('The length of logical indices does not match the data dimensions.');
end

% Calculate weighted averages for the filtered data
weighted_avg_dO18ec_scaled = sum(dO18ec_filtered .* P_filtered, 3, 'omitnan') ./ sum(P_filtered, 3, 'omitnan');
weighted_avg_PRECTlat = sum(PRECTlat_filtered.*P_filtered, 3, 'omitnan') ./ sum(P_filtered, 3, 'omitnan');
weighted_avg_PRECTocn = sum(PRECTocn_filtered .* P_filtered, 3, 'omitnan') ./ sum(P_filtered, 3, 'omitnan');
weighted_avg_PRECTdist = sum(PRECTdist_filtered .* P_filtered, 3, 'omitnan')./ sum(P_filtered, 3, 'omitnan');

%Get rid of weird Prime Meridian line
weighted_avg_dO18ec_scaled = cat(1,weighted_avg_dO18ec_scaled((size(weighted_avg_dO18ec_scaled,1)/2+1):end,:),weighted_avg_dO18ec_scaled(1:size(weighted_avg_dO18ec_scaled,1)/2,:));
weighted_avg_PRECTocn = cat(1,weighted_avg_PRECTocn((size(weighted_avg_PRECTocn,1)/2+1):end,:),weighted_avg_PRECTocn(1:size(weighted_avg_PRECTocn,1)/2,:));
weighted_avg_PRECTdist = cat(1,weighted_avg_PRECTdist((size(weighted_avg_PRECTdist,1)/2+1):end,:),weighted_avg_PRECTdist(1:size(weighted_avg_PRECTdist,1)/2,:));
weighted_avg_PRECTlat = cat(1,weighted_avg_PRECTlat((size(weighted_avg_PRECTlat,1)/2+1):end,:),weighted_avg_PRECTlat(1:size(weighted_avg_PRECTlat,1)/2,:));
lon=[lon((length(lon)/2+1):end);lon(1:length(lon)/2)];


% Plot
figure;
%Plot weighted average of 10*tau_bar
subplot(4, 1, 1);
make_figure_pcolor(weighted_avg_dO18ec_scaled, lat, lon, [-90 90], [-180 180], linspace(-15, 15, 100), 1);
clim([-40 0]);
xlabel('Longitude Index');
ylabel('Latitude Index');
title('Weighted Average of tau bar Scaled (Annual)');

% Plot weighted average of d_transport
subplot(4, 1, 2);
make_figure_pcolor(weighted_avg_PRECTocn, lat, lon, [-90 90], [0 360], linspace(0, 100, 100), 1);
%clim([0 100]);
xlabel('Longitude Index');
ylabel('Latitude Index');
title('P Weighted Average of PRECTocn (Annual)');

subplot(4, 1, 3);
make_figure_pcolor(10^3*weighted_avg_PRECTdist, lat, lon, [-90 90], [-180 180], linspace(-15, 15, 100), 1);
clim([0 30000000]);
xlabel('Longitude Index');
ylabel('Latitude Index');
title('weighted Average of PRECTdist (DJFM)');

%Plot weighted average of evap_lat
subplot(4, 1, 4);
make_figure_pcolor(weighted_avg_PRECTlat, lat, lon, [-90 90], [-180 180], linspace(-60, 60, 100), 1);
xlabel('Longitude');
ylabel('Latitude');
title('Weighted Average of evaporation latitude (Annual)');
