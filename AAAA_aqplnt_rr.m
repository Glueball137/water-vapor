%AAAA_Aqplnt_rr
clear;

% Load data
load('CESM_aqua_john2.mat','QFLX','lat', 'lon', 'P', ...
    'PRECT_pnt000','PRECT_pnt075','PRECT_pnt150','PRECT_pnt225', ...
    'PRECT_pnt300','PRECT_pnt375','PRECT_pnt450','PRECT_pnt525', ...
    'PRECT_pnt600','PRECT_pnt675','PRECT_pnt750','PRECT_pnt825','PRECT_pnt900','UQ','VQ');

[lat2, lon2] = meshgrid(lat, lon);  % Meshgrid: (lon, lat)

% Time setup
[~, ~, timesteps] = size(P);
dt = 30;
dates = datenum('18791231', 'yyyymmdd') + (ceil(dt/2):dt:dt*timesteps);
datemon = datestr(dates, 'mm');
months_to_include = {'01','02','03','04','05','06','07','08','09','10','11','12'};
is_desired_month = ismember(datemon, months_to_include);

% Filter precipitation
P_filtered = P(:,:,is_desired_month);

% Define tags and initialize results
tag_names = {'000','075','150','225','300','375','450','525','600','675','750','825','900'};
percent_within_1000km = zeros(1, length(tag_names));

r=1000;

% Loop through each source point
for i = 1:length(tag_names)
    tag = tag_names{i};
    varname = ['PRECT_pnt' tag];
    if exist(varname, 'var')
        data = eval(varname);
        data_filtered = data(:,:,is_desired_month);

        % Weighted average precip footprint
        weighted_avg = mean(data_filtered,3);

        % Get source point location
        source_lat = -str2double(tag)/10;  % Southern Hemisphere assumption
        source_lon = 0;

        % Compute distance from source point
        d = greatCircleDistance(source_lat, 0, lat2, lon2); % In km

        [x,y]=find(d==min(min(d)));
        
        L=mean(sqrt(UQ(x,y,:).^2+VQ(x,y,:).^2),3)./mean(P(x,y,:),3)./1000;
        %L2=mean(sqrt(UQ(x,y,:).^2+VQ(x,y,:).^2),3)./mean(QFLX(x,y,:),3)./1000;
        percent_within_r_approx(i)=(1-exp(-r./L));

        % Mask: only grid cells within 1000 km
        mask = d <= r;
        mask2 = d <= L;
        %mask3 = d <= L2;
        % Compute percentage of total precip within 1000 km
        total_precip = sum(sum(weighted_avg .* cosd(lat2)), 'omitnan');
        local_precip = sum(sum(weighted_avg .* cosd(lat2) .* mask), 'omitnan');
        local_precip_2=sum(sum(weighted_avg .* cosd(lat2) .* mask2), 'omitnan');
        %local_precip_3=sum(sum(weighted_avg .* cosd(lat2) .* mask3), 'omitnan');

        percent_within_1000km(i) = 100 * (local_precip / total_precip);
        percent_within_L_approx(i) = 100 * (local_precip_2 / total_precip);
        %percent_within_L2_approx(i) = 100 * (local_precip_3 / total_precip);

    else
        warning(['Variable ' varname ' not found.']);
        percent_within_1000km(i) = NaN;
        percent_within_L_approx(i) = NaN;
        %percent_within_L2_approx(i) = NaN;
    end
end

% Display results
disp('Percentage of precipitation within 1000 km:');
for i = 1:length(tag_names)
    fprintf('PRECT_pnt%s: %.2f%%\n', tag_names{i}, percent_within_1000km(i));
    fprintf('PRECT_pnt%s: %.2f%%\n', tag_names{i}, 100.*percent_within_L_approx(i));
    %fprintf('PRECT_pnt%s: %.2f%%\n', tag_names{i}, 100.*percent_within_L2_approx(i));
    %fprintf('PRECT_pnt%s: %.2f%%\n', tag_names{i}, percent_within_L(i));
end



T = table(tag_names', ...
          percent_within_1000km', ...
          100 * percent_within_r_approx', ...
          'VariableNames', {'Tag', 'Within_1000km', 'Approx_within_L'});

% === Write to Excel ===
filename = 'precip_summary.xlsx';  % Creates a new file or overwrites
writetable(T, filename);

disp(['✅ Results written to ' filename]);