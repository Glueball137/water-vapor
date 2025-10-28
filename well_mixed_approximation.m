% Load the data
load('CESM_data_john_2deg.mat', 'P', 'dO182', 'PRECTcp', 'pres_qweight','lat','lon','QFLX');

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
    PRECTcp_filtered = PRECTcp(:,:,is_desired_month);
    pres_qweight_filtered = pres_qweight(:,:,is_desired_month);
    %PRECTdist_filtered = PRECTdist(:,:,is_desired_month);
    %PRECTlat_filtered = PRECTlat(:,:,is_desired_month);
else
    error('The length of logical indices does not match the data dimensions.');
end

p_weighted_avg_PRECTcp = sum(PRECTcp_filtered .* P_filtered, 3, 'omitnan') ./ sum(P_filtered, 3, 'omitnan');
q_weighted_pres_qweight = sum(pres_qweight_filtered .* P_filtered, 3, 'omitnan') ./ sum(P_filtered, 3, 'omitnan');

figure;
subplot(1, 1, 1);
make_figure_pcolor(p_weighted_avg_PRECTcp-q_weighted_pres_qweight, lat, lon, [-90 90], [-180 180], linspace(-15, 15, 100), 1);
clim([-10000 10000]);
xlabel('Longitude Index');
ylabel('Latitude Index');
title('PRECTcp-pres_qweight (annual)');