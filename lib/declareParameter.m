function declareParameter(varargin)
% declareParameter(...
%     'VariableName','string with the name of the variable',...
%     'DefaultValue',default value for the variable; assigned if
%                      (1) not present in the list of parameters passed
%                          to the function, and
%                      (2) a value cannot be recoved from the
%                          |parametersStructure| in the field 'VariableName'
%                      (3) a value cannot be recoved from the
%                          |parametersMfile'' in a variable named
%                           parameters.'callerFunction'.'VariableName'
%                    when the function getFromPedigree() is passed as the
%                    'DefaultValue', a string is composed based on
%                    the name of the pedigree
%
%     'AdmissibleValues',{ list of admissible value for the variable },...
%     'Description',{ 
%                    'variable description (line 1)'
%                    'variable description (line 2)'
%                    ... },...
%     'PossibleInheritances',{ 
%          % list of scripts and input parameters for those scripts from 
%          % which the value for this variable could be inherited 
%          % (possibly after regexprep substitution)
%          'script name 1','parameters','regular expression','replacement rule';
%          'script name 2','parameters','regular expression','replacement rule';
%          ...
%          });
%
% Declares an input parameter for a function. 
%
% declareParameter(...
%     'Help','string with a help header describing the function');
%
% Defines a help header that describes the overal function. The
% actual help for the function also includes the 'Description' of
% the several input and output parameters. 
% 
% The help header and input/output parameter descriptions may
% include Matlab's publishing Markup:
%  . *BOLD TEXT*
%  . |MONOSPACED TEXT|
%  . * bulleted item 1
%    * bulleted item 2
%  . %  monospaced text [preceeded by % and 2 or more spaces
%
% The first times it is called, declares the following 'standard' parameters:
%
% declareParameter(...
%     'VariableName','verboseLevel',...
%     'DefaultValue',0,...
%     'Description', {
%         'Level of verbose for debug outputs (0 - for no debug output)'});
% declareParameter(...
%     'VariableName','parametersStructure',...
%     'DefaultValue','',...
%     'Description', {
%         'Structure whose fields are used to initialize parameters'
%         'not present in the list of parameters passed to the function.'
%         'This structure should contains fields with names that match'
%         'the name of the parameters to be initialized.'
%         });
% declareParameter(...
%     'VariableName','pedigreeClass',...
%     'DefaultValue','',...
%     'Description', {
%         'When nonempty, the function outputs are saved to a file set.'
%         'All files in the set will be characterized by a ''pedigree'','
%         'which decribes all the input parameters that were used in the script.'
%         'This variable contains the name of the file class and may include a path.'
%         'See also createPedigree'
%         });
% declareParameter(...
%     'VariableName','executeScript',...
%     'AdmissibleValues',{'yes','no','asneeded'},...
%     'DefaultValue','yes',...
%     'Description', {
%             'Determines whether or not the body of the function should be executed:'
%             '''yes'' - the function body should always be executed.'
%             '''no''  - the function body should never be executed and therefore the'
%             '          function returns after processing all the input parameters.'
%             '''asneeded'' - if a pedigree file exists that match all the input parameters'
%             '               (as well as all the parameters of all ''upstream'' functions)'
%             '               the function body is not executed, otherwise it is execute.'
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
        fprintf('declareParameter(%s): Initializing ''localVariables_'' in caller''s workspace\n',callerName);
    end
    callerVariables=standardParameters();
else
    % add to existing parameter list
    callerVariables=evalin('caller','localVariables_');
end

thisVariable.type='parameter';

%% Go over list of inputs
i=1;
while i<length(varargin)
    if isfield(thisVariable,varargin{i})
        error('declareParameter(%s): Only one ''%s'' allowed\n',callerName,varargin{i})
    end
    switch varargin{i}
      case 'Help'
        thisVariable.VariableName='Help_';
        thisVariable.Description=varargin{i+1};
        i=i+2;
      case 'VariableName'
        thisVariable.VariableName=varargin{i+1};
        if exist(thisVariable.VariableName,'builtin')
            error('declareParameter(%s): Variable name ''%s'' is a builtin function\n',callerName,thisVariable.VariableName);
        end
        % if exist(thisVariable.VariableName,'file')
        %     error('declareParameter(%s): Variable name ''%s'' is an m-script (%s)\n',callerName,thisVariable.VariableName,which(thisVariable.VariableName));
        % end
        i=i+2;
      case 'DefaultValue'
        thisVariable.DefaultValue=varargin{i+1};
        i=i+2;
      case 'AdmissibleValues'
        thisVariable.AdmissibleValues=varargin{i+1};
        i=i+2;
      case 'Description'
        thisVariable.Description=varargin{i+1};
        i=i+2;
      case 'PossibleInheritances'
        thisVariable.PossibleInheritances=varargin{i+1};
        i=i+2;
      otherwise
        error('declareParameter(%s): Unknown input type ''%s''\n',callerName,varargin{i});
    end
end

if ~isfield(thisVariable,'VariableName')
    error('declareParameter(%s): ''VariableName'' required\n',callerName);
end

%% Assign localVariables_ to caller's workspace

callerVariables{end+1,1}=thisVariable;

assignin('caller','localVariables_',callerVariables);