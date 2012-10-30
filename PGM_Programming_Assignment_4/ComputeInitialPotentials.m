%COMPUTEINITIALPOTENTIALS Sets up the cliques in the clique tree that is
%passed in as a parameter.
%
%   P = COMPUTEINITIALPOTENTIALS(C) Takes the clique tree skeleton C which is a
%   struct with three fields:
%   - nodes: cell array representing the cliques in the tree.
%   - edges: represents the adjacency matrix of the tree.
%   - factorList: represents the list of factors that were used to build
%   the tree. 
%   
%   It returns the standard form of a clique tree P that we will use through 
%   the rest of the assigment. P is struct with two fields:
%   - cliqueList: represents an array of cliques with appropriate factors 
%   from factorList assigned to each clique. Where the .val of each clique
%   is initialized to the initial potential of that clique.
%   - edges: represents the adjacency matrix of the tree. 
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function P = ComputeInitialPotentials(C)

% number of cliques
N = length(C.nodes);

% initialize cluster potentials 
P.cliqueList = repmat(struct('var', [], 'card', [], 'val', []), N, 1);
P.edges = zeros(N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% First, compute an assignment of factors from factorList to cliques. 
% Then use that assignment to initialize the cliques in cliqueList to 
% their initial potentials. 

% C.nodes is a list of cliques.
% So in your code, you should start with: P.cliqueList(i).var = C.nodes{i};
% Print out C to get a better understanding of its structure.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P.edges = C.edges;
for i=1:N
    P.cliqueList(i).var = C.nodes{i};        
end;

% Assign factor to a clique
alpha=zeros(length(C.factorList),1);
for k=1:length(C.factorList)
    for i=1:N
        fVar = C.factorList(k).var;
        cVar = C.nodes{i};
        if(all(ismember(fVar, cVar)) && alpha(k) == 0)
            alpha(k) = i;
        end;
    end;
end;


% Compute the initial potentials
for i=1:N
    inds = find(alpha == i);
    if(isempty(inds))
        P.cliqueList(i).val(:) = 1;
        continue;
    end;
    F1 = C.factorList(inds(1));
    for t=2:length(inds)
        F2 = C.factorList(inds(t));
        F1 = FactorProduct(F1,F2);
    end;
    
    
    [S, I] = sort(F1.var);
    out.card = F1.card(I);
    allAssignmentsIn = IndexToAssignment(1:prod(F1.card), F1.card);
    allAssignmentsOut = allAssignmentsIn(:,I); % Map from in assgn to out assgn
    out.val(AssignmentToIndex(allAssignmentsOut, out.card)) = F1.val;
    P.cliqueList(i).card = out.card;
    P.cliqueList(i).val = out.val;

end

