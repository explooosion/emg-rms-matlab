clc;
close all;
clear;

%% 整合匯出資料
% 請先跑完 Start_1.m
% 將每人的所有階段資料整併成一份資料

PATH = './export/';

getNames = dir(PATH);

for s=1:length(getNames)
    if(length(getNames(s).name) == 3)
    % ======================================================
    NAME = getNames(s).name;
    getFiles = dir([PATH NAME '/']);
    files = {};
    HRVAll = [];
    for s=1:length(getFiles)
        if(length(getFiles(s).name) == 17)
            files{end+1} = getFiles(s).name;
        end
    end
    for f=1:length(files)  
        HRVAll = [ HRVAll ; table2cell(readtable(['./export/' NAME '/' cell2mat(files(f)) ]))];
    end
    
    HRVAll = cell2mat(HRVAll);
    HRVAll(:,3) = rescale(HRVAll(:,2),1,100);
    
    Header = {'Stage','RMS','RMS_Scale'};
    HRVAll = array2table(HRVAll, 'VariableNames', Header);

    writetable(HRVAll, [PATH NAME '/' 'HRV.csv']);
    % ======================================================
    end
end



