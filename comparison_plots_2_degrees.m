%Comparison between CESM and Attenuation model

clear;

% Load data
load('CESM_59vars_30day_2deg.mat', 'P', 'tau_bar', 'd_transport', 'evap_lat', 'lon2', 'lat2','oceanfrac');
P2=P;
%Check dimensions of the data arrays
size_P2 = size(P2); % The dimensions are [lat, lon, days]
timesteps = size_P2(3);
dt=3;

% Generate dates and month strings
dates2 = datenum('19791231', 'yyyymmdd') + (ceil(dt/2):dt:dt*timesteps); % Adjust indexing
datemon2 = datestr(dates2, 'mm');

% Check sizes
disp(['Size of P: ', num2str(size_P2)]);
disp(['Number of timesteps: ', num2str(timesteps)]);
disp(['Length of datemon: ', num2str(length(datemon2))]);

% Define months to include
months_to_include = {'01','02','03','04','05','06','07','08','09','10','11','12'};
%months_to_include = {'01','02','03','12'};
%months_to_include = {'06','07','08','09'};


% Create logical index for the desired months
is_desired_month = ismember(datemon2, months_to_include);

% Check logical indices
disp(['Length of is_desired_month: ', num2str(length(is_desired_month))]);
disp(['Number of true values: ', num2str(sum(is_desired_month))]);

% Ensure logical indexing is correct
if length(is_desired_month) == timesteps
    % Filter data for the desired months
    P2_filtered = P(:,:,is_desired_month);
    tau_bar_filtered = tau_bar(:,:,is_desired_month);
    d_transport_filtered = d_transport(:,:,is_desired_month);
    evap_lat_filtered = evap_lat(:,:,is_desired_month);
    ocean_frac_filtered = oceanfrac(:,:,is_desired_month);
else
    error('The length of logical indices does not match the data dimensions.');
end


% Calculate weighted averages for the filtered data
weighted_avg_tau_bar_scaled = -10 .* sum(tau_bar_filtered .* P2_filtered, 3, 'omitnan') ./ ...
    sum((tau_bar_filtered.*0+1).*P2_filtered, 3, 'omitnan');
weighted_avg_d_transport = sum(d_transport_filtered .* P2_filtered, 3, 'omitnan') ./ ...
    sum((d_transport_filtered.*0+1).*P2_filtered, 3, 'omitnan');
weighted_avg_evap_lat = sum(evap_lat_filtered .* P2_filtered, 3, 'omitnan')./ ...
    sum((evap_lat_filtered.*0+1).*P2_filtered, 3, 'omitnan');
weighted_avg_ocean_frac = sum(ocean_frac_filtered .* P2_filtered, 3, 'omitnan')./ ...
    sum((ocean_frac_filtered.*0+1) .* P2_filtered, 3, 'omitnan');



%load CESM data
load('CESM_data_john_2deg.mat', 'P', 'PRECT_d18Oec', 'PRECTdist', 'PRECTlat','lat','lon','QFLX','PRECTocn');

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
months_to_include = {'01','02','03','04','05','06','07','08','09','10','11','12'};
%months_to_include = {'01','02','03','12'};
%months_to_include = {'06','07','08','09'};
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


weighted_avg_dO18ec_scaled = sum(dO18ec_filtered .* P_filtered, 3, 'omitnan') ./ ...
    sum((dO18ec_filtered.*0+1) .* P_filtered, 3, 'omitnan');
weighted_avg_PRECTlat = sum(PRECTlat_filtered.*P_filtered, 3, 'omitnan') ./ ...
    sum((PRECTlat_filtered.*0+1) .* P_filtered, 3, 'omitnan');
weighted_avg_PRECTocn = sum(PRECTocn_filtered .* P_filtered, 3, 'omitnan') ./ ...
    sum((PRECTocn_filtered.*0+1) .* P_filtered, 3, 'omitnan');
weighted_avg_PRECTdist = sum(PRECTdist_filtered .* P_filtered, 3, 'omitnan')./ ...
    sum((PRECTdist_filtered.*0+1) .* P_filtered, 3, 'omitnan');


