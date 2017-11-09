% tool_curateSimulationTrials
%{
By running driver_computeClassificationStatistics and varying
CAT_PERCENT_DEV and TEST_PERCENT_DEV, you can empirically determine which
trials were most representative of your true data. Run this script
immediately after running driver_computeClassificationStatistics to use
those parameters to curate a selection of trials that represents your data
well.
Author: Joshua Beard
C: 2/7/17
E: 6/8/17
%}
driver_computeClasificationsStatistics

oldLog = svmTrialLog;
svmTrialLog.wasTest = oldLog.wasTest(goodTrials,:);
svmTrialLog.correct = oldLog.correct(goodTrials,:);
svmTrialLog.absScore = oldLog.absScore(goodTrials,:);
svmTrialLog.performance = oldLog.performance(goodTrials,:);
svmTrialLog.maxPerformance = max(svmTrialLog.performance);
svmTrialLog.minPerformance = min(svmTrialLog.performance);
svmTrialLog.avgPerformance = mean(svmTrialLog.performance);
%%
save([resultsPath 'svmTrialLog_100representative'], 'svmTrialLog');