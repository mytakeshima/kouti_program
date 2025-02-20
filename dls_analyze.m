% データの読み込み
u_data = ncread('kouchicloud.nc', 'u'); % 東西風データ
v_data = ncread('kouchicloud.nc', 'v'); % 南北風データ
lat = ncread('kouchicloud.nc', 'latitude'); % 緯度データ
lon = ncread('kouchicloud.nc', 'longitude'); % 経度データ

% 圧力レベルのインデックス（例：1 = 500hPa, 3 = 1000hPa）
level_500hpa_idx = 1;
level_1000hpa_idx = 3;


%高知範囲 32.5-34 132.5-134.5
%四国範囲 31-34 131-135
% 緯度経度の範囲を指定
lat_range = [31, 34];
lon_range = [131, 135];

% 緯度経度の範囲内のインデックスを取得
lat_indices = find(lat >= lat_range(1) & lat <= lat_range(2));
lon_indices = find(lon >= lon_range(1) & lon <= lon_range(2));

% 指定された圧力レベルの風速データを抽出
u_500 = u_data(lon_indices, lat_indices, level_500hpa_idx, :);
v_500 = v_data(lon_indices, lat_indices, level_500hpa_idx, :);
u_1000 = u_data(lon_indices, lat_indices, level_1000hpa_idx, :);
v_1000 = v_data(lon_indices, lat_indices, level_1000hpa_idx, :);

% DLSの計算
dls = sqrt((u_500 - u_1000).^2 + (v_500 - v_1000).^2);
dls_vector = dls(:); % 1次元ベクトルに変換

% ヒストグラムのビンの設定
bin_edges = 0:1:26; % DLSの範囲を0から26 m/sまで、1 m/sの刻みで設定

% ヒストグラムの計算
[counts, edges] = histcounts(dls_vector, bin_edges);

% ヒストグラムのプロット
figure;
b = bar(edges(1:end-1), counts, 'histc');

% パーセンテージの計算
total_counts = sum(counts);
percentages = 100 * counts / total_counts;

% グラフのラベリング
xlabel('DLS (m/s)');
ylabel('頻度');
title('指定範囲内のDLSの値の分布');
xticks(edges(1:2:end)); % 2つごとのエッジにマーク
xticklabels(arrayfun(@(x) sprintf('%d', x), edges(1:2:end), 'UniformOutput', false));
xtickangle(45);

% 数とパーセンテージの表示
text(edges(1:end-1) + 0.5, counts, arrayfun(@(c, p) sprintf('%d (%.2f%%)', c, p), counts, percentages, 'UniformOutput', false), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Color', 'red');

% プロット保存
saveas(gcf, fullfile('C:\Users\murqk\Desktop\卒論結果まとめ\高知\XRAIN(累積降水量使用)', 'DLS集計(範囲四国).png'));
