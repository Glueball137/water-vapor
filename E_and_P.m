%Calculation of the E, P, and E-P fields from CESM
% Load the data
load('CESM_data_john_2deg.mat', 'P', 'PRECT_d18Oec', 'PRECTdist', 'PRECTlat','lat','lon','QFLX','PRECTocn');
%load('CESM_59vars_7day.mat','lat2','lon2')

avg_P = mean(P, 3, 'omitnan');
avg_P = cat(1,avg_P((size(avg_P,1)/2+1):end,:),avg_P(1:size(avg_P,1)/2,:));

lon=[lon((length(lon)/2+1):end);lon(1:length(lon)/2)];
% Plot weighted average of d_transport
subplot(1, 1, 1);
make_figure_pcolor(avg_P, lat, lon, [-90 90], [-180 180], linspace(-15, 15, 100), 1);
clim([0 .0001]);
xlabel('Longitude Index');
ylabel('Latitude Index');
title('Average of P');