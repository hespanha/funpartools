function [stopNow,parameters]=setParameters(nargout,list_)
% [stopNow,parameters]=setParameters(varargin)
%
% Assigns a list of parameters in the caller's workspace. 'list'
% is a cell array of the form
% {'variable name 1',value 1,'variable name 2', value 2,...}
%
% All parameters assigned are also returned as fields in a structure:
%   parameters.{variable name}
%
% A parameter list with a single value {'help'} displays the
% function's documentation
%
% A parameter list with a two values {'help','latex'} displays the
% function's latex-formatted documentation and also writes it to a
% file with the same name as the function, but with the extension .tex
%
% This function is typically used within a m-script function as follows:
%
%   function [varargout]=functionName(varargin)
%   % For help on the input parameters type 'scriptName Help' 
%
%     % Function global help
%     declareParameter(...
%         'Help', { '...' })
%
%     % Declare all input parameters, see 'help declareParameter'
%     declareParameter( .... ); 
%
%     % Declare all output parameters, see 'help declareOutput'
%     declareOutput( .... );
%
%     % Retrieve parameters and inputs
%     [stopNow,params]=setParameters(nargout,varargin);
%     if stopNow
%        return;
%     end
%
%     % Start main code here
%
%     ....
% 
%     % Set outputs
% 
%     vargout=setOutputs(nargout,params);
%
%  end
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

parameters=struct();

%% Get localVariables_ from caller's workspace

if evalin('caller','exist(''localVariables_'',''var'')')
    callerVariables=evalin('caller','localVariables_');
else
    error('setParameters(%s): Use declareParameters before calling setParameter\n',callerName_);
end

