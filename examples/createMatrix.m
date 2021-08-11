function varargout=createMatrix(varargin);
% To get help, type createMatrix('help')
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

    declareParameter(...
        'Help', {
            'This script creates a random matrix.'
                });

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Define parameters, inputs, and outputs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    declareParameter(...
        'VariableName','sz',...
        'DefaultValue',[1,1],...
        'Description', {'2x1 array with the matrix size.'});

    declareParameter(...
        'VariableName','rang',...
        'DefaultValue',[-1,1],...
        'Description', {'2x1 array with the desired interva for the entries.'});

    declareOutput(...
        'VariableName','matrix',...
        'Description', {
            'Random matrix with desired size and entries uniformly '
            'distributed within the given range.'
                       });

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Retrieve parameters and inputs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [stopNow,params]=setParameters(nargout,varargin);
    if stopNow
        return
    end

    if length(sz)~=2
        error('parameter ''sz'' must have length 2');
    end
    if length(rang)~=2
        error('parameter ''rang'' must have length 2');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Function body
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    matrix=rang(1)+(rang(2)-rang(1))*rand(sz);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Set outputs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    varargout=setOutputs(nargout,params);
end
