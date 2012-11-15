% Copyright (C) Daphne Koller, Stanford University, 2012

function [MEU OptimalDecisionRule] = OptimizeLinearExpectations( I )
  % Inputs: An influence diagram I with a single decision node and one or more utility nodes.
  %         I.RandomFactors = list of factors for each random variable.  These are CPDs, with
  %              the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional utilities.
  % Return value: the maximum expected utility of I and an optimal decision rule 
  % (represented again as a factor) that yields that expected utility.
  % You may assume that there is a unique optimal decision.
  %
  % This is similar to OptimizeMEU except that we will have to account for
  % multiple utility factors.  We will do this by calculating the expected
  % utility factors and combining them, then optimizing with respect to that
  % combined expected utility factor.  
  MEU = [];
  OptimalDecisionRule = [];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % YOUR CODE HERE
  %
  % A decision rule for D assigns, for each joint assignment to D's parents, 
  % probability 1 to the best option from the EUF for that joint assignment 
  % to D's parents, and 0 otherwise.  Note that when D has no parents, it is
  % a degenerate case we can handle separately for convenience.
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  I2 = I;
  EUF = struct('var', [], 'card', [], 'val', []);
  for i=1:length(I2.UtilityFactors)
      I.UtilityFactors = I2.UtilityFactors(i);
      EUFs{i} = CalculateExpectedUtilityFactor(I);
      EUF = FactorSum(EUF, EUFs{i});
  end;
  
  D = I2.DecisionFactors;
      
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
