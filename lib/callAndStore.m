function varargout=callAndStore(fun,varargin)
% [y1,y2,...]=callAndStore(@fun,x1,x2,...)
%
% Calls the function 'fun' using
%    [y1,y2,...]=fun(x1,x2,...)
% and stores its inputs and outputs (in a global variable), so that
% subsequent calls to the same function with the same parameters can
% simply return the stored values, without actually calling the
% function.
%
% callAndStore();
%
% Clears all previously saved data.
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


verboseLevel=1;

global callAndStoreSave_

if nargin==0 || isequal(callAndStoreSave_,[])
    callAndStoreSave_=struct('fun',{},'varargin',{},'varargout',{},'nCalls',{});
    fprintf('callAndStore: initializing structure to save data\n');
    if nargin==0
        return
    end
end

funName=char(fun);
if length(funName)>20
    funName=[funName(1:min(end,17)),'...'];
end

for i=1:length(callAndStoreSave_)
    if isequal(char(fun),char(callAndStoreSave_(i).fun)) && ...
            isequal(varargin,callAndStoreSave_(i).varargin) && ...
            nargout==length(callAndStoreSave_(i).varargout) 
        if verboseLevel>0
            fprintf('callAndStore: retrieving call to ''%s'' from stored value %d (%d retrieval)\n',...
                    funName,i,callAndStoreSave_(i).nCalls);
        end
        varargout=callAndStoreSave_(i).varargout;
        callAndStoreSave_(i).nCalls=callAndStoreSave_(i).nCalls+1;
        return
    end
    if verboseLevel>1
        fprintf('callAndStore: no match for stored value %d\n',i);
        fprintf('   fun      %d: "%s" == "%s"?\n',...
                isequal(char(fun),char(callAndStoreSave_(i).fun)),char(fun),char(callAndStoreSave_(i).fun));
        fprintf('   nargout  %d: %d == %d?\n',...
                nargout==length(callAndStoreSave_(i).varargout),nargout,length(callAndStoreSave_(i).varargout));
        fprintf('   varargin %d:\n',isequal(varargin,callAndStoreSave_(i).varargin));
        disp(varargin);
        disp(callAndStoreSave_(i).varargin);
    end
end
fprintf('callAndStore: calling function ''%s'' and storing results in entry %d\n',...
        funName,length(callAndStoreSave_)+1);
try
    [varargout{1:nargout}]=fun(varargin{:});
catch me
    fprintf('\ncallAndStore: error in calling ''%s'' with %d arguments:\n',funName,length(varargin))
    for i=1:length(varargin)
        fprintf(' %d:',i);
        disp(varargin{i})
    end
    rethrow(me)
end
callAndStoreSave_(end+1).fun=fun;
callAndStoreSave_(end).varargin=varargin;
callAndStoreSave_(end).varargout=varargout;
callAndStoreSave_(end).nCalls=1;
