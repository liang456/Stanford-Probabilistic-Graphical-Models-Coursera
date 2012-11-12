function PA5_RunTests()

  clear;
  load('exampleIOPA5.mat');
  
  % load intermediate test data
  load('additionalINPUT.mat');
  load('additionalOUTPUT.mat');
  
  basicTestOnly = true;

  partNames = validParts();
  partId = promptPart();

  len = length(partNames);
  partNamesAlligned = char( partNames );
    
  resultAll = 1;

  for i = 1:len
    if ( partId ~= (len+1) && partId ~= i )
      continue;
    end

    fprintf('Testing %s ...\n\n', partNames{i} );
    result = 1;

    switch i
    case 1 % NaiveGetNextClusters
      for iter = 1:3
        [out1 out2] = NaiveGetNextClusters( exampleINPUT.t1a1, exampleINPUT.t1a2{iter} );
        Output.t1{iter} = [out1 out2];
        
        resultIter = isEqualTol(Output.t1{iter}, exampleOUTPUT.t1{iter}, ...
            sprintf('Output.t1{%d}', iter) );
        fprintf('iter %d) ---- %s\n\n', iter, bool2ans(resultIter));
        
        result = result && resultIter;
      end
      
    case 2 % CreateClusterGraph
      Output.t2 = CreateClusterGraph(exampleINPUT.t2a1, exampleINPUT.t2a2);
      result = isEqualTol(Output.t2, exampleOUTPUT.t2, 'Output.t2');

    case 3 % CheckConvergence
      for iter = 1:2
        Output.t3{iter} = CheckConvergence( exampleINPUT.t3a1{iter}, exampleINPUT.t3a2{iter} );

        resultIter = isEqualTol(logical(Output.t3{iter}), logical(exampleOUTPUT.t3{iter}), ...
            sprintf('Output.t3{%d}', iter) );
        fprintf('iter %d) ---- %s\n\n', iter, bool2ans(resultIter));
        
        result = result && resultIter;
      end    

    case 4 % ClusterGraphCalibrate
      if (basicTestOnly)
        [Output.t4o1 Output.t4o2] = ClusterGraphCalibrate(exampleINPUT.t4a1, 0);
        result = isEqualTol(Output.t4o1, exampleOUTPUT.t4o1, 'Output.t4o1') && ...
               isEqualTol(Output.t4o2, exampleOUTPUT.t4o2, 'Output.t4o2');
      else   
        [Output.t4o1 Output.t4o2 Output.t4o3] = A_ClusterGraphCalibrate_Test(exampleINPUT.t4a1, 0);
        result = isEqualTol(Output.t4o1, exampleOUTPUT.t4o1, 'Output.t4o1') && ...
               isEqualTol(Output.t4o2, exampleOUTPUT.t4o2, 'Output.t4o2') && ...
               isEqualTol(Output.t4o3, additionalOUTPUT.t4o3, 'Output.t4o3');
      end
      
    case 5 % ComputeApproxMarginalsBP
      Output.t5 = ComputeApproxMarginalsBP(exampleINPUT.t5a1, exampleINPUT.t5a2);
      result = isEqualTol(Output.t5, exampleOUTPUT.t5, 'Output.t5');   
  
    case 6 % BlockLogDistribution
      for iter = 1:4
        if (iter == 1)
          Output.t6{1} = BlockLogDistribution(exampleINPUT.t6a1, ...
              exampleINPUT.t6a2, exampleINPUT.t6a3, exampleINPUT.t6a4);
          answer = exampleOUTPUT.t6;          
        elseif (~basicTestOnly)   
          Output.t6{iter} = BlockLogDistribution( ...
              additionalINPUT.t6a1{iter}, additionalINPUT.t6a2{iter}, ...
              additionalINPUT.t6a3{iter}, additionalINPUT.t6a4{iter});
          answer = additionalOUTPUT.t6{iter};
        end
        
        resultIter = isEqualTol(Output.t6{iter}, answer, ...
             sprintf('Output.t6{%d}', iter), 0.001 );
        fprintf('iter %d) ---- %s\n\n', iter, bool2ans(resultIter));
        
        result = result && resultIter;
        
        if basicTestOnly; break; end;
      end 

    case 7 % GibbsTrans
      randi('seed',1);
      for iter = 1:10
        Output.t7{iter} = GibbsTrans(exampleINPUT.t7a1{iter}, ...
            exampleINPUT.t7a2{iter}, exampleINPUT.t7a3{iter});

        resultIter = isEqualTol(Output.t7{iter}, exampleOUTPUT.t7{iter}, ...
            sprintf('Output.t7{%d}', iter) );
        fprintf('iter %d) ---- %s\n\n', iter, bool2ans(resultIter));
        
        result = result && resultIter;
      end

    case 8 % MCMCInference
      exampleINPUT.t8a4{2} = 'MHGibbs';
      randi('seed',1);
      for iter = 1:2
        [Output.t8o1{iter}, Output.t8o2{iter}] = MCMCInference(exampleINPUT.t8a1{iter},...
            exampleINPUT.t8a2{iter}, exampleINPUT.t8a3{iter}, ...
            exampleINPUT.t8a4{iter}, exampleINPUT.t8a5{iter}, ...
            exampleINPUT.t8a6{iter}, exampleINPUT.t8a7{iter}, ...
            exampleINPUT.t8a8{iter});
        
        resultIter = ...
          isEqualTol(Output.t8o1{iter}, exampleOUTPUT.t8o1{iter}, ...
            sprintf('Output.t8o1{%d}', iter) ) && ...
          isEqualTol(Output.t8o2{iter}, exampleOUTPUT.t8o2{iter}, ...
            sprintf('Output.t8o2{%d}', iter) );
        fprintf('iter %d) ---- %s\n\n', iter, bool2ans(resultIter));
        
         result = result && resultIter;
       end

    case 9 % MHUniformTrans
      randi('seed',1);
      for iter = 1:10
        Output.t9{iter} = MHUniformTrans(exampleINPUT.t9a1{iter}, ...
            exampleINPUT.t9a2{iter}, exampleINPUT.t9a3{iter});
      
        resultIter = isEqualTol(Output.t9{iter}, exampleOUTPUT.t9{iter}, ...
            sprintf('Output.t9{%d}', iter) );
        fprintf('iter %d) ---- %s\n\n', iter, bool2ans(resultIter));
        
        result = result && resultIter;       
      end

    case 10 % MHSWTrans (Variant 1)
      randi('seed',1);
      for iter = 1:10
        Output.t10{iter} = MHSWTrans(exampleINPUT.t10a1{iter}, ...
          exampleINPUT.t10a2{iter}, exampleINPUT.t10a3{iter}, ...
          exampleINPUT.t10a4{iter});
      
        resultIter = isEqualTol(Output.t10{iter}, exampleOUTPUT.t10{iter}, ...
          sprintf('Output.t10{%d}', iter) );
        fprintf('iter %d) ---- %s\n\n', iter, bool2ans(resultIter));
        
        result = result && resultIter;
      end

    case 11 % MHSWTrans (Variant 2)
      randi('seed',1);
      for iter = 1:20
        Output.t11{iter} = MHSWTrans(exampleINPUT.t11a1{iter}, ...
          exampleINPUT.t11a2{iter}, exampleINPUT.t11a3{iter}, ...
          exampleINPUT.t11a4{iter});
      
        resultIter = isEqualTol(Output.t11{iter}, exampleOUTPUT.t11{iter}, ...
          sprintf('Output.t11{%d}', iter) );
        fprintf('iter %d) ---- %s\n\n', iter, bool2ans(resultIter));
        
        result = result && resultIter;
      end
            
    case 12 % MCMCInference (part 2)
      randi('seed',1);
      for iter = 1:2
        [Output.t12o1{iter}, Output.t12o2{iter}] = ...
            MCMCInference(exampleINPUT.t12a1{iter},...
                exampleINPUT.t12a2{iter}, exampleINPUT.t12a3{iter}, ...
                exampleINPUT.t12a4{iter}, exampleINPUT.t12a5{iter}, ...
                exampleINPUT.t12a6{iter}, exampleINPUT.t12a7{iter}, ...
                exampleINPUT.t12a8{iter});
      
        resultIter = ...
            isEqualTol(Output.t12o1{iter}, exampleOUTPUT.t12o1{iter}, ...
              sprintf('Output.t12o1{%d}', iter) ) && ...
            isEqualTol(Output.t12o2{iter}, exampleOUTPUT.t12o2{iter}, ...
              sprintf('Output.t12o2{%d}', iter) );
        fprintf('iter %d) ---- %s\n\n', iter, bool2ans(resultIter));
        
        randi('seed', 26288942);
        result = result && resultIter;
      end
    end % end switch
      
    fprintf( [num2str(i), ')', char(9), partNamesAlligned(i,:), '  -----  '] );
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
    fprintf('%s answer!\n', bool2ans(result));
