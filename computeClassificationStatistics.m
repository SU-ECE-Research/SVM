function [TP, TN, FP, FN, TPR, SPC, PPV, NPV, FPR, FDR, ACC] = computeClassificationStatistics(results)
% Compute classification statistics (true positive and true negative rates, as well as false positive and fals negative rates. 

% See the following page for more detailed definitions

% Note: "1" in the input means that the sample contains a snow leopard

% Columns in the results variable:
% Ground Truth (1)         Classification Result (2)

% How many images that contain snow leopards were classified as images
% containing snow leopards
TP = sum((results(:, 1) == 1) & (results(:,2) == 1));     % true positive

% How many images that do not contain snow leopards were classified as
% images that do not contain snow leopards
TN = sum((results(:, 1) == 0) & (results(:,2) == 0));     % true negative

% How many images that do not contain snow leopards were classified as
% containting a snow leopard
FP = sum((results(:, 1) == 0) & (results(:,2) == 1));     % false positive

% How many images that contain a snow leopard were classified as not
% containing a snow leopard
FN = sum((results(:, 1) == 1) & (results(:,2) == 0));     % false negative

% Number of actual images that do not contain a snow leopard
N = sum(results(:, 1) == 0);     % number of negatives in ground truth
% Number of actual images that do contain a snow leopard
P = sum(results(:, 1) == 1);     % number of positivesin ground truth

% Sensitivity or True Positive Rate - proportion of actual positives which are correctly identified as such
% (We want is as close to 100% as possible.)
TPR = 100*TP/P;

% Specificity or True Negative Rate - proportion of negatives which are correctly identified as such
% (We want it as close to 100% as possible.)
SPC = 100*TN/N;

% Precision or Positive Predictive Value
% (We want it as close to 100% as possible.)
PPV = 100*TP/(TP + FP);

% Negative Predictive Value
% (We want it as close to 100% as possible.)
NPV = 100*TN/(TN + FN);

% Fall-Out or False Positive Rate
% (We want it as close to 0% as possible.)
FPR = 100*FP/N;

% False Discovery Rate
% (We want it as close to 0% as possible.)
FDR = 100 - PPV;

% Accuracy
% (We want it as close to 100% as possible.)
ACC = 100*(TP + TN)/(P + N);







    



