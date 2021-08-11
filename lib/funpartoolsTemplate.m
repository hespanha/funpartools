function varargout=@BASEFILENAMELESSEXTENSION@(varargin);
% To get help, type @BASEFILENAMELESSEXTENSION@('help')
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

    declareParameter(...
        'Help', {
            'This script does lots of stuff.'
                });

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Define inputs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    declareParameter(...
        'VariableName','inputVar1',...
        'AdmissibleValues',{},...
        'DefaultValue',[],...
        'Description', {
            'This input variable is XXXX.'
                       });

    declareParameter(...
        'VariableName','inputVar2',...
        'AdmissibleValues',{},...
        'DefaultValue',[],...
        'Description', {
            'This input variable is XXXX.'
                       });

    declareOutput(...
        'VariableName','outputVar1',...
        'Description', {
            'This output variable is XXXX.'
                       });

    declareOutput(...
        'VariableName','outputVar2',...
        'Description', {
            'This output variable is XXXX.'
                       });

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Retrieve parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [stopNow,parameters__]=setParameters(nargout,varargin);
    if stopNow
        return
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Function body
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('@BASEFILENAMELESSEXTENSION@: starting...');
    t0=clock;

    % Code goes here

    fprintf('done @BASEFILENAMELESSEXTENSION@ (%.3f sec)\n',etime(clock,t0));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Set outputs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    varargout=setOutputs(nargout,parameters__);
end