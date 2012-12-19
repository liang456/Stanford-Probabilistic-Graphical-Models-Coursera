function PA8_RunTests()

  clear;
  load PA8SampleCases
  load PA8Data
  
  turnOnVisualizations = false;
  
  constTOL = 1e-6;
  
  partNames = validParts();
  partId = promptPart();

  len = length(partNames);
    
  resultAll = 1;

  for i = 1:len
    if ( partId ~= (len+1) && partId ~= i )
      continue;
    end

    fprintf('\n%i) Testing %s ...\n', i, partNames{i} );
    result = 1;

    switch i
    case 1 % FitGaussianParameters
      [Output.t1o1 Output.t1o2] = FitGaussianParameters( exampleINPUT.t1a1 ); 
      result = isEqualTol(Output.t1o1, exampleOUTPUT.t1o1, 'Output.t1o1', constTOL) && ...
               isEqualTol(Output.t1o2, exampleOUTPUT.t1o2, 'Output.t1o2', constTOL);
      
    case 2 % FitLinearGaussianParameters
      [Output.t2o1 Output.t2o2] = FitLinearGaussianParameters( exampleINPUT.t2a1, exampleINPUT.t2a2 );
      result = isEqualTol(Output.t2o1, exampleOUTPUT.t2o1, 'Output.t2o1', constTOL) && ...
               isEqualTol(Output.t2o2, exampleOUTPUT.t2o2, 'Output.t2o2', constTOL);

    case 3 % ComputeLogLikelihood
      if turnOnVisualizations
        VisualizeDataset(trainData.data);
      end
    
      Output.t3 = ComputeLogLikelihood( exampleINPUT.t3a1, exampleINPUT.t3a2, exampleINPUT.t3a3 );
      result = isEqualTol(Output.t3, exampleOUTPUT.t3, 'Output.t3', constTOL);

    case 4 % LearnCPDsGivenGraph
      [Output.t4o1 Output.t4o2] = ...
          LearnCPDsGivenGraph(exampleINPUT.t4a1, exampleINPUT.t4a2, exampleINPUT.t4a3);
      result = isEqualTol(Output.t4o1, exampleOUTPUT.t4o1, 'Output.t4o1', constTOL) && ...
               isEqualTol(Output.t4o2, exampleOUTPUT.t4o2, 'Output.t4o2', constTOL);
      
    case 5 % ClassifyDataset
      Output.t5 = ClassifyDataset(exampleINPUT.t5a1, exampleINPUT.t5a2, ...
                                exampleINPUT.t5a3, exampleINPUT.t5a4);
      result = isEqualTol(Output.t5, exampleOUTPUT.t5, 'Output.t5', constTOL);
    
      if turnOnVisualizations
        VisualizeModels(exampleINPUT.t5a3, exampleINPUT.t5a4);
      end

      %Compare structure G1 (no edges) and G2 (tree)
      fprintf('\n- Measuring accuracy for Naive Bayes model\n');
      [P1 ~] = LearnCPDsGivenGraph(trainData.data, G1, trainData.labels);
      accuracyNaiveBayes = ClassifyDataset(exampleINPUT.t5a1, exampleINPUT.t5a2, P1, G1);
      if turnOnVisualizations
        VisualizeModels(P1, G1);
      end

      fprintf('\n- Measuring accuracy for CLG model\n');
      [P2 ~] = LearnCPDsGivenGraph(trainData.data, G2, trainData.labels);
      accuracyCLG = ClassifyDataset(exampleINPUT.t5a1, exampleINPUT.t5a2, P2, G2);
      if turnOnVisualizations
        VisualizeModels(P2, G2);   
      end
      
      result = result && ( abs(accuracyNaiveBayes - 0.79) <= 0.01 ) && ...
          ( abs(accuracyCLG - 0.84) <= 0.01 );
  
    case 6 % LearnGraphStructure
      [Output.t6o1 Output.t6o2] = LearnGraphStructure( exampleINPUT.t6a1 );
      result = isEqualTol(Output.t6o1, exampleOUTPUT.t6o1, 'Output.t6o1', constTOL) && ...
               isEqualTol(Output.t6o2, exampleOUTPUT.t6o2, 'Output.t6o2', constTOL);

    case 7 % LearnGraphAndCPDs
      [Output.t7o1 Output.t7o2 Output.t7o3] = ...
          LearnGraphAndCPDs( exampleINPUT.t7a1, exampleINPUT.t7a2 );
      result = isEqualTol(Output.t7o1, exampleOUTPUT.t7o1, 'Output.t7o1', constTOL) && ...
               isEqualTol(Output.t7o2, exampleOUTPUT.t7o2, 'Output.t7o2', constTOL) && ...
               isEqualTol(Output.t7o3, exampleOUTPUT.t7o3, 'Output.t7o3', constTOL);

      % Compare accuracy and likelihood from test 5 with accuracy for model
      % with separate graphs
      fprintf('\n- Measuring accuracy for CLG model with separate graphs structures learned from data\n');
      [P3 G3 ~] = LearnGraphAndCPDs(trainData.data, trainData.labels);
      accuracyWithLearnedGraphStructure = ClassifyDataset(testData.data, testData.labels, P3, G3);
      if turnOnVisualizations
        VisualizeModels(P3, G3);
      end
      
      result = result && ( abs(accuracyWithLearnedGraphStructure - 0.93) <= 0.01 );
      
    end % end switch
      
    display_result(result);
      
    resultAll = resultAll && result;
  end % end for

  if resultAll
    fprintf('\nALL CODE IS CORRECT!\n\n')
  else
    fprintf('\nSOME CODE IS INCORRECT!\n\n')
  end

