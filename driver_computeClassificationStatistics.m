% driver_computeClassificationStatistics

%{
- Loads a specific svmTrialLog
- Determines which trials we should be counting based on:
    - distribution of total images in training vs testing
    - distribution of cat images in training vs testing
- Runs computeClassificationStatistics 
- Saves classification stats

Taz Bales-Heisterkamp
C: 2/6/17
E: 2/7/17
%}

%main_SVM;
clear all;
%% get svmTrialLog 
trialLogName = 'svmTrialLog_2';
resultsPath = '\\ecefs1\ECE_Research-Space-Share\RESULTS\Tajikistan_2012_CTPhotos\Murghab_Concession\';
load([resultsPath trialLogName '.mat']);

%saveSuffix = '_TestFilteredNO_CatFilteredNO';
%saveSuffix = '_TestFilteredNO_CatFilteredYES';
%saveSuffix = '_TestFilteredYES_CatFilteredNO';
saveSuffix = '_TestFilteredYES_CatFilteredYES';
%%
% whether we want to eliminate trials which don't have an acceptable
% percentage of testing images or testing images with cats
filterByTestPercent = true;
%filterByTestPercent = false;
filterByCatPercent = true;
%filterByCatPercent = false;


% how far the percentage of cats in the testing set can deviate from the
% overall percentage of cats
CAT_PERCENT_DEV = .0079; 

% percentage of images which were used for testing rather than training
DESIRED_TEST_PERCENT = .30;
TEST_PERCENT_DEV = .099;

minTestPercent = max((DESIRED_TEST_PERCENT - TEST_PERCENT_DEV),0);
maxTestPercent = min((DESIRED_TEST_PERCENT + TEST_PERCENT_DEV),1);

%% 
% find a bunch of values
numTrials = length(svmTrialLog.performance);
numImages = length(svmTrialLog.isCat);
numCats = sum(svmTrialLog.isCat);

totalPercentCats = numCats/numImages;
minCatPercent = max((totalPercentCats - CAT_PERCENT_DEV),0);
maxCatPercent = min((totalPercentCats + CAT_PERCENT_DEV),1);

% these are numTrials x 1 vectors
numTestImages = sum(svmTrialLog.wasTest, 2);
numTestCats = svmTrialLog.wasTest*svmTrialLog.isCat;

percentTest = numTestImages./numImages;
percentCats = numTestCats./numTestImages;

%% filter our trials 

% logical vector of trials to consider
goodTrials = ones(numTrials, 1, 'logical');

if filterByTestPercent  
   goodTrials = (goodTrials                     &...
                percentTest < maxTestPercent    &...
                percentTest > minTestPercent    );
end

if filterByCatPercent  
   goodTrials = (goodTrials                     &...
                percentCats < maxCatPercent    &...
                percentCats > minCatPercent    );
end
% Print number of good trials
sum(goodTrials)


%% find average classification stats

% for every trial
for t = 1:numTrials
    % if we're considering it
    if goodTrials(t)
        resultsForCCS = [];
        for i = 1:numImages
            % if it was a testing image
            if (svmTrialLog.wasTest(t, i))

                %get groundTruth
                groundTruth = svmTrialLog.isCat(i);

                %get our classification
                if svmTrialLog.correct(t, i)
                    ourClass = groundTruth;
                else
                    ourClass = ~groundTruth;
                end

                resultsForCCS = [resultsForCCS; [groundTruth, ourClass]];
            end
        end

        [TP(t), TN(t), FP(t), FN(t), TPR(t), SPC(t), PPV(t), NPV(t), FPR(t), FDR(t), ACC(t)] = computeClassificationStatistics(resultsForCCS);
    end
end
orig_stats = {'TP', TP; 'TN', TN; 'FP', FP; 'FN', FP; 'TPR', TPR; 'SPC', SPC; 'PPV', PPV; 'NPV', NPV; 'FPR', FPR; 'FDR', FDR; 'ACC', ACC};

% get rid of indexes we don't care about 
TP = TP(goodTrials);
TN = TN(goodTrials);
FP = FP(goodTrials);
FN = FN(goodTrials);
TPR = TPR(goodTrials);
SPC = SPC(goodTrials);
PPV = PPV(goodTrials);
NPV = NPV(goodTrials);
FPR = FPR(goodTrials);
FDR = FDR(goodTrials);
ACC = ACC(goodTrials);

% find our averages
averages.TP = mean(TP, 'omitnan'); % probs not helpful
averages.TN = mean(TN, 'omitnan'); % probs not helpful
averages.FP = mean(FP, 'omitnan'); % probs not helpful
averages.FN = mean(FN, 'omitnan'); % probs not helpful

averages.TPR = mean(TPR, 'omitnan'); % true positive rate
averages.SPC = mean(SPC, 'omitnan'); % true negative rate 
averages.PPV = mean(PPV, 'omitnan'); % positive predictive value   100*TP/(TP + FP);
averages.NPV = mean(NPV, 'omitnan'); % negative predictive value   100*TN/(TN + FN);
averages.FPR = mean(FPR, 'omitnan'); % false positive rate         100*FP/N;
averages.FDR = mean(FDR, 'omitnan'); % false discovery rate        100 - PPV;
averages.ACC = mean(ACC, 'omitnan'); % accuracy (CCR)              100*(TP + TN)/(P + N);

classification_stats = {'orig_stats', orig_stats; 'averages', averages};
save([resultsPath trialLogName '_stats' saveSuffix], 'classification_stats');
