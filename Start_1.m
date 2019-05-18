clc;
close all;
clear;

%% �N���w���H���έp��X�Ҧ����� 
% Ū���ɮ� (data, time), �C���ɮ׬�������
disp('Ū���ɮ�...');

PATH = './export/';

% �п�J�m�W
NAME = '�L�a�w';

% �д��Ѧ@���X�Ӷ��q
STAGES = {'a','b','c','d','e','f','g','h','i'};

for s=1:length(STAGES)
    
    STAGE = STAGES{s};

    getFiles = dir(['./data/' NAME '/' STAGE '/emg/']);

    EMGAll5Mins = [];

    for f=3:length(getFiles)

        FILE = strrep(getFiles(f).name,'.dat','');

        disp([ STAGE '���q�ഫ�i�� ' num2str(f-2) '/' num2str(length(getFiles)-2) ' : ' FILE '.dat' ]);

        EMGFILE = table2cell(readtable(['./data/' NAME '/' STAGE '/emg/' FILE '.dat'], 'Format', '%f%s' ));

        % ���Φ��������᪺���
        % t5EMG = �C�q���������ɶ��P���, t5Lens = �@�X�q������
        [t5EMG, t5Lens] = DataSplit(EMGFILE, 5);

        %% �p�⤭�����@�q�� RMS
        % ���|�B���s���
        DataCells = {t5Lens}; % ���������q���ơA�Ω�p��C�q��������
        TimeCells = {t5Lens}; % ���������ɶ���ơA�Ω�p��C�q�������� RRI
        for i=1:t5Lens
            EMG = t5EMG{:,i};
            DataCells{i} = cell2mat(EMG(:,1));
            TimeCells{i} = EMG(:,2);
        end

        EMG5Mins = zeros(t5Lens, 2);
        for i=1:t5Lens %t5Lens
            % �ļ�
            %FS = 200;

            % ���X�q��t���
            dc = DataCells{:,i};
            dc = dc(:,1);

            % ���`�������b 100~300 ����
            tmpDC = dc(dc >= 100 & dc <= 400);
            mDC = mean(tmpDC);

            errCounter = 0;
            % �N���X�z���Ȩ��N��������
            for d=1:length(dc)
                if dc(d) < 100
                    % disp([ '���`��(�L�p) - ' num2str(dc(d)) ] );
                    dc(d) = mDC;
                    errCounter = errCounter + 1;
                end
                if dc(d) > 400
                    % disp([ '���`��(�L�j) - ' num2str(dc(d)) ] );
                    dc(d) = mDC;
                    errCounter = errCounter + 1;
                end
            end
            % disp([ '���`�Ȥ�� - ' num2str(errCounter) '/' num2str(d) ] );

            % Stage
            EMG5Mins(i,1) = s;
            % RMS
            EMG5Mins(i,2) = sqrt(sum(dc.^2)/length(dc));
            
            % ���X�ɶ��b���
            %tc = TimeCells{:,i}; tc = tc(:,1);

        end

        % For debug
        % EMG5MinsTable = array2table(EMG5Mins, 'VariableNames', Header);

        % �N�������@�q����Ʋ֭p�_��
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

    % �@�� Time Domain �ܤƹϪ�
    showTDchart = 0;
    if showTDchart
        for k=1:length(EMGAll5Mins(1,:))
            time = 0:5:length(EMGAll5Mins(:,1))*5;
            % �Ĥ@����0
            data = vertcat(0, EMGAll5Mins(:,k));
            figure, plot(time, data)
            title(['HRV �ɰ���� - ' Header{k}])
            xlabel('����(min)')
            ylabel('�@��(ms)');
        end
    end
    
end


