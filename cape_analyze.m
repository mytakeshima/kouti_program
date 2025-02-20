% データの読み込み
data = ncread('kouchicape.nc', 'cape');
lat = ncread('kouchicape.nc', 'latitude'); % 緯度データ
lon = ncread('kouchicape.nc', 'longitude'); % 経度データ


%高知範囲 32.5-34 132.5-134.5
%四国範囲 31-34 131-135
% 緯度経度範囲を指定
lat_range = [32.5, 34];
lon_range = [132.5, 134.5];

% 指定された緯度経度範囲内のインデックスを取得
lat_indices = find(lat >= lat_range(1) & lat <= lat_range(2));
lon_indices = find(lon >= lon_range(1) & lon <= lon_range(2));

% 対応するデータのみ抽出
filtered_data = data(lon_indices, lat_indices, :);
filtered_data_vector = filtered_data(:); % 1次元ベクトルに変換

% ヒストグラムのビンの設定
bin_edges = 0:500:5000; % CAPEを0から5000まで、500の刻みでビン分け

% ヒストグラムの計算
[counts, edges] = histcounts(filtered_data_vector, bin_edges);

% ヒストグラムのプロット
figure;
b = bar(edges(1:end-1), counts, 'histc');

% パーセンテージの計算
total_counts = sum(counts);
percentages = 100 * counts / total_counts;

% グラフのラベリング
xlabel('CAPEの値');
ylabel('頻度');
title('指定範囲内のCAPEの値の分布');
xticks(edges);
xticklabels(arrayfun(@(x) sprintf('%d-%d', x, x+500), edges(1:end-1), 'UniformOutput', false));
xtickangle(45);

% 数とパーセンテージの表示
text(edges(1:end-1) + 250, counts, arrayfun(@(c, p) sprintf('%d (%.2f%%)', c, p), counts, percentages, 'UniformOutput', false), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Color', 'red');

% プロット保存
saveas(gcf, fullfile('C:\Users\murqk\Desktop\卒論結果まとめ\高知\XRAIN累積降水量使用', 'cape集計(四国).png'));
