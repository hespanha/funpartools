classdef outputWithPedigree
% Class used to represent variables stored in files.
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

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
