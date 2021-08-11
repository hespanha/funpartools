function str=value2str(value)
% str=value2str(value)
%
%   Returns a character string with a value, regardless of whether the
%   value is numeric or a string
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

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
end