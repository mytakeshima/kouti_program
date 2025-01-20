% 必要なデータの読み込み
cloud_file = 'kouchicloud.nc';
cape_file = 'kouchicape.nc';

% 比湿データ
q_data = ncread(cloud_file, 'q'); % 比湿データ
lat_q = ncread(cloud_file, 'latitude');
lon_q = ncread(cloud_file, 'longitude');

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
num_time_steps = size(q_data, 4)-23; %おそらくここの値を変えれば時間範囲を短くできる。
time_axis = time_start + (0:num_time_steps-1) * time_step;

% 緯度・経度の範囲設定
% XRAIN範囲 31-34.5 131-135 南北1680 東西1280
% デスクトップにある方は32.5-34 132.5-134.5 南北720 東西704
% ERA5範囲 31-34 131-135

%高知範囲 32.5-34 132.5-134.5
%四国範囲 31-34 131-135

lat_target = 37.2; % 中心緯度
lon_target = 136.9; % 中心経度
lat_range = [32.5, 34];
lon_range = [132.5, 134.5];

% 比湿範囲インデックス
lat_idx_q = find(lat_q >= lat_range(1) & lat_q <= lat_range(2));
lon_idx_q = find(lon_q >= lon_range(1) & lon_q <= lon_range(2));

% CAPE平均値計算
% cape_avg = squeeze(mean(mean(cape_data(lon_idx_q, lat_idx_q, :), 1), 2));
% CAPE平均値計算の範囲を調整
cape_avg = squeeze(mean(mean(cape_data(lon_idx_q, lat_idx_q, 1:num_time_steps), 1), 2));


% 比湿平均値計算
% q_selected = q_data(lon_idx_q, lat_idx_q, 2, :); % 850 hPaの比湿
% time_axisに行の個数を合わせる
q_selected = q_data(lon_idx_q, lat_idx_q, 2, 1:num_time_steps); % 850 hPaの比湿
q_avg = squeeze(mean(mean(q_selected, 1), 2));

% % DLS計算
% u_500 = u_data(lon_idx_q, lat_idx_q, level_500hpa_idx, :);
% v_500 = v_data(lon_idx_q, lat_idx_q, level_500hpa_idx, :);
% u_1000 = u_data(lon_idx_q, lat_idx_q, level_1000hpa_idx, :);
% v_1000 = v_data(lon_idx_q, lat_idx_q, level_1000hpa_idx, :);


% DLS計算のための風速データの抽出範囲を調整
u_500 = u_data(lon_idx_q, lat_idx_q, level_500hpa_idx, 1:num_time_steps);
v_500 = v_data(lon_idx_q, lat_idx_q, level_500hpa_idx, 1:num_time_steps);
u_1000 = u_data(lon_idx_q, lat_idx_q, level_1000hpa_idx, 1:num_time_steps);
v_1000 = v_data(lon_idx_q, lat_idx_q, level_1000hpa_idx, 1:num_time_steps);


dls = sqrt((u_500 - u_1000).^2 + (v_500 - v_1000).^2); % 深層シアー
dls_avg = squeeze(mean(mean(dls, 1), 2));









% 降水量計算
precip_volume_avg = [];
precip_times = datetime.empty;



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
    %データ後から更新します。更新先 XRAIN範囲 31-34.5 131-135 南北1680 東西1280
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
    precip_volume_avg(end+1) = mean(valid_volume);
    precip_times(end+1) = xrain_time;
end










%% JTLNデータ読み取り
%% パラメータ設定
% データディレクトリのベースパス
base_dir = 'E:\JTLN20230812~0821\2023\08\'; % JTLN保存ディレクトリ　
addpath 'C:\Users\murqk\Desktop\EN\'; % GetJson関数のパス


% 結果保存用変数
lightning_counts = zeros(num_time_steps, 1); % 時間ごとの雷の個数


