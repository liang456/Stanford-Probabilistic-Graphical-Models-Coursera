function PS2_RunTests()

    clear;

    constTOL = 1e-6;

    load('PA2_TestInput');
    load('PA2_TestOutput');
    
    partNames = validParts();
    partId = promptPart();

    len = length(partNames);
    partNamesAlligned = char( partNames );
    
    resultAll = 1;
    
    for i = 1:len
        if ( partId ~= (len+1) && partId ~= i )
            continue;
        end
    
        switch i
        case 1 % PhenotypeGivenGenotypeMendelianFactor
            % Example 1 (from sampleGeneticNetworks.m)
            Output.t1 = phenotypeGivenGenotypeMendelianFactor(TestInput.t1i1, TestInput.t1i2, TestInput.t1i3);
            result = isequal(TestOutput.t1, Output.t1);
        case 2 % PhenotypeGivenGenotypeFactor
            % Example 1 (from sampleGeneticNetworks.m)
            Output.t2 = phenotypeGivenGenotypeFactor(TestInput.t2i1, TestInput.t2i2, TestInput.t2i3);
            result = isEqualTol(TestOutput.t2, Output.t2, constTOL);
        case 3 % GenotypeGivenAlleleFreqsFactor
            % Example 1 (from sampleGeneticNetworks.m)
            Output.t3 = genotypeGivenAlleleFreqsFactor(TestInput.t3i1, TestInput.t3i2);
            result = isEqualTol(TestOutput.t3, Output.t3, constTOL);
        case 4 % GenotypeGivenParentsGenotypesFactor
            % Example 1 (from sampleGeneticNetworks.m)
            Output.t4e1 = genotypeGivenParentsGenotypesFactor(TestInput.t4i1, ...
                TestInput.t4i2, TestInput.t4i3, TestInput.t4i4);
            result = isEqualTol(TestOutput.t4e1, Output.t4e1, constTOL);
            
            % Example 2 (Additional example)
            Output.t4e2 = genotypeGivenParentsGenotypesFactor(TestInput.t4e2i1, ...
                TestInput.t4e2i2, TestInput.t4e2i3, TestInput.t4e2i4);
            result = result && isEqualTol(TestOutput.t4e2, Output.t4e2, constTOL);
        case 5 % ConstructGeneticNetwork
            % Example 1 (from sampleGeneticNetworks.m)
            Output.t5 = constructGeneticNetwork(TestInput.t5i1, TestInput.t5i2, TestInput.t5i3);
            result = isEqualTol(TestOutput.t5e1, Output.t5, constTOL);          
        case 6 % PhenotypeGivenCopiesFactor
            % Example 1 (from sampleGeneticNetworks.m)
            Output.t6 = phenotypeGivenCopiesFactor(TestInput.t6i1, TestInput.t6i2, ...
                TestInput.t6i3, TestInput.t6i4, TestInput.t6i5);
            result = isEqualTol(TestOutput.t6e1, Output.t6, constTOL);
        case 7 % ConstructDecoupledGeneticNetwork
            % Example 1 (from sampleGeneticNetworks.m)
            Output.t7 = constructDecoupledGeneticNetwork(TestInput.t7i1, TestInput.t7i2, TestInput.t7i3);
            result = isEqualTol(TestOutput.t7e1, Output.t7, constTOL);
        case 8 % ConstructSigmoidPhenotypeFactor
            % Example 1 (from sampleGeneticNetworks.m)
            Output.t8 = constructSigmoidPhenotypeFactor(TestInput.t8i1, ...
                TestInput.t8i2, TestInput.t8i3, TestInput.t8i4);

            result = isEqualTol(TestOutput.t8e1, Output.t8, constTOL);
        end % switch
        
        fprintf( [num2str(i), ')', char(9), partNamesAlligned(i,:), '  -----  '] );
        display_result(result);
        
        resultAll = resultAll && result;
    end % for

if resultAll
    fprintf('\nALL CODE IS CORRECT!\n\n')
else
    fprintf('\nSOME CODE IS INCORRECT!\n\n')
end

end % end function 'PS2_RunTests'

function display_result(result)
    if result
        fprintf('Correct answer!\n')
    else
        fprintf('Incorrect answer!\n')
    end
end


function id = homework_id() 
  id = '2';
end

function [partNames] = validParts()
  partNames = { 'phenotypeGivenGenotypeMendelianFactor', ...
                'phenotypeGivenGenotypeFactor', ...
                'genotypeGivenAlleleFreqsFactor', ...
                'genotypeGivenParentsGenotypesFactor', ...
                'constructGeneticNetwork', ...
                'phenotypeGivenCopiesFactor', ...
                'constructDecoupledGeneticNetwork', ...
                'constructSigmoidPhenotypeFactor'
              };
end

function srcs = sources()
  % Separated by part
  srcs = { { 'phenotypeGivenGenotypeMendelianFactor.m' }, ...
           { 'phenotypeGivenGenotypeFactor.m' }, ...
           { 'genotypeGivenAlleleFreqsFactor.m' }, ...
           { 'genotypeGivenParentsGenotypesFactor.m' }, ...
           { 'constructGeneticNetwork.m' }, ...
           { 'phenotypeGivenCopiesFactor.m' }, ...
           { 'constructDecoupledGeneticNetwork.m' }, ...
           { 'constructSigmoidPhenotypeFactor.m' }
         };
end

function ret = isValidPartId(partId)
  partNames = validParts();
  ret = (~isempty(partId)) && (partId >= 1) && (partId <= numel(partNames) + 1);
end

function partId = promptPart()
  fprintf('== Select which part(s) to test:\n', ...
          homework_id());
  partNames = validParts();
  srcFiles = sources();
  for i = 1:numel(partNames)
    fprintf('==   %d) %s [', i, partNames{i});
    fprintf(' %s ', srcFiles{i}{:});
    fprintf(']\n');
  end
  fprintf('==   %d) All of the above \n==\nEnter your choice [1-%d]: ', ...
          numel(partNames) + 1, numel(partNames) + 1);
  selPart = input('', 's');
  partId = str2num(selPart);
  if ~isValidPartId(partId)
    partId = -1;
  end
  
  fprintf('\n\n');
end

function res = isEqualTol(argument1, argument2, toleranceInput)
  res = comparedata(argument1, argument2, [], ...
                struct('displaycontextprogress', 0, 'NumericTolerance', toleranceInput));
end
