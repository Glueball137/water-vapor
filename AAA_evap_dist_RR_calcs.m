clear;

% Load data
load('CESM_aqua_john2.mat', 'lat', 'lon', 'P','QFLX', ...
    'PRECT_pnt000','PRECT_pnt075','PRECT_pnt150','PRECT_pnt225', ...
    'PRECT_pnt300','PRECT_pnt375','PRECT_pnt450','PRECT_pnt525', ...
    'PRECT_pnt600','PRECT_pnt675','PRECT_pnt750','PRECT_pnt825','PRECT_pnt900','UQ','VQ');

[lat2, lon2] = meshgrid(lat, lon);  % lat2, lon2: (lon, lat)

% Time filter
[~, ~, timesteps] = size(P);
dt = 30;
dates = datenum('18791231', 'yyyymmdd') + (ceil(dt/2):dt:dt*timesteps);
datemon = datestr(dates, 'mm');
months_to_include = {'01','02','03','04','05','06','07','08','09','10','11','12'};
is_desired_month = ismember(datemon, months_to_include);

% Filter P
P_filtered = P(:,:,is_desired_month);

% Tags
tag_names = {'000','075','150','225','300','375','450','525','600','675','750','825','900'};
masks = zeros([size(lat2), length(tag_names)]);  % 3D mask array: (lon x lat x tag)

% Loop

evap_dist=zeros(length(tag_names),1);
L=evap_dist;
for i = 1:length(tag_names)
    tag = tag_names{i};
    varname = ['PRECT_pnt' tag];

    if exist(varname, 'var')
        data = eval(varname);
        data_filtered = data(:,:,is_desired_month);

        % Weighted average precip footprint
        % weighted_avg = sum(data_filtered .* P_filtered, 3, 'omitnan') ./ ...
        %                sum((data_filtered * 0 + 1) .* P_filtered, 3, 'omitnan');
        weighted_avg=mean(data_filtered,3);

        % Source location
        source_lat = -str2double(tag)./10;
        source_lon = 0;

        % Distance from source (in km)
        d = greatCircleDistance(source_lat, source_lon, lat2, lon2);

        % Compute evaporation-weighted mean distance
        evap_dist(i) = sum(sum(d .* weighted_avg .* cosd(lat2)), 'omitnan') / ...
            sum(sum(weighted_avg .* cosd(lat2)), 'omitnan');

        [x,y]=find(d==min(min(d)),1);

        F(i)=mean(sqrt(UQ(x,y,is_desired_month).^2+VQ(x,y,is_desired_month).^2),3);
        Pmag(i)=mean(P(x,y,is_desired_month),3);
        Emag(i)=mean(QFLX(x,y,is_desired_month),3);

        L(i)=F(i)./Pmag(i)./1000;
        L2(i)=F(i)./Emag(i)./1000;
        % Create mask
        mask = d <= 1000;
        masks(:,:,i) = mask;

        % (Optional) Display result
        fprintf('PRECT_pnt%s: evap_dist = %.2f km\n', tag, evap_dist);
    else
        warning(['Variable ' varname ' not found.']);
        masks(:,:,i) = NaN;
    end
end













% Choose index
plot_idx = 12; % index for PRECT_pnt600
mask_to_plot = masks(:,:,plot_idx);

% Rearrange longitude for plotting if needed
mask_plot = cat(1, mask_to_plot((end/2+1):end,:), mask_to_plot(1:end/2,:));
lon_plot = [lon((end/2 + 1):end); lon(1:end/2)];

% Plot
figure;
make_figure_pcolor(mask_plot, lat, lon_plot, [-90 90], [-180 180], linspace(0, 1, 3), 1);
clim([0 1]);
xlabel('Longitude');
ylabel('Latitude');
title(['Mask for PRECT\_pnt' tag_names{plot_idx} ' (d ≤ evap\_dist)']);

