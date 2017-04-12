function [P loglikelihood] = LearnCPDsGivenGraph(dataset, G, labels)
%
% Inputs:
% dataset: N x 10 x 3, N poses represented by 10 parts in (y, x, alpha)
% G: graph parameterization as explained in PA description
% labels: N x 2 true class labels for the examples. labels(i,j)=1 if the
%         the ith example belongs to class j and 0 elsewhere
%
% Outputs:
% P: struct array parameters (explained in PA description)
% loglikelihood: log-likelihood of the data (scalar)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

N = size(dataset, 1);
K = size(labels,2);

loglikelihood = 0;
P.c = zeros(1,K);

% estimate parameters
% fill in P.c, MLE for class probabilities
% fill in P.clg for each body part and each class
% choose the right parameterization based on G(i,1)
% compute the likelihood - you may want to use ComputeLogLikelihood.m
% you just implemented.
%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('log likelihood: %f\n', loglikelihood);

P.c = sum(labels)./N;
multiGraph = 1;
if (size(G,3) == 1)
    multiGraph = 0;
end;
allG = G;

clg = struct('mu_y', [], 'sigma_y', [],'mu_x', [], 'sigma_x', [],'mu_angle', [], 'sigma_angle', [], 'theta', []);

for i=1:size(G,1)
    P.clg(i) = clg;
end;

for k=1:K
    ids = find(labels(:,k) == 1);
    for i=1:size(G,1)
        if(multiGraph)
            G = squeeze(allG(:,:,k));
        else
            G = allG;
        end;
        
        
        if(G(i,1) == 0)
            %Naive Bayes
            [P.clg(i).mu_y(k) P.clg(i).sigma_y(k)] = FitGaussianParameters(squeeze(dataset(ids, i, 1)));
            [P.clg(i).mu_x(k), P.clg(i).sigma_x(k)] = FitGaussianParameters(squeeze(dataset(ids, i, 2)));
            [P.clg(i).mu_angle(k), P.clg(i).sigma_angle(k)] = FitGaussianParameters(squeeze(dataset(ids, i, 3)));
            
            
        else
            %Conditional Linear Gaussian
            pa = G(i,2);
            [theta, P.clg(i).sigma_y(k)] = FitLinearGaussianParameters(squeeze(dataset(ids, i, 1)), squeeze(dataset(ids, pa, :)));
            P.clg(i).theta(k,1:4) = [theta(end), theta(1:end-1)'];
            [theta, P.clg(i).sigma_x(k)] = FitLinearGaussianParameters(squeeze(dataset(ids, i, 2)), squeeze(dataset(ids, pa, :)));
            P.clg(i).theta(k,5:8) = [theta(end), theta(1:end-1)'];
            [theta, P.clg(i).sigma_angle(k)] = FitLinearGaussianParameters(squeeze(dataset(ids, i, 3)), squeeze(dataset(ids, pa, :)));
            P.clg(i).theta(k,9:12) = [theta(end), theta(1:end-1)'];
        end;
        
    end
end

loglikelihood = ComputeLogLikelihood(P, allG, dataset);