%%------------------------------ NOTE ----------------------------------- %
% Do not run this code! The excel file has been created and running this
% will overwrite the good information we have!

% For generating labels for SVM

%{
Author: Joshua Beard
C: 2/1/17
E: 2/1/17
%}

%% Parameters
resultsFolder_a = '\\ecefs1\ECE_Research-Space-Share\RESULTS\Tajikistan_2012_CTPhotos\Murghab_Concession\';
resultsFolder_b = '\\ecefs1\ECE_Research-Space-Share\RESULTS\Tajikistan_2012_CTPhotos\Madiyan_Pshart\';
dataFolder_a = '\\ecefs1\ECE_Research-Space-Share\DATA\Tajikistan_2012_CTPhotos\Murghab_Concession\';
dataFolder_b = '\\ecefs1\ECE_Research-Space-Share\DATA\Tajikistan_2012_CTPhotos\Madiyan_Pshart\';
folderList = 'svmEveryFolderList';
saveName = 'svm_every_labels_1';
okToProceed = 1
if isempty(dir(pathJoin((resultsFolder_a, saveName))))
    overwriteOK = input('Are you sure you want to overwrite an Excel file that already exists? [Y/n] >>>', 's')
    okToProceed = strcmp(lower(overwriteOK),'y') || strcmp(lower(overwriteOK),'yes')
end

if okToProceed
    %% Initialization
    load([resultsFolder_a folderList]);
    folderList = eval(folderList);
    excelData{1,1} = 'LOCATION';
    excelData{1,2} = 'LINK';
    excelData{1,3} = 'FILE NAME';
    excelData{1,4} = 'LABEL';
    problems = 0;
    problemSets = {};
    n = 1;
    % Necessary?
    skipList = {[resultsFolder_a 'ATO06\P038\Set_197\'];...
                [resultsFolder_a 'ATO13\P022\Set_100\'];...
                [resultsFolder_a 'ATO18\P027\Set_44\'];...
                [resultsFolder_a 'ATO24\P040\Set_38\'];...
                [resultsFolder_a 'ATO37\P009\Set_55\'];...
                [resultsFolder_a 'ATO12\CAM41985\052912\Set_3\'];...
                };

    %% Work
    % Do every folder
    for f = 1:length(folderList)
        thisFolder = folderList(f).name;
        if ~strcmp(thisFolder(end), '\')
            thisFolder = [thisFolder '\'];
        end
        thisFolderPath_a = [resultsFolder_a thisFolder];
        thisFolderPath_b = [resultsFolder_b thisFolder];
        imageLocation_a = [dataFolder_a thisFolder];
        imageLocation_b = [dataFolder_b thisFolder];
        try
            load([thisFolderPath_a 'setInfo.mat']);
            useB = false;
        catch ME
            try
                load([thisFolderPath_b 'setInfo.mat']);
            catch ME
                problems = problems+1;
                problemSets{problems, 1} = thisFolder;
                problemSets{problems, 2} = ME.identifier;
                problemSets{problems, 3} = ME.message;
                continue;
            end
                useB = true;
        end


        % Do every set
        for s = 1:length(setInfo)
            % Do every image
            for i = 1:setInfo(s).nImgs
                % Grab the image name, directory, etc. Dump it into an excel
                % file
                n = n + 1;
                if useB
                    excelData{n, 1} = [imageLocation_b];           % Location of image
                    excelData{n, 2} = [imageLocation_b setInfo(s).names{i}];
                else
                    excelData{n, 1} = [imageLocation_a];           % Location of image
                    excelData{n, 2} = [imageLocation_a setInfo(s).names{i}];
                end
                excelData{n, 3} = setInfo(s).names{i};  % Image name
                excelData{n,4} = 0;                     % Label (assume 0)
            end
        end
    end

    xlswrite([resultsFolder_a saveName], excelData);
    done;
end
    