end % end function 'PS5_RunTests'

function str = bool2ans(bool)
    if bool
        str = 'Correct';
    else
        str = 'Incorrect';
    end
end

function display_result(result)
    fprintf('  -----  %s answer!\n', bool2ans(result));
end

function id = homework_id() 
  id = '8';
end

function [partNames] = validParts()
  partNames = { 'FitGaussianParameters', ...
		'FitLinearGaussianParameters', ...
		'ComputeLogLikelihood', ...
        'LearnCPDsGivenGraph', ...
        'ClassifyDataset', ...
        'LearnGraphStructure', ...
        'LearnGraphAndCPDs'
	      };
end

function srcs = sources()
% Separated by part
  srcs = { { 'FitGaussianParameters.m' }, ... %1
	   { 'FitLinearGaussianParameters.m' }, ... %3    
	   { 'ComputeLogLikelihood.m' }, ... %5
	   { 'LearnCPDsGivenGraph.m' }, ... %7     
	   { 'ClassifyDataset.m' }, ... %9
	   { 'LearnGraphStructure.m' }, ... %11
	   { 'LearnGraphAndCPDs.m' } %13
	 };
end

function ret = isValidPartId(partId)
  partNames = validParts();
  ret = (~isempty(partId)) && (partId >= 1) && (partId <= numel(partNames) + 1);
end

function partId = promptPart()
  fprintf('== Testinf Programming assignment ¹ %s\n', homework_id());
  fprintf('== Select which part(s) to test:\n');
  partNames = validParts();
  srcFiles = sources();
  
  for i = 1:numel(partNames)
    fprintf('==   %d) %s [ %s ]\n', i, partNames{i}, srcFiles{i}{:});
  end
  
  fprintf('==   %d) All of the above \n==\nEnter your choice [1-%d]: ', ...
          numel(partNames) + 1, numel(partNames) + 1);
  
  partId = str2double(input('', 's'));
  if ~isValidPartId(partId)
    partId = -1;
  end
  
  fprintf('\n\n');
end

function res = isEqualTol(argument1, argument2, context, toleranceInput)
  if (nargin == 3),
    res = CompareData(argument1, argument2, context, ...
            struct('displaycontextprogress', 0, 'NumericTolerance', 0, ...
            'showMinMaxAbsDiff', 0));
  else
    res = CompareData(argument1, argument2, context, ...
            struct('displaycontextprogress', 0, 'NumericTolerance', toleranceInput, ...
            'showMinMaxAbsDiff', 0));
  end
end