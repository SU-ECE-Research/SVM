%{ 
main_SVM
Script for training and testing a SVM to detect snow leopards.
Iterates tests several hundred times to generate average CCR
Assumes featuresLabels is a NxD+1
N = number of samples
D = number of features
Last column: labels

Authors:
Agnieszka Miguel & Joshua Beard
C: 2/3/17
E: 6/8/17

For more information about SVM and this implementation, see
https://www.mathworks.com/help/stats/support-vector-machines-for-binary-classification.html#bsr5o09

NOTE: There are some magic numbers in << getUniqueCameras >> based on the 
old naming convention in this code, and must be changed based on the new 
naming convention
%}

%% Parameters
clear all; close all;
resultsPath = '\\ecefs1\ECE_Research-Space-Share\RESULTS\Tajikistan_2012_CTPhotos\Murghab_Concession\';
svmFeaturesLabels = 'svmFeaturesLabels';
featureSource = 'featureSource';
folderListName = 'svmEveryFolderList';
%features = [totalSpots, templateSpots, spotDensity, templateCoverage, avgSize, label]

% SVM Parameters ----------------------------------------------------------
% The SVM's prior is the likelihood of seeing a given class in the testing
% data. A uniform prior assumes each class is equally likely (like seeing a
% head or tail on a coin flip. An empirical prior assumes that the testing
% data will be distributed the same way the training data is (i.e. if we
% flip a coin 100 times as our training set, and we see 90 heads, then
% we are nine times as likely to see a head on a flip in our testing set);
% this effectively gives us a higher "correct classification rate" (which
% is only one way of measuring performance). We found in our testing that
% a uniform prior yielded a lower false negative rate (FNR), which is
% actually very important to us, as we don't want to lose any snow
% leopards.
svm_prior = 'empirical';
%svm_prior = 'uniform';

% The SVM's cost matrix is another way to skew our results one way or
% another. It is oriented as:
% TP FN
% FP TN
% Since we don't want to apply a cost to any correct classifications, it is
% always 0 on the diagonal. If we put a higher weight at the false negative
% (FN) spot, we'll see a shift towards positive classifications. If we put
% a higher weight at the false positive (FP) spot, we'll see a shift
% towards negative classifications. Since we expect to see only 1-7% of all
% our images to be cats, we would rather skew towards positive so we don't
% lose cats.
svm_costMat = [0 1;
               1 0];
           
% The SVM kernel is the transformation from feature space to some other
% discriminant space. I don't have a very deep understanding of it, so I
% suggest reading Machine Learning and Pattern Recognition by Bishop. We
% use the Radial Basis Function, or RBF
svm_kernel = 'rbf';


           
% Whether to standardize the features before testing
svm_standardize = true;

% Change this to save details about this series of tests with this file
seriesDescription = 'empirical-0110-rbf-true';

% Number of train-test cycles in this series
numTrials = 1000;     

% Dimensionality of features
% Assume data is NxD, labels are attached
featureDimensionality = size(svmFeaturesLabels,2)-1;  

% Average ratio of training data
trainRatio = .7;

%% Initialization
load([resultsPath svmFeaturesLabels '.mat']);
load([resultsPath featureSource '.mat']);
load([resultsPath folderListName '.mat']);
folderList = eval(folderListName);

%{
SVM trial log:
- wasTest: was this sample testing data for this trial?
- correct: 1 means correct, 0 means incorrect or not test
- CCR: correct classification rate for each trial
- isCat: self-explanatory
- min, max, avg CCR: self-explanatory
%}
svmTrialLog = struct(   'wasTest', zeros(numTrials,size(svmFeaturesLabels,1),'logical'),...
                        'correct', zeros(numTrials,size(svmFeaturesLabels,1),'logical'),...
                        'absScore', zeros(numTrials,size(svmFeaturesLabels,1),'single'),...
                        'CCR', zeros(numTrials,1,'single'),...
                        'isCat', zeros(1,size(svmFeaturesLabels,1), 'logical'),...
                        'maxCCR', 0,...
                        'minCCR', 1,...
                        'avgCCR', 0);


%% TODO: Fix << getUniqueCameras >> to work with new file system
% Determine which cameras are unique
% NOTE: << getUniqueCameras >> must be modified for new naming convention
% There are some magic numbers in the function below, BEWARE!
uniqueCams_isTraining = getUniqueCameras(folderList)

%%
% Find if unique camera is in feature source data
uniqueCamInFeatureSource = zeros(length(uniqueCams_isTraining),1);
for q = 1:size(svmFeaturesLabels, 1)
    for u = 1:length(uniqueCams_isTraining) 
        if sameCam(featureSource{q,1}, uniqueCams_isTraining{u,1})
            uniqueCamInFeatureSource(u) = 1;
            break;
        end
    end
end
    
%% Train/Test Trial Cycle
for trial = 1:numTrials
    
    % Randomly select training data
    trainData = [];
    testData = []; % Necessary?
    
    % Separate training/testing data by camera, so we don't train and test
    % on the same background
    
    % For each unique camera...
    for q = 1:size(uniqueCams_isTraining,1)
        
        % Get a random number from (0,1). If it's lower than train ratio,
        % use it as training. This means if train ratio is .7, there's a
        % 70% chance that a given camera will become training data
        if rand < trainRatio
            uniqueCams_isTraining{q,2} = 1;
        else
            uniqueCams_isTraining{q,2} = 0;
        end
    end
    
    %% Using the previously sorted training/testing cameras, sort training
    % and testing data. There's probably a more efficient way to sort this,
    % but w/e, it's certainly not the longest component of this process.
    % For every image
    for q = 1:size(svmFeaturesLabels, 1)
        
        % For every unique camera
        for u = 1:size(uniqueCams_isTraining, 1) 
            
            % If the image came from that camera
            if sameCam(featureSource{q,1}, uniqueCams_isTraining{u,1})
                
                % If this camera is marked for training
                if uniqueCams_isTraining{u,2} 
                    % Put it in training
                    trainData = [trainData;  svmFeaturesLabels(q,:),q];
                
                % If it's not marked for training, put it in testing
                else 
                    testData = [testData; svmFeaturesLabels(q,:),q];
                    svmTrialLog.wasTest(trial, q) = true; % Record this as a test sample
                end
                break;
            end
        end
    end
                  
    %% Training
    SVMModel = fitcsvm( trainData(:, 1:featureDimensionality),...       % Features
                        trainData(:, featureDimensionality+1),...       % Labels
                        'Prior', svm_prior,...      % Prior probabilities of each class
                        'Cost', svm_costMat,...      % Cost Matrix
                        'Standardize', svm_standardize,...     % Standardize features
                        'KernelFunction', svm_kernel);   % Kernel

    %% Classification
    [classResult, score] = predict( SVMModel,...
                                    testData(:, 1:featureDimensionality));
    %% Verification
    correct = classResult == testData(:,featureDimensionality+1);
    % CCR
    p = single(sum(correct)/size(testData,1))
    % Record the CCR of this trial
    svmTrialLog.CCR(trial) = p;
    if p < svmTrialLog.minCCR
        svmTrialLog.minCCR = p;
    end
    if p > svmTrialLog.maxCCR
        svmTrialLog.maxCCR = p;
    end
    % If a sample was used in this test, record its classification
    % correctness in the trial log
    for q = 1:length(correct)
        svmTrialLog.correct(trial, testData(q,end)) = correct(q);
        svmTrialLog.absScore(trial, testData(q,end)) = abs(score(q));
    end
    
end

% TODO: bring min and max outside the loop to speed it up a little
svmTrialLog.avgCCR = mean(svmTrialLog.CCR);
svmTrialLog.isCat = svmFeaturesLabels(:,featureDimensionality+1);
save([resultsPath 'svmTrialLog_' seriesDescription], 'svmTrialLog');
% Uncomment the following line if computer is too slow because RAM fills up
%clear svmTrialLog;
fprintf('REMEMBER:\nsvmTrialLog is saved!');
done;