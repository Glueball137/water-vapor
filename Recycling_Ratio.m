%Recycling Ratios
%Preliminary aquaplanet plots
clear;


% Load the data
load('CESM_aqua_john2.mat','lat2','lon2','PRECT_pnt000');



%First, create mesh grids of lat2 lon2:

[lat2,lon2]=meshgrid(lat,lon);

% adjust lat1 to match the tag latitude but leave lon1=0;
lat1=0;
lon1=0;

evap_dist=sum(sum(d.*P_point.*cosd(lat2)))./sum(sum(P_point.*cosd(lat2)));

% compare evap_dist with the average of |F|/P (transport length scale)
%expectation is that evap_dist > length scale based on monthly F and P.

% below is the function that is called in the code above; save it as a file named "greatCircleDistance.m"
function d = greatCircleDistance(lat1, lon1, lat2, lon2)
    % Convert degrees to radians
    lat1 = deg2rad(lat1);
    lon1 = deg2rad(lon1);
    lat2 = deg2rad(lat2);
    lon2 = deg2rad(lon2);

    % Radius of Earth in kilometers
    R = 6371;

    % Ensure lat2 and lon2 are the same size
    if ~isequal(size(lat2), size(lon2))
        error('lat2 and lon2 must be the same size.');
    end

    % Expand lat1 and lon1 to match the size of lat2/lon2
    lat1 = lat1 * ones(size(lat2));
    lon1 = lon1 * ones(size(lon2));

    % Haversine formula (element-wise)
    deltaLat = lat2 - lat1;
    deltaLon = lon2 - lon1;

    a = sin(deltaLat/2).^2 + cos(lat1) .* cos(lat2) .* sin(deltaLon/2).^2;
    c = 2 * atan2(sqrt(a), sqrt(1 - a));

    % Distance matrix
    d = R * c;
end

%To calculate the fraction of evaporation that precipitates within a given radius R0:

mask=d<=R0;

ratio=sum(sum(mask.*P_point.*cosd(lat2)))./sum(sum(P_point.*cosd(lat2)));





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
    PRECT_pnt000_filtered = PRECT_pnt000(:,:,is_desired_month);
else
    error('The length of logical indices does not match the data dimensions.');
end

% Calculate weighted averages for the filtered data
weighted_avg_PRECT_pnt000 = sum(PRECT_pnt000_filtered .* P_filtered, 3, 'omitnan') ./ ...
    sum((PRECT_pnt000_filtered.*0+1).*P_filtered, 3, 'omitnan');

%Get rid of weird Prime Meridian line
weighted_avg_PRECT_pnt000 = cat(1,weighted_avg_PRECT_pnt000((size(weighted_avg_PRECT_pnt000,1)/2+1):end,:),weighted_avg_PRECT_pnt000(1:size(weighted_avg_PRECT_pnt000,1)/2,:));
lon=[lon((length(lon)/2+1):end);lon(1:length(lon)/2)];


%First, create mesh grids of lat2 lon2:

[lat2,lon2]=meshgrid(lat,lon);

% adjust lat1 to match the tag latitude but leave lon1=0;
lat1=0;
lon1=0;

d = greatCircleDistance(lat1, lon1, lat2, lon2);

evap_dist=sum(sum(d.*P_point.*cosd(lat2)))./sum(sum(P_point.*cosd(lat2)));

% compare evap_dist with the average of |F|/P (transport length scale)
%expectation is that evap_dist > length scale based on monthly F and P.

% below is the function that is called in the code above; save it as a file named "greatCircleDistance.m"
function d = greatCircleDistance(lat1, lon1, lat2, lon2)
    % Convert degrees to radians
    lat1 = deg2rad(lat1);
    lon1 = deg2rad(lon1);
    lat2 = deg2rad(lat2);
    lon2 = deg2rad(lon2);

    % Radius of Earth in kilometers
    R = 6371;

    % Ensure lat2 and lon2 are the same size
    if ~isequal(size(lat2), size(lon2))
        error('lat2 and lon2 must be the same size.');
    end

    % Expand lat1 and lon1 to match the size of lat2/lon2
    lat1 = lat1 * ones(size(lat2));
    lon1 = lon1 * ones(size(lon2));

    % Haversine formula (element-wise)
    deltaLat = lat2 - lat1;
    deltaLon = lon2 - lon1;

    a = sin(deltaLat/2).^2 + cos(lat1) .* cos(lat2) .* sin(deltaLon/2).^2;
    c = 2 * atan2(sqrt(a), sqrt(1 - a));

    % Distance matrix
    d = R * c;
end

%To calculate the fraction of evaporation that precipitates within a given radius R0:

mask=d<=R0;

ratio=sum(sum(mask.*PRECT_pnt900.*cosd(lat2)))./sum(sum(PRECT_pnt900.*cosd(lat2)));
print(ratio)
