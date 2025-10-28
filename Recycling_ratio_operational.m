% Recycling Ratios for PRECT_pnt000 to PRECT_pnt900
clear;

% Load all necessary variables at once
load('CESM_aqua_john2.mat', 'lat', 'lon', 'P', ...
    'PRECT_pnt000','PRECT_pnt075','PRECT_pnt150','PRECT_pnt225', ...
    'PRECT_pnt300','PRECT_pnt375','PRECT_pnt450','PRECT_pnt525', ...
    'PRECT_pnt600','PRECT_pnt675','PRECT_pnt750','PRECT_pnt825','PRECT_pnt900');

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

% Define tag names and preallocate result
tag_names = {'000','075','150','225','300','375','450','525','600','675','750','825','900'};
ratios = zeros(1, length(tag_names));

% Loop through each PRECT_pntXXX field
for i = 1:length(tag_names)
    tag = tag_names{i};
    varname = ['PRECT_pnt' tag];
    if evalin('base', ['exist(''' varname ''', ''var'')'])
        data = eval(varname);
        data_filtered = data(:,:,is_desired_month);

        % Compute weighted average across time
        weighted_avg = mean(data_filtered,3);
        % Get latitude for this tag (e.g., '075' → -7.5)
        source_lat = -str2double(tag);  % Negative because it's in SH
        source_lon = 0;

        % Compute great circle distance from this latitude at 0E
        d = greatCircleDistance(source_lat, source_lon, lat2, lon2);

        % Compute recycling distance and ratio
        evap_dist = sum(sum(d .* weighted_avg .* cosd(lat2))) / sum(sum(weighted_avg .* cosd(lat2)));
        mask = d <= evap_dist;
        ratio = sum(sum(mask .* weighted_avg .* cosd(lat2))) / sum(sum(weighted_avg .* cosd(lat2)));

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



