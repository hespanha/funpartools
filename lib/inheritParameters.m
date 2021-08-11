function inheritParameters(fun,pars)
% inheritParameters(function,parameters)
%
% Inherits from the function with name ''fun'' all the parameters with
% names in the cell string ''pars''
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

    funpars=feval(fun,'help');

    % select parameters of interest
    k=cellfun(@(x)ismember(x.VariableName,pars),funpars,'UniformOutput',true);
    funpars=funpars(k);

    %% Get localVariables_ from caller's workspace

    if evalin('caller','~exist(''localVariables_'',''var'')')
        % first time it is called, create 'standard' parameters
        if verboseLevel
            fprintf('declareParameter(%s): Initializing ''localVariables_'' in caller''s workspace\n',callerName);
        end
        callerVariables=standardParameters();
    else
        % add to existing parameter list
        callerVariables=evalin('caller','localVariables_');
    end

    for i=1:length(funpars)
        callerVariables{end+1,1}=funpars{i};
    end

    %% Assign localVariables_ to caller's workspace
    assignin('caller','localVariables_',callerVariables);
end