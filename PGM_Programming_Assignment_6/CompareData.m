function retval = CompareData(data1, data2, context, Params)
% function retval = comparedata(data1, data2, context, Params)
%   compares to see if data1 and data2 are roughly recursively equal. "Rough" here is defined by
%   the Params.  Note that matlabs ISEQUAL function is a test for exact equality.  comparedata
%   will print out intermediate results wheras ISEQUAL just returns 0 or 1.
% Output Arg
%   retval = 0 for not roughly equal 1 for roughly equal.
% Input Args: - Note context and Params are optional and have defaults as specified below.
%   data1, data2 - objects to be compared - arbitrarily nested structurs, cell arrays, numeric arrays.
%       Anything else gets compared with ISEQUAL.
%   context('Top') - This is current context string of the recursion.  Example: if the user calls
%       comparedata with an empty context or ommits it all together the top level context will
%       be set to "Top".  If then, for example, data1 and data2 are structures and data1 has
%       a "Fred" field but data2 doesn't the program will print out:
%       "Mismatch in Top.Fred not found in second structure.
%   Params - structure
%       outfileorfid(1) - Place to print progress. Either name of a file or a file handle open for 
%           writing text. Default of 1 is handle 1 which means the screen.  String implies path
%           name.
%           Note that if there is a mismatch a message with the start word "Mismatch" will be output
%           so as to facilitate file searching.
%       displaycontextprogress(1) - outputs current context string at each new level of recursion
%           e.g Top.a.b.c would mean that data1.a.b.c is being compared to data2.a.b.c
%           Note that if turned on this gets written out to the screen and to the location specified
%           to outfileorfid (obviously if outfileorfid is 1 by user input or default it's not
%           output twice).
%       NumericTolerance(1e-10) - When comparing numeric arrays (at any level of comparison recursion)
%           equality will be determined by whether all elements of the two items have an 
%           absolute value difference less than this tolerance. That is:
%           max(abs(Array1(:) - Array2(:))) < NumericTolerance
%           1e-10 should be good enough for practical equality for real life being small enough
%               to be beyond the accuracy of data yet account for typical numeric error growth
%      ignoreunmatchedfieldnames(0) - if at some level of recursion two structures are being compared
%           such that one has fields that the other doesn't have 0 will mean that the comparedata can
%           still return 1 (i.e. rough equality) if the common fields are recursively roughly equal.
%           A value of 0, the default, means that unique fields automatically disqualify rough equality.
%           Note that in any event, the field differences will be output.
%      showMinMaxAbsDiff(1) - show min/max/abs while comparing numeric arrays
% Notes:
%   If at some level of recursive comparison the rough equality test fails the 
%   function will continue.  It will continue comparing as best it can.  This means
%   comparing just the common fields of structures even if some fields are not in common
%   but array elements (e.g. cell arrays or structur arrays) will not be compared (and
%   so not recursively compared if their size doesn't match.
%
%   Things that are defined as mismatches (in order):
%   If the type of the two objects differ.  This is determined by Matlab's CLASS function.  This means
%       that numeric arrays although numerically equal can fail if they have different numeric suptypes.
%       Example retval=comparedata(int16([1]), double([1]) fails because data1 is a int16 and data2 is
%       a double although they are numerically equal.  This could be rectified but not today.
%   size(data1) ~= size(data2) - Everything's an array internally and so all must have the same no. of 
%       elements.
%   Unique fields in a structure - if ignoreunmatchedfieldnames is non-zero then this is not a mismatch.
%   Numeric arrays whose elements differ beyond tolerance as defined by NumericTolerance
%   isequal fails
%
%   Examples
%   >> retval=comparedata(int16([1]), double([1]))
%   context = Top
%   Top not the same data type int16 vs. double
%   retval =0
%
%   >> s1.a=1; s1.b=2; s1.c=3;         s2.a=1; s2.b=2;
%   >> retval=comparedata(s1, s2, [], struct('ignoreunmatchedfieldnames', 1))
%   context = Top
%   Mismatch in Top.c not found in second structure
%   context = Top.a
%   context = Top.b
%   retval =1
%   
%   Comparing RR and RG structures output answers to comparedataRRRG.txt and comparing numeric arrays
%   with a tolerance of 1e-5.  Context will show top level as Fred.  Output is long so select pieces are below:
%   >> retval=comparedata(RR, RG, 'Fred', struct('outfileorfid', 'comparedataRRRG.txt', 'NumericTolerance',1e-5));
%   context = Fred
%   Mismatch in Fred.RepDataMR not found in second structure
%   Mismatch in Fred.fred not found in second structure
%   ....
%   context = Fred.grn
%   Mismatch in Fred.grn. Two objects not the same array size: 0 0 vs 1 49777 
%   ...
%   Mismatch : at Fred.x numeric array comparison - abs(data 1 - data 2) > tolerance:
%       mindiff = -2115.180411 at [1, 45967]
%       maxdiff = 1880.794556 at [1, 45451]
%       max abs diff = 2115.180411 at [1, 45967]
%   context = Fred.y
%   Mismatch : at Fred.y numeric array comparison - abs(data 1 - data 2) > tolerance:
%       mindiff = -1882.577620 at [1, 44844]
%       maxdiff = 1667.421048 at [1, 26426]
%       max abs diff = 1882.577620 at [1, 44844]
%   ---------------------------------
%   Author: Andrew Diamond of EnVision Systems LLC, Svyatoslav Zarutskiy 

    defaultparams = struct('outfileorfid', 1, ...
                        'displaycontextprogress',1, ...
                        'NumericTolerance', 1e-10,...
                        'ignoreunmatchedfieldnames',0, ...
                        'showMinMaxAbsDiff', 1);

    if(~exist('Params', 'var'))
        Params = [];
    end

    Params = mergedefaultparams(Params, defaultparams);

    if(length(Params.outfileorfid) == 1 && isnumeric(Params.outfileorfid))
        Params.fid = Params.outfileorfid;
    elseif(~isempty(Params.outfileorfid) && ischar(Params.outfileorfid))
        [Params.fid, message] = fopen(Params.outfileorfid, 'wt');
        if(Params.fid < 3)
            error('Failed open file %s for reason %s', Params.outfileorfid, message);
        end
    end

    if(~exist('context', 'var') || isempty(context))
        context = 'Top';
    end

    retval = comparedatarecurse(data1, data2, context, Params);
end

function retval = comparedatarecurse(data1, data2, context, Params)
  persistent ParamsP;
  persistent iskindequalP;
  if(exist('Params', 'var'))
    iskindequalP = 1;
    ParamsP = Params;
  end
    
  if(ParamsP.displaycontextprogress)
    if(ParamsP.fid ~= 1)
      fprintf(1,'context = %s\n', context);
    end
    fprintf(ParamsP.fid,'context = %s\n', context);
  end
    
  if(~strcmp(class(data1), class(data2)))
    iskindequalP = 0;
    fprintf(ParamsP.fid,'%s not the same data type %s vs. %s\n',context, class(data1), class(data2));    
  elseif(any(size(data1) ~= size(data2)))
    iskindequalP = 0;
    fprintf(ParamsP.fid,'Mismatch in %s. Two objects have different array sizes: ',context);  
    fprintf(ParamsP.fid,'[%s] vs [%s]\n', num2str(size(data1)), num2str(size(data2)) );    
  elseif(isstruct(data1))
    names1 = fieldnames(data1);    
    names2 = fieldnames(data2);
    names1s = sort(names1);    
    names2s = sort(names2);
    matchinds = zeros(1, min(length(names1s), length(names2s)));
    imatchind = 0; 
      
    for inames1s = 1:length(names1s)
      if(isempty(strcmp(names1s{inames1s}, names2s)))
        fprintf(ParamsP.fid, ...
            'Mismatch in %s.%s not found in second structure\n', context, names1s{inames1s});
          if(~ParamsP.ignoreunmatchedfieldnames)
            iskindequalP = 0;
          end
      else
        imatchind = imatchind + 1;
         matchinds(imatchind) = inames1s;
      end
    end
      
    for inames2s = 1:length(names2s)
      if(isempty(strcmp(names2s{inames2s}, names1s)))
        fprintf(ParamsP.fid, ...
            'Mismatch in %s.%s not found in first structure\n', context, names2s{inames2s});
        if(~ParamsP.ignoreunmatchedfieldnames)
          iskindequalP = 0;
        end
      end
    end
      
    if (numel(data1) > 1)
      for iElt = 1:length(data1(:))
        [~, ind2subvretstr]=ind2subv(size(data1), iElt);
         comparestruct(data1(iElt), data2(iElt), names1s, ...
             matchinds(1:imatchind), sprintf('%s[%s]', context, ind2subvretstr));
      end
    else
      comparestruct(data1, data2, names1s, matchinds(1:imatchind), context);
    end
      
  elseif(iscell(data1))
    for iElt=1:length(data1(:))
      [~, ind2subvretstr]=ind2subv(size(data1), iElt);
      comparedatarecurse(data1{iElt}, data2{iElt}, sprintf('%s{%d}', context, ind2subvretstr));
    end
       
  elseif (isnumeric(data1))
    diff = data1(:) - data2(:);
    [mindiff, mindiffi] = min(diff);
    [maxdiff, maxdiffi] = max(diff);
    [maxabsdiff, maxabsdiffi] = max(abs(diff));
      
    if (maxabsdiff > ParamsP.NumericTolerance)
      if (numel(data1) == 1) % scalar
        fprintf(ParamsP.fid,...
            'Mismatch : at %s numeric scalar comparison - abs(data 1 - data 2) > tolerance of %g:\n', ...
            context, ParamsP.NumericTolerance);  
        fprintf(ParamsP.fid, ...
            'Scalar 1 = %e, Scalar 2 = %e, Scalar1 - Scalar2 = %e\n', ...
            data1, data2, data1-data2);
      else
        fprintf(ParamsP.fid, ...
            'Mismatch : at %s numeric array comparison - abs(data 1 - data 2) > tolerance of %g:\n', ...
            context,ParamsP.NumericTolerance);
              
          fprintf(ParamsP.fid, '   Found: [ %s ]\n', num2str(data1, '%.3f '));
          fprintf(ParamsP.fid, 'Expected: [ %s ]\n', num2str(data2, '%.3f '));
              
          if ParamsP.showMinMaxAbsDiff == 1
            [~, ind2subvretstr] = ind2subv(size(data1), mindiffi);
            fprintf(ParamsP.fid,'    mindiff = %e at [%s]\n', mindiff, ind2subvretstr);
            [~, ind2subvretstr] = ind2subv(size(data1), maxdiffi);
            fprintf(ParamsP.fid,'    maxdiff = %e at [%s]\n', maxdiff, ind2subvretstr);
            [~, ind2subvretstr] = ind2subv(size(data1), maxabsdiffi);
            fprintf(ParamsP.fid,'    max abs diff = %e at [%s]\n', maxabsdiff, ind2subvretstr);
          end
       end
       iskindequalP = 0;
    end
  
  elseif (islogical(data1))
    if ~isequal(data1, data2)
      if (numel(data1) == 1) % scalar
        fprintf(ParamsP.fid,...
            'Mismatch : at %s bool scalar comparison - bools are not equal:\n', ...
            context);  
        fprintf(ParamsP.fid, 'Bool found = %s, Bool expected = %s\n', mat2str(data1), mat2str(data2));
      else
        fprintf(ParamsP.fid, ...
            'Mismatch : at %s bool array comparison - arrays are not equal:\n', ...
            context);
              
          fprintf(ParamsP.fid, '   Found: [ %s ]\n', mat2str(data1));
          fprintf(ParamsP.fid, 'Expected: [ %s ]\n', mat2str(data2));              
       end
       iskindequalP = 0;
    end
    
  elseif (~isequal(data1, data2))
    fprintf(ParamsP.fid, ...
        'Mismatch in %s. Two non-numeric, non-cell, non-structure arrays are not equal \n', ...
        context);
    iskindequalP = 0;   
  end
    
  if(exist('Params', 'var'))
    if(ischar(ParamsP.outfileorfid))
      fclose(ParamsP.fid);
    end
    retval = iskindequalP;
  end
end

function comparestruct(data1, data2, names, matchinds, context)
    for imatchnames = 1:length(matchinds)
        namei = names{matchinds(imatchnames)};
        comparedatarecurse(data1.(namei), data2.(namei), sprintf('%s.%s',context,namei));
    end
end

function [ind2subvret, ind2subvretstr] = ind2subv(arraysize, ind1d)
    retstring = '[';
    for k=1:length(arraysize)-1
        retstring = sprintf('%sI%d, ', retstring,k);
    end
    if(~isempty(arraysize))
        retstring = sprintf('%sI%d', retstring,length(arraysize));
    end
    
    retstring = sprintf('%s]', retstring);
    evalstring = [retstring, '= ind2sub(', 'arraysize,', num2str(ind1d), ');'];
    eval(evalstring);
    ind2subvret = eval(retstring);
    ind2subvretstr = sprintf('%d, ',ind2subvret);
    commas = strfind(ind2subvretstr,','); % for backward compaitibility to 6.0, etc. find(ind2subvretstr == ',');
    
    if(~isempty(commas))
        ind2subvretstr = ind2subvretstr(1:commas(end)-1);
    end
end

function params = mergedefaultparams(params, defaultparams)
    if(isempty(params))
        params = defaultparams;
        return;
    end
    names = fieldnames(defaultparams);
    for iname=1:length(names)
        namei = names{iname};
        if(~isfield(params,namei)) % add the default 
            params.(namei) = defaultparams.(namei);
        elseif( isstruct( defaultparams.(namei) ) )
            params.(namei) = mergedefaultparams( params.(namei), defaultparams.(namei) );
        end
    end
end
