function varargout=@BASEFILENAMELESSEXTENSION@(varargin);
% To get help, type @BASEFILENAMELESSEXTENSION@('help')
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

declareParameter(...
    'Help', {
        'This script does lots of stuff.'
            });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','inputVar1',...
    'AdmissibleValues',{},...
    'DefaultValue',[],...
    'Description', {
        'This input variable is XXXX.'
                   });
    
declareParameter(...
    'VariableName','inputVar2',...
    'AdmissibleValues',{},...
    'DefaultValue',[],...
    'Description', {
        'This input variable is XXXX.'
                   });

declareOutput(...
    'VariableName','outputVar1',...
    'Description', {
        'This output variable is XXXX.'
                   });
    
declareOutput(...
    'VariableName','outputVar2',...
    'Description', {
        'This output variable is XXXX.'
                   });
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Retrieve parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[stopNow,parameters__]=setParameters(nargout,varargin);
if stopNow
    return 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function body
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('@BASEFILENAMELESSEXTENSION@: starting...');
t0=clock;

% Code goes here

fprintf('done @BASEFILENAMELESSEXTENSION@ (%.3f sec)\n',etime(clock,t0));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set outputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

varargout=setOutputs(nargout,parameters__);


