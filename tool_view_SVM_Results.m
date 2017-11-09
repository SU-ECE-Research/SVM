% Get SVM results and play with it
%{
Joshua Beard
C: 3/6/17
E: 3/6/17

%}
%% Parameters
%clear all; close all;
svmResultsPath = '//ecefs1/ECE_Research-Space-Share/RESULTS/Tajikistan_2012_CTPhotos/Murghab_Concession/';
svmTrialLogCollectionName = 'svmTrialLogCollection_Empirical_VariableCostFP'; % Arbitrarily chosen
svmFeatureSourceName = 'featureSource';
logNum = 1;
%%
% Load data and get a nice handle on it
load([svmResultsPath svmTrialLogCollectionName]);
trial = eval([svmTrialLogCollectionName '{logNum}']);
%trial = tlc(logNum);

load([svmResultsPath svmFeatureSourceName]);
fs = eval(svmFeatureSourceName);
%%
numFPFNimgs = 3;

TP = repmat(trial.isCat',100,1).* trial.correct;
FN = repmat(trial.isCat',100,1).*~trial.correct;
TN = repmat(~trial.isCat',100,1).* trial.correct; 
FP = repmat(~trial.isCat',100,1).*~trial.correct;

[FPmax, FPidx] = sort(sum(FP),'descend');
[FNmax, FNidx] = sort(sum(FN),'descend');
%%
for q = 1:numFPFNimgs
    FPmaxName = featureSource{FPidx(q)};
    FNmaxName = featureSource{FNidx(q)};
    figure;
    imshow(FPmaxName);
    figure;
    title(['Consistent False Positive ' num2str(q)]);
    imshow(FNmaxName);
    title(['Consistent False Negative ' num2str(q)]);
end
%% Plotting
close all;
figure; hold on;
%plot(sum(TP), '.');
plot(sum(FN), '.');
%plot(sum(TN), 'o');
plot(sum(FP), '.');
legend('FN','FP');
%legend('TP','FN', 'TN','FP');
%%

correctAndTest = trial.wasTest.*trial.correct;
imgAcc = sum(trial.correct)./sum(trial.wasTest);
histogramBins = 0:1:1;

figure; hold on;
plot(imgAcc,'o');
title('Individual image accuracy');

figure; hold on;
histogram(imgAcc, histogramBins)
title('Histogram of image accuracy')

%
