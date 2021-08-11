function callerVariables=standardParameters()
% callerVariables=standardParameters()
%
% Returns the default parameters. Typically not called directly.
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

    %% Get localVariables_ from caller's workspace

    callerVariables{1,1}.type='parameter';
    callerVariables{1,1}.VariableName='verboseLevel';
    callerVariables{1,1}.DefaultValue=0;
    callerVariables{1,1}.Description={
        'Level of verbose for debug outputs (|0| - for no debug output)'};

    callerVariables{2,1}.type='parameter';
    callerVariables{2,1}.VariableName='parametersStructure';
    callerVariables{2,1}.DefaultValue='';
    callerVariables{2,1}.Description={
        'Structure whose fields are used to initialize parameters'
        'not present in the list of parameters passed to the function.'
        'This structure should contains fields with names that match'
        'the name of the parameters to be initialized.'
                   };

    callerVariables{3,1}.type='parameter';
    callerVariables{3,1}.VariableName='pedigreeClass';
    callerVariables{3,1}.DefaultValue='';
    callerVariables{3,1}.Description={
        'When nonempty, the function outputs are saved to a set of files.'
        'All files in the set will be characterized by a ''pedigree'','
        'which decribes all the input parameters that were used in the script.'
        'This variable contains the name of the file class and may include a path.'
        'See also createPedigree'
                   };

    callerVariables{4,1}.type='parameter';
    callerVariables{4,1}.VariableName='executeScript';
    callerVariables{4,1}.AdmissibleValues={'yes','no','asneeded'};
    callerVariables{4,1}.DefaultValue='yes';
    callerVariables{4,1}.Description={
        'Determines whether or not the body of the function should be executed:'
        '* |yes| - the function body should always be executed.'
        '* |no|  - the function body should never be executed and therefore the'
        '          function returns after processing all the input parameters.'
        '* |asneeded| - if a pedigree file exists that match all the input parameters'
        '               (as well as all the parameters of all ''upstream'' functions)'
        '               the function body is not executed, otherwise it is execute.'
                   };
end