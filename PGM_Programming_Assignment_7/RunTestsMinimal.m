%% Change this to test the different parts of the assignment.
%% Or, you can comment it out and set it globally from the command line.
testNum = 2

%% Load all the necessary files:
load('Train1X.mat');
load('Train1Y.mat');
load('Validation1X.mat');
load('Validation1Y.mat');
load('Part1Lambdas.mat');
load('ValidationAccuracy.mat');
%% Part 2:
load('Part2Sample.mat');


switch testNum
  case 1
    thetaOpt = LRTrainSGD(Train1X, Train1Y, 0);
    predY = LRPredict(Train1X, thetaOpt);
    accuracy = LRAccuracy(Train1Y, predY)
    assert(accuracy, 0.96, 0.005);

  case 2
    allAcc = LRSearchLambdaSGD(Train1X, Train1Y, Validation1X, Validation1Y, Part1Lambdas);
    assert(allAcc(:), ValidationAccuracy(:), 1e-6);

  case 3
    [~, logZ] = CliqueTreeCalibrate(sampleUncalibratedTree, false);
    assert(logZ, sampleLogZ, 1e-6);

  case 4
    %% This is wastly inadequate, you should probably test the different
    %% components of nll computation separately. Unfortunately, we don't
    %% have the problem divided into canonical subtasks. But, you should
    %% probably try to create your own tests for those.
    [nll, ~] = InstanceNegLogLikelihood(sampleX, sampleY, sampleTheta, sampleModelParams);
    assert(nll, sampleNLL, 1e-6);

  case 5
    [~, grad] = InstanceNegLogLikelihood(sampleX, sampleY, sampleTheta, sampleModelParams);
    assert(grad, sampleGrad, 1e-6);

end

disp('Test finished successfully!');