%interpolate landfrac

%load landfrac
load('landfrac.mat')

%define original space
lon_orig = linspace(0, 360, 289); 
lon_orig=lon_orig(1:end-1);
lat_orig = linspace(-90, 90, 192);  
[X_orig, Y_orig] = meshgrid(lat_orig, lon_orig);

%define new space
lon_new = linspace(1, 359, 180);
lat_new = linspace(-88, 88, 89);
[Xq, Yq] = meshgrid(lat_new, lon_new);
%transpose for meshgrid [lat x lon]
%landfrac = landfrac;  % Now size should be 192x288 = [lat x lon]

Tq = interp2(X_orig, Y_orig, landfrac, Xq, Yq, 'linear');
figure;
pcolor(Yq, Xq, Tq);
shading interp;
colorbar;
title('Interpolated landfrac (180x89)');
xlabel('Longitude');
ylabel('Latitude');