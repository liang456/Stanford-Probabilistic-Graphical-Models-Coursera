% A simple test suite for PA 3
%
% copy the comparedata.m file from last week's test suite or from
% http://www.mathworks.com/matlabcentral/fileexchange/1459-comparedata
% into the directory for this weeks assignment and save this file
% as PA3Test.m
%
% A test can have three different results:
%  - If the test suite says "OK", your code produced the exactly the same
%     output as the sample data.
%  - If it says "ok with warnings", the output of your code will probably
%    pass the initial submit check, but differs from the sample output.
%    A likely cause is that a val-array contains the right values in the
%    right order, but a different shape (like a row instead of a column
%    vector).
%  - If it says "FAIL", your code produced something that will most
%    probably not be accepted.
%
% If you call PA3Test, it will always run all tests in sequence until the
% first test fails.
function result = PA3Test()
models = load('PA3Models.mat');
samples = load('PA3SampleCases.mat');

ok = true;
for test = 1:6
  if ~ok
    continue;
  end

  switch test
  case 1
    images = samples.Part1SampleImagesInput;
    factors = ComputeSingletonFactors(images, models.imageModel);
    ok = checkResult('ComputeSingletonFactors', samples.Part1SampleFactorsOutput, SortAllFactors(factors), factors);
  case 2
    images = samples.Part2SampleImagesInput;
    factors = ComputePairwiseFactors(images, models.pairwiseModel, models.imageModel.K);
    ok = checkResult('ComputePairwiseFactors', samples.Part2SampleFactorsOutput, SortAllFactors(factors), factors);
  case 3
    images = samples.Part3SampleImagesInput;
    factors = ComputeTripletFactors(images, models.tripletList, models.imageModel.K);
    factors = SortAllFactors(factors);
    ok = checkResult('ComputeTripletFactors', samples.Part3SampleFactorsOutput, SortAllFactors(factors), factors);
  case 4
    images = samples.Part4SampleImagesInput;
    factor = ComputeSimilarityFactor(images, models.imageModel.K, 1, 2);
    ok = checkResult('ComputeSimilarityFactors', samples.Part4SampleFactorOutput, SortFactorVars(factor), factor);
  case 5
    images = samples.Part5SampleImagesInput;
    factors = ComputeAllSimilarityFactors(images, models.imageModel.K);
    factors = SortAllFactors(factors);
    ok = checkResult('ComputeAllSimilarityFactors', samples.Part5SampleFactorsOutput, SortAllFactors(factors), factors);
  case 6
    allFactors = samples.Part6SampleFactorsInput;
    factors = ChooseTopSimilarityFactors(allFactors, 2);
    factors = SortAllFactors(factors);
    ok = checkResult('ChooseTopSimilarityFactors', samples.Part6SampleFactorsOutput, SortAllFactors(factors), factors);
  end
end
end

function f = SortAllFactors(factors)

for i = 1:length(factors)
    factors(i) = SortFactorVars(factors(i));
end

varMat = vertcat(factors(:).var);
[unused, order] = sortrows(varMat);

f = factors(order);

end
function G = SortFactorVars(F)

[sortedVars, order] = sort(F.var);
G.var = sortedVars;

G.card = F.card(order);
G.val = zeros(numel(F.val), 1);

assignmentsInF = IndexToAssignment(1:numel(F.val), F.card);
assignmentsInG = assignmentsInF(:,order);
G.val(AssignmentToIndex(assignmentsInG, G.card)) = F.val;

end

function res = checkResult(label, expected, sorted, raw)
  fprintf('%s ...\n', label);
  params = struct('displaycontextprogress', 0, 'NumericTolerance', 1e-6);
  cmp = comparedata(expected, sorted, [], params);
  if cmp
    rawCmp = comparedata(expected, raw, [], params);
    if rawCmp
      fprintf('%s: OK\n', label);
    else
      fprintf('%s: ok with warnings\n', label);
    end
    res = true;
  else
    fprintf('%s: FAIL\n', label);
    res = false
  end
end