%% Print help and exit with stopNow=1
if ~isempty(list_) && strcmp(lower(list_{1}),'help') && (length(list_)==1 ||...
                                      length(list_)==2 && strcmp(lower(list_{2}),'latex'))
    latex=length(list_)==2;
    
    if nargout==0
        %% Print help and exit with stopNow=1
        % print template
        if latex
            texfilename=sprintf('%s.tex',callerName_);
            fx=fopen(texfilename,'w');
            %fprintf('\\subsubsection*{%s}\n\n',callerName_);
            %fprintf(fx,'\\subsubsection*{%s}\n\n',callerName_);
            fprintf('\\begin{quote}\n  \\texttt{[...]=%s(''parameter name 1'',value,''parameter name 2'',value,...);}\n\\end{quote}\n',callerName_);
            fprintf(fx,'\\begin{quote}\n  \\texttt{[...]=%s(''parameter name 1'',value,''parameter name 2'',value,...);}\n\\end{quote}\n',callerName_);
        else
            fprintf('%% [...]=%s(''parameter name 1'',value,''parameter name 2'',value,...);\n%%\n',callerName_);
        end
        % print function description
        Help_=0;
        for i_=1:length(callerVariables)
            if strcmp(callerVariables{i_}.VariableName,'Help_')
                Help_=1;
                if latex
                    fprintf(fx,'%s\n',markup2latex(callerVariables{i_}.Description,0));
                    fprintf('%s\n',markup2latex(callerVariables{i_}.Description,0));
                else
                    fprintf('%s',markup2matlab(callerVariables{i_}.Description,0));
                end
            end
        end    
        if Help_
            if latex
                fprintf(fx,'\n');
                fprintf('\n');
            else
                fprintf('%%\n');
            end
        end
        % print input parameters
        first=1;
        for i_=1:length(callerVariables)
            if ~strcmp(callerVariables{i_}.VariableName,'Help_') && ...
                    strcmp(callerVariables{i_}.type,'parameter')
                if first
                    if latex
                        fprintf('\\paragraph{Input parameters:}\n\n\\begin{itemize}\n');
                        fprintf(fx,'\\paragraph{Input parameters:}\n\n\\begin{itemize}\n');
                    else
                        fprintf('%% Input parameters:\n%% ----------------\n');
                    end
                    first=0;
                end
                if latex
                    fprintf('\\item \\texttt{%s}',callerVariables{i_}.VariableName);
                    fprintf(fx,'\\item \\texttt{%s}',callerVariables{i_}.VariableName);
                else
                    fprintf('%%\n%% %s',callerVariables{i_}.VariableName);
                end
                if isfield(callerVariables{i_},'DefaultValue') 
                    if latex
                        fprintf(' [default \\texttt{%s}]',...
                                markup2latex(value2str(callerVariables{i_}.DefaultValue),0));
                        fprintf(fx,' [default \\texttt{%s}]',...
                                markup2latex(value2str(callerVariables{i_}.DefaultValue),0));
                    else
                        fprintf(' [default %s]',value2str(callerVariables{i_}.DefaultValue));
                    end
                end
                if isfield(callerVariables{i_},'AdmissibleValues') 
                    if latex
                        fprintf(' taking values in [');
                        fprintf(fx,' taking values in [');
                    else
                        fprintf(' taking values in [');
                    end
                    for j_=1:length(callerVariables{i_}.AdmissibleValues)
                        if latex
                            fprintf('\\texttt{%s}',...
                                    markup2latex(value2str(callerVariables{i_}.AdmissibleValues{j_}),0));
                            fprintf(fx,'\\texttt{%s}',...
                                    markup2latex(value2str(callerVariables{i_}.AdmissibleValues{j_}),0));
                        else
                            fprintf('%s',value2str(callerVariables{i_}.AdmissibleValues{j_}));
                        end
                        if j_<length(callerVariables{i_}.AdmissibleValues)
                            fprintf(',');
                            if latex
                                fprintf(fx,',');
                            end
                        else
                            fprintf(']');
                            if latex
                            fprintf(fx,']');
                            end
                        end
                    end
                end
                if latex
                    fprintf('\n\n');
                    fprintf(fx,'\n\n');
                else
                    fprintf('\n');
                end
                
                if latex
                    fprintf('%s\n',markup2latex(callerVariables{i_}.Description,1));
                    fprintf(fx,'%s\n',markup2latex(callerVariables{i_}.Description,1));
                else
                    fprintf('%s',markup2matlab(callerVariables{i_}.Description,1));
                end
                if isfield(callerVariables{i_},'PossibleInheritances') 
                    if latex
                        fprintf('\n\n    Typically obtained from:');
                        fprintf(fx,'\n\n    Typically obtained from:');
                    else
                        fprintf('%%\n%%    Typically obtained from:');
                    end
                    for l_=1:size(callerVariables{i_}.PossibleInheritances,1)
                        script=...
                            sprintf('%s(%s)',callerVariables{i_}.PossibleInheritances{l_,1:2});
                        if isempty(callerVariables{i_}.PossibleInheritances{l_,3})&&...
                                isempty(callerVariables{i_}.PossibleInheritances{l_,3})
                            if latex
                                fprintf('\n       \\texttt{%s}',script);
                                fprintf(fx,'\n       \\texttt{%s}',script);
                            else
                                fprintf('\n%%       %s',script);
                            end
                        else
                            if latex
                                fprintf('\n       \\texttt{regexprep(%s,''%s'',''%s'')}',...
                                        script,callerVariables{i_}.PossibleInheritances{l_,3:4});
                                fprintf(fx,'\n       \\texttt{regexprep(%s,''%s'',''%s'')}',...
                                        script,callerVariables{i_}.PossibleInheritances{l_,3:4});
                            else
                                fprintf('\n%%       regexprep(%s,''%s'',''%s'')',...
                                        script,callerVariables{i_}.PossibleInheritances{l_,3:4});
                            end
                        end
                        if l_<size(callerVariables{i_}.PossibleInheritances,1)
                            fprintf(' or');
                        end
                    end
                    fprintf('\n');
                end
                if latex
                    fprintf('\n');
                    fprintf(fx,'\n');
                end
            end
        end
        if ~first && latex
            fprintf('\\end{itemize}\n');
            fprintf(fx,'\\end{itemize}\n');
        end
        % print Outputs
        first=1;
        for i_=1:length(callerVariables)
            if ~strcmp(callerVariables{i_}.VariableName,'Help_') && ...
                    strcmp(callerVariables{i_}.type,'output')
                if first
                    if latex
                        fprintf('\n\\paragraph{Outputs:}\n\n\\begin{itemize}\n');
                        fprintf(fx,'\n\\paragraph{Outputs:}\n\n\\begin{itemize}\n');
                    else
                        fprintf('%%\n%% Outputs:\n%% -------\n');
                    end
                    first=0;
                end
                if latex
                    fprintf('\\item \\texttt{%s}',callerVariables{i_}.VariableName);
                    fprintf(fx,'\\item \\texttt{%s}',callerVariables{i_}.VariableName);
                else
                    fprintf('%%\n%% %s',callerVariables{i_}.VariableName);
                end
                if latex
                    fprintf('\n\n');
                    fprintf(fx,'\n\n');
                else
                    fprintf('\n');
                end

                if latex
                    fprintf('%s\n',markup2latex(callerVariables{i_}.Description,1));
                    fprintf(fx,'%s\n',markup2latex(callerVariables{i_}.Description,1));
                else
                    fprintf('%s',markup2matlab(callerVariables{i_}.Description,1));
                end
            end
        end
        if ~first && latex
            fprintf('\\end{itemize}\n');
            fprintf(fx,'\\end{itemize}\n');
        end
        if latex
            fprintf(fx,'\n\n');
            fclose(fx);
        else
            fprintf('%%\n\n');
        end
        %error('setParameters(%s): Called with ''help'' -- no error\n',callerName_);
        parameters=NaN;
        stopNow=true;
        return;
    else
        parameters=callerVariables;
        assignin('caller','varargout',{parameters});
        stopNow=true;
        return
    end
