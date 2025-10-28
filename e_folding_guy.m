% Recycling Ratios for PRECT_pnt000 to PRECT_pnt900
clear;

% Load all necessary variables at once
load('CESM_aqua_john2.mat', 'lat', 'lon', 'P', ...
    'PRECT_pnt000','PRECT_pnt075','PRECT_pnt150','PRECT_pnt225', ...
    'PRECT_pnt300','PRECT_pnt375','PRECT_pnt450','PRECT_pnt525', ...
    'PRECT_pnt600','PRECT_pnt675','PRECT_pnt750','PRECT_pnt825','PRECT_pnt900','UQ','VQ');

% Create lat-lon meshgrid
[lat2,lon2] = meshgrid(lat,lon);
lat1 = 0;
lon1 = 0;

% Distance from source point
d = greatCircleDistance(lat1, lon1, lat2, lon2);

% Setup for time and filtering
[~, ~, timesteps] = size(P);
dt = 30;
dates = datenum('18791231', 'yyyymmdd') + (ceil(dt/2):dt:dt*timesteps);
datemon = datestr(dates, 'mm');
all_months_to_include = {'01','02','03','04','05','06','07','08','09','10','11','12'};
boreal_summer_months_to_include = {'06','07','08','09'};
boreal_winter_months_to_include = {'12','01','02','03'};
is_desired_month = ismember(datemon, all_months_to_include);

% Filter P (used for weighting)
P_filtered = P(:,:,is_desired_month);
UQ_filtered = UQ(:,:,is_desired_month);
VQ_filtered = VQ(:,:,is_desired_month);
% Define tag names and preallocate result
tag_names = {'000','075','150','225','300','375','450','525','600','675','750','825','900'};
ratios = zeros(1, length(tag_names));

% Loop through each PRECT_pntXXX field
% Loop through each PRECT_pntXXX field using F/P-based evap_dist
for i = 1:length(tag_names)
    tag = tag_names{i};
    varname = ['PRECT_pnt' tag];

    if evalin('base', ['exist(''' varname ''', ''var'')'])
        data = eval(varname);
        data_filtered = data(:,:,is_desired_month);

        % Compute weighted precipitation average over time
        weighted_avg = sum(data_filtered .* P_filtered, 3, 'omitnan') ./ ...
                       sum((data_filtered * 0 + 1) .* P_filtered, 3, 'omitnan');

        % Compute F = sqrt(UQ^2 + VQ^2)
        Fmag = sqrt(UQ_filtered.^2 + VQ_filtered.^2);

        % Avoid divide-by-zero in F/P
        P_safe = P_filtered;
        P_safe(P_safe == 0) = NaN;
        length_scale = Fmag ./ P_safe;

        % Time-mean F/P field
        avg_length_scale = mean(length_scale, 3, 'omitnan');

        % Compute cos(lat)-weighted global mean length scale (becomes evap_dist)
        coslat_weight = cosd(lat2);
        evap_dist = sum(avg_length_scale .* coslat_weight, 'all', 'omitnan') / ...
                    sum(coslat_weight, 'all', 'omitnan');

        % Get lat/lon for this source point (Southern Hemisphere only)
        source_lat = -str2double(tag);
        source_lon = 0;

        % Distance grid from source point
        d = greatCircleDistance(source_lat, source_lon, lat2, lon2);

        % Create mask: distances within mean(F/P)
        mask = d <= evap_dist./1000;

        % Apply mask to precipitation footprint to get recycling ratio
        ratio = sum(sum(mask .* weighted_avg .* cosd(lat2))) / ...
                sum(sum(weighted_avg .* cosd(lat2)));

        ratios(i) = ratio;
    else
        warning(['Variable ' varname ' not found in workspace.']);
        ratios(i) = NaN;
    end
end


% Display results
disp('Recycling ratios for each PRECT_pntXXX:');
for i = 1:length(tag_names)
    fprintf('PRECT_pnt%s: %.4f\n', tag_names{i}, ratios(i));
end