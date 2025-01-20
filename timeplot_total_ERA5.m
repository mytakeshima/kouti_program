% 必要なデータの読み込み
cloud_file = 'kouchicloud.nc';
cape_file = 'kouchicape.nc';
rain_file = 'kouchirain.nc';

% 比湿データ
q_data = ncread(cloud_file, 'q'); % 比湿データ
lat_q = ncread(cloud_file, 'latitude');
lon_q = ncread(cloud_file, 'longitude');


% 降水量データ
rain_data =ncread(rain_file, 'tp');


% CAPEデータ
cape_data = ncread(cape_file, 'cape');

% 風速データ（DLS計算用）
u_data = ncread(cloud_file, 'u'); % 東西風
v_data = ncread(cloud_file, 'v'); % 南北風

% 圧力レベル（DLS用）
level_500hpa_idx = 1; % 500 hPa
level_1000hpa_idx = 3; % 1000 hPa

% 時間軸設定
time_start = datetime(2023, 8, 12, 0, 0, 0) + hours(9); % JST
time_step = hours(1);
num_time_steps = size(q_data, 4)-23;
time_axis = time_start + (0:num_time_steps-1) * time_step;

%XRAINデータ範囲 32.5-34 132.3-134.5
%使用データ範囲 32.5-34 132.5-134.5

%高知範囲 32.5-34 132.5-134.5
%四国範囲 31-34 131-135


% 緯度・経度の範囲設定
lat_target = 33.25; % 中心緯度
lon_target = 133.4; % 中心経度
lat_range = [31, 34];
lon_range = [131, 135];

% 比湿範囲インデックス
lat_idx_q = find(lat_q >= lat_range(1) & lat_q <= lat_range(2));
lon_idx_q = find(lon_q >= lon_range(1) & lon_q <= lon_range(2));

% CAPE平均値計算
% cape_avg = squeeze(mean(mean(cape_data(lon_idx_q, lat_idx_q, :), 1), 2));
% CAPE平均値計算の範囲を調整
cape_avg = squeeze(mean(mean(cape_data(lon_idx_q, lat_idx_q, 1:num_time_steps), 1), 2));


% 領域の面積 (m²) の計算
vert_length = 27.75 * 1000;  % 縦方向 (m)
horiz_length = 21.88 * 1000; % 横方向 (m)
area_ERA5 = vert_length * horiz_length;  % 面積 (m²)

% 降水量データを体積に変換
rain_volume = rain_data(lon_idx_q, lat_idx_q, 1:num_time_steps) * area_ERA5; %m^3

% 降水量平均値計算
rain_volume_avg = squeeze(mean(mean(rain_volume, 1), 2)); % グリッドごとの平均降水量



% 比湿平均値計算
% q_selected = q_data(lon_idx_q, lat_idx_q, 2, :); % 850 hPaの比湿
% time_axisに行の個数を合わせる
q_selected = q_data(lon_idx_q, lat_idx_q, 2, 1:num_time_steps); % 850 hPaの比湿
q_avg = squeeze(mean(mean(q_selected, 1), 2));



% DLS計算のための風速データの抽出範囲を調整
u_500 = u_data(lon_idx_q, lat_idx_q, level_500hpa_idx, 1:num_time_steps);
v_500 = v_data(lon_idx_q, lat_idx_q, level_500hpa_idx, 1:num_time_steps);
u_1000 = u_data(lon_idx_q, lat_idx_q, level_1000hpa_idx, 1:num_time_steps);
v_1000 = v_data(lon_idx_q, lat_idx_q, level_1000hpa_idx, 1:num_time_steps);


dls = sqrt((u_500 - u_1000).^2 + (v_500 - v_1000).^2); % 深層シアー
dls_avg = squeeze(mean(mean(dls, 1), 2));






% % 降水量計算
% precip_volume_avg = [];
% precip_times = datetime.empty;
% 
% % % 緯度経度の範囲
% % target_lat_range = [36, 39]; % 中心緯度 ± 0.5
% % target_lon_range = [135, 139]; % 中心経度 ± 0.5
% 
% % ファイルの存在、中身、フォーマットを確認する関数
% function [data, isValid] = safeLoadData(filePath)
%     data = [];  % 初期データ配列
%     isValid = false;  % データの有効性フラグ
% 
%     % ファイルの存在を確認
%     if exist(filePath, 'file')
%         try
%             data = readmatrix(filePath);
%             if isempty(data)
%                 disp(['Warning: File is empty - ', filePath]);
%             else
%                 disp(['Data loaded successfully: ', filePath]);
%                 isValid = true;
%             end
%         catch
%             disp(['Error reading file: ', filePath]);
%         end
%     else
%         disp(['File does not exist: ', filePath]);
%     end
% end
% 
% % データ処理ループ
% for t = 0:num_time_steps-1
%     xrain_time = time_start + t * time_step;
%     xrain_file = fullfile('E:\XRAIN(高知)\', ...
%         sprintf('202308%02d-%02d00.csv', day(xrain_time), hour(xrain_time)));
% 
%     [data, isValid] = safeLoadData(xrain_file);
% 
%     if ~isValid
%         continue;  % 無効なデータはスキップ
%     end
% 
%     % 緯度経度の生成
%     latitudes = linspace(34.5, 31, 1680);  % 北から南へ
%     longitudes = linspace(131, 135, 1280); % 西から東へ
% 
%     % 対象範囲内のデータのみを抽出
%     lat_indices = find(latitudes >= lat_range(1) & latitudes <= lat_range(2));
%     lon_indices = find(longitudes >= lon_range(1) & longitudes <= lon_range(2));
% 
%     valid_data = data(lat_indices, lon_indices);
%     valid_data = valid_data(valid_data >= 0);  % 0以上のデータのみ扱う
% 
%     if isempty(valid_data)
%         fprintf('No valid data in file %s. Skipping...\n', xrain_file);
%         continue;
%     end
% 
%     % 体積計算
%     valid_volume = valid_data / 1000 * (250 * 250); % 体積[m³]
% 
%     % 平均降水量計算
%     precip_volume_avg(end+1) = mean(valid_volume);
%     precip_times(end+1) = xrain_time;
% end