%% データ処理
for t = 1:num_time_steps
    % 現在の時間
    curr_time = time_axis(t) - hours(9);

    % 累積する雷の数の初期化
    cumulative_lightning_count = 0;

    % 10分間隔のファイルを処理
    for minute = 0:10:50
        % 現在の時間から10分間隔の時間を設定
        specific_time = curr_time + minutes(minute);

        % 対応するディレクトリを構築
        curr_date_dir = fullfile(base_dir, datestr(specific_time, 'dd'));

        % JSONファイル名を構築
        file_pattern = sprintf('FLASHES_%s.json', datestr(specific_time, 'yyyy-mm-ddTHH-MM'));
        json_file = fullfile(curr_date_dir, file_pattern);

        % JSONファイルが存在しない場合はスキップ
        if ~isfile(json_file)
            fprintf('File %s does not exist. Skipping...\n', json_file);
            continue;
        end

        % JSONファイルの読み込み
        [time, type, latitude, longitude, ~, ~, ~] = GetJson(json_file);
         fprintf('JSON file %s loaded successfully.\n', json_file);  % 読み込み成功メッセージ


        % 緯度経度フィルタ
        lat_idx = latitude >= lat_range(1) & latitude <= lat_range(2);
        lon_idx = longitude >= lon_range(1) & longitude <= lon_range(2);

        % 現在の時間枠内のデータをカウント
        % valid_idx = lat_idx & lon_idx & (time >= specific_time & time < (specific_time + minutes(10)));
        valid_idx = lat_idx & lon_idx
        cumulative_lightning_count = cumulative_lightning_count + sum(valid_idx);
    end

    % 時間ステップごとの累積雷の数を記録
    lightning_counts(t) = cumulative_lightning_count;
end



% %% データ処理
% for t = 1:num_time_steps
%     % 現在の時間
%     curr_time = time_axis(t);
% 
%     % 対応するディレクトリを構築
%     curr_date_dir = fullfile(base_dir, datestr(curr_time, 'dd'));
% 
%     % JSONファイル名を構築
%     file_pattern = sprintf('FLASHES_%s.json', datestr(curr_time, 'yyyy-mm-ddTHH-MM'));
%     json_file = fullfile(curr_date_dir, file_pattern);
% 
%     % JSONファイルが存在しない場合はスキップ
%     if ~isfile(json_file)
%         fprintf('File %s does not exist. Skipping...\n', json_file);
%         continue;
%     end
% 
%     % JSONファイルの読み込み
%     [time, type, latitude, longitude, ~, ~, ~] = GetJson(json_file);
% 
%     % 緯度経度フィルタ
%     lat_idx = latitude >= lat_range(1) & latitude <= lat_range(2);
%     lon_idx = longitude >= lon_range(1) & longitude <= lon_range(2);
% 
%     % 現在の時間枠内のデータをカウント
%     valid_idx = lat_idx & lon_idx & (time >= curr_time & time < (curr_time + time_step));
%     lightning_counts(t) = sum(valid_idx);
% end






% cape_avg, q_avg, dls_avg, precip_volume_avg, precip_timesが存在するものとする

% 降水量の時間軸と他データの時間軸を揃える
[common_times, idx_precip, idx_other] = intersect(precip_times, time_axis);

% データの共通部分を抽出
precip_common = precip_volume_avg(idx_precip);
cape_common = cape_avg(idx_other);
q_common = q_avg(idx_other);
dls_common = dls_avg(idx_other);

lightning_common = lightning_counts(idx_other);

% 相互相関の計算
% CAPEと降水量
[corr_cape, lags_cape] = xcorr(precip_common - mean(precip_common), ...
                               cape_common - mean(cape_common), 'coeff');

% 比湿と降水量
[corr_q, lags_q] = xcorr(precip_common - mean(precip_common), ...
                         q_common - mean(q_common), 'coeff');

% DLSと降水量
[corr_dls, lags_dls] = xcorr(precip_common - mean(precip_common), ...
                             dls_common - mean(dls_common), 'coeff');

%雷と降水量
[corr_lightning, lags_lightning] = xcorr(precip_common - mean(precip_common), ...
                             lightning_common - mean(lightning_common), 'coeff');


% 相関係数が最も高いタイムラグのインデックスを求める
[~, max_idx_cape] = max(abs(corr_cape));
[~, max_idx_q] = max(abs(corr_q));
[~, max_idx_dls] = max(abs(corr_dls));
[~, max_idx_lightning] = max(abs(corr_lightning));

% 最も高い相関のタイムラグを取得
lag_cape = lags_cape(max_idx_cape);
lag_q = lags_q(max_idx_q);
lag_dls = lags_dls(max_idx_dls);
lag_lightning = lags_lightning(max_idx_lightning);