end
stopNow=0;

if mod(length(list_),2)==1
    error('setParameters(%s): Length of ''list'' must be even (%d instead)\n',callerName_,length(list_));
end

if verboseLevel>=2
    fprintf('setParameters(%s): Setting  parameters for %s(%d parameters);\n',callerName_,callerName_,length(list_)/2);
end

%% Assign values from parameter 'list'
for j_=1:2:length(list_)
    assigned=0;
    for i_=1:length(callerVariables)
        if  strcmp(callerVariables{i_}.type,'output')
            continue;
        end
        if strcmp(list_{j_},callerVariables{i_}.VariableName)
            if verboseLevel>=2
                fprintf('setParameters(%s): Explicit assignment ''%s''\n',callerName_,list_{j_})
            end
            assignin('caller',list_{j_},list_{j_+1});
            parameters=setfield(parameters,list_{j_},list_{j_+1});
            assigned=1;
            break
        end
    end    
    if ~assigned
        error('setParameters(%s): Undeclared parameter ''%s''\n',callerName_,list_{j_});
    end
end

%% Assign values from parametersStructure
% get value for the variable 'parametersStructure'
% (either from caller's workspace or from default value)
if evalin('caller','exist(''parametersStructure'',''var'')')
    parametersStructure=evalin('caller','parametersStructure');
else
    if verboseLevel>=2
        fprintf('setParameters(%s): Undefined ''parametersStructure'', looking for default value\n',...
                callerName_);
    end
    % look for default value
    for i_=length(callerVariables):-1:1
        if strcmp(callerVariables{i_}.VariableName,'parametersStructure') && ...
                isfield(callerVariables{i_},'DefaultValue')
            if verboseLevel>=1
                fprintf('setParameters(%s): Default  assignment %s=%s\n',...
                        callerName_,callerVariables{i_}.VariableName,...
                        value2str(callerVariables{i_}.DefaultValue));
            end
            assignin('caller',callerVariables{i_}.VariableName,...
                              callerVariables{i_}.DefaultValue); 
            parameters=setfield(parameters,callerVariables{i_}.VariableName,...
                                callerVariables{i_}.DefaultValue); 
            parametersStructure=callerVariables{i_}.DefaultValue;
            break;
        end
    end
end

% get values in 'parametersStructure'
if exist('parametersStructure','var')
    for i_=length(callerVariables):-1:1
        if  strcmp(callerVariables{i_}.type,'output')
            continue;
        end
        cmd=sprintf('~exist(''%s'',''var'')',callerVariables{i_}.VariableName);
        if evalin('caller',cmd)   % does not exist in caller's workspace?
            if isfield(parametersStructure,callerVariables{i_}.VariableName)
                value=getfield(parametersStructure,callerVariables{i_}.VariableName);
                parameters=setfield(parameters,callerVariables{i_}.VariableName,value);
                if verboseLevel>=1
                    fprintf('setParameters(%s): parametersStructure assignment %s=%s\n',...
                            callerName_,callerVariables{i_}.VariableName,...
                            value2str(value));
                end
                assignin('caller',callerVariables{i_}.VariableName,value);
            else
                if verboseLevel>=2
                    fprintf('setParameters(%s): Unassigned variable ''%s'' not in parametersStructure\n',...
                            callerName_,callerVariables{i_}.VariableName);
                end
            end
        end
    end
else
    if verboseLevel>=2
        fprintf('setParameters(%s): Undefined variable ''parametersStructure''\n',...
                callerName_);
    end
end

%% Assign default values
for i_=length(callerVariables):-1:1
    if isfield(callerVariables{i_},'DefaultValue') && ...
            ~strcmp(class(callerVariables{i_}.DefaultValue),'outputWithPedigree')
        cmd=sprintf('~exist(''%s'',''var'')',callerVariables{i_}.VariableName);
        if evalin('caller',cmd)  % does not exist in caller's workspace?
            if verboseLevel>=1
                fprintf('setParameters(%s): Default  assignment %s=%s\n',...
                        callerName_,callerVariables{i_}.VariableName,...
                        value2str(callerVariables{i_}.DefaultValue));
            end
            assignin('caller',callerVariables{i_}.VariableName,...
                              callerVariables{i_}.DefaultValue);
            parameters=setfield(parameters,callerVariables{i_}.VariableName,...
                              callerVariables{i_}.DefaultValue);
        end
    end
end 

%% look for DefaultValues from pedigree
if evalin('caller','exist(''pedigreeClass'',''var'')')
    pedigreeClass=evalin('caller','pedigreeClass');
else
    pedigreeClass='';
end

if ~isempty(pedigreeClass)
    [className,pedigreeName,pedigreeNameMat,...
     pedigreeSuffix,pedigreeSuffixMat,...
     dateFormat,basenameUniqueRegexp,timeStampFormat,pedigreeWildcard,...
     reusingPedigree...
    ]=createPedigree(pedigreeClass,parameters,callerName_);
    assignin('caller','className_',className);
    assignin('caller','pedigreeName_',pedigreeName);
    for i_=length(callerVariables):-1:1
        if isfield(callerVariables{i_},'DefaultValue') && ...
                strcmp(class(callerVariables{i_}.DefaultValue),'outputWithPedigree')
            filename=sprintf('%s+%s',className,callerVariables{i_}.VariableName);
            assignin('caller',callerVariables{i_}.VariableName,filename);
        end
    end
else
    reusingPedigree=false;
    assignin('caller','className_','');
    assignin('caller','pedigreeName_','');
end

%% Check for admissible values
for i_=1:length(callerVariables)
    cmd=sprintf('exist(''%s'',''var'')',callerVariables{i_}.VariableName);
    if evalin('caller',cmd)  % exists in caller space?
        if isfield(callerVariables{i_},'AdmissibleValues')
            value=evalin('caller',callerVariables{i_}.VariableName);
            if checkAdmissible(value,callerVariables{i_}.AdmissibleValues)
                err=sprintf(['setParameters(%s): Unadmissible value %s=%s, not in\n   ['],...
                            callerName_,callerVariables{i_}.VariableName,value2str(value));
                for j_=1:length(callerVariables{i_}.AdmissibleValues)
                    err=[err,sprintf('%s',value2str(callerVariables{i_}.AdmissibleValues{j_}))];
                    if j_<length(callerVariables{i_}.AdmissibleValues)
                        err(end+1)=',';
                    else
                        err(end+1)=']';
                    end
                end
                error(err);
            end
        end
    else
        if ~strcmp(callerVariables{i_}.VariableName,'Help_') && ...
                ~strcmp(callerVariables{i_}.type,'output') 
            error('setParameters(%s): Variable ''%s'' has not been assigned\n',...
                  callerName_,callerVariables{i_}.VariableName);
        end
    end 
end

%% Check if script should be executed
if evalin('caller','exist(''executeScript'',''var'')')
    executeScript=evalin('caller','executeScript');
    if strcmp(executeScript,'yes') || (strcmp(executeScript,'asneeded') && ~reusingPedigree)
        stopNow=false;
    else
        if isempty(pedigreeClass)
            error('%s: executeScript=''false'' only allowed when ''pedigreeClass'' is defined\n',callerName_);
        end
        stopNow=true;
        fprintf('%s: pedigree found, no need to execute (executeScript=%s,reusingPedigree=%d)\n',callerName_,executeScript,reusingPedigree);
        if nargout>0
            %% Assign output values
            vargout={};
            k=1;
            for i_=1:length(callerVariables)
                if k>nargout
                    break;
                end
                if strcmp(callerVariables{i_}.type,'output')
                    filename=sprintf('%s+%s.mat',className,callerVariables{i_}.VariableName);
                    vargout{k}=outputWithPedigree(pedigreeName,filename,callerVariables{i_}.VariableName,true);
                    if isempty(vargout{k}.fileName)
                        stopNow=false;
                        fprintf('%s: variable ''%s'' missing, must execute afterall\n',...
                                callerName_,callerVariables{i_}.VariableName);
                    end
                    k=k+1;
                end
            end
            if nargout>length(vargout)
                error('setParameters: %d outputs declared, but function was called with %d outputs\n',length(vargout),nargout);
            end
            assignin('caller','varargout',vargout);
        end
    end
end

%% Get variables from  files
if ~stopNow
    for i_=1:length(callerVariables)
        if  strcmp(callerVariables{i_}.type,'output')
            continue;
        end
        cmd=sprintf('exist(''%s'',''var'') && (strcmp(class(%s),''outputWithPedigree'') || iscell(%s) && all(cellfun(@(x)strcmp(class(x),''outputWithPedigree''),%s) ))',...
                    callerVariables{i_}.VariableName,callerVariables{i_}.VariableName,...
                    callerVariables{i_}.VariableName,callerVariables{i_}.VariableName);
        rc=evalin('caller',cmd);
        if rc % exists in caller space?
            if verboseLevel>=2
                fprintf('setParameters(%s): outputWithPedigree found in ''%s''\n',...
                        callerName_,callerVariables{i_}.VariableName);
            end
            obj=evalin('caller',callerVariables{i_}.VariableName);
            if iscell(obj)
                assignin('caller',callerVariables{i_}.VariableName,...
                         cellfun(@(x)getValue(x,callerName_),obj,'UniformOutput',false));
            else
                assignin('caller',callerVariables{i_}.VariableName,getValue(obj,callerName_));
            end
        end
    end    
end

end

function err=checkAdmissible(value,admissible)

err=1;
for i=1:length(admissible)
    if strcmp(value2str(value),value2str(admissible{i}))
        err=0;
        break
    end
end

end

function newstr=markup2latex(oldstr,indent)

    if ~iscell(oldstr)
        oldstr={oldstr};
    end
    
    newstr='';
    depth=1;
    oldindent{depth}=-1;
    for i=1:length(oldstr)
        str=oldstr{i};
        %% Quote special latex characters
        str=regexprep(str,'_','\\_');
        str=regexprep(str,'{','\\{');
        str=regexprep(str,'}','\\}');
        str=regexprep(str,'#','\\#');
        str=regexprep(str,'\^','\textasciicircum{}');
        
        %% MATLAB Markup

        % bold
        str=regexprep(str,'\*([^*]+)\*','\\textbf{$1}');
        % monospace
        str=regexprep(str,'\|([^|]+)\|','\\texttt{$1}');
        
        % lists
        S=regexp(str,'^(\s*)\*([^*]+)$','tokens');
        if ~isempty(S)
            if length(S{1}{1})>oldindent{depth}
                newstr=[newstr,repmat(' ',1,3*indent),sprintf('\n\\begin{itemize}\n')];
                indent=indent+1;
                depth=depth+1;
                oldindent{depth}=length(S{1}{1});
            else
                while length(S{1}{1})<oldindent{depth}
                    indent=indent-1;
                    depth=depth-1;
                    newstr=[newstr,repmat(' ',1,3*indent),sprintf('\n\\end{itemize}\n')];
                end
            end
            str=regexprep(str,'^\s*\*\s*([^*]+)$','\\item $1');
        else
            S=regexp(str,'^(\s*)[^\s]','tokens');
            if ~isempty(S)
                while length(S{1}{1})<oldindent{depth}
                    indent=indent-1;
                    depth=depth-1;
                    newstr=[newstr,repmat(' ',1,3*indent),sprintf('\n\\end{itemize}\n')];
                end
            end
        end
        % monospace formated text
        S=regexp(str,'^%\s\s(\s*[^*]+.*)$','tokens');
        if ~isempty(S)
            str=sprintf('\n\\texttt{  %s}\\\n',regexprep(S{1}{1},' ','~'));
        end

        str=regexprep(str,'%','\\%');
        
        if i>1
            newstr=[newstr,repmat(' ',1,3*indent),sprintf('\n%s',str)];
        else
            newstr=[newstr,repmat(' ',1,3*indent),sprintf('%s',str)];
        end
        %fprintf('after="%s"\n',str)
    end
    while depth>1
        indent=indent-3;
        depth=depth-1;
        newstr=[newstr,repmat(' ',1,3*indent),sprintf('\\end{itemize}\n')];
    end
end

function newstr=markup2matlab(oldstr,indent)
    if ~iscell(oldstr)
        oldstr={oldstr};
    end
    
    newstr='';
    bullet=false;
    for i=1:length(oldstr)
        str=oldstr{i};
        str=regexprep(str,'\|([^*]+)\|','$1');
        str=regexprep(str,'^%','');
        newstr=[newstr,'% ',repmat(' ',1,3*indent),sprintf('%s\n',str)];
    end
end