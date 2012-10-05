function T = IsFactorEqual(F1, F2)
	% Compare var
	if (~isempty(setdiff(F1.var, F2.var))), T=0; return; end;
	% Compare card
	if (F1.card ~= F2.card), T=0; return; end;
	% Compare val
	% fprintf("Check val %f\n", F1.val-F2.val);
	if (any(abs(F1.val-F2.val) > 0.0001)), T=0; return; end;	
	T = 1;
end