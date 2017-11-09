% Tool for analysing some information about SVM trials
%{
Testing results from simulated train/test trials
Joshua Beard
C: 2/6/17
E: 2/6/17
%}

%%
clear all;
rp = '\\ecefs1\ECE_Research-Space-Share\RESULTS\Tajikistan_2012_CTPhotos\Murghab_Concession\';
seriesID = '100';
fn = 'svmTrialLog_';
log = load([rp fn seriesID]);
log = log.svmTrialLog;
%%
close all;
si = ['Series # ' seriesID];
prior = 'Empirical Prior';
correctTest = log.wasTest.*log.correct;
numTests = sum(log.wasTest,2);
numCorrect = sum(log.correct,2);
ratCorrectTest = sum(int8(log.correct)./int8(log.wasTest),2);
% Plot performance as a function of number of testing images
figure;
plot(numTests, log.performance, 'o');
title(['Correct Classification Rate vs # of Test Images']);

% Plot number of correct classifications as a function of number of testing
% images
figure;
plot(numTests, numCorrect,'o');
title(['Correct Classifications vs # of Test Images']);

% histogram of correct classifications
figure;
histogram(sum(log.correct))%,15)
title(['Histogram of Correct Classifications']);


% histogram of correct classifications
figure;
histogram((log.performance))%,15)
title(['Histogram of Correct Classification Rate']);

% number of times tested (should be uniform)
figure; hold on;
plot(sum(log.wasTest),'o');
plot(sum(log.correct),'.');
title([prior ': was test & correct']);
legend('wasTest','correct');

% Histogram of number of test images
figure;
histogram(numTests, 10)
title(['Histogram of Number of Test Images']);