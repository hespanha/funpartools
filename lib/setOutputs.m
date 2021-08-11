function vargout=setOutputs(nargout,params)
% output=setOutputs()
%
% Returns caller's varargout
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

    verboseLevel=0;  % 0 none, 1 less, 2 more

    callerName_=dbstack(1);
    callerName_=callerName_(1).name;

    %% Get localVariables_ from caller's workspace

    if evalin('caller','exist(''pedigreeClass'',''var'')')
        pedigreeClass=evalin('caller','pedigreeClass');
        pedigreeName=evalin('caller','pedigreeName_');
        pedigreeNameMat=evalin('caller','pedigreeNameMat_');
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
                vargout{k}=outputWithPedigree(pedigreeName,filename,callerVariables{i}.VariableName,false);
                saveValue(vargout{k},eval(callerVariables{i}.VariableName),callerName_);
            end
            k=k+1;
        end
    end

    if nargout>length(vargout)
        error('setOutputs: %d outputs declared, but function was called with %d outputs\n',length(vargout),nargout);
    end

    if ~isempty(pedigreeClass)
        finalizePedigree(pedigreeName,pedigreeNameMat);
    end
end