end

function id = homework_id() 
  id = '5';
end

function [partNames] = validParts()
  partNames = { 'NaiveGetNextClusters', ...
                'CreateClusterGraph', ...
                'CheckConvergence', ...
                'ClusterGraphCalibrate', ...
                'ComputeApproxMarginalBP', ...
                'BlockLogDistribution',...
                'GibbsTrans', ...
                'MCMCInference PART 1', ...
                'MHUniformTrans',...
                'MHSWTrans variant 1', ...
                'MHSWTrans variant 2', ...
                'MCMCInference PART 2'
              };
end

function srcs = sources()
  % Separated by part
  srcs = { { 'NaiveGetNextClusters.m'}, ... %1
           { 'CreateClusterGraph.m'}, ... %3
           { 'CheckConvergence.m'}, ... %5
           { 'ClusterGraphCalibrate.m'}, ... %7
           { 'ComputeApproxMarginalsBP.m'}, ... %9
           { 'BlockLogDistribution.m'}, ... %11
           { 'GibbsTrans.m'},... %13
           { 'MCMCInference.m'}, ... %15
           { 'MHUniformTrans.m'},... %17
           { 'MHSWTrans.m'}, ... %19
           { 'MHSWTrans.m'}, ... %21
           { 'MCMCInference.m'} %23
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