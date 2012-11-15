% A simple test suite for PA 6
%
% Based on the code by Mihaly Barasz posted on the forum.
%
% copy the CompareData.m file from last weeks test suite
% into the directory for this weeks assignment and save this file
% as PA6_RunTests.m
%
function result = PA6_RunTests(anyway)

if ~exist('CompareData', 'file')
  fprintf('please install CompareData.m as indicated in the comment\n');
  fprintf('at the beginning of this file\n');
  result = false;
  return;
end

if (~exist('TS','var'))
  %% This is based on TestCases to make it all more testable.

  TS = repmat(struct('I', [], 'allDs', [], 'allEU', [], 'EUF', []), 1, 3);

  %% Test case 1.
  I.RandomFactors = struct('var', [1], 'card', [2], 'val', normval([7, 3]));
  I.DecisionFactors = struct('var', [2], 'card', [2], 'val', [1 0]);
  I.UtilityFactors = struct('var', [1, 2], 'card', [2, 2], 'val', [10, 1, 5, 1]);

  TS(1).I = I;
  TS(1).allDs = [1 0; 0 1];
  TS(1).EUF = struct('var', [2], 'card', [2], 'val', [7.3 3.8]);
  TS(1).allEU = [7.3 3.8];
  TS(1).MEU = 7.3;
  TS(1).OptDR = struct('var', [2], 'card', [2], 'val', [1 0]);

  %% Test case 2.
  I.RandomFactors = ...
      [struct('var', [1], 'card', [2], 'val', normval([7, 3])), ...
       CPDFromFactor(struct('var', [3,1,2], 'card', [2,2,2], 'val', [4 4 1 1 1 1 4 4]), 3)];
  I.DecisionFactors = struct('var', [2], 'card', [2], 'val', [1 0]);
  I.UtilityFactors = struct('var', [2,3], 'card', [2, 2], 'val', [10, 1, 5, 1]);

  TS(2).I = I;
  TS(2).allDs = [1 0; 0 1];
  TS(2).EUF = struct('var', [2], 'card', [2], 'val', [7.5 1.0]);
  TS(2).allEU = [7.5 1.0];
  TS(2).MEU = 7.5;
  TS(2).OptDR = struct('var', [2], 'card', [2], 'val', [1 0]);

  %% Test case 3.
  I.RandomFactors = ...
      [struct('var', [1], 'card', [2], 'val', normval([7, 3])), ...
       CPDFromFactor(struct('var', [3,1,2], 'card', [2,2,2], 'val', [4 4 1 1 1 1 4 4]), 3)];
  I.DecisionFactors = struct('var', [2,1], 'card', [2,2], 'val', [1,0,0,1]);
  I.UtilityFactors = struct('var', [2,3], 'card', [2, 2], 'val', [10, 1, 5, 1]);

  TS(3).I = I;
  TS(3).allDs = [1 0 1 0; 1 0 0 1; 0 1 1 0; 0 1 0 1];
  TS(3).EUF = struct('var', [1,2], 'card', [2 2], 'val', [5.25 2.25 0.7 0.3]);
  TS(3).allEU = [7.5 5.55 2.95 1.0];
  TS(3).MEU = 7.5;
  TS(3).OptDR = struct('var', [1,2], 'card', [2,2], 'val', [1,1,0,0]);

  %% Test case 4.
  I.RandomFactors = ...
      [struct('var', [1], 'card', [2], 'val', normval([7, 3])), ...
       CPDFromFactor(struct('var', [3,1,2], 'card', [2,2,2], 'val', [4 4 1 1 1 1 4 4]), 3)];
  I.DecisionFactors = struct('var', [2,1], 'card', [2,2], 'val', [1,0,0,1]);
  I.UtilityFactors = ...
      [struct('var', [2,3], 'card', [2, 2], 'val', [10, 1, 5, 1]), ...
       struct('var', [2], 'card', [2], 'val', [1, 10])];

  T4.I = I;
  T4.MEU = 11;
  T4.OptDR = struct('var', [1,2], 'card', [2,2], 'val', [0,0,1,1]);

end

if nargin == 1
  run_all = anyway;
else
  run_all = false;
end

ok = true;
passed = 0;
skipped = 0;
failed = 0;
for test = 1:5
  if ~(run_all || ok)
    skipped = skipped + 1;
    continue;
  end

  switch test
    case 1
      for t = 1:length(TS)
        T = TS(t);
        for d = 1:size(T.allDs, 1)
          T.I.DecisionFactors.val = T.allDs(d, :);
          EU = SimpleCalcExpectedUtility(T.I);
          ok = checkResult('SimpleCalcExpectedUtility', EU, T.allEU(d));
        end
      end

    case 2
      for t = 1:length(TS)
        T = TS(t);
        EUF = CalculateExpectedUtilityFactor(T.I);
        ok = checkResult('CalculateExpectedUtilityFactor', EUF, T.EUF);
      end

    case 3
      for t = 1:length(TS)
        T = TS(t);
        [meu optdr] = OptimizeMEU(T.I);
        ok = checkResult('OptimizeMEU meu', meu, T.MEU);
        ok = ok && checkResult('OptimizeMEU optdr', optdr, T.OptDR);
      end

    case 4
      [meu optdr] = OptimizeWithJointUtility(T4.I);
      ok = checkResult('OptimizeWithJointUtility meu', meu, T4.MEU);
      ok = ok && checkResult('OptimizeWithJointUtility optdr', optdr, T4.OptDR);
      %% Also, see if it works with single utility:
      for t = 1:length(TS)
        T = TS(t);
        [meu optdr] = OptimizeWithJointUtility(T.I);
        ok = ok && checkResult('OptimizeWithJointUtility sng meu', meu, T.MEU);
        ok = ok && checkResult('OptimizeWithJointUtility sng optdr', optdr, T.OptDR);
      end

    case 5
      [meu optdr] = OptimizeLinearExpectations(T4.I);
      ok = checkResult('OptimizeLinearExpectations meu', meu, T4.MEU);
      ok = ok && checkResult('OptimizeLinearExpectations optdr', optdr, T4.OptDR);
      %% Also, see if it works with single utility:
      for t = 1:length(TS)
        T = TS(t);
        [meu optdr] = OptimizeLinearExpectations(T.I);
        ok = ok && checkResult('OptimizeLinearExpectation sng meu', meu, T.MEU);
        ok = ok && checkResult('OptimizeLinearExpectation sng optdr', optdr, T.OptDR);
      end
  end

  if ok
    passed = passed + 1;
  else
    failed = failed + 1;
  end
end

fprintf('%d tests OK, %d skipped, %d failed\n', passed, skipped, failed);
result = ok;
end

function res = checkResult(label, expected, observed)
params = struct('displaycontextprogress', 0, 'NumericTolerance', 1e-6);
  cmp = CompareData(expected, observed, [], params);
  fprintf('%s: ', label);
  if cmp
    fprintf('OK\n');
    res = true;
  else
    fprintf('FAIL\n');
    res = false;
  end
end

function v = normval(v)
  v = v / sum(v);
end
