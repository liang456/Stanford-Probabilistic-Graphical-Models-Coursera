% File: EM_cluster.m
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

function [P loglikelihood ClassProb] = EM_cluster(poseData, G, InitialClassProb, maxIter)

% INPUTS
% poseData: N x 10 x 3 matrix, where N is number of poses;
%   poseData(i,:,:) yields the 10x3 matrix for pose i.
% G: graph parameterization as explained in PA8
% InitialClassProb: N x K, initial allocation of the N poses to the K
%   classes. InitialClassProb(i,j) is the probability that example i belongs
%   to class j
% maxIter: max number of iterations to run EM

% OUTPUTS
% P: structure holding the learned parameters as described in the PA
% loglikelihood: #(iterations run) x 1 vector of loglikelihoods stored for
%   each iteration
% ClassProb: N x K, conditional class probability of the N examples to the
%   K classes in the final iteration. ClassProb(i,j) is the probability that
%   example i belongs to class j

% Initialize variables
N = size(poseData, 1);
K = size(InitialClassProb, 2);

ClassProb = InitialClassProb;

loglikelihood = zeros(maxIter,1);

% P.c = [];
% P.clg.sigma_x = [];
% P.clg.sigma_y = [];
% P.clg.sigma_angle = [];

% EM algorithm
for iter=1:maxIter
  
  % M-STEP to estimate parameters for Gaussians
  %
  % Fill in P.c with the estimates for prior class probabilities
  % Fill in P.clg for each body part and each class
  % Make sure to choose the right parameterization based on G(i,1)
  %
  % Hint: This part should be similar to your work from PA8
  
  P.c = zeros(1,K);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % YOUR CODE HERE
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   count = zeros(1,K);
%   for i=1:N
%       [~, k] = max(ClassProb(i,:));
%       count(k) = count(k) + 1;
%   end;
%   P.c = count./N;
  
  labels = zeros(N,K);
  for n=1:N
      [~, k] = max(ClassProb(n,:));
      labels(n,k) = 1;
  end;
%   [P loglikelihood(iter)] = LearnCPDsGivenGraph(poseData, G, labels);
  
  P.c = mean(ClassProb);
  
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

% loglikelihood = ComputeLogLikelihood(P, allG, poseData);


G = allG;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % E-STEP to re-estimate ClassProb using the new parameters
  %
  % Update ClassProb with the new conditional class probabilities.
  % Recall that ClassProb(i,j) is the probability that example i belongs to
  % class j.
  %
  % You should compute everything in log space, and only convert to
  % probability space at the end.
  %
  % Tip: To make things faster, try to reduce the number of calls to
  % lognormpdf, and inline the function (i.e., copy the lognormpdf code
  % into this file)
  %
  % Hint: You should use the logsumexp() function here to do
  % probability normalization in log space to avoid numerical issues
  
  ClassProb = zeros(N,K);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % YOUR CODE HERE
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  N = size(poseData, 1);
multiGraph = 1;
if (size(G,3) == 1)
    multiGraph = 0;
end;
G = allG;

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
        classLogLike(k) = sum_pi + log(P.c(k));
    end;
    d(n) = logsumexp(classLogLike);
    ClassProb(n,:) = exp(classLogLike - repmat(d(n), size(classLogLike)));
end;
  G = allG;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Compute log likelihood of dataset for this iteration
  % Hint: You should use the logsumexp() function here
  loglikelihood(iter) = 0;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % YOUR CODE HERE
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  loglikelihood(iter) = sum(d);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Print out loglikelihood
  disp(sprintf('EM iteration %d: log likelihood: %f', ...
    iter, loglikelihood(iter)));
  if exist('OCTAVE_VERSION')
    fflush(stdout);
  end
  
  % Check for overfitting: when loglikelihood decreases
  if iter > 1
    if loglikelihood(iter) < loglikelihood(iter-1)
      break;
    end
  end
  
end

% Remove iterations if we exited early
loglikelihood = loglikelihood(1:iter);
