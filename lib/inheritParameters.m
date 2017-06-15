function inheritParameters(fun,pars)
% inheritParameters(function,parameters)
%
% Inherits from the function with name ''fun'' all the parameters with
% names in the cell string ''pars''
%
% Copyright 2012-2017 Joao Hespanha

% This file is part of Tencalc.
%
% TensCalc is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version.
%
% TensCalc is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with TensCalc.  If not, see <http://www.gnu.org/licenses/>.

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