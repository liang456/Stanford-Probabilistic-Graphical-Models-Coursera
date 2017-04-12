% File: EM_HMM.m
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

function [P loglikelihood ClassProb PairProb] = EM_HMM(actionData, poseData, G, InitialClassProb, InitialPairProb, maxIter)

% INPUTS
% actionData: structure holding the actions as described in the PA
% poseData: N x 10 x 3 matrix, where N is number of poses in all actions
% G: graph parameterization as explained in PA description
% InitialClassProb: N x K matrix, initial allocation of the N poses to the K
%   states. InitialClassProb(i,j) is the probability that example i belongs
%   to state j.
%   This is described in more detail in the PA.
% InitialPairProb: V x K^2 matrix, where V is the total number of pose
%   transitions in all HMM action models, and K is the number of states.
%   This is described in more detail in the PA.
% maxIter: max number of iterations to run EM

% OUTPUTS
% P: structure holding the learned parameters as described in the PA
% loglikelihood: #(iterations run) x 1 vector of loglikelihoods stored for
%   each iteration
% ClassProb: N x K matrix of the conditional class probability of the N examples to the
%   K states in the final iteration. ClassProb(i,j) is the probability that
%   example i belongs to state j. This is described in more detail in the PA.
% PairProb: V x K^2 matrix, where V is the total number of pose transitions
%   in all HMM action models, and K is the number of states. This is
%   described in more detail in the PA.

% Initialize variables
N = size(poseData, 1);
K = size(InitialClassProb, 2);
L = size(actionData, 2); % number of actions
V = size(InitialPairProb, 1);

ClassProb = InitialClassProb;
PairProb = InitialPairProb;

loglikelihood = zeros(maxIter,1);

P.c = [];
P.clg.sigma_x = [];
P.clg.sigma_y = [];
P.clg.sigma_angle = [];

% EM algorithm
for iter=1:maxIter
    
    % M-STEP to estimate parameters for Gaussians
    % Fill in P.c, the initial state prior probability (NOT the class probability as in PA8 and EM_cluster.m)
    % Fill in P.clg for each body part and each class
    % Make sure to choose the right parameterization based on G(i,1)
    % Hint: This part should be similar to your work from PA8 and EM_cluster.m
    
    P.c = zeros(1,K);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for a=1:L
        C(a) = actionData(a).marg_ind(1);
    end;
    P.c = sum(ClassProb(C,:))./L;
    
    N = size(poseData, 1);
    multiGraph = 1;
    if (size(G,3) == 1)
        multiGraph = 0;
    end;
    allG = G;
    
    for k=1:K
        for i=1:size(G,1)
            if(multiGraph)
                G = squeeze(allG(:,:,k));
            else
                G = allG;
            end;
            if(G(i,1) == 0)
                %Naive Bayes
                [P.clg(i).mu_y(k) P.clg(i).sigma_y(k)] = FitG(squeeze(poseData(:, i, 1)), ClassProb(:,k));
                [P.clg(i).mu_x(k), P.clg(i).sigma_x(k)] = FitG(squeeze(poseData(:, i, 2)), ClassProb(:,k));
                [P.clg(i).mu_angle(k), P.clg(i).sigma_angle(k)] = FitG(squeeze(poseData(:, i, 3)), ClassProb(:,k));
                
            else
                %Conditional Linear Gaussian
                pa = G(i,2);
                [theta, P.clg(i).sigma_y(k)] = FitLG(squeeze(poseData(:, i, 1)), squeeze(poseData(:, pa, :)), ClassProb(:,k));
                P.clg(i).theta(k,1:4) = [theta(end), theta(1:end-1)'];
                [theta, P.clg(i).sigma_x(k)] = FitLG(squeeze(poseData(:, i, 2)), squeeze(poseData(:, pa, :)), ClassProb(:,k));
                P.clg(i).theta(k,5:8) = [theta(end), theta(1:end-1)'];
                [theta, P.clg(i).sigma_angle(k)] = FitLG(squeeze(poseData(:, i, 3)), squeeze(poseData(:, pa, :)), ClassProb(:,k));
                P.clg(i).theta(k,9:12) = [theta(end), theta(1:end-1)'];
            end;
            
        end
    end
    G = allG;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % M-STEP to estimate parameters for transition matrix
    % Fill in P.transMatrix, the transition matrix for states
    % P.transMatrix(i,j) is the probability of transitioning from state i to state j
    P.transMatrix = zeros(K,K);
    
    % Add Dirichlet prior based on size of poseData to avoid 0 probabilities
    P.transMatrix = P.transMatrix + size(PairProb,1) * .05;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    T = sum(PairProb);
    T = reshape(T, K, K) + P.transMatrix;
    for i=1:K
        T(i,:) = T(i,:)./sum(T(i,:));
    end;
    P.transMatrix = T;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % E-STEP preparation: compute the emission model factors (emission probabilities) in log space for each
    % of the poses in all actions = log( P(Pose | State) )
    % Hint: This part should be similar to (but NOT the same as) your code in EM_cluster.m
    
    logEmissionProb = zeros(N,K);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    multiGraph = 1;
    if (size(G,3) == 1)
        multiGraph = 0;
    end;
    
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
    G = allG;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % E-STEP to compute expected sufficient statistics
    % ClassProb contains the conditional class probabilities for each pose in all actions
    % PairProb contains the expected sufficient statistics for the transition CPDs (pairwise transition probabilities)
    % Also compute log likelihood of dataset for this iteration
    % You should do inference and compute everything in log space, only converting to probability space at the end
    % Hint: You should use the logsumexp() function here to do probability normalization in log space to avoid numerical issues
    
    ClassProb = zeros(N,K);
    PairProb = zeros(V,K^2);
    loglikelihood(iter) = 0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    emptyF = struct('var', [], 'card', [], 'val', []);
    %Initial state factors over L initial poses.
    for a=1:L
        F1 = emptyF;
        F1.var = 1;
        F1.card = K;
        F1.val = log(P.c(:))';
        %Pair-wise state factors over all pairs of states
        numTrans = length(actionData(a).pair_ind);
        F2 = repmat(emptyF, 1, numTrans);
        for f=1:numTrans
            F2(f).var = [f, f+1];
            F2(f).card = K*K;
            F2(f).val = log(reshape(P.transMatrix, 1, length(P.transMatrix(:))));
        end;
        
        numPoses = length(actionData(a).marg_ind);
        F3 = repmat(emptyF, 1, numPoses);
        for f=1:numPoses
            F3(f).var = f;
            F3(f).card = K;
            F3(f).val = logEmissionProb(actionData(a).marg_ind(f),:);
        end;
        
        Factors = [F1,F3,F2];
        
        [M, PCalibrated] = ComputeExactMarginalsHMM(Factors);
        
        for i=1:length(M)
            Norm = logsumexp(M(i).val);
            ids = actionData(a).marg_ind(M(i).var);
            ClassProb(ids,:) = exp(M(i).val - Norm);
        end;
        
        for i=1:length(PCalibrated.cliqueList)
            Norm = logsumexp(PCalibrated.cliqueList(i).val);
            ind = PCalibrated.cliqueList(i).var(1);
            ids = actionData(a).pair_ind(ind);
            PairProb(ids,:) = exp(PCalibrated.cliqueList(i).val - Norm);
        end;
        
        loglikelihood(iter) = loglikelihood(iter) + Norm;
    end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Print out loglikelihood
    disp(sprintf('EM iteration %d: log likelihood: %f', ...
        iter, loglikelihood(iter)));
    if exist('OCTAVE_VERSION')
        fflush(stdout);
    end
    
    % Check for overfitting by decreasing loglikelihood
    if iter > 1
        if loglikelihood(iter) < loglikelihood(iter-1)
            break;
        end
    end
    
end

% Remove iterations if we exited early
loglikelihood = loglikelihood(1:iter);
