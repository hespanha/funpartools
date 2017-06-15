function declareOutput(varargin)
% declareOutput(...
%     'VariableName','string with the name of the variable',...
%     'Description',{ 
%                    'variable description (line 1)'
%                    'variable description (line 2)'
%                    ... });
%
% Declares an output for a function
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



verboseLevel=0;

callerName=dbstack(1);
callerName=callerName(1).name;

%% Get localVariables_ from caller's workspace

if evalin('caller','~exist(''localVariables_'',''var'')')
    % first time it is called, create 'standard' parameters
    if verboseLevel
        fprintf('declareOutput(%s): Initializing ''localVariables_'' in caller''s workspace\n',callerName);
    end
    callerVariables=standardParameters();
else
    % add to existing parameter list
    callerVariables=evalin('caller','localVariables_');
end

thisVariable.type='output';

%% Go over list of inputs
i=1;
while i<length(varargin)
    if isfield(thisVariable,varargin{i})
        error('declareOutput(%s): Only one ''%s'' allowed\n',callerName,varargin{i})
    end
    switch varargin{i}
      case 'VariableName'
        thisVariable.VariableName=varargin{i+1};
        if exist(thisVariable.VariableName,'builtin')
            error('declareOutput(%s): Variable name ''%s'' is a builtin function\n',callerName,thisVariable.VariableName);
        end
        % if exist(thisVariable.VariableName,'file')
        %     error('declareOutput(%s): Variable name ''%s'' is an m-script (%s)\n',callerName,thisVariable.VariableName,which(thisVariable.VariableName));
        % end
        i=i+2;
      case 'Description'
        thisVariable.Description=varargin{i+1};
        i=i+2;
      otherwise
        error('declareOutput(%s): Unknown input type ''%s''\n',callerName,varargin{i});
    end
end

if ~isfield(thisVariable,'VariableName')
    error('declareOutput(%s): ''VariableName'' required\n',callerName);
end

%% Assign localVariables_ to caller's workspace

callerVariables{end+1,1}=thisVariable;

assignin('caller','localVariables_',callerVariables);