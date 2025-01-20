% ERA5データの読み込み
precip_data_ERA5 = ncread('kouchirain.nc', 'tp'); % 降水量データ
lat_ERA5 = ncread('kouchirain.nc', 'latitude');  % 緯度データ
lon_ERA5 = ncread('kouchirain.nc', 'longitude'); % 経度データ




%XRAINデータ範囲 31-34.5 131-135
%使用データ範囲 32.5-34 132.5-134.5

%高知範囲 32.5-34 132.5-134.5
%四国範囲 31-34 131-135

% 観測したい範囲の緯度・経度を指定
lat_target = 39;  % 中心緯度
lon_target = 140.5; % 中心経度
lat_range = [32.5, 34];
lon_range = [132.5, 134.5];

% 指定した範囲のインデックスを取得
lat_idx_ERA5 = find(lat_ERA5 >= lat_range(1) & lat_ERA5 <= lat_range(2));
lon_idx_ERA5 = find(lon_ERA5 >= lon_range(1) & lon_ERA5 <= lon_range(2));

% 領域の面積 (m²) の計算
vert_length = 27.75 * 1000;  % 縦方向 (m)
horiz_length = 21.88 * 1000; % 横方向 (m)
area_ERA5 = vert_length * horiz_length;  % 面積 (m²)

% 時間軸の設定
time_start = datetime(2023, 8, 12, 0, 0, 0) + hours(9); % JST
time_step = hours(1);
num_time_steps = size(precip_data_ERA5,3)-23; 
time_axis = time_start + (0:num_time_steps-1) * time_step;

% 降水量データを体積に変換（ERA5）
precip_volume_ERA5 = precip_data_ERA5(lon_idx_ERA5, lat_idx_ERA5, 1:num_time_steps) * area_ERA5;  % m³
precip_volume_sum_ERA5 = squeeze(sum(sum(precip_volume_ERA5, 1), 2)); % 時間ごとの領域内合計値


% XRAINデータの処理
precip_volume_sum_XRAIN = [];
precip_times_XRAIN = datetime.empty;


% ファイルの存在、中身、フォーマットを確認する関数
function [data, isValid] = safeLoadData(filePath)
    data = [];  % 初期データ配列
    isValid = false;  % データの有効性フラグ

    % ファイルの存在を確認
    if exist(filePath, 'file')
        try
            data = readmatrix(filePath);
            if isempty(data)
                disp(['Warning: File is empty - ', filePath]);
            else
                disp(['Data loaded successfully: ', filePath]);
                isValid = true;
            end
        catch
            disp(['Error reading file: ', filePath]);
        end
    else
        disp(['File does not exist: ', filePath]);
    end
end

% データ処理ループ
for t = 0:num_time_steps-1
    xrain_time = time_start + t * time_step;
    xrain_file = fullfile('E:\XRAIN累積降水量ver2(四国)\2023\8\', ...
        sprintf('202308%02d-%02d.csv', day(xrain_time), hour(xrain_time)));
    
    [data, isValid] = safeLoadData(xrain_file);
    
    if ~isValid
        continue;  % 無効なデータはスキップ
    end

    % 緯度経度の生成
    latitudes = linspace(34, 31, 1440);  % 北から南へ
    longitudes = linspace(131, 135, 1280); % 西から東へ
    
    % 対象範囲内のデータのみを抽出
    lat_indices = find(latitudes >= lat_range(1) & latitudes <= lat_range(2));
    lon_indices = find(longitudes >= lon_range(1) & longitudes <= lon_range(2));
    
    valid_data = data(lat_indices, lon_indices);
    valid_data = valid_data(valid_data >= 0);  % 0以上のデータのみ扱う
    
    if isempty(valid_data)
        fprintf('No valid data in file %s. Skipping...\n', xrain_file);
        continue;
    end
    
    % 体積計算
    valid_volume = valid_data / 1000 * (250 * 250); % 体積[m³]
    
    % 平均降水量計算
    precip_volume_sum_XRAIN(end+1) = sum(valid_volume);% 時間ごとの領域内合計値
    precip_times_XRAIN(end+1) = xrain_time;
end


% 共通の時間軸を見つける
[common_times, idx_ERA5, idx_XRAIN] = intersect(time_axis, precip_times_XRAIN);

% 共通の時間軸に基づく降水量データを抽出
common_precip_ERA5 = precip_volume_sum_ERA5(idx_ERA5);
common_precip_XRAIN = precip_volume_sum_XRAIN(idx_XRAIN);

% 相関係数を計算
[R, P] = corrcoef(common_precip_ERA5, common_precip_XRAIN);

% 相関係数とp値を表示
fprintf('相関係数: %f\n', R(1,2));
fprintf('p値: %f\n', P(1,2));

% オプション：散布図と回帰線をプロット
figure;
scatter(common_precip_ERA5, common_precip_XRAIN, 'filled');
hold on;
% 最小二乗回帰線
fit = polyfit(common_precip_ERA5, common_precip_XRAIN, 1);
plot(common_precip_ERA5, polyval(fit, common_precip_ERA5), '-r');
xlabel('ERA5 降水量 (m³)');
ylabel('XRAIN 降水量 (m³)');
title(sprintf('ERA5とXRAINの降水量の相関係数: %.2f', R(1,2)));
grid on;
hold off;

% 散布図の保存
saveas(gcf, fullfile('C:\Users\murqk\Desktop\卒論結果まとめ\高知\XRAIN(累積降水量使用)\', 'Correlation_Scatter_Plot(範囲高知).png'));
