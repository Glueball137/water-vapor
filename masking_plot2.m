% Tag to inspect
tag = '000';
varname = ['PRECT_pnt' tag];
data = eval(varname);
data_filtered = data(:,:,is_desired_month);

% Compute weighted average precipitation
weighted_avg = sum(data_filtered .* P_filtered, 3, 'omitnan') ./ ...
               sum((data_filtered*0 + 1) .* P_filtered, 3, 'omitnan');

% Compute F = sqrt(UQ^2 + VQ^2), then F/P
Fmag = sqrt(UQ_filtered.^2 + VQ_filtered.^2);
P_safe = P_filtered;
P_safe(P_safe == 0) = NaN;
length_scale = Fmag ./ P_safe;

% Average over time
avg_length_scale = mean(length_scale, 3, 'omitnan');

% Cos-weighted global mean of F/P
coslat_weight = cosd(lat2);
mean_F_over_P = sum(avg_length_scale .* coslat_weight, 'all', 'omitnan') / ...
                sum(coslat_weight, 'all', 'omitnan');

% === Step 2: Build circle mask of radius mean_F_over_P ===

% Get evaporation center location (e.g. 900 → -90 latitude)
source_lat = -str2double(tag);
source_lon = 0;

% Compute great circle distances from the evaporation source point
d = greatCircleDistance(source_lat, source_lon, lat2, lon2);

% Mask = inside mean transport distance
mask = double(d <= mean_F_over_P);

% Reorder for Prime Meridian
mask_plot = cat(1, mask((end/2 + 1):end,:), mask(1:end/2,:));
lon_plot = [lon((end/2 + 1):end); lon(1:end/2)];

% Plot the mask
make_figure_pcolor(mask_plot, lat, lon_plot, [-90 90], [-180 180], linspace(0, 1, 3), 1);
clim([0 1]);
xlabel('Longitude');
ylabel('Latitude');
title(['F/P Length Scale Mask for PRECT\_pnt' tag ' (radius = ' num2str(mean_F_over_P, '%.1f') ' km)']);
