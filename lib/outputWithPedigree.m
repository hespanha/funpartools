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
        saveFormat='serial';
                           % 'plainsave' seems to be the same as 'v7
                           % 'v7'   much faster than -v7.3
                           % 'v7.3' slower, but seems needed for large files
                           % 'serial' very fast but seems to cause a crash for large data
    end
    
    methods
        function obj=outputWithPedigree(pedigreeName,fileName,variableName,checkFiles)
            obj.pedigreeName=pedigreeName;
            obj.fileName=fileName;
            obj.variableName=variableName;
            if checkFiles
                switch obj.saveFormat
                  case 'plainsave' % probably same as v7
                    fileExists=exist(obj.fileName,'file');
                  case 'v7'
                    fileExists=exist(obj.fileName,'file');
                  case 'v7.3'
                    fileExists=exist(obj.fileName,'file');
                  case 'serial'
                    obj.fileName=regexprep(obj.fileName,'\.mat$',''); 
                    fileExists=exist([obj.fileName,'.serialmatlab'],'file');
                  otherwise
                    error('%s: unkown save format ''%s''\n',caller,obj.saveFormat);
                end
                if ~fileExists
                    obj.fileName='';
                end
            end
        end
        
        function saveValue(obj,value,caller)
            if nargin>=3
                fprintf('%s: saving %s -> %s... ',caller,obj.variableName,obj.fileName);
                t0=clock;
            end
            switch obj.saveFormat
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
                error('%s: unkown save format ''%s''\n',caller,obj.saveFormat);
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
            switch obj.saveFormat
              case {'plainsave','v7','v7.3'}
                load(obj.fileName,obj.variableName);
                value=eval(obj.variableName);
              case 'serial'
                value=serialload(obj.fileName);
              otherwise
                error('%s: unkown save format ''%s''\n',caller,obj.saveFormat);
            end
            if nargin>=2
                fprintf('done (%.3f sec)\n',etime(clock,t0));
            end
        end
        
        function varargout=feval(f,varargin)

            f1=getValue(f);
            varargout=cell(nargout,1);
            if nargin>1
                [varargout{:}]=feval(f1,varargin);
            else
                [varargout{:}]=feval(f1);
            end
        end
            
        function varargout=help(f)

            f1=getValue(f);
            varargout=cell(nargout,1);
            [varargout{:}]=help(f1);
        end
            
        % function disp(obj)
        %     fprintf('pedigreeName = %s\n',obj.pedigreeName);
        %     fprintf('fileName     = %s\n',obj.fileName);
        %     fprintf('variableName = %s\n',obj.variableName);
        %     fprintf('saveFormat   = %s\n',obj.saveFormat);
        % end
    
    end
    
end