%% JTLNデータ読み取り
%% パラメータ設定
% データディレクトリのベースパス
base_dir = 'E:\JTLN20230812~0821\2023\08\'; % JTLN保存ディレクトリ　
addpath 'C:\Users\murqk\Desktop\EN\'; % GetJson関数のパス






% 雷の個数を初期化
lightning_counts = zeros(num_time_steps, 1); % num_time_stepsと同じ長さに設定

% データ処理ループ
for t = 1:num_time_steps
    % 現在の時間
    curr_time = time_axis(t);

    % 対応するディレクトリを構築
    curr_date_dir = fullfile(base_dir, datestr(curr_time, 'dd'));

    % JSONファイル名を構築
    file_pattern = sprintf('FLASHES_%s.json', datestr(curr_time, 'yyyy-mm-ddTHH-MM'));
    json_file = fullfile(curr_date_dir, file_pattern);

    % JSONファイルが存在しない場合はスキップ
    if ~isfile(json_file)
        fprintf('File %s does not exist. Skipping...\n', json_file);
        continue;
    end

    % JSONファイルの読み込み
    [time, type, latitude, longitude, ~, ~, ~] = GetJson(json_file);

    % 緯度経度フィルタ
    lat_idx = latitude >= lat_range(1) & latitude <= lat_range(2);
    lon_idx = longitude >= lon_range(1) & longitude <= lon_range(2);

    % 現在の時間枠内のデータをカウント
    valid_idx = lat_idx & lon_idx & (time >= curr_time & time < (curr_time + time_step));
    lightning_counts(t) = sum(valid_idx);
end

% サブプロット作成
figure;

% サブプロット1: 降水量とCAPE
subplot(4, 1, 1);
yyaxis left;
plot(time_axis, cape_avg, '-b', 'LineWidth', 1.5);
ylabel('CAPE (J/kg)');
yyaxis right;
plot(time_axis, rain_volume_avg, '-r', 'LineWidth', 1.5);
ylabel('降水量（m³）');
xlabel('時間 (JST)');
title('CAPEおよび降水量の時系列');
legend('CAPE',  '降水量（体積 PV）');
grid on;

% サブプロット2: 比湿
subplot(4, 1, 2);
yyaxis left;
plot(time_axis, q_avg, '-g', 'LineWidth', 1.5);
ylabel('比湿 (kg/kg)');
yyaxis right;
plot(time_axis, rain_volume_avg, '-r', 'LineWidth', 1.5);
ylabel('降水量（m³）');
xlabel('時間 (JST)');
title('比湿および降水量の時系列');
legend('比湿 (q)',  '降水量（体積 PV）');
grid on;

% サブプロット3: DLS
subplot(4, 1, 3);
yyaxis left;
plot(time_axis, dls_avg, '-m', 'LineWidth', 1.5);
ylabel('DLS (m/s)');
yyaxis right;
plot(time_axis, rain_volume_avg, '-r', 'LineWidth', 1.5);
ylabel('降水量（m³）');
xlabel('時間 (JST)');
title('DLSおよび降水量の時系列');
legend('DLS',  '降水量（体積 PV）');
grid on;

% サブプロット4: 雷の個数
subplot(4, 1, 4);
yyaxis left;
plot(time_axis, lightning_counts, '-b', 'LineWidth', 1.5);
ylabel('雷の個数');
yyaxis right;
plot(time_axis, rain_volume_avg, '-r', 'LineWidth', 1.5);
ylabel('降水量（m³）');
xlabel('時間 (JST)');
title('雷および降水量の時系列');
legend('雷',  '降水量（体積 PV）');
grid on;

% プロット保存
saveas(gcf, fullfile('C:\Users\murqk\Desktop\卒論結果まとめ\高知\', '時系列プロットERA5(範囲四国).png'));
