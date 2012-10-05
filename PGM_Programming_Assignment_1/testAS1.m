function testAS1
	A = struct('var', [1], 'card', [2], 'val', [0.11, 0.89]);
	B = struct('var', [2, 1], 'card', [2, 2], 'val', [0.59, 0.41, 0.22, 0.78]);
	C = struct('var', [3, 2], 'card', [2, 2], 'val', [0.39, 0.61, 0.06, 0.94]);

	X = struct('var', [2, 1], 'card', [2, 3], 'val', [0.5, 0.8, 0.1, 0, 0.3, 0.9]);
	Y = struct('var', [3, 2], 'card', [2, 2], 'val', [0.5, 0.7, 0.1, 0.2]);
	
% Test Factor Product
	fprintf('Test Factor Product\n');
	% Case 1
	PRODUCT1 = struct('var', [1, 2], 'card', [2, 2], 'val', [0.0649, 0.1958, 0.0451, 0.6942]);
	assert(IsFactorEqual(PRODUCT1, FactorProduct(A, B)) == 1, 'Result not match!!');
	fprintf('Test case 1: Pass\n');

	% Case 2 (as in lecture note)
	PRODUCT2 = struct('var', [1, 2, 3], 'card', [3, 2, 2], 'val', [0.25, 0.05, 0.15, 0.08, 0, 0.09, 0.35, 0.07, 0.21, 0.16, 0, 0.18]);
	assert(IsFactorEqual(PRODUCT2, FactorProduct(X, Y)) == 1, 'Result not match!!');
	fprintf('Test case 2: Pass\n');
	
% Test Factor Marginalization
	fprintf('Test Factor Marginalization\n');
	% Case 1
	MARGINALIZATION = struct('var', [1], 'card', [2], 'val', [1 1]);	
	assert(IsFactorEqual(MARGINALIZATION, FactorMarginalization(B, [2])) == 1, 'Result not match!!');
	fprintf('Test case 1: Pass\n');
	
	% Case 2 (similar to lecture note, except that the order of variable is different
	%			hence the order of value in marginalization result factor is also different)
	Z = struct('var', [3, 2, 1], 'card', [2, 2, 3], 'val', [0.25, 0.35, 0.08, 0.16, 0.05, 0.07, 0, 0, 0.15, 0.21, 0.09, 0.18]);
	MARGINALIZATION = struct('var', [1, 3], 'card', [3, 2], 'val', [0.33, 0.05, 0.24, 0.51, 0.07, 0.39]);	
	assert(IsFactorEqual(MARGINALIZATION, FactorMarginalization(Z, [2])) == 1, 'Result not match!!');
	fprintf('Test case 2: Pass\n');

% Test Observe Evidence
	fprintf('Test Observe Evidence\n');
	% Case 1
	EVIDENCE(1) = struct('var', [1], 'card', [2], 'val', [0.11, 0.89]);
	EVIDENCE(2) = struct('var', [2, 1], 'card', [2, 2], 'val', [0.59, 0, 0.22, 0]);
	EVIDENCE(3) = struct('var', [3, 2], 'card', [2, 2], 'val', [0, 0.61, 0, 0]);	
	RESULTS = ObserveEvidence([A, B, C], [2 1; 3 2]);
	for i=1:3
		assert(IsFactorEqual(EVIDENCE(i), RESULTS(i)) == 1, 'Result not match!!');
	end
	fprintf('Test case 1: Pass\n');
	
	% Case 2 (as in lecture note)
	EVIDENCE = struct('var', [3, 2, 1], 'card', [2, 2, 3], 'val', [0.25, 0, 0.08, 0, 0.05, 0, 0, 0, 0.15, 0, 0.09, 0]);	
	RESULTS = ObserveEvidence([Z], [3 1]);
	assert(IsFactorEqual(EVIDENCE, RESULTS) == 1, 'Result not match!!');
	fprintf('Test case 2: Pass\n');
	
% Test Joint Distribution
	fprintf('Test Joint Distribution\n');
	% Case 1
	JOINT = struct('var', [1, 2, 3], 'card', [2, 2, 2], 'val', [0.025311, 0.076362, 0.002706, 0.041652, 0.039589, 0.119438, 0.042394, 0.652548]);	
	assert(IsFactorEqual(JOINT, ComputeJointDistribution([A B C])) == 1, 'Result not match!!');
	fprintf('Test case 1: Pass\n');
	
	% Case 2 (as in Question 9 of problem set 1)
% 	[F, names, valNames] = ConvertNetwork('Credit_net.net');			% change your file name accordingly
% 	JOINT = struct('var', [1, 2, 3], 'card', [2, 2, 2], 'val', [0.8019, 0.0891, 0.0036, 0.0054, 0.0495, 0.0495, 0.0001, 0.0009]);	
% 	assert(IsFactorEqual(JOINT, ComputeJointDistribution(F)) == 1, 'Result not match!!');
% 	fprintf('Test case 2: Pass\n');

% Test Marginal
	fprintf('Test Marginal\n');
	% Case 1
	MARGINAL = struct('var', [2, 3], 'card', [2, 2], 'val', [0.0858, 0.0468, 0.1342, 0.7332]);
	assert(IsFactorEqual(MARGINAL, ComputeMarginal([2, 3], [A B C], [1, 2])) == 1, 'Result not match!!');
	fprintf('Test case 1: Pass\n');

	% Case 2 (as in Question 9 of problem set 1)
	indxTraffic = 1;
	for i=1:length(names)
		if (strcmp(names{i}, 'Traffic'))
			indxTraffic = i; 
			break;
		end
	end
	TRAFFIC = struct('var', [indxTraffic], 'card', [2], 'val', [0.8551, 0.1449]); 
	assert(IsFactorEqual(TRAFFIC, ComputeMarginal([indxTraffic], [F], [])) == 1, 'Result not match!!');
	fprintf('Test case 2: Pass\n');	
end