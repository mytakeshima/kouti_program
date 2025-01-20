% 指定範囲の赤枠表示のプログラム
% データ収集領域を示すときに使用

% 地図のファイルパス
shapefile = 'C:\Users\murqk\Desktop\EN\JPN_adm1.shp';

% 地図の読み込み
S = shaperead(shapefile);

% 地図の描画
figure;
mapshow(S, 'EdgeColor', 'black'); % 地図の境界線を黒色で描画
hold on;

% 指定した範囲（例：緯度・経度の範囲を設定）
%山形範囲 38.5-39.5 139.5-140.5
%東北範囲 37-41 139-142
%石川範囲 36.5-37.75 136-137.5
%北陸範囲 36-39 135-139
%高知範囲 32.5-34 132.5-134.5
%四国範囲 31-34 131-135


lat_min = 31; % 最小緯度
lat_max = 34; % 最大緯度
lon_min = 131; % 最小経度
lon_max = 135; % 最大経度

% 赤い枠を描画
plot([lon_min, lon_max, lon_max, lon_min, lon_min], ...
     [lat_min, lat_min, lat_max, lat_max, lat_min], ...
     'r-', 'LineWidth', 2);

% 描画の設定
xlabel('経度');
ylabel('緯度');
title('指定範囲の赤枠表示');
hold off;
