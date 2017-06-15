function callerVariables=standardParameters()
% callerVariables=standardParameters()
%
% Returns the default parameters. Typically not called directly.
%
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

%% Get localVariables_ from caller's workspace

callerVariables{1,1}.type='parameter';
callerVariables{1,1}.VariableName='verboseLevel';
callerVariables{1,1}.DefaultValue=0;
callerVariables{1,1}.Description={
    'Level of verbose for debug outputs (|0| - for no debug output)'};

callerVariables{2,1}.type='parameter';
callerVariables{2,1}.VariableName='parametersStructure';
callerVariables{2,1}.DefaultValue='';
callerVariables{2,1}.Description={
    'Structure whose fields are used to initialize parameters'
    'not present in the list of parameters passed to the function.'
    'This structure should contains fields with names that match'
    'the name of the parameters to be initialized.'
                   };

callerVariables{3,1}.type='parameter';
callerVariables{3,1}.VariableName='pedigreeClass';
callerVariables{3,1}.DefaultValue='';
callerVariables{3,1}.Description={
    'When nonempty, the function outputs are saved to a file set.'
    'All files in the set will be characterized by a ''pedigree'','
    'which decribes all the input parameters that were used in the script.'
    'This variable contains the name of the file class and may include a path.'
    'See also createPedigree'
                   };

callerVariables{4,1}.type='parameter';
callerVariables{4,1}.VariableName='executeScript';
callerVariables{4,1}.AdmissibleValues={'yes','no','asneeded'};
callerVariables{4,1}.DefaultValue='yes';
callerVariables{4,1}.Description={
    'Determines whether or not the body of the function should be executed:'
    '* |yes| - the function body should always be executed.'
    '* |no|  - the function body should never be executed and therefore the'
    '          function returns after processing all the input parameters.'
    '* |asneeded| - if a pedigree file exists that match all the input parameters'
    '               (as well as all the parameters of all ''upstream'' functions)'
    '               the function body is not executed, otherwise it is execute.'
                   };