%Get rid of weird Prime Meridian line (attn model vars)
weighted_avg_tau_bar_scaled = cat(1,weighted_avg_tau_bar_scaled((size(weighted_avg_tau_bar_scaled,1)/2+1):end,:),weighted_avg_tau_bar_scaled(1:size(weighted_avg_tau_bar_scaled,1)/2,:));
weighted_avg_d_transport = cat(1,weighted_avg_d_transport((size(weighted_avg_d_transport,1)/2+1):end,:),weighted_avg_d_transport(1:size(weighted_avg_d_transport,1)/2,:));
weighted_avg_evap_lat = cat(1,weighted_avg_evap_lat((size(weighted_avg_evap_lat,1)/2+1):end,:),weighted_avg_evap_lat(1:size(weighted_avg_evap_lat,1)/2,:));
weighted_avg_ocean_frac = cat(1,weighted_avg_ocean_frac((size(weighted_avg_ocean_frac,1)/2+1):end,:),weighted_avg_ocean_frac(1:size(weighted_avg_ocean_frac,1)/2,:));
lon2=[lon2((length(lon2)/2+1):end);lon2(1:length(lon2)/2)];

%Get rid of weird prime meridian line (CESM vars)
weighted_avg_dO18ec_scaled = cat(1,weighted_avg_dO18ec_scaled((size(weighted_avg_dO18ec_scaled,1)/2+1):end,:),weighted_avg_dO18ec_scaled(1:size(weighted_avg_dO18ec_scaled,1)/2,:));
weighted_avg_PRECTocn = cat(1,weighted_avg_PRECTocn((size(weighted_avg_PRECTocn,1)/2+1):end,:),weighted_avg_PRECTocn(1:size(weighted_avg_PRECTocn,1)/2,:));
weighted_avg_PRECTdist = cat(1,weighted_avg_PRECTdist((size(weighted_avg_PRECTdist,1)/2+1):end,:),weighted_avg_PRECTdist(1:size(weighted_avg_PRECTdist,1)/2,:));
weighted_avg_PRECTlat = cat(1,weighted_avg_PRECTlat((size(weighted_avg_PRECTlat,1)/2+1):end,:),weighted_avg_PRECTlat(1:size(weighted_avg_PRECTlat,1)/2,:));
lon=[lon((length(lon)/2+1):end);lon(1:length(lon)/2)];

%define differences
tau_bar_minus_d018ec = weighted_avg_tau_bar_scaled - weighted_avg_dO18ec_scaled;
d_transport_minus_PRECTdist = 10^3*weighted_avg_d_transport - 10^3*weighted_avg_PRECTdist;
evap_lat_minus_PRECTlat = weighted_avg_evap_lat - weighted_avg_PRECTlat;
ocean_frac_minus_PRECTocn = 10^2*weighted_avg_ocean_frac - weighted_avg_PRECTocn;

figure;
% Plot weighted average of 10*tau_bar
subplot(4, 1, 1);
make_figure_pcolor(tau_bar_minus_d018ec, lat2, lon2, [-90 90], [-180 180], linspace(-15, 15, 100), 1);
clim([-100 100]);
xlabel('Longitude Index');
ylabel('Latitude Index');
title('tau bar minus dO18ec (JJAS)');

% Plot weighted average of d_transport
subplot(4, 1, 2);
make_figure_pcolor(d_transport_minus_PRECTdist, lat2, lon2, [-90 90], [-180 180], linspace(-15, 15, 100), 1);
clim([-10000000 10000000]);
xlabel('Longitude Index');
ylabel('Latitude Index');
title('d transport minus PRECTdist (DJFM)');

% Plot weighted average of evap_lat
subplot(4, 1, 3);

make_figure_pcolor(evap_lat_minus_PRECTlat, lat2, lon2, [-90 90], [-180 180], linspace(-60, 60, 100), 1);
clim([-100 100]);
xlabel('Longitude');
ylabel('Latitude');
title('evap lat minus PRECTlat (JJAS)');

subplot(4, 1, 4);
make_figure_pcolor(ocean_frac_minus_PRECTocn, lat2, lon2, [-90 90], [-180 180], linspace(-60, 60, 100), 1);
clim([-100 100]);
xlabel('Longitude');
ylabel('Latitude');
title('ocean frac minus PRECTocn (JJAS)');