% データをタイムラグに応じてシフト
precip_shifted_cape = circshift(precip_common, -lag_cape);
precip_shifted_q = circshift(precip_common, -lag_q);
precip_shifted_dls = circshift(precip_common, -lag_dls);
precip_shifted_lightning = circshift(precip_common, -lag_lightning);


% CAPEと降水量の上位10点
[sorted_values_cape, sorted_indices_cape] = sort(abs(cape_common - mean(cape_common)) .* abs(precip_shifted_cape - mean(precip_shifted_cape)), 'descend');
top_10_indices_cape = sorted_indices_cape(1:10);
top_10_times_cape = common_times(top_10_indices_cape);



% DLSと降水量の上位10点
[sorted_values_dls, sorted_indices_dls] = sort(abs(dls_common - mean(dls_common)) .* abs(precip_shifted_dls - mean(precip_shifted_dls)), 'descend');
top_10_indices_dls = sorted_indices_dls(1:10);
top_10_times_dls = common_times(top_10_indices_dls);

% 比湿と降水量の上位10点
[sorted_values_q, sorted_indices_q] = sort(abs(q_common - mean(q_common)) .* abs(precip_shifted_q - mean(precip_shifted_q)), 'descend');
top_10_indices_q = sorted_indices_q(1:10);
top_10_times_q = common_times(top_10_indices_q);

% 雷と降水量の上位10点
[sorted_values_lightning, sorted_indices_lightning] = sort(abs(lightning_common - mean(lightning_common)) .* abs(precip_shifted_q - mean(precip_shifted_q)), 'descend');
top_10_indices_lightning = sorted_indices_lightning(1:10);
top_10_times_lightning = common_times(top_10_indices_lightning);



% 結果の表示
fprintf('CAPEと降水量の相関に寄与する上位10点の時刻:\n');
for i = 1:10
    fprintf('%d: %s\n', i, datestr(top_10_times_cape(i)));
end


fprintf('\nDLSと降水量の相関に寄与する上位10点の時刻:\n');
for i = 1:10
    fprintf('%d: %s\n', i, datestr(top_10_times_dls(i)));
end

fprintf('\n比湿と降水量の相関に寄与する上位10点の時刻:\n');
for i = 1:10
    fprintf('%d: %s\n', i, datestr(top_10_times_q(i)));
end

fprintf('\n雷と降水量の相関に寄与する上位10点の時刻:\n');
for i = 1:10
    fprintf('%d: %s\n', i, datestr(top_10_times_lightning(i)));
end




% 散布図プロット
figure;

% CAPEと降水量
subplot(4, 1, 1);
scatter(cape_common, precip_shifted_cape, 10,'b', 'filled');
xlabel('CAPE');
ylabel('降水量');
title(sprintf('降水量とCAPEの散布図 (タイムラグ: %d, 相関係数: %.2f)', ...
    -lag_cape, corr_cape(max_idx_cape)));
grid on;


% DLSと降水量
subplot(4, 1, 2);
scatter(dls_common, precip_shifted_dls,10, 'm', 'filled');
xlabel('DLS');
ylabel('降水量');
title(sprintf('降水量とDLSの散布図 (タイムラグ: %d, 相関係数: %.2f)', ...
    -lag_dls, corr_dls(max_idx_dls)));
grid on;


% 比湿と降水量
subplot(4, 1, 3);
scatter(q_common, precip_shifted_q, 10,'g', 'filled');
xlabel('比湿');
ylabel('降水量');
title(sprintf('降水量と比湿の散布図 (タイムラグ: %d, 相関係数: %.2f)', ...
    -lag_q, corr_q(max_idx_q)));
grid on;

% 雷と降水量
subplot(4, 1, 4);
scatter(lightning_common, precip_shifted_q,10, 'r', 'filled');
xlabel('雷');
ylabel('降水量');
title(sprintf('降水量と雷の散布図 (タイムラグ: %d, 相関係数: %.2f)', ...
    -lag_lightning, corr_lightning(max_idx_lightning)));
grid on;


% プロットの保存
saveas(gcf, fullfile('C:\Users\murqk\Desktop\卒論結果まとめ\高知\XRAIN(累積降水量使用)', '散布図プロット(範囲高知).png'));
