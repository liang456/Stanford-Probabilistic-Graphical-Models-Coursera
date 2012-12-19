% File: RecognizeActions.m
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

function [accuracy, predicted_labels] = RecognizeActions(datasetTrain, datasetTest, G, maxIter)

% INPUTS
% datasetTrain: dataset for training models, see PA for details
% datasetTest: dataset for testing models, see PA for details
% G: graph parameterization as explained in PA decription
% maxIter: max number of iterations to run for EM

% OUTPUTS
% accuracy: recognition accuracy, defined as (#correctly classified examples / #total examples)
% predicted_labels: N x 1 vector with the predicted labels for each of the instances in datasetTest, with N being the number of unknown test instances


% Train a model for each action
% Note that all actions share the same graph parameterization and number of max iterations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:length(datasetTrain)
    [Action(i).P Action(i).loglikelihood Action(i).ClassProb Action(i).PairProb] = EM_HMM(datasetTrain(i).actionData, datasetTrain(i).poseData, G, datasetTrain(i).InitialClassProb, datasetTrain(i).InitialPairProb, maxIter);
end;
% load action.mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Classify each of the instances in datasetTrain
% Compute and return the predicted labels and accuracy
% Accuracy is defined as (#correctly classified examples / #total examples)
% Note that all actions share the same graph parameterization

accuracy = 0;
predicted_labels = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

loglikelihood = zeros(length(Action), size(datasetTest.actionData, 2));
for act=1:length(Action);
    %     llh = ModifiedEStep(Action(act).P, G, datasetTest.poseData, datasetTest.actionData);
    P = Action(act).P;
    poseData = datasetTest.poseData;
    actionData = datasetTest.actionData;
    K = size(P.c, 2);
    N = size(poseData,1);
    L = size(actionData, 2); % number of actions
    multiGraph = 1;
    if (size(G,3) == 1)
        multiGraph = 0;
    end;
    allG = G;
    for n=1:N
        % Loop over each class
        for k=1:K
            if(multiGraph)
                G = squeeze(allG(:,:,k));
            else
                G = allG;
            end;
            
            % Compute joint log-likelihood over the different parts
            sum_pi=0;
            for i=1:size(poseData,2)
                y = poseData(n,i,1);
                x = poseData(n,i,2);
                angle = poseData(n,i,3);
                if(G(i,1) == 0)
                    %Naive Bayes
                    mu_y = P.clg(i).mu_y(k);
                    sigma_y = P.clg(i).sigma_y(k);
                    mu_x = P.clg(i).mu_x(k);
                    sigma_x = P.clg(i).sigma_x(k);
                    mu_angle = P.clg(i).mu_angle(k);
                    sigma_angle = P.clg(i).sigma_angle(k);
                else
                    %Conditional Linear Gaussian
                    pa = G(i,2);
                    mu_y = sum(P.clg(i).theta(k,1:4).*[1; squeeze(poseData(n, pa, :))]');
                    sigma_y = P.clg(i).sigma_y(k);
                    mu_x = sum(P.clg(i).theta(k,5:8).*[1; squeeze(poseData(n, pa, :))]');
                    sigma_x = P.clg(i).sigma_x(k);
                    mu_angle = sum(P.clg(i).theta(k,9:12).*[1; squeeze(poseData(n, pa, :))]');
                    sigma_angle = P.clg(i).sigma_angle(k);
                end;
                
                py = lognormpdf(y, mu_y, sigma_y);
                px = lognormpdf(x, mu_x, sigma_x);
                pangle = lognormpdf(angle, mu_angle, sigma_angle);
                sum_pi = sum_pi+py+px+pangle;
            end;
            classLogLike(k) = sum_pi;
        end;
        %         d(n) = logsumexp(classLogLike);
        %         logEmissionProb(n,:) = (classLogLike - repmat(d(n), size(classLogLike)));
        logEmissionProb(n,:) = classLogLike;
    end;
    
    lle = zeros(1,L);
    emptyF = struct('var', [], 'card', [], 'val', []);
    
    for i=1:L
        F1 = emptyF;
        F1.var = 1;
        F1.card = K;
        F1.val = log(P.c(:))';
        
        numPoses = length(actionData(i).marg_ind);
        F3 = repmat(emptyF, 1, numPoses);
        for f=1:numPoses
            F3(f).var = f;
            F3(f).card = K;
            F3(f).val = logEmissionProb(actionData(i).marg_ind(f),:);
        end;
        
        %Pair-wise state factors over all pairs of states
        numTrans = length(actionData(i).pair_ind);
        F2 = repmat(emptyF, 1, numTrans);
        for f=1:numTrans
            F2(f).var = [f, f+1];
            F2(f).card = K*K;
            F2(f).val = log(reshape(P.transMatrix, 1, length(P.transMatrix(:))));
        end;
        Factors = [F1,F3,F2];
        
        [M, PCalibrated] = ComputeExactMarginalsHMM(Factors);
        
        for t=1:length(PCalibrated.cliqueList)
            Norm = logsumexp(PCalibrated.cliqueList(t).val);
            ind = PCalibrated.cliqueList(t).var(1);
            ids = actionData(i).pair_ind(ind);
            PairProb(ids,:) = exp(PCalibrated.cliqueList(t).val - Norm);
        end;
        
        
        lle(i) = Norm;
    end
    
    loglikelihood(act,:) = lle;
end
[~, ids] = max(loglikelihood);
predicted_labels = ids';
accuracy = sum(predicted_labels == datasetTest.labels)/length(predicted_labels);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%