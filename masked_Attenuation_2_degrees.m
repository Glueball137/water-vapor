%Calculate ocean_frac variables we are interested in
% Load the data
load('CESM_59vars_30day_2deg.mat', 'P', 'tau_bar', 'd_transport', 'evap_lat', 'lon2', 'lat2','oceanfrac');

% Check dimensions of the data arrays
size_P = size(P); % Assuming the dimensions are [lat, lon, days]
timesteps = size_P(3);
dt=3;

% Generate dates and month strings
dates = datenum('19791231', 'yyyymmdd') + (ceil(dt/2):dt:dt*timesteps); % Adjust indexing
datemon = datestr(dates, 'mm');

% Check sizes
disp(['Size of P: ', num2str(size_P)]);
disp(['Number of timesteps: ', num2str(timesteps)]);
disp(['Length of datemon: ', num2str(length(datemon))]);

% Define months to include
months_to_include = {'01','02','03','04','05','06','07','08','09','10','11','12'};

% Create logical index for the desired months
is_desired_month = ismember(datemon, months_to_include);

% Check logical indices
disp(['Length of is_desired_month: ', num2str(length(is_desired_month))]);
disp(['Number of true values: ', num2str(sum(is_desired_month))]);

% Ensure logical indexing is correct
if length(is_desired_month) == timesteps
    % Filter data for the desired months
    P_filtered = P(:,:,is_desired_month);
    tau_bar_filtered = tau_bar(:,:,is_desired_month);
    d_transport_filtered = d_transport(:,:,is_desired_month);
    evap_lat_filtered = evap_lat(:,:,is_desired_month);
    ocean_frac_filtered = oceanfrac(:,:,is_desired_month);
else
    error('The length of logical indices does not match the data dimensions.');
end


%filter out nans
ocean_frac_filtered(ocean_frac_filtered>1 | ocean_frac_filtered<0)=nan;

% Calculate weighted averages for the filtered data
weighted_avg_tau_bar_scaled = -10 .* sum(tau_bar_filtered .* P_filtered, 3, 'omitnan') ./ ...
    sum((tau_bar_filtered.*0+1).*P_filtered, 3, 'omitnan');
weighted_avg_d_transport = sum(d_transport_filtered .* P_filtered, 3, 'omitnan') ./ ...
    sum((d_transport_filtered.*0+1).*P_filtered, 3, 'omitnan');
weighted_avg_evap_lat = sum(evap_lat_filtered .* P_filtered, 3, 'omitnan')./ ...
    sum((evap_lat_filtered.*0+1).*P_filtered, 3, 'omitnan');
weighted_avg_ocean_frac = sum(ocean_frac_filtered .* P_filtered, 3, 'omitnan')./ ...
    sum((ocean_frac_filtered.*0+1) .* P_filtered, 3, 'omitnan');

%Get rid of weird Prime Meridian line
weighted_avg_tau_bar_scaled = cat(1,weighted_avg_tau_bar_scaled((size(weighted_avg_tau_bar_scaled,1)/2+1):end,:),weighted_avg_tau_bar_scaled(1:size(weighted_avg_tau_bar_scaled,1)/2,:));
weighted_avg_d_transport = cat(1,weighted_avg_d_transport((size(weighted_avg_d_transport,1)/2+1):end,:),weighted_avg_d_transport(1:size(weighted_avg_d_transport,1)/2,:));
weighted_avg_evap_lat = cat(1,weighted_avg_evap_lat((size(weighted_avg_evap_lat,1)/2+1):end,:),weighted_avg_evap_lat(1:size(weighted_avg_evap_lat,1)/2,:));
weighted_avg_ocean_frac = cat(1,weighted_avg_ocean_frac((size(weighted_avg_ocean_frac,1)/2+1):end,:),weighted_avg_ocean_frac(1:size(weighted_avg_ocean_frac,1)/2,:));
land_frac = cat(1,Tq((size(Tq,1)/2+1):end,:),Tq(1:size(Tq,1)/2,:));
lon2=[lon2((length(lon2)/2+1):end);lon2(1:length(lon2)/2)];
%Xq=[Xq((length(Xq)/2+1):end);XQ(1:length(Xq)/2)];

weighted_avg_ocean_frac2 = weighted_avg_ocean_frac.*land_frac;

ocean_mask = 1 - land_frac;

figure;
subplot(1, 1, 1);
make_figure_pcolor(weighted_avg_ocean_frac.*land_frac, lat2, lon2, [-90 90], [-180 180], linspace(-60, 60, 100), 1);
clim([0 1]);
xlabel('Longitude');
ylabel('Latitude');
title('Weighted Average of ocean fraction (YEARLY)');

%dummy2=sum(sum(sum(weighted_avg_ocean_frac.*land_frac.*P_filtered,3).*cosd(lat2'), 'omitnan'), 'omitnan')./sum(sum(sum(land_frac.*P_filtered,3).*cosd(lat2'),'omitnan'), 'omitnan');
dummy5=sum(sum(sum(weighted_avg_ocean_frac.*land_frac.*P_filtered,3).*cosd(lat2'), 'omitnan'), 'omitnan')./sum(sum(sum(land_frac.*P_filtered,3).*cosd(lat2'),'omitnan'), 'omitnan');
disp(['average ocean_frac: ', num2str(dummy5)]);

%Try to make Evaporation data