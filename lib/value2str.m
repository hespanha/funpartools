function str=value2str(value)
% str=value2str(value)
%
%   Returns a character string with a value, regardless of whether the
%   value is numeric or a string
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

    if isnumeric(value)
        if length(value)==0
            str='[]';
        elseif length(value)==1
            str=sprintf('%g',value);
        else
            str='[';
            for i=1:length(value)-1
                str=[str,sprintf('%g',value(i)),','];
            end
            str=[str,sprintf('%g',value(end)),']'];
        end
    elseif islogical(value)
        if length(value)==0
            str='[]';
        elseif length(value)==1
            if value
                str='true';
            else
                str='false';
            end
        else
            str='[';
            for i=1:length(value)-1
                if value(i)
                    str=[str,'true,'];
                else
                    str=[str,'false,'];
                end
            end
            if value(end)
                str=[str,'true]'];
            else
                str=[str,'false]'];
            end
        end
    elseif ischar(value)
        str=sprintf('''%s''',value);
    elseif iscell(value)
        if length(value)>0
            str='{';
            for i=1:length(value)-1
                str=[str,value2str(value{i}),','];
            end
            str=[str,value2str(value{end}),'}'];
        else
            str='{}';
        end
    elseif strcmp(class(value),'outputWithPedigree')
        str=sprintf('<to be determined from the pedigree %s>',value.pedigreeName);
    elseif isstruct(value)
        names=fieldnames(value);
        str='(';
        for k=1:length(value)
            for i=1:length(names)
                str=sprintf('%s%s=%s,',str,names{i},value2str(getfield(value(k),names{i})));
            end
            str(end)=';';
        end
        str(end)=')';
    else
        str=['<',class(value),'>'];
        %disp(value)
        %error('value2str: does not know to convert ''%s'' to string\n',class(value))
    end
