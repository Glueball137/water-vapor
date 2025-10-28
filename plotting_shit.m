% Figure setup
figure;
tag_names = {'000','075','150','225','300','375','450','525','600','675','750','825','900'};
n_tags = length(tag_names);

% Loop over all tags
for i = 1:n_tags
    tag = tag_names{i};
    varname = ['PRECT_pnt' tag];
    
    % Load precipitation data
    data = eval(varname);
    data_filtered = data(:,:,is_desired_month);
    
    % Compute weighted average precipitation (over time)
    weighted_avg = sum(data_filtered .* P_filtered, 3, 'omitnan') ./ ...
                   sum((data_filtered*0 + 1) .* P_filtered, 3, 'omitnan');
    
    % Compute F magnitude from filtered UQ and VQ
    Fmag = sqrt(UQ_filtered.^2 + VQ_filtered.^2);
    
    % Avoid divide-by-zero in F/P
    P_safe = P_filtered;
    P_safe(P_safe == 0) = NaN;
    
    % Compute length scale F/P
    length_scale = Fmag ./ P_safe;
    
    % Time-mean length scale weighted by cos(lat)
    avg_length_scale = mean(length_scale, 3, 'omitnan');
    coslat_weight = cosd(lat2);
    global_avg_length_scale = sum(avg_length_scale .* coslat_weight, 'all', 'omitnan') / ...
                              sum(coslat_weight, 'all', 'omitnan');
    
    % Source location
    source_lat = -str2double(tag);
    source_lon = 0;
    
    % Compute distance grid from source
    d = greatCircleDistance(source_lat, source_lon, lat2, lon2);
    
    % Build mask: distances within avg_length_scale (converted to km)
    mask = double(d <= global_avg_length_scale / 1000);
    
    % Fix Prime Meridian discontinuity for plotting
    mask_plot = cat(1, mask((end/2 + 1):end, :), mask(1:end/2, :));
    lon_plot = [lon((end/2 + 1):end); lon(1:end/2)];
    
    % Create subplot (use a grid layout)
    subplot(3, 5, i); % Adjust grid size (3x5) as needed for all tags
    
    % Plot mask
    make_figure_pcolor(mask_plot, lat, lon_plot, [-90 90], [-180 180], linspace(0,1,3), 1);
    clim([0 1]);
    xlabel('Longitude');
    ylabel('Latitude');
    title(['Mask PRECT\_pnt' tag]);
end

sgtitle('F/P Radius Masks for PRECT\_pnt000 to PRECT\_pnt900');