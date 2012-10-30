%GETNEXTCLIQUES Find a pair of cliques ready for message passing
%   [i, j] = GETNEXTCLIQUES(P, messages) finds ready cliques in a given
%   clique tree, P, and a matrix of current messages. Returns indices i and j
%   such that clique i is ready to transmit a message to clique j.
%
%   We are doing clique tree message passing, so
%   do not return (i,j) if clique i has already passed a message to clique j.
%
%	 messages is a n x n matrix of passed messages, where messages(i,j)
% 	 represents the message going from clique i to clique j.
%   This matrix is initialized in CliqueTreeCalibrate as such:
%      MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);
%
%   If more than one message is ready to be transmitted, return
%   the pair (i,j) that is numerically smallest. If you use an outer
%   for loop over i and an inner for loop over j, breaking when you find a
%   ready pair of cliques, you will get the right answer.
%
%   If no such cliques exist, returns i = j = 0.
%
%   See also CLIQUETREECALIBRATE
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function [i, j] = GetNextCliques(P, messages)

% initialization
% you should set them to the correct values in your code
i = 0;
j = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

flag = 0;
for i=1:size(P.edges,1)
    for j=1:size(P.edges,1)
        if(P.edges(i,j) == 0)
            continue;
        end;
        if(~isempty(messages(i,j).var))
            continue;
        end;
        neighbors = setdiff(find(P.edges(i,:) == 1), j);
        eligible = 1;
        for k=1:length(neighbors)
            if(neighbors ~= j)
            if(isempty(messages(neighbors(k), i).var))
                eligible = 0;
                break;
            end;
            end;
        end;
        if(eligible == 1)
            flag = 1;
            break;
        end;
    end;
    if(flag==1)
        break;
    end;
end;

if(flag == 0)
    i=0;
    j=0;
end;
% for i=1:length(P.cliqueList)
%     neighbors = find(P.edges(i,:) == 1);
%     n = length(neighbors);
%     ms = 0;
%     if(n == 0)
%         continue;
%     end;
%     potential = [];
%     for k=1:n
%         j = neighbors(k);
%         if(isempty(messages(i,j).var))
%             potential = [potential,j];
%         end;
%         if(~isempty(messages(j,i).var))
%             ms = ms+1;
%         else
%             if(isempty(messages(i,j).var))
%                 potential = [potential,j];
%             end
%         end;
%     end;
%     if(n-ms == 1)
%         if(length(potential) == 1)
%             flag = 1;
%             j = potential;
%             break;
%         end;
%     end;
% end;

if(flag==0)
    i=0;
    j=0;
end;
        


return;
