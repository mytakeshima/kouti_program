% % % データの読み込み
% % q_data = ncread('kouchicloud.nc', 'q'); % 比湿データ
% % lat = ncread('kouchicloud.nc', 'latitude'); % 緯度データ
% % lon = ncread('kouchicloud.nc', 'longitude'); % 経度データ
% % 
% % 
% % %高知範囲 32.5-34 132.5-134.5
% % %四国範囲 31-34 131-135
% % % 緯度経度範囲を指定
% % lat_range = [31, 34];
% % lon_range = [131, 135];
% % 
% % % 指定された緯度経度範囲内のインデックスを取得
% % lat_indices = find(lat >= lat_range(1) & lat <= lat_range(2));
% % lon_indices = find(lon >= lon_range(1) & lon <= lon_range(2));
% % 
% % % 指定された圧力レベル（ここでは2）のデータを抽出
% % pressure_level = 2; % 圧力レベルインデックス
% % q_data_at_level = q_data(lon_indices, lat_indices, pressure_level, :);
% % q_data_vector = q_data_at_level(:); % 1次元ベクトルに変換
% % 
% % % ヒストグラムのビンの設定
% % bin_edges = 0:0.005:0.05; % 比湿の範囲を具体的な範囲に応じて設定
% % 
% % % ヒストグラムの計算
% % [counts, edges] = histcounts(q_data_vector, bin_edges);
% % 
% % % ヒストグラムのプロット
% % figure;
% % b = bar(edges(1:end-1), counts, 'histc');
% % 
% % % パーセンテージの計算
% % total_counts = sum(counts);
% % percentages = 100 * counts / total_counts;
% % 
% % % グラフのラベリング
% % xlabel('比湿 (g/kg)');
% % ylabel('頻度');
% % title('指定範囲内の比湿の値の分布');
% % xticks(edges);
% % xticklabels(arrayfun(@(x) sprintf('%d-%d', x, x+1), edges(1:end-1), 'UniformOutput', false));
% % xtickangle(45);
% % 
% % % 数とパーセンテージの表示
% % text(edges(1:end-1) + 0.5, counts, arrayfun(@(c, p) sprintf('%d (%.2f%%)', c, p), counts, percentages, 'UniformOutput', false), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Color', 'red');
% % 
% % % プロット保存
% % saveas(gcf, 'humidity_distribution.png');
% % 
% % % プロット保存
% % saveas(gcf, fullfile('C:\Users\murqk\Desktop\卒論結果まとめ\高知\XRAIN累積降水量使用', '比湿集計(四国).png'));


% % % % % データの読み込み
% % % % q_data = ncread('kouchicloud.nc', 'q'); % 比湿データ
% % % % lat = ncread('kouchicloud.nc', 'latitude'); % 緯度データ
% % % % lon = ncread('kouchicloud.nc', 'longitude'); % 経度データ
% % % % 
% % % % % 緯度経度範囲を指定
% % % % lat_range = [31, 34];
% % % % lon_range = [131, 135];
% % % % 
% % % % % 指定された緯度経度範囲内のインデックスを取得
% % % % lat_indices = find(lat >= lat_range(1) & lat <= lat_range(2));
% % % % lon_indices = find(lon >= lon_range(1) & lon <= lon_range(2));
% % % % 
% % % % % 指定された圧力レベル（ここでは2）のデータを抽出
% % % % pressure_level = 2; % 圧力レベルインデックス
% % % % q_data_at_level = q_data(lon_indices, lat_indices, pressure_level, :);
% % % % q_data_vector = q_data_at_level(:); % 1次元ベクトルに変換
% % % % 
% % % % % ヒストグラムのビンの設定
% % % % bin_edges = 0:0.001:0.015; % 比湿の範囲を0から0.015まで、0.001の刻みで設定
% % % % 
% % % % % ヒストグラムの計算
% % % % [counts, edges] = histcounts(q_data_vector, bin_edges);
% % % % 
% % % % % ヒストグラムのプロット
% % % % figure;
% % % % b = bar(edges(1:end-1), counts, 'histc');
% % % % 
% % % % % パーセンテージの計算
% % % % total_counts = sum(counts);
% % % % percentages = 100 * counts / total_counts;
% % % % 
% % % % % グラフのラベリング
% % % % xlabel('比湿 (g/kg)');
% % % % ylabel('頻度');
% % % % title('指定範囲内の比湿の値の分布');
% % % % xticks(edges(1:2:end));  % 2つごとのエッジにマーク
% % % % xticklabels(arrayfun(@(x) sprintf('%.3f', x), edges(1:2:end), 'UniformOutput', false));
% % % % xtickangle(45);
% % % % 
% % % % % 数とパーセンテージの表示
% % % % text(edges(1:end-1) + 0.0005, counts, arrayfun(@(c, p) sprintf('%d (%.2f%%)', c, p), counts, percentages, 'UniformOutput', false), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Color', 'red');
% % % % 
% % % % % プロット保存
% % % % saveas(gcf, fullfile('C:\Users\murqk\Desktop\卒論結果まとめ\高知\XRAIN累積降水量使用', '比湿集計(四国).png'));


% データの読み込み
q_data = ncread('kouchicloud.nc', 'q'); % 比湿データ
lat = ncread('kouchicloud.nc', 'latitude'); % 緯度データ
lon = ncread('kouchicloud.nc', 'longitude'); % 経度データ



% % %高知範囲 32.5-34 132.5-134.5
% % %四国範囲 31-34 131-135
% 緯度経度範囲を指定
lat_range = [31, 34];
lon_range = [131, 135];

% 指定された緯度経度範囲内のインデックスを取得
lat_indices = find(lat >= lat_range(1) & lat <= lat_range(2));
lon_indices = find(lon >= lon_range(1) & lon <= lon_range(2));

% 指定された圧力レベル（ここでは2）のデータを抽出
pressure_level = 2; % 圧力レベルインデックス
q_data_at_level = q_data(lon_indices, lat_indices, pressure_level, :);
q_data_vector = q_data_at_level(:); % 1次元ベクトルに変換

% ヒストグラムのビンの設定
bin_edges = 0.004:0.001:0.020; % 比湿の範囲を0.004から0.020まで、0.001の刻みで設定

% ヒストグラムの計算
[counts, edges] = histcounts(q_data_vector, bin_edges);

% ヒストグラムのプロット
figure;
b = bar(edges(1:end-1), counts, 'histc');

% パーセンテージの計算
total_counts = sum(counts);
percentages = 100 * counts / total_counts;

% グラフのラベリング
xlabel('比湿 (g/kg)');
ylabel('頻度');
title('指定範囲内の比湿の値の分布');
xticks(edges);  % 各エッジにマーク
xticklabels(arrayfun(@(x) sprintf('%.3f', x), edges, 'UniformOutput', false));
xtickangle(45);

% 数とパーセンテージの表示
text(edges(1:end-1) + 0.0005, counts, arrayfun(@(c, p) sprintf('%d (%.2f%%)', c, p), counts, percentages, 'UniformOutput', false), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Color', 'red');

% プロット保存
saveas(gcf, fullfile('C:\Users\murqk\Desktop\卒論結果まとめ\高知\XRAIN(累積降水量使用)', '比湿集計(四国).png'));
