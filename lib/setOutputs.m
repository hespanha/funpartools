function vargout=setOutputs(nargout,params)
% output=setOutputs()
%
% Returns caller's varargout
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

verboseLevel=0;  % 0 none, 1 less, 2 more

callerName_=dbstack(1);
callerName_=callerName_(1).name;

%% Get localVariables_ from caller's workspace

if evalin('caller','exist(''pedigreeClass'',''var'')')
    pedigreeClass=evalin('caller','pedigreeClass');
    pedigreeName=evalin('caller','pedigreeName_');
    className=evalin('caller','className_');
else
    pedigreeClass='';
end

if evalin('caller','exist(''localVariables_'',''var'')')
    callerVariables=evalin('caller','localVariables_');
else
    error('setParameters(%s): Use declareParameters before calling setOutput\n',callerName_);
end

%% Assign output values
vargout={};
k=1;
for i=1:length(callerVariables)
    if k>nargout
        break;
    end
    if strcmp(callerVariables{i}.type,'output')
        vargout{k}=evalin('caller',callerVariables{i}.VariableName);
        if ~isempty(pedigreeClass)
            filename=sprintf('%s+%s',className,callerVariables{i}.VariableName);
            eval(sprintf('%s=vargout{k};',callerVariables{i}.VariableName));
            vargout{k}=outputWithPedigree(pedigreeName,filename,callerVariables{i}.VariableName);
            saveValue(vargout{k},eval(callerVariables{i}.VariableName),callerName_);
        end
        k=k+1;
    end
end

if nargout>length(vargout)
    error('setOutputs: %d outputs declared, but function was called with %d outputs\n',length(vargout),nargout);
end

