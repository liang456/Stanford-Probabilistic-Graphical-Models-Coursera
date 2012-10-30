% A simple test suite for PA 4
%
% copy the comparedata.m file from last week's test suite or from
% http://www.mathworks.com/matlabcentral/fileexchange/1459-comparedata
% into the directory for this weeks assignment and save this file
% as PA4_Run_Tests.m
%
% If you call PA4_RUn_Tests, it will always run all tests in sequence until the
% first test fails.
function result = PA4_Run_Tests(anyway)

  if ~exist('comparedata', 'file')
    fprintf('please install comparedata.m as indicated in the comment\n');
    fprintf('at the beginning of this file\n');
    result = false;
    return;
  end

  load PA4Sample.mat;

  if nargin == 1
    run_all = anyway;
  else
    run_all = false;
  end

  ok = true;
  passed = 0;
  skipped = 0;
  failed = 0;
  for test = 1:9
    if ~(run_all || ok)
      skipped = skipped + 1;
      continue;
    end

    switch test
      case 1
        pot = ComputeInitialPotentials(InitPotential.INPUT);
        ok = checkResult('ComputeInitialPotentials', InitPotential.RESULT, pot);
      case 2
        [i j] = GetNextCliques(GetNextC.INPUT1, GetNextC.INPUT2);
        ok = checkResult('GetNextCliques i', i, GetNextC.RESULT1);
        ok = ok && checkResult('GetNextCliques j', j, GetNextC.RESULT2);
      case 3
        t = CliqueTreeCalibrate(SumProdCalibrate.INPUT, 0);
        ok = checkResult('CliqueTreeCalibrate', SumProdCalibrate.RESULT, t);
      case 4
        t = ComputeExactMarginalsBP(ExactMarginal.INPUT, [], 0);
        ok = checkResult('ComputeExactMarginalsBP', ExactMarginal.RESULT, t);
      case 5
        t = FactorMaxMarginalization(FactorMax.INPUT1, FactorMax.INPUT2);
        ok = checkResult('FactorMaxMarginalization', FactorMax.RESULT, t);
      case 6
        t = CliqueTreeCalibrate(MaxSumCalibrate.INPUT, 1);
        ok = checkResult('CliqueTreeCalibrate', MaxSumCalibrate.RESULT, t);
      case 7
        t = ComputeExactMarginalsBP(MaxMarginals.INPUT, [], 1);
        ok = checkResult('ComputeExactMarginalsBP', MaxMarginals.RESULT, t);
      case 8
        t = MaxDecoding(MaxDecoded.INPUT);
        ok = checkResult('MaxDecoding', MaxDecoded.RESULT, t);
      case 9
        maxMarginals = ComputeExactMarginalsBP(OCRNetworkToRun, [], 1);
        MAPAssignment = MaxDecoding(maxMarginals);
        chars = 'abcdefghijklmnopqrstuvwxyz';
        res = chars(MAPAssignment);
        ok = checkResult('OCR Network', 'mornings', res);
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
  cmp = comparedata(expected, observed, [], params);
  fprintf('%s: ', label);
  if cmp
    fprintf('OK\n');
    res = true;
  else
    fprintf('FAIL\n');
    res = false;
  end
end
