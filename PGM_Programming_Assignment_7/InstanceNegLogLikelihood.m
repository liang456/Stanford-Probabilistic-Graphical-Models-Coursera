% function [nll, grad] = InstanceNegLogLikelihood(X, y, theta, modelParams)
% returns the negative log-likelihood and its gradient, given a CRF with parameters theta,
% on data (X, y).
%
% Inputs:
% X            Data.                           (numCharacters x numImageFeatures matrix)
%              X(:,1) is all ones, i.e., it encodes the intercept/bias term.
% y            Data labels.                    (numCharacters x 1 vector)
% theta        CRF weights/parameters.         (numParams x 1 vector)
%              These are shared among the various singleton / pairwise features.
% modelParams  Struct with three fields:
%   .numHiddenStates     in our case, set to 26 (26 possible characters)
%   .numObservedStates   in our case, set to 2  (each pixel is either on or off)
%   .lambda              the regularization parameter lambda
%
% Outputs:
% nll          Negative log-likelihood of the data.    (scalar)
% grad         Gradient of nll with respect to theta   (numParams x 1 vector)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

function [nll, grad] = InstanceNegLogLikelihood(X, y, theta, modelParams)

% featureSet is a struct with two fields:
%    .numParams - the number of parameters in the CRF (this is not numImageFeatures
%                 nor numFeatures, because of parameter sharing)
%    .features  - an array comprising the features in the CRF.
%
% Each feature is a binary indicator variable, represented by a struct
% with three fields:
%    .var          - a vector containing the variables in the scope of this feature
%    .assignment   - the assignment that this indicator variable corresponds to
%    .paramIdx     - the index in theta that this feature corresponds to
%
% For example, if we have:
%
%   feature = struct('var', [2 3], 'assignment', [5 6], 'paramIdx', 8);
%
% then feature is an indicator function over X_2 and X_3, which takes on a value of 1
% if X_2 = 5 and X_3 = 6 (which would be 'e' and 'f'), and 0 otherwise.
% Its contribution to the log-likelihood would be theta(8) if it's 1, and 0 otherwise.
%
% If you're interested in the implementation details of CRFs,
% feel free to read through GenerateAllFeatures.m and the functions it calls!
% For the purposes of this assignment, though, you don't
% have to understand how this code works. (It's complicated.)

featureSet = GenerateAllFeatures(X, modelParams);

% Use the featureSet to calculate nll and grad.
% This is the main part of the assignment, and it is very tricky - be careful!
% You might want to code up your own numerical gradient checker to make sure
% your answers are correct.
%
% Hint: you can use CliqueTreeCalibrate to calculate logZ effectively.
%       We have halfway-modified CliqueTreeCalibrate; complete our implementation
%       if you want to use it to compute logZ.

nll = 0;
grad = zeros(size(theta));
%%%
% Your code here:

%Initialise empty factors
n = length(y);
for i=1:n-1
    F(i) = EmptyFactorStruct();
    F(i).var = i;
    F(i).card = 26;
    F(i).val = zeros(1,26);
    
    FF(i) = EmptyFactorStruct();
    FF(i).var = [i, i+1];
    FF(i).card = [26, 26];
    FF(i).val = zeros(1,26*26);
end;
F(n) = EmptyFactorStruct();
F(n).var = n;
F(n).card = [26];
F(n).val = zeros(1,26);

allFactors = [F, FF];

%Populate the factor values

%Loop over each factor
ThetaCount = zeros(size(theta));
for f = 1:length(allFactors)
    factorVar = allFactors(f).var;
    for i=1:length(featureSet.features)
        %Find the factor that has the same scope as the factor
        if(length(factorVar) ~= length(featureSet.features(i).var))
            continue;
        end;
        if all(sort(factorVar) == sort(featureSet.features(i).var))
            if(all(y(featureSet.features(i).var) == featureSet.features(i).assignment))
                ThetaCount(featureSet.features(i).paramIdx) = ThetaCount(featureSet.features(i).paramIdx) + 1;
            end;
            map = [];
            for j = 1:length(factorVar)
                map(j) = find(factorVar == featureSet.features(i).var(j));
            end;
            idx = AssignmentToIndex(featureSet.features(i).assignment(map), allFactors(f).card);
            allFactors(f).val(idx) = allFactors(f).val(idx) + theta(featureSet.features(i).paramIdx);
        end;
    end;
end;

for i=1:length(allFactors)
    allFactors(i).val = exp(allFactors(i).val);
end;

P = CreateCliqueTree(allFactors);
[P, logZ] = CliqueTreeCalibrate(P,0);
reg =  sum(theta.^2)*(modelParams.lambda/2);
featureWeights = (theta.*ThetaCount);
nll = logZ-sum(featureWeights)+reg;


% Calculate normalized probability distributions
for f=1:length(allFactors)
    for i=1:length(P.cliqueList)
        if(length(intersect(P.cliqueList(i).var, allFactors(f).var)) == length(allFactors(f).var))
            if(all(intersect(P.cliqueList(i).var, allFactors(f).var) == allFactors(f).var))
                V = setdiff(P.cliqueList(i).var, allFactors(f).var);
                allFactors(f) = FactorMarginalization(P.cliqueList(i), V);
                allFactors(f).val = allFactors(f).val./sum(allFactors(f).val);
                break;
            end;
        end;
    end;
end;
ModelFactorCounts = zeros(size(theta));

for i=1:length(featureSet.features)
    %Find the factor that has the same scope as the factor
    for f = 1:length(allFactors)
        factorVar = allFactors(f).var;
        if(length(factorVar) ~= length(featureSet.features(i).var))
            continue;
        end;
        if all(sort(factorVar) == sort(featureSet.features(i).var))
            map = [];
            for j = 1:length(factorVar)
                map(j) = find(factorVar == featureSet.features(i).var(j));
            end;
            idx = AssignmentToIndex(featureSet.features(i).assignment, allFactors(f).card);
            ModelFactorCounts(featureSet.features(i).paramIdx) = ModelFactorCounts(featureSet.features(i).paramIdx) + allFactors(f).val(idx);
            break;
        end;
    end;
end;

regTheta = modelParams.lambda*theta;
grad = ModelFactorCounts - ThetaCount + regTheta;