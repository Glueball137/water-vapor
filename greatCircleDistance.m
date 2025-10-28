function d = greatCircleDistance(lat1, lon1, lat2, lon2)
    lat1 = deg2rad(lat1);
    lon1 = deg2rad(lon1);
    lat2 = deg2rad(lat2);
    lon2 = deg2rad(lon2);
    R = 6371;

    if ~isequal(size(lat2), size(lon2))
        error('lat2 and lon2 must be the same size.');
    end

    lat1 = lat1 * ones(size(lat2));
    lon1 = lon1 * ones(size(lon2));

    deltaLat = lat2 - lat1;
    deltaLon = lon2 - lon1;

    a = sin(deltaLat/2).^2 + cos(lat1) .* cos(lat2) .* sin(deltaLon/2).^2;
    c = 2 * atan2(sqrt(a), sqrt(1 - a));

    d = R * c;
end