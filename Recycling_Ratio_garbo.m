%Recycling Ratios
%Preliminary aquaplanet plots
clear;


% Load the data
load('CESM_aqua_john2.mat','lat','lon','PRECT_pnt600','P');

%First, create mesh grids of lat2 lon2:

[lat2,lon2]=meshgrid(lat,lon);

% adjust lat1 to match the tag latitude but leave lon1=0;
lat1=0;
lon1=0;

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
    %PRECTdist_filtered = PRECTdist(:,:,is_desired_month);
    PRECT_pnt600_filtered = PRECT_pnt600(:,:,is_desired_month);
else
    error('The length of logical indices does not match the data dimensions.');
end

% Calculate weighted averages for the filtered data
weighted_avg_PRECT_pnt600 = sum(PRECT_pnt600_filtered .* P_filtered, 3, 'omitnan')./sum((PRECT_pnt600_filtered.*0+1).*P_filtered, 3, 'omitnan');

%Get rid of weird Prime Meridian line
weighted_avg_PRECT_pnt600 = cat(1,weighted_avg_PRECT_pnt600((size(weighted_avg_PRECT_pnt600,1)/2+1):end,:),weighted_avg_PRECT_pnt600(1:size(weighted_avg_PRECT_pnt600,1)/2,:));
lon=[lon((length(lon)/2+1):end);lon(1:length(lon)/2)];


%First, create mesh grids of lat2 lon2:

[lat2,lon2]=meshgrid(lat,lon);

% adjust lat1 to match the tag latitude but leave lon1=0;
lat1=0;
lon1=0;

d = greatCircleDistance(lat1, lon1, lat2, lon2);

%To calculate the fraction of evaporation that precipitates within a given radius R0:


evap_dist=sum(sum(d.*PRECT_pnt600.*cosd(lat2)))./sum(sum(PRECT_pnt600.*cosd(lat2)));
mask=d<=evap_dist;
ratio=mean(sum(sum(mask.*PRECT_pnt600.*cosd(lat2)))./sum(sum(PRECT_pnt600.*cosd(lat2))),3);
disp(ratio)
