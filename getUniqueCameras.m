function uniqueCameras = getUniqueCameras(folderList)
% Iterates through all folders in folderList and returns unique cameras
% contained therein, specifically for grouping images in SVM

%{
Joshua Beard
6/7/17
NOTE: There are some magic numbers optimized for the old naming 
convention in this code, so it must be rewritten for the new old naming 
convention
%}

uniqueCameras = cell(1,2);
thisCamNum = 0
% Go through all folders
for f = 1:length(folderList)
    uname = true;
    % Go through list of found unique cameras
    for  n = 1:length(uniqueCameras)
        if length(folderList(f).name) > 10 && length(uniqueCameras{n}) > 10
            if strcmp(folderList(f).name(1:14), uniqueCameras{n}(1:14))
                uname = false;
                break;
            end
        end
    end
    
    if uname
        thisCamNum = thisCamNum+1
        if length(folderList(f).name) > 10;
            % Madiyan_Pshart
            uniqueCameras{thisCamNum,1} = folderList(f).name(1:14);
        else
            % Murghab_Concession
            uniqueCameras{thisCamNum,1} = folderList(f).name;
        end
    end
end