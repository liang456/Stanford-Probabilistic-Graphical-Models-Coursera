function loglikelihood = ComputeLogLikelihood(P, G, dataset)
% returns the (natural) log-likelihood of data given the model and graph structure
%
% Inputs:
% P: struct array parameters (explained in PA description)
% G: graph structure and parameterization (explained in PA description)
%
%    NOTICE that G could be either 10x2 (same graph shared by all classes)
%    or 10x2x2 (each class has its own graph). your code should compute
%    the log-likelihood using the right graph.
%
% dataset: N x 10 x 3, N poses represented by 10 parts in (y, x, alpha)
%
% Output:
% loglikelihood: log-likelihood of the data (scalar)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

N = size(dataset,1); % number of examples
K = length(P.c); % number of classes

loglikelihood = 0;
% You should compute the log likelihood of data as in eq. (12) and (13)
% in the PA description
% Hint: Use lognormpdf instead of log(normpdf) to prevent underflow.
%       You may use log(sum(exp(logProb))) to do addition in the original
%       space, sum(Prob).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check if there are multiple graph structures
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
        for i=1:size(dataset,2)
            y = dataset(n,i,1);
            x = dataset(n,i,2);
            angle = dataset(n,i,3);
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
                mu_y = sum(P.clg(i).theta(k,1:4).*[1; squeeze(dataset(n, pa, :))]');
                sigma_y = P.clg(i).sigma_y(k);
                mu_x = sum(P.clg(i).theta(k,5:8).*[1; squeeze(dataset(n, pa, :))]');
                sigma_x = P.clg(i).sigma_x(k);
                mu_angle = sum(P.clg(i).theta(k,9:12).*[1; squeeze(dataset(n, pa, :))]');
                sigma_angle = P.clg(i).sigma_angle(k);
            end;
            
            py = lognormpdf(y, mu_y, sigma_y);
            px = lognormpdf(x, mu_x, sigma_x);
            pangle = lognormpdf(angle, mu_angle, sigma_angle);
            
            
            sum_pi = sum_pi+py+px+pangle;
        end;
        pc = P.c(k);
        classLogLike(k) = log(pc)+sum_pi;
    end;
    
    d(n) = log(sum(exp(classLogLike)));
end;

loglikelihood = sum(d);