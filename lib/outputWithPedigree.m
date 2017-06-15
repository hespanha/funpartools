classdef outputWithPedigree
% Class used to represent variables stored in files.
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

    properties
        pedigreeName
        fileName
        variableName
        saveformat='serial';
                           % 'plainsave' seems to be the same as 'v7
                           % 'v7'   much faster than -v7.3
                           % 'v7.3' slower, but seems needed for large files
                           % 'serial' very fast but seems to cause a crash for large data
    end
    
    methods
        function [obj,fileExists]=outputWithPedigree(pedigreeName,fileName,variableName)
            obj.pedigreeName=pedigreeName;
            obj.fileName=fileName;
            obj.variableName=variableName;
            switch obj.saveformat
              case 'plainsave' % probably same as v7
                if nargout>1
                    fileExists=exist(obj.fileName,'file');
                end
              case 'v7'
                if nargout>1
                    fileExists=exist(obj.fileName,'file');
                end
              case 'v7.3'
                if nargout>1
                    fileExists=exist(obj.fileName,'file');
                end
              case 'serial'
                obj.fileName=regexprep(obj.fileName,'\.mat$',''); 
                if nargout>1
                   fileExists=exist([obj.fileName,'.serialmatlab'],'file');
                end
              otherwise
                error('%s: unkown save format ''%s''\n',caller,obj.saveformat);
            end
        end
        
        function saveValue(obj,value,caller)
            if nargin>=3
                fprintf('%s: saving %s -> %s... ',caller,obj.variableName,obj.fileName);
                t0=clock;
            end
            switch obj.saveformat
              case 'plainsave' % probably same as v7
                assign(obj.variableName,value);
                save(obj.fileName,obj.variableName); 
              case 'v7'
                assign(obj.variableName,value);
                save(obj.fileName,obj.variableName,'-v7');  % much faster than -v7.3
              case 'v7.3'
                assign(obj.variableName,value);
                save(obj.fileName,obj.variableName,'-v7.3'); % very slow but needed for large files
              case 'serial'
                serialsave(obj.fileName,value);
              otherwise
                error('%s: unkown save format ''%s''\n',caller,obj.saveformat);
            end
            if nargin>=3
                fprintf('done (%.3f sec)\n',etime(clock,t0));
            end
        end
        
        function value=getValue(obj,caller)
            if nargin>=2
                fprintf('%s: loading %s <- %s... ',caller,obj.variableName,obj.fileName);
                t0=clock;
            end
            switch obj.saveformat
              case {'plainsave','v7','v7.3'}
                load(obj.fileName,obj.variableName);
                value=eval(obj.variableName);
              case 'serial'
                value=serialload(obj.fileName);
              otherwise
                error('%s: unkown save format ''%s''\n',caller,obj.saveformat);
            end
            if nargin>=2
                fprintf('done (%.3f sec)\n',etime(clock,t0));
            end
        end
        
        function disp(obj)
            fprintf('pedigreeName = %s\n',obj.pedigreeName);
            fprintf('fileName     = %s\n',obj.fileName);
            fprintf('variableName = %s\n',obj.variableName);
        end
    
    end
    
end
