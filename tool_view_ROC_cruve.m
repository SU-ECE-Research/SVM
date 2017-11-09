% Tool for creating ROC curve. This is what we used for the ICIP paper i
% think?
% submission
% TODO: fix hardcoded potions
%{
Joshua Beard & Taz Bales-Heisterkamp
C: 2/7/17
E: 2/7/17
%}
clear all;
close all;
uniform = 'svmTrialLogCollection_1200';     % TODO
empirical = 'svmTrialLogCollection_1100';   % TODO
%dumb = 'svmTrialLogCollection_2000';
resultsPath = '\\ecefs1\ECE_Research-Space-Share\RESULTS\Tajikistan_2012_CTPhotos\Murghab_Concession\';
load([resultsPath uniform]);
uni = svmTrialLogCollection;
load([resultsPath empirical]);
emp = svmTrialLogCollection;
%}
%%

figure; hold on;
vec = linspace(0,1,2);


q = 1;
%for q = 1:length(collection)
A = uni{q};
% Get classifications
t1 = repmat(A.isCat',100,1).* A.correct;    % Cat & correct -> TP
f1 = repmat(A.isCat',100,1).*~A.correct;    % Cat & incorrect -> FN
f2 = repmat(~A.isCat',100,1).* A.correct;   % Not cat & correct -> TN
t2 = repmat(~A.isCat',100,1).*~A.correct;   % Not cat & incorrect -> FP
T = (t1+t2) > 0;
F = (f1+f2) > 0;
% Get scores
TS = T.*A.absScore.*A.wasTest;
FS = -(F.*A.absScore.*A.wasTest);
score = TS+FS;
% Average the scores
avgScore = mean(score);
% Do the ROC away.
[Xu,Yu] = perfcurve(A.isCat, avgScore, 1);
Integral(q) = sum(Yu)/length(Yu);
%for q = 1:length(collection)
A = emp{q};
% Get classifications
t1 = repmat(A.isCat',100,1).* A.correct;
f1 = repmat(A.isCat',100,1).*~A.correct;
f2 = repmat(~A.isCat',100,1).* A.correct; 
t2 = repmat(~A.isCat',100,1).*~A.correct;
T = (t1+t2) > 0;
F = (f1+f2) > 0;
% Get scores
TS = T.*A.absScore.*A.wasTest;
FS = -(F.*A.absScore.*A.wasTest);
score = TS+FS;
% Average the scores
avgScore = mean(score);
% Do the ROC away.
[Xe,Ye] = perfcurve(A.isCat, avgScore, 1);
Integral(q) = sum(Ye)/length(Ye);

up = plot(Xu,Yu,'linewidth', 2);
ep = plot(Xe,Ye,'linewidth', 2);
plot(vec,vec,'k--');

set(gca, 'FontSize', 12);
title(['ROC Curves for Empirical and Uniform Priors'], 'FontSize', 14);
leg = legend('Uniform Prior', 'Empirical Prior','Location','SE');
set(leg, 'fontSize',14);
xlabel('False Positive Rate (FPR)', 'FontSize', 14);
ylabel('True Positive Rate (TPR)', 'FontSize', 14);
axis square;