% driver_computeClassificationStatistics
%{
- Loads a specific svmTrialLog
- Determines which trials we should be counting based on:
    - distribution of total images in training vs testing
    - distribution of cat images in training vs testing
- Runs computeClassificationStatistics 
- Saves classification stats

Taz Bales-Heisterkamp & Joshua B=ed
C: 2/6/17
E: 2/7/17
%}


%clear all;

%%
%{
fileNamea = 'svmTrialLogCollection_a_1100';
fileNameb = 'svmTrialLogCollection_b_1101';
fileNamec = 'svmTrialLogCollection_c_1102';
saveName = 'svmTrialLogCollection_1100';
resultsPath = '\\ecefs1\ECE_Research-Space-Share\RESULTS\Tajikistan_2012_CTPhotos\Murghab_Concession\';
a = load([resultsPath fileNamea '.mat']);
b = load([resultsPath fileNameb '.mat']);
c = load([resultsPath fileNamec '.mat']);
a = a.svmTrialLogCollection;
b = b.svmTrialLogCollection;
c = c.svmTrialLogCollection;
svmTrialLogCollection = [a,b,c];
%}
numTrials = length(svmTrialLogCollection{1, 1}.performance);

classStats = struct('allTP',    zeros(numTrials, 1),   ...
                    'allTN',    zeros(numTrials, 1),   ...
                    'allFP',    zeros(numTrials, 1),   ...
                    'allFN',    zeros(numTrials, 1),   ...
                    'allTPR',   zeros(numTrials, 1),   ...
                    'allSPC',   zeros(numTrials, 1),   ...
                    'allPPV',   zeros(numTrials, 1),   ...
                    'allNPV',   zeros(numTrials, 1),   ...
                    'allFPR',   zeros(numTrials, 1),   ...
                    'allFDR',   zeros(numTrials, 1),   ...
                    'allACC',   zeros(numTrials, 1),   ...
                    'avgTP',    0,                     ...
                    'avgTN',    0,                     ...
                    'avgFP',    0,                     ...
                    'avgFN',    0,                     ...
                    'avgTPR',   0,                     ...
                    'avgSPC',   0,                     ...
                    'avgPPV',   0,                     ...
                    'avgNPV',   0,                     ...
                    'avgFPR',   0,                     ...
                    'avgFDR',   0,                     ...
                    'avgACC',   0                     ...
                    );
%% 
for simNum = 1:length(svmTrialLogCollection)
    currentLog = svmTrialLogCollection{1, simNum};
    
    %numTrials = length(currentLog.performance);
    numImages = length(currentLog.isCat);

    %% find average classification stats

    % for every trial
    for t = 1:numTrials
            resultsForCCS = [];
            % for every image
            for i = 1:numImages
                % if it was a testing image
                if (currentLog.wasTest(t, i))

                    %get groundTruth
                    groundTruth = currentLog.isCat(i);

                    %get our classification
                    if currentLog.correct(t, i)
                        ourClass = groundTruth;
                    else
                        ourClass = ~groundTruth;
                    end

                    resultsForCCS = [resultsForCCS; [groundTruth, ourClass]];
                end % if test

            end % for every image
            [TP(t), TN(t), FP(t), FN(t), TPR(t), SPC(t), PPV(t), NPV(t), FPR(t), FDR(t), ACC(t)] = computeClassificationStatistics(resultsForCCS);
            
    end % for every trial
    
    classStats.allTP = TP; 
    classStats.allTN = TN; 
    classStats.allFP = FP; 
    classStats.allFN = FN; 
    classStats.allTPR = TPR; 
    classStats.allSPC = SPC; 
    classStats.allPPV = PPV; 
    classStats.allNPV = NPV; 
    classStats.allFPR = FPR; 
    classStats.allFDR = FDR; 
    classStats.allACC = ACC; 
    
    % find our averages
    classStats.avgTP = mean(TP, 'omitnan'); 
    classStats.avgTN = mean(TN, 'omitnan'); 
    classStats.avgFP = mean(FP, 'omitnan'); 
    classStats.avgFN = mean(FN, 'omitnan'); 
    classStats.avgTPR = mean(TPR, 'omitnan'); % true positive rate
    classStats.avgSPC = mean(SPC, 'omitnan'); % true negative rate 
    classStats.avgPPV = mean(PPV, 'omitnan'); % positive predictive value   100*TP/(TP + FP);
    classStats.avgNPV = mean(NPV, 'omitnan'); % negative predictive value   100*TN/(TN + FN);
    classStats.avgFPR = mean(FPR, 'omitnan'); % false positive rate         100*FP/N;
    classStats.avgFDR = mean(FDR, 'omitnan'); % false discovery rate        100 - PPV;
    classStats.avgACC = mean(ACC, 'omitnan'); % accuracy (CCR)              100*(TP + TN)/(P + N);
   
    svmTrialLogCollection{1, simNum}.classStats = classStats;
end
save([resultsPath saveName], 'svmTrialLogCollection');

