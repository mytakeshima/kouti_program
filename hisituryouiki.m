% 数日間にわたるデータの読み取りとプロット方法

info = ncinfo('kouchicloud.nc');

% NetCDFファイルからデータを読み込む
data = ncread('kouchicloud.nc', 'q');

lat = ncread('kouchicloud.nc', 'latitude'); % 緯度データを読み込む
lon = ncread('kouchicloud.nc', 'longitude'); % 経度データを読み込む

% シェープファイルのパスを適切に設定
S = shaperead('C:\Users\murqk\Desktop\EN\JPN_adm1.shp'); % シェープファイルのパスを確認

% プロットする緯度と経度の範囲を指定（例: 北緯30度〜45度、東経130度〜145度）


%高知範囲 32.5-34 132.5-134.5
%四国範囲 31-34 131-135
lat_range = [36 39];
lon_range = [135 139];

% 指定した範囲のインデックスを取得
lat_idx = find(lat >= 31 & lat <= 34);
lon_idx = find(lon >= 131 & lon <= 135);

% 指定した範囲のデータを取り出す
lat_sub = lat(lat_idx);
lon_sub = lon(lon_idx);

% 開始日時の設定
start_time = datetime(2023, 8, 12, 9, 0, 0); % 2024/9/17 09:00

% 各時間ステップに対するプロットのループ
for time_index = 1:241
    % 現在の時間を計算
    current_time = start_time + hours(time_index - 1);

    % % 現在の時間ステップのデータを取り出す
    % data_slice = data(:,:,time_index);
    % data_sub = data_slice(lon_idx, lat_idx);
   
    % 現在の時間ステップの比湿データを取得
    q_slice = q_data(lon_idx_q, lat_idx_q, 2, time_index); % 850 hPaの比湿

    % プロットの作成
    figure('Visible', 'off'); % 新しい図を非表示で作成

    % pcolorプロット
    pcolor(lon_sub, lat_sub, q_slice');
    shading interp; % 補間をかけて滑らかに表示
    colorbarHandle = colorbar; % カラーバーを表示し、そのハンドルを取得
    xlabel('経度');
    ylabel('緯度');
    title(['日時: ' datestr(current_time, 'yyyy/mm/dd HH:MM(LT)')]);


    % カラーバーにラベルを追加
    %caxis([0 100]);
    ylabel(colorbarHandle, '比湿 kg/kg'); % カラーバーのラベルを設定

    % 日本地図の枠を表示
    hold on;
    mapshow(S, 'FaceColor', 'none'); % 日本地図を表示（輪郭のみ）
    grid on;
    hold off;

     % ファイル名に日時を追加
    time_str = datestr(current_time, 'yyyymmdd_HHMM'); % ファイル名用の日時文字列
    file_name = ['比湿_plot_' time_str '.png']; % ファイル名を生成


    % プロットの保存や表示に関する処理
    saveas(gcf, fullfile('C:\Users\murqk\Desktop\卒論結果まとめ\高知\四国比湿(LT)\', file_name));

    % 図を閉じる
    close(gcf);
end
