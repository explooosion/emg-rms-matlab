clc;
close all;
clear;

%% 將指定的人切割計算出所有指標 
% 讀取檔案 (data, time), 每個檔案為五分鐘
disp('讀取檔案...');

PATH = './export/';

% 請輸入姓名
NAME = '林家安';

% 請提供共有幾個階段
STAGES = {'a','b','c','d','e','f','g','h','i'};

for s=1:length(STAGES)
    
    STAGE = STAGES{s};

    getFiles = dir(['./data/' NAME '/' STAGE '/emg/']);

    EMGAll5Mins = [];

    for f=3:length(getFiles)

        FILE = strrep(getFiles(f).name,'.dat','');

        disp([ STAGE '階段轉換進度 ' num2str(f-2) '/' num2str(length(getFiles)-2) ' : ' FILE '.dat' ]);

        EMGFILE = table2cell(readtable(['./data/' NAME '/' STAGE '/emg/' FILE '.dat'], 'Format', '%f%s' ));

        % 切割成五分鐘後的資料
        % t5EMG = 每段五分鐘的時間與資料, t5Lens = 共幾段五分鐘
        [t5EMG, t5Lens] = DataSplit(EMGFILE, 5);

        %% 計算五分鐘一段的 RMS
        % 堆疊、分群資料
        DataCells = {t5Lens}; % 五分鐘的電位資料，用於計算每段五分鐘的
        TimeCells = {t5Lens}; % 五分鐘的時間資料，用於計算每段五分鐘的 RRI
        for i=1:t5Lens
            EMG = t5EMG{:,i};
            DataCells{i} = cell2mat(EMG(:,1));
            TimeCells{i} = EMG(:,2);
        end

        EMG5Mins = zeros(t5Lens, 2);
        for i=1:t5Lens %t5Lens
            % 採樣
            %FS = 200;

            % 取出電位差資料
            dc = DataCells{:,i};
            dc = dc(:,1);

            % 正常值應落在 100~300 不等
            tmpDC = dc(dc >= 100 & dc <= 400);
            mDC = mean(tmpDC);

            errCounter = 0;
            % 將不合理的值取代成平均值
            for d=1:length(dc)
                if dc(d) < 100
                    % disp([ '異常值(過小) - ' num2str(dc(d)) ] );
                    dc(d) = mDC;
                    errCounter = errCounter + 1;
                end
                if dc(d) > 400
                    % disp([ '異常值(過大) - ' num2str(dc(d)) ] );
                    dc(d) = mDC;
                    errCounter = errCounter + 1;
                end
            end
            % disp([ '異常值比例 - ' num2str(errCounter) '/' num2str(d) ] );

            % Stage
            EMG5Mins(i,1) = s;
            % RMS
            EMG5Mins(i,2) = sqrt(sum(dc.^2)/length(dc));
            
            % 取出時間軸資料
            %tc = TimeCells{:,i}; tc = tc(:,1);

        end

        % For debug
        % EMG5MinsTable = array2table(EMG5Mins, 'VariableNames', Header);

        % 將五分鐘一段的資料累計起來
        EMGAll5Mins = [ EMGAll5Mins ; EMG5Mins ];

        %% Export 5mins Data
        if ~exist([ PATH NAME ], 'dir')
            mkdir([ PATH NAME ]);
        end
        % writetable(EMG5MinsTable, [PATH NAME STAGE FILE '.csv']);
    end


    %% Export All 5mins Data

    %RMSScale = rescale(EMGAll5Mins(:,2),1,100);
    %EMGAll5Mins(:,3) = RMSScale;
        
    Header = {'Stage','RMS','RMS_Scale'};
    EMGAll5MinsTable = array2table(EMGAll5Mins, 'VariableNames', Header);

    % Export All Day Data
    writetable(EMGAll5MinsTable, [PATH NAME '/' STAGE '-EMGAll5Mins.csv']);

    % 一天 Time Domain 變化圖表
    showTDchart = 0;
    if showTDchart
        for k=1:length(EMGAll5Mins(1,:))
            time = 0:5:length(EMGAll5Mins(:,1))*5;
            % 第一筆補0
            data = vertcat(0, EMGAll5Mins(:,k));
            figure, plot(time, data)
            title(['HRV 時域指標 - ' Header{k}])
            xlabel('分鐘(min)')
            ylabel('毫秒(ms)');
        end
    end
    
end


