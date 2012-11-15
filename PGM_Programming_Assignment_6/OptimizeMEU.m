% Copyright (C) Daphne Koller, Stanford University, 2012

function [MEU OptimalDecisionRule] = OptimizeMEU( I )

  % Inputs: An influence diagram I with a single decision node and a single utility node.
  %         I.RandomFactors = list of factors for each random variable.  These are CPDs, with
  %              the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional utilities.
  % Return value: the maximum expected utility of I and an optimal decision rule 
  % (represented again as a factor) that yields that expected utility.
  
  % We assume I has a single decision node.
  % You may assume that there is a unique optimal decision.
  D = I.DecisionFactors(1);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % YOUR CODE HERE...
  % 
  % Some other information that might be useful for some implementations
  % (note that there are multiple ways to implement this):
  % 1.  It is probably easiest to think of two cases - D has parents and D 
  %     has no parents.
  % 2.  You may find the Matlab/Octave function setdiff useful.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
  
  EUF = CalculateExpectedUtilityFactor(I);
  OptimalDecisionRule = EUF;
  OptimalDecisionRule.val = zeros(size(EUF.val));
  if(length(D.var) == 1)
      [~, id] = max(EUF.val);
      OptimalDecisionRule.val(id) = 1;
  else
      for i=1:length(D.var)
          map(i) = find(EUF.var == D.var(i));
          invMap(i) = find(D.var == EUF.var(i));
      end;
      assignEUF = IndexToAssignment(1:length(EUF.val), EUF.card);
      assignD = assignEUF(:, map);
      PAs = AssignmentToIndex(1:prod(D.card(2:end)), D.card(2:end));
      for i=1:size(PAs,1)
%           [~,ids] = find(ismember(assign(:,2:end), PAs(i,:)),1);
          newAssigns = [[1:D.card(1)]', repmat(PAs(i,:), length([1:D.card(1)]),1)];
          ids = AssignmentToIndex(newAssigns(:,invMap), EUF.card);
          [~,id] = max(EUF.val(ids));
          OptimalDecisionRule.val(ids(id)) = 1;
      end;

        
        
  end;
  F = FactorProduct(OptimalDecisionRule, EUF);
  MEU = sum(F.val(:));
          
  
  
      
    
    

end
