function accuracy = ClassifyDataset(dataset, labels, P, G)
% returns the accuracy of the model P and graph G on the dataset 
%
% Inputs:
% dataset: N x 10 x 3, N test instances represented by 10 parts
% labels:  N x 2 true class labels for the instances.
%          labels(i,j)=1 if the ith instance belongs to class j 
% P: struct array model parameters (explained in PA description)
% G: graph structure and parameterization (explained in PA description) 
%
% Outputs:
% accuracy: fraction of correctly classified instances (scalar)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

N = size(dataset, 1);
accuracy = 0.0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
multiGraph = 1;
if (size(G,3) == 1)
    multiGraph = 0;
end;
allG = G;

pred = zeros(size(labels));
K = size(labels,2);
count = 0;
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
        classLogLike(k) = sum_pi;
    end;
    [~, id] = max((classLogLike));
    pred(n,id) = 1;
    if(labels(n,id) == 1)
        count = count+1;
    end;
end;

accuracy = count/N;

fprintf('Accuracy: %.2f\n', accuracy);