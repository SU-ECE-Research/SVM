% BEWARE: Hardcoded 
% create_svm_testing_folder_list
% create the list of svm testing folders in the same format as our other
% folderLists

% Joshua Beard & Taz Bales-Heisterkamp
% C: 2/4/17
% E: 2/4/17


resultsFolder = '\\ecefs1\ECE_Research-Space-Share\RESULTS\Tajikistan_2012_CTPhotos\Murghab_Concession\';
load([resultsFolder 'folderList']);
load([resultsFolder 'svmTrainFolderList']);
%%
testNamesList = {
    'ATO04\P016',...
    'ATO12\CAM41985\061412',...
    'ATO13\P022',...
    'ATO14\P015',...
    'ATO16\P037',...
    'ATO18\P027',...
    'ATO22\CAM42020\051312',...
    'ATO22\CAM42020\062512',...
    'ATO24\P040',...
    'ATO26\CAM41922\092212',...
    'ATO26\CAM42007\092212',...
    'ATO31\CAM40679\091612',...
    'ATO31\CAM42010\091612',...
    'ATO32\P026',...
    'ATO33\P031',...
    'ATO35\P039',...
    'ATO37\P009',...
    'MAD04\CAM42012\072212',...
    'MAD04\CAM42012\091712',...
    'MAD05\P024',...
    'MAD14\P001',...
};

indexer = 1;

for k = 1:length(folderList)
    for m = 1:length(testNamesList)
        if strcmp(folderList(k).name, testNamesList{m})
            svmTestFolderList(indexer) = folderList(k);
            indexer = indexer + 1;
        end
    end
end

dup = 0;
for q = 1:length(svmTrainFolderList)
    iterator = 1;
    doneSearching = false;
    while ~doneSearching
        % If a folder is in both, delete it from test
        if  length(svmTrainFolderList(q).name) > 10 &&...
            length(svmTestFolderList(iterator).name) > 10;
            
            if strcmp(  svmTrainFolderList(q).name(1:14),...
                        svmTestFolderList(iterator).name(1:14))
                fprintf('q = %i\ni = %i\n', q, iterator); 
                dup = dup+1;
            end
        end
        if strcmp(svmTrainFolderList(q).name, svmTestFolderList(iterator).name)
            %svmTestFolderList = [svmTestFolderList(1:iterator-1),svmTestFolderList(iterator+1:end)];
            dup =dup+1;
            fprintf('q = %i\ni = %i\n', q, iterator);
            doneSearching = true;
        end
        % If we reach end of svmTrainFolderList, it's not duplicated
        iterator = iterator+1;
        if iterator > length(svmTestFolderList)
            doneSearching = true;
        end
    end
end

save([resultsFolder 'svmTestFolderList.mat'],'svmTestFolderList');
done;