%Calculate PRECTocn landfrac values
%CESM averages

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
%Tq_expanded = repmat(Tq, [1, 1, size(PRECTocn_filtered, 3)]);
%landfrac_evap = sum((QFLX_filtered .* Tq_expanded), 3, 'omitnan') ./ sum(QFLX_filtered, 3, 'omitnan');
%PRECTocn_landfrac = sum((PRECTocn_filtered .* (1 - Tq_expanded)) .* P_filtered, 3, 'omitnan') ./ sum(P_filtered, 3, 'omitnan');


%Get rid of weird Prime Meridian line
weighted_avg_dO18ec_scaled = cat(1,weighted_avg_dO18ec_scaled((size(weighted_avg_dO18ec_scaled,1)/2+1):end,:),weighted_avg_dO18ec_scaled(1:size(weighted_avg_dO18ec_scaled,1)/2,:));
weighted_avg_PRECTocn = (1./100).*cat(1,weighted_avg_PRECTocn((size(weighted_avg_PRECTocn,1)/2+1):end,:),weighted_avg_PRECTocn(1:size(weighted_avg_PRECTocn,1)/2,:));
weighted_avg_PRECTdist = cat(1,weighted_avg_PRECTdist((size(weighted_avg_PRECTdist,1)/2+1):end,:),weighted_avg_PRECTdist(1:size(weighted_avg_PRECTdist,1)/2,:));
weighted_avg_PRECTlat = cat(1,weighted_avg_PRECTlat((size(weighted_avg_PRECTlat,1)/2+1):end,:),weighted_avg_PRECTlat(1:size(weighted_avg_PRECTlat,1)/2,:));
weighted_avg_land_frac = cat(1,Tq((size(Tq,1)/2+1):end,:),Tq(1:size(Tq,1)/2,:));
lon=[lon((length(lon)/2+1):end);lon(1:length(lon)/2)];
%Xq=[Xq((length(Xq)/2+1):end);XQ(1:length(Xq)/2)];

weighted_avg_PRECTocn2 = weighted_avg_PRECTocn.*weighted_avg_land_frac;

ocean_mask = 1 - weighted_avg_land_frac;

figure;
subplot(1, 1, 1);
make_figure_pcolor(weighted_avg_PRECTocn.*weighted_avg_land_frac, lat, lon, [-90 90], [-180 180], linspace(-60, 60, 100), 1);
clim([0 1]);
xlabel('Longitude');
ylabel('Latitude');
title('Weighted Average of ocean fraction (YEARLY)');

dummy2=sum(sum(sum(weighted_avg_PRECTocn.*weighted_avg_land_frac.*P_filtered,3).*cosd(lat'), 'omitnan'), 'omitnan')./sum(sum(sum(weighted_avg_land_frac.*P_filtered,3).*cosd(lat'),'omitnan'), 'omitnan');

display(['average of (landfrac) PRECTocn: ',num2str(dummy2)])