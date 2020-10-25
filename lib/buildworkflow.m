function buildworkflow(varargin)
% For help on the input parameters type 'buildworkflow help'
%
% Uses a GUI to creates a script that sets parameters and calls a
% sequence of functions created with funpartools. The features
% provided include:
%
% 1) Automatic population of function parameters with default values
% 2) Automatic creation of filenames with pedigrees
% 3) Link of parameters across multiple files ('inheritance')
%
% To do
% b) allow using paths as inputs to run the script multiple times, one
%    for each file that matches the path
% d) automatic population of function parameters based on existing
%    pedigrees
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

% Function global help
    declareParameter(...
        'Help', {
            'This function uses a GUI to creates a script that sets'
            'parameters and calls a sequence of functions created with'
            'funpartools. The features provided include:'
            '1) Automatic population of function parameters with default values'
            '2) Automatic creation of filenames with pedigrees'
            '3) Link of parameters across multiple files (''inheritance'')'
                })

    declareParameter(...
        'VariableName','fig',...
        'DefaultValue',gcf,...
        'Description', {
            'Handle of figure where the workflow will be created.'
            'Defaults to the current figure (gcf).'
                       });

    declareParameter(...
        'VariableName','outputFolder',...
        'DefaultValue','../output-files',...
        'Description', {
            'Folder where all the pedigrees will be created.'
                       });

    declareParameter(...
        'VariableName','workflowName',...
        'DefaultValue','execute.m',...
        'Description', {
            'Filename for the script that executes the workflow.'
                       });


    declareParameter(...
        'VariableName','scriptsPaths',...
        'DefaultValue',{'.'},...
        'Description', {
            'Cell array with path where one should look for the scripts'
            'on which workflow should be based.'
                       });

    declareParameter(...
        'VariableName','predefidedWorkflows',...
        'DefaultValue',{},...
        'Description', {
            'Cell array of cell strings, where each element of the array contains'
            'a sequence of script names that can form a workflow.'
            'These sequences of scripts will be used to attempt to complete'
            'workflows partially created by the user. The first workflows in the array'
            'have priority over the latter ones.'
                       });

    % Assign parameters
    [stopNow,parameters]=setParameters(nargout,varargin);
    if stopNow
        if nargout>0
            out1=parameters;
        end
        return;
    end

    workflow={};

    %% function parameters
    workflow.scriptsPath=scriptsPaths;
    workflow.predefidedWorkflows=predefidedWorkflows;
    workflow.outputFolder=outputFolder;
    if ~isdir(outputFolder)
        system(sprintf('mkdir %s',outputFolder));
    end
    workflow.filename=workflowName;
    workflow.verboseLevel=verboseLevel;

    %% find functions
    workflow.availableFunctions={};
    for i=1:length(workflow.scriptsPath)
        files=what(workflow.scriptsPath{i});
        for j=1:length(files.m)
            [~,name]=fileparts(files.m{j});
            txt=fileread(fullfile(files.path,files.m{j}));
            if ~isempty(strfind(txt,'declareParameter('))
                workflow.availableFunctions{end+1}=name;
            end
        end
    end

    %% Draw parameters
    workflow.topMargin=.5;
    workflow.lineHeight=1.8;
    workflow.boxHeight=1.6;
    workflow.guiWidth=150;
    workflow.guiHeight=500;

    %% Functions
    workflow.assignTypes={'value','pedigree','inherit','inherit&rep'};
    workflow.functions={};

    set(fig,'UserData',workflow);
    set(fig,'ResizeFcn',@(a,b)redraw());

    if 1
        load();
    end

    redraw();

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Callback function for redraw
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function redraw()
    workflow=get(gcf,'UserData');
    if isempty(workflow)
        return;
    end
    if workflow.verboseLevel>0
        fprintf('redraw()\n');
    end

    %% Clear window, create panels, and scroll
    clf
    set(gcf,'units','characters');
    figPosition=get(gcf,'position');
    panel1=uipanel('Parent',gcf,...
                   'BackgroundColor','black',...
                   'Units','characters','position',[0,0,figPosition(3:4)]);
    panel=uipanel('Parent',gcf,...
                  'BackgroundColor','white',...
...%                  'Units','characters','position',[1,-.5+figPosition(4)-workflow.guiHeight,workflow.guiWidth,workflow.guiHeight]);
                  'Units','characters','position',[1,-.5+figPosition(4)-workflow.guiHeight,figPosition(3)-4,workflow.guiHeight]);
    scrollbar=uicontrol('Style','Slider','Parent',gcf,...
                        'Units','normalized','Position',[0.95 0 0.05 1],...
                        'min',figPosition(4)-1,'max',workflow.guiHeight,...
                        'sliderstep',[1/(workflow.guiHeight-figPosition(4)),...
                                      figPosition(4)/2/(workflow.guiHeight-figPosition(4))],...
                        'value',workflow.guiHeight,...
                        'Callback',{@slider_callback1,panel});
    set(panel,'units','characters');
    home(workflow,panel);
    %% Print existing workflow
    for i=1:length(workflow.functions)
        %% function name & controls (execute, insert above, delete)
        newline(workflow,panel);
        %% execute function?
        uicontrol('parent',panel,...
                  'Style','checkbox','Value',workflow.functions{i}.execute,...
                  'Callback',{@checkFunctionCB,i},...
                  'Units','characters','Position',right(workflow,panel,3));
        %% function name (with help)
        uicontrol('parent',panel,...
                  'Style','pushbutton','string',sprintf('%d:%s',i,workflow.functions{i}.name),...
                  'Callback',{@helpFunctionCB,i},...
                  'horizontalalignment','left',...
                  'Units','characters','Position',right(workflow,panel,20));
        %% insert above?
        string=sprintf('add above: %s|',workflow.availableFunctions{:});
        uicontrol('parent',panel,...
                  'Style','popup','String',string(1:end-1),...
                  'Callback',{@insertFunctionCB,i},...
                  'Units','characters','Position',right(workflow,panel,20));
        %% delete
        uicontrol('parent',panel,...
                  'Style','pushbutton','string','delete',...
                  'Callback',{@deleteFunctionCB,i},...
                  'horizontalalignment','left',...
                  'Units','characters','Position',right(workflow,panel,7));
        if workflow.functions{i}.execute
            for j=1:length(workflow.functions{i}.parameters)
                if any(strcmp(workflow.functions{i}.parameters{j}.VariableName,{'Help_','parametersStructure','parametersMfile','verboseLevel'}))
                    continue;
                end
                %% parameter name
                newline(workflow,panel);
                right(workflow,panel,5);
                uicontrol('parent',panel,...
                          'Style','pushbutton','string',workflow.functions{i}.parameters{j}.VariableName,...
                          'Callback',{@helpVariableCB,i,j},...
                          'horizontalalignment','left',...
                          'Units','characters','Position',right(workflow,panel,20));
                type=find(strcmp(workflow.functions{i}.parameters{j}.assign.type,...
                                 workflow.assignTypes));
                string=sprintf('%s|',workflow.assignTypes{:});
                %% assign type
                uicontrol('parent',panel,...
                          'Style','popup','string',string(1:end-1),...
                          'Callback',{@assignTypeCB,i,j},...
                          'horizontalalignment','left',...
                          'value',type,...
                          'Units','characters','Position',right(workflow,panel,17));
                switch (workflow.functions{i}.parameters{j}.assign.type)
                  case {'value','pedigree'}
                    if isnan(workflow.functions{i}.parameters{j}.assign.value)
                        color='red';
                    else
                        color='black';
                    end
                    string=workflow.functions{i}.parameters{j}.assign.value;
                    uicontrol('parent',panel,...
                              'Style','edit','string',string,...
                              'ForegroundColor',color,...
                              'Callback',{@editValueCB,i,j},...
                              'horizontalalignment','left',...
                              'fontname','courier new',...
                              'max',3,'min',1,...
                              'Units','characters','Position',right(workflow,panel,max(76,length(string))));
                    if isfield(workflow.functions{i}.parameters{j}.assign,'pedigree')
                        string=workflow.functions{i}.parameters{j}.assign.pedigree;
                        if workflow.functions{i}.parameters{j}.assign.pedigreehasdata
                            string=[string,' (has data)'];
                        else
                            string=[string,' (no data)'];
                        end
                        uicontrol('parent',panel,...
                                  'Style','text','string',string,...
                                  'BackgroundColor','white',...
                                  'horizontalalignment','left',...
                                  'Units','characters','Position',right(workflow,panel,length(string)));
                    end
                  case {'inherit'}
                    [array,string]=functions2pipestring(workflow);
                    value=workflow.functions{i}.parameters{j}.assign.inheritFunction;
                    if isnan(value)
                        string=[string,'|NaN'];
                        value=length(array)+1;
                    end
                    uicontrol('parent',panel,...
                              'Style','popup','string',string,...
                              'value',value,...
                              'Callback',{@editInheritFunctionCB,i,j},...
                              'horizontalalignment','left',...
                              'Units','characters','Position',right(workflow,panel,20));
                    [array,string,value]=variables2pipesstring(workflow,...
                                                               workflow.functions{i}.parameters{j}.assign.inheritFunction,...
                                                               workflow.functions{i}.parameters{j}.assign.inheritVariable);
                    uicontrol('parent',panel,...
                              'Style','popup','string',string,'value',value,...
                              'Callback',{@editInheritVariableCB,i,j,array},...
                              'horizontalalignment','left',...
                              'Units','characters','Position',right(workflow,panel,20));
                  case {'inherit&rep'}
                    [array,string]=functions2pipestring(workflow);
                    value=workflow.functions{i}.parameters{j}.assign.inheritFunction;
                    uicontrol('parent',panel,...
                              'Style','popup','string',string,...
                              'value',value,...
                              'Callback',{@editInheritFunctionCB,i,j},...
                              'horizontalalignment','left',...
                              'Units','characters','Position',right(workflow,panel,20));
                    [array,string,value]=variables2pipesstring(workflow,...
                                                               workflow.functions{i}.parameters{j}.assign.inheritFunction,...
                                                               workflow.functions{i}.parameters{j}.assign.inheritVariable);
                    uicontrol('parent',panel,...
                              'Style','popup','string',string,'value',value,...
                              'Callback',{@editInheritVariableCB,i,j,array},...
                              'horizontalalignment','left',...
                              'Units','characters','Position',right(workflow,panel,20));
                    uicontrol('parent',panel,...
                              'Style','edit','string',workflow.functions{i}.parameters{j}.assign.regexp,...
                              'Callback',{@editRegexpCB,i,j},...
                              'horizontalalignment','left',...
                              'Units','characters','Position',right(workflow,panel,10));
                    uicontrol('parent',panel,...
                              'Style','edit','string',workflow.functions{i}.parameters{j}.assign.rep,...
                              'Callback',{@editRepCB,i,j},...
                              'horizontalalignment','left',...
                              'Units','characters','Position',right(workflow,panel,20));
                  otherwise
                    error('draw of assign.type=%s not implemented\n',workflow.functions{i}.parameters{j}.assign.type);
                end
            end
        end
    end

    %% Print footer

    newline(workflow,panel);
    string=sprintf('add: %s|',workflow.availableFunctions{:});
    uicontrol('parent',panel,...
              'Style','popup','String',string(1:end-1),...
              'Callback',{@insertFunctionCB,length(workflow.functions)+1},...
              'Units','characters','Position',right(workflow,panel,20));
    uicontrol('parent',panel,...
              'Style','pushbutton','String','autocomplete',...
              'Callback',@autocompleteCB,...
              'Units','characters','Position',right(workflow,panel,12));
    string=sprintf('save [%s]',workflow.filename);
    uicontrol('parent',panel,...
              'Style','pushbutton','String',string,...
              'Callback',{@saveCB,1},...
              'Units','characters','Position',right(workflow,panel,length(string)));
    string=sprintf('get pedigrees',workflow.filename);
    uicontrol('parent',panel,...
              'Style','pushbutton','String',string,...
              'Callback',@pedigreesCB,...
              'Units','characters','Position',right(workflow,panel,length(string)));

    set(gcf,'UserData',workflow);

end

function slider_callback1(src,eventdata,arg1)
    workflow=get(gcf,'UserData');
    if isempty(workflow)
        return;
    end
    figPosition=get(gcf,'position');
    val = get(src,'Value');
    %set(arg1,'Position',[1,-.5+figPosition(4)-val,workflow.guiWidth,workflow.guiHeight]);
    set(arg1,'Position',[1,-.5+figPosition(4)-val,figPosition(3)-4,workflow.guiHeight]);
end

function home(workflow,panel);
    figPosition=get(panel,'position');
    xy=[1,figPosition(4)-workflow.topMargin];
    set(panel,'UserData',xy);
end

function xy=newline(workflow,panel);
    xy=get(panel,'UserData');
    xy=[1,xy(2)-workflow.lineHeight];
    set(panel,'UserData',xy);
end

function position=right(workflow,panel,nchars);
    xy=get(panel,'UserData');
    if nchars>76
        nlines=ceil(nchars/60);
        position=[xy(1),xy(2)-(nlines-1),76,(nlines-1)+workflow.boxHeight];
        xy(1)=xy(1)+76+2;
        xy(2)=xy(2)-(nlines-1);
    else
        position=[xy(1),xy(2),nchars,workflow.boxHeight];
        xy(1)=xy(1)+nchars+2;
    end
    set(panel,'UserData',xy);
end

function [array,string]=functions2pipestring(workflow)

    array={};
    string=[];
    for i=1:length(workflow.functions)
        if isfield(workflow.functions{i},'name')
            array{end+1}=workflow.functions{i}.name;
            string=sprintf('%s%d:%s|',string,i,array{i});
        end
    end
    string(end)=[];
end

function [array,string,value]=variables2pipesstring(workflow,i,variable);

    if isnan(i)
        array={'NaN'};
        string='NaN';
        value=1;
    else
        array=cellfun(@(x)getfield(x,'VariableName'),workflow.functions{i}.parameters,'UniformOutput',0);
        string=sprintf('%s|',array{:});
        string(end)=[];
        value=find(strcmp(variable,array));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Callback functions for editing values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function checkFunctionCB(hObject,eventdata,i)
    workflow=get(gcf,'UserData');
    if isempty(workflow)
        return;
    end
    if workflow.verboseLevel>0
        fprintf('checkFunctionCB(%g,%s,%d)\n',hObject,eventdata,i);
    end

    value=get(hObject,'value');
    if value
        % set all functions that depende in this functions
        toSet=[i];
        for ii=1:length(workflow.functions)
            for jj=1:length(workflow.functions{ii}.parameters)
                if any(strcmp(workflow.functions{ii}.parameters{jj}.assign.type,{'inherit','inherit&rep'}))
                    if ismember(workflow.functions{ii}.parameters{jj}.assign.inheritFunction,toSet)
                        toSet=union(toSet,ii);
                        continue;
                    end
                end
            end
        end
        for k=1:length(toSet)
            workflow.functions{toSet(k)}.execute=1;
        end
    else
        % unset all functions that this function depends on
        toUnset=i;
        while ~isempty(toUnset)
            i=toUnset(1);
            toUnset=setdiff(toUnset,i);
            workflow.functions{i}.execute=0;
            for jj=1:length(workflow.functions{i}.parameters)
                if any(strcmp(workflow.functions{i}.parameters{jj}.assign.type,{'inherit','inherit&rep'}))
                    toUnset=union(toUnset,workflow.functions{i}.parameters{jj}.assign.inheritFunction);
                end
            end
        end
        for k=1:length(toUnset)
            workflow.functions{toUnset(k)}.execute=0;
        end
    end
    set(gcf,'UserData',workflow);
    redraw()
end

function helpFunctionCB(hObject,eventdata,i)
    workflow=get(gcf,'UserData');
    if isempty(workflow)
        return;
    end
    if workflow.verboseLevel>0
        fprintf('helpFunctionCB(%g,%s,%d)\n',hObject,eventdata,i);
    end

    value=get(hObject,'value');
    variables=cellfun(@(x)getfield(x,'VariableName'),workflow.functions{i}.parameters,'UniformOutput',0);
    j=find(strcmp(variables,'Help_'));
    disp(workflow.functions{i}.name)
    disp(workflow.functions{i}.parameters{j}.Description)
    helpdlg(workflow.functions{i}.parameters{j}.Description,workflow.functions{i}.name)

    set(gcf,'UserData',workflow);
end

function helpVariableCB(hObject,eventdata,i,j)
    workflow=get(gcf,'UserData');
    if isempty(workflow)
        return;
    end
    if workflow.verboseLevel>0
        fprintf('helpVariableCB(%g,%s,%d,%d)\n',hObject,eventdata,i,j);
    end

    value=get(hObject,'value');
    disp(workflow.functions{i}.parameters{j}.VariableName);
    disp(workflow.functions{i}.parameters{j}.Description);
    helpdlg(workflow.functions{i}.parameters{j}.Description,[workflow.functions{i}.name,'/',workflow.functions{i}.parameters{j}.VariableName]);

    set(gcf,'UserData',workflow);
end

function assignTypeCB(hObject,eventdata,i,j)
    workflow=get(gcf,'UserData');
    if isempty(workflow)
        return;
    end
    if workflow.verboseLevel>0
        fprintf('assignTypeCB(%g,%s,%d,%d)\n',hObject,eventdata,i,j);
    end

    value=get(hObject,'value');
    workflow.functions{i}.parameters{j}.assign.type=workflow.assignTypes{value};
    switch (workflow.functions{i}.parameters{j}.assign.type)
      case {'inherit','inherit&rep'}
        workflow.functions{i}.parameters{j}.assign.inheritFunction=1;
        [array,~,~]=variables2pipesstring(workflow,...
                                          workflow.functions{i}.parameters{j}.assign.inheritFunction,...
                                          '');
        workflow.functions{i}.parameters{j}.assign.inheritVariable=array{1};
        workflow.functions{i}.parameters{j}.assign.regexp='''(.*)''';
        workflow.functions{i}.parameters{j}.assign.rep='''''';
      case {'value','pedigree'}
        workflow.functions{i}.parameters{j}.assign.value=NaN;
      otherwise
        error('unknown assign.type=''%s''\n',workflow.functions{i}.parameters{j}.assign.type);
    end

    set(gcf,'UserData',workflow);
    redraw();
end

function editValueCB(hObject,eventdata,i,j)
    workflow=get(gcf,'UserData');
    if isempty(workflow)
        return;
    end
    if workflow.verboseLevel>0
        fprintf('editValueCB(%g,%s,%d,%d)\n',hObject,eventdata,i,j);
    end

    value=get(hObject,'string');
    workflow.functions{i}.parameters{j}.assign.value=value;
    set(gcf,'UserData',workflow);
end

function editRegexpCB(hObject,eventdata,i,j)
    workflow=get(gcf,'UserData');
    if isempty(workflow)
        return;
    end
    if workflow.verboseLevel>0
        fprintf('editRegexpCB(%g,%s,%d,%d)\n',hObject,eventdata,i,j);
    end

    value=get(hObject,'string');
    workflow.functions{i}.parameters{j}.assign.regexp=value;
    set(gcf,'UserData',workflow);
end

function editRepCB(hObject,eventdata,i,j)
    workflow=get(gcf,'UserData');
    if isempty(workflow)
        return;
    end
    if workflow.verboseLevel>0
        fprintf('editRepCB(%g,%s,%d,%d)\n',hObject,eventdata,i,j);
    end

    value=get(hObject,'string');
    workflow.functions{i}.parameters{j}.assign.rep=value;
    set(gcf,'UserData',workflow);
end

function editInheritFunctionCB(hObject,eventdata,i,j,functions)
    workflow=get(gcf,'UserData');
    if isempty(workflow)
        return;
    end
    if workflow.verboseLevel>0
        fprintf('editInheritFunctionCB(%g,%s,%d,%d)\n',hObject,eventdata,i,j);
    end

    value=get(hObject,'value');
    workflow.functions{i}.parameters{j}.assign.inheritFunction=value;
    set(gcf,'UserData',workflow);
    redraw();
end

function editInheritVariableCB(hObject,eventdata,i,j,variables)
    workflow=get(gcf,'UserData');
    if isempty(workflow)
        return;
    end
    if workflow.verboseLevel>0
        fprintf('editInheritVariableCB(%g,%s,%d,%d)\n',hObject,eventdata,i,j);
    end

    value=get(hObject,'value');
    workflow.functions{i}.parameters{j}.assign.inheritVariable=variables{value};
    set(gcf,'UserData',workflow);
    redraw();
end


function insertFunctionCB(hObject,eventdata,i)
    workflow=get(gcf,'UserData');
    if isempty(workflow)
        return;
    end
    if workflow.verboseLevel>0
        fprintf('insertFunctionCB(%g,%s,%d)\n',hObject,eventdata,i);
    end

    value=get(hObject,'value');
    workflow=insertFunction(workflow,i,workflow.availableFunctions{get(hObject,'value')});
    set(gcf,'UserData',workflow);
    redraw();
end

function workflow=insertFunction(workflow,i,name)
    if workflow.verboseLevel>0
        fprintf('insertFunction(%d,%s)\n',i,name);
    end

    %% open space
    workflow.functions(i+1:end+1)= workflow.functions(i:end);
    for ii=1:length(workflow.functions)
        for j=1:length(workflow.functions{ii}.parameters)
            switch (workflow.functions{ii}.parameters{j}.assign.type)
              case {'inherit','inherit&rep'}
                if workflow.functions{ii}.parameters{j}.assign.inheritFunction>=i
                    workflow.functions{ii}.parameters{j}.assign.inheritFunction=...
                        workflow.functions{ii}.parameters{j}.assign.inheritFunction+1;
                end
              case {'value','pedigree'}
              otherwise
                error('unknown assign.type=''%s''\n',workflow.functions{ii}.parameters{j}.assign.type);
            end
        end
    end
    %% add new one
    workflow.functions{i}.name=name;
    workflow.functions{i}.execute=1;
    workflow.functions{i}.parameters={};
    workflow=getFunctionDefaults(workflow,i);
end

function deleteFunctionCB(hObject,eventdata,i)
    workflow=get(gcf,'UserData');
    if isempty(workflow)
        return;
    end
    if workflow.verboseLevel>0
        fprintf('deleteFunctionCB(%g,%s,%d)\n',hObject,eventdata,i);
    end

    workflow=deleteFunction(workflow,i);
    set(gcf,'UserData',workflow);
    redraw();
end

function workflow=deleteFunction(workflow,i)
    if workflow.verboseLevel>0
        fprintf('deleteFunction(%d)\n',i);
    end

    %% remove function
    workflow.functions(i)=[];
    for ii=1:length(workflow.functions)
        for j=1:length(workflow.functions{ii}.parameters)
            switch (workflow.functions{ii}.parameters{j}.assign.type)
              case {'inherit','inherit&rep'}
                if workflow.functions{ii}.parameters{j}.assign.inheritFunction==i
                    workflow.functions{ii}.parameters{j}.assign.inheritFunction=NaN;
                elseif workflow.functions{ii}.parameters{j}.assign.inheritFunction>i
                    workflow.functions{ii}.parameters{j}.assign.inheritFunction=...
                        workflow.functions{ii}.parameters{j}.assign.inheritFunction-1;
                end
              case {'value','pedigree'}
              otherwise
                error('unknown assign.type=''%s''\n',workflow.functions{ii}.parameters{j}.assign.type);
            end
        end
    end
end

function workflow=getFunctionDefaults(workflow,i)
    if workflow.verboseLevel>0
        fprintf('getFunctionDefaults(%d)\n',i);
    end

    %try
        parameters=feval(workflow.functions{i}.name,'help');
        %catch me
        %parameters=struct();
        %end

    existingVariables=cellfun(@(x)getfield(x,'VariableName'),workflow.functions{i}.parameters,'UniformOutput',0);
    allVariables=cellfun(@(x)getfield(x,'VariableName'),parameters,'UniformOutput',0);

    %% Check if all previously set variables are valid
    if ~isempty(setdiff(existingVariables,allVariables))
        disp(setdiff(existingVariables,allVariables))
        error('unknown variables for function %s\n',workflow.functions{i}.name);
    end

    %% Set assignments based on: previous values OR defaults
    for j=1:length(parameters)
        k=find(strcmp(parameters{j}.VariableName,existingVariables));
        if ~isempty(k)
            parameters{j}.assign=workflow.functions{i}.parameters{k}.assign;
            continue
        end
        if isfield(parameters{j},'PossibleInheritances')
            [array,string]=functions2pipestring(workflow);
            found=0;
            for l=1:size(parameters{j}.PossibleInheritances,1)
                if strcmp(parameters{j}.PossibleInheritances{l,1},'createPedigree')
                    parameters{j}.assign.type='pedigree';
                    parameters{j}.assign.value=sprintf('''%s/%02d%s''',...
                                                       workflow.outputFolder,i,workflow.functions{i}.name);
                    found=1;
                    break
                else
                    k=min(find(strcmp(parameters{j}.PossibleInheritances{l,1},array)));
                    if ~isempty(k)
                        parameters{j}.assign.inheritFunction=k;
                        parameters{j}.assign.inheritVariable=parameters{j}.PossibleInheritances{l,2};
                        if isempty(parameters{j}.PossibleInheritances{l,3})&&isempty(parameters{j}.PossibleInheritances{l,4})
                            parameters{j}.assign.type='inherit';
                        else
                            parameters{j}.assign.type='inherit&rep';
                            parameters{j}.assign.regexp=value2str(parameters{j}.PossibleInheritances{l,3});
                            parameters{j}.assign.rep=value2str(parameters{j}.PossibleInheritances{l,4});
                        end
                        found=1;
                        break
                    end
                end
            end
            if found
                continue
            end
        end
        if isfield(parameters{j},'DefaultValue')
            parameters{j}.assign.type='value';
            parameters{j}.assign.value=value2str(parameters{j}.DefaultValue);
            continue
        end
        parameters{j}.assign.type='value';
        parameters{j}.assign.value=NaN;
    end
    workflow.functions{i}.parameters=parameters;
end

function autocompleteCB(hObject,eventdata)
    workflow=get(gcf,'UserData');
    if isempty(workflow)
        return;
    end
    if workflow.verboseLevel>0
        fprintf('autocompleteCB(%g,%s)\n',hObject,eventdata);
    end

    % find appropriate autocomplete
    for i=1:length(workflow.predefidedWorkflows)
        if isempty(workflow.functions)
            k=0;
        else
            k=min(find(strcmp(workflow.functions{end}.name,workflow.predefidedWorkflows{i})));
        end
        if ~isempty(k)
            for ii=k+1:length(workflow.predefidedWorkflows{i})
                workflow=insertFunction(workflow,length(workflow.functions)+1,workflow.predefidedWorkflows{i}{ii});
            end
            break
        end
    end
    set(gcf,'UserData',workflow);
    redraw();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Callback function for save
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pedigreesCB(hObject,eventdata)
    workflow=get(gcf,'UserData');
    if isempty(workflow)
        return;
    end
    if workflow.verboseLevel>0
        fprintf('pedigreeCB(%g,%s)\n',hObject,eventdata);
    end

    saveCB(hObject,eventdata,0);
    eval('parameters=toerase;');
    for i=1:length(workflow.functions)
        for j=1:length(workflow.functions{i}.parameters)
            if strcmp(workflow.functions{i}.parameters{j}.assign.type,'pedigree')
                workflow.functions{i}.parameters{j}.assign.pedigree=getfield(parameters{i},workflow.functions{i}.parameters{j}.VariableName);
                workflow.functions{i}.parameters{j}.assign.pedigreehasdata=pedigreeHasData(workflow,workflow.functions{i}.parameters{j}.assign.pedigree);
            end
        end
    end
    delete('toerase.m');
    set(gcf,'UserData',workflow);
    redraw();
end

function hasdata=pedigreeHasData(workflow,name)
    %% get key formating parameters for filenames
    [filename,pedigreeName,pedigreeSuffix,dateFormat,basenameUniqueRegexp,timeStampFormat,pedigreeWildcard]=createPedigree();

    if workflow.verboseLevel>0
        fprintf('Analysing pedigree: %s\n',name);
    end
    thisName=[name,pedigreeSuffix];
    thisWildcard=[name,'*'];

    [~,filename,ext]=fileparts(thisName);
    filename=[filename,ext];

    matchFiles=dir(thisWildcard);

    hasdata=false;
    for i=1:length(matchFiles)
        if strcmp(matchFiles(i).name,filename)
            %            fprintf('   same (ignored)\n');
            continue;
        end
        if workflow.verboseLevel>0
            fprintf('         data file: %s\n',matchFiles(i).name)
        end
        hasdata=true;
        break;
    end

end

function saveCB(hObject,eventdata,execute)
    workflow=get(gcf,'UserData');
    if isempty(workflow)
        return;
    end
    if workflow.verboseLevel>0
        fprintf('saveCB(%g,%s)\n',hObject,eventdata);
    end

    if execute
        [filename,filepath]=uiputfile('*.m','Select File to Save Parameters',workflow.filename);
        workflow.filename=fullfile(filepath,filename);
        [filepath,scriptname,extension]=fileparts(filename);
        fid=fopen(workflow.filename,'w');
    else
        scriptname='toerase';
        fid=fopen('toerase.m','w');
    end

    fprintf(fid,'function parameters=%s()\n',scriptname);
    fprintf(fid,'%%%% ATTENTION: This file has been generated by buildworkflow().\n');
    fprintf(fid,'%%%%            . Changes may prevent buildworkflow() from reading this file.\n');
    fprintf(fid,'%%%%            . Changes may be subsequently overwritten by buildworkflow().\n');

    for i=1:length(workflow.functions)
        fprintf(fid,'\n%%%% Parameters for %s (%d)\n',workflow.functions{i}.name,i);
        % leave pedigrees for end
        types=cellfun(@(x)x.assign.type,workflow.functions{i}.parameters,'UniformOutput',0);
        k1=find(~strcmp(types,'pedigree'));
        k2=find(strcmp(types,'pedigree'));
        for j=[k1(:)',k2(:)']
            if any(strcmp(workflow.functions{i}.parameters{j}.VariableName,{'Help_','parametersStructure','parametersMfile','verboseLevel'}))
                continue;
            end
            switch (workflow.functions{i}.parameters{j}.assign.type)
              case 'value',
                fprintf(fid,'parameters{%d}.%s=%s;\n',i,...
                        workflow.functions{i}.parameters{j}.VariableName,...
                        workflow.functions{i}.parameters{j}.assign.value);
              case 'pedigree',
                if isfield(workflow.functions{i}.parameters{j}.assign,'pedigree')
                    comment=sprintf(' %% %s',workflow.functions{i}.parameters{j}.assign.pedigree);
                else
                    comment='';
                end
                fprintf(fid,'parameters{%d}.%s=createPedigree(%s,parameters{%d});%s\n',i,...
                        workflow.functions{i}.parameters{j}.VariableName,...
                        workflow.functions{i}.parameters{j}.assign.value,i,comment);
              case 'inherit',
                fprintf(fid,'parameters{%d}.%s=parameters{%d}.%s;\n',i,...
                        workflow.functions{i}.parameters{j}.VariableName,...
                        workflow.functions{i}.parameters{j}.assign.inheritFunction,...
                        workflow.functions{i}.parameters{j}.assign.inheritVariable);
              case 'inherit&rep',
                fprintf(fid,'parameters{%d}.%s=regexprep(parameters{%d}.%s,%s,%s);\n',i,...
                        workflow.functions{i}.parameters{j}.VariableName,...
                        workflow.functions{i}.parameters{j}.assign.inheritFunction,...
                        workflow.functions{i}.parameters{j}.assign.inheritVariable,...
                        workflow.functions{i}.parameters{j}.assign.regexp,...
                        workflow.functions{i}.parameters{j}.assign.rep...
                        );
              otherwise,
                error('assign.type=%s unknown\n',workflow.functions{i}.parameters{j}.assign.type);
            end
        end
    end

    if execute
        fprintf(fid,'\n%%%% Call scripts\n');
        fprintf(fid,'if nargout==0\n');
        for i=1:length(workflow.functions)
            fprintf(fid,'   if %d\n',workflow.functions{i}.execute);
            fprintf(fid,'      fprintf(''%s\\n%s\\n'');\n',workflow.functions{i}.name,repmat('-',1,length(workflow.functions{i}.name)));
            fprintf(fid,'      %s(''parametersStructure'',parameters{%d});\n',...
                    workflow.functions{i}.name,i);
            fprintf(fid,'   end\n');
        end
        fprintf(fid,'end\n');
    end
    fclose(fid);
    rehash

    %% create batch
    if execute
        batchname=fullfile(filepath,[scriptname,'.sh']);
        [status,shell]=system('which sh');
        if status==0
            fid=fopen(batchname,'w');
            fprintf(fid,'#!%s\n',shell);
            fprintf(fid,'unset DISPLAY\n');
            fprintf(fid,'nohup matlab -nodisplay -nosplash -r %s >>%s.out 2>&1 &\n',scriptname,scriptname);
            fclose(fid);
            system(sprintf('chmod u+x %s',batchname));
        end
    end

    if workflow.verboseLevel>0
        fprintf('  done saving\n');
    end
    set(gcf,'UserData',workflow);
end

function load()
    workflow=get(gcf,'UserData');
    if isempty(workflow)
        return;
    end

    [filename,filepath]=uigetfile('*.m','Select File to Load Parameters',workflow.filename);
    workflow.filename=fullfile(filepath,filename);

    fid=fopen(workflow.filename,'r');

    if fid<0
        return;
    end

    ifexecute=[];

    while 1
        tline=fgetl(fid);
        if ~ischar(tline), break, end

        % empty
        if isempty(tline)
            if workflow.verboseLevel>0
                fprintf('empty line\n');
            end
            continue
        end

        % comment
        s=regexp(tline,'^\s*(?<comment>%.*)?$','names');
        if ~isempty(s)
            if workflow.verboseLevel>0
                fprintf('%s\n',s.comment);
            end
            continue
        end

        % function
        s=regexp(tline,'^\s*function\s*(?<function>.*)\s*(?<comment>%.*)?$','names');
        if ~isempty(s)
            if workflow.verboseLevel>0
                fprintf('function %s ''%s''\n',s.function,s.comment);
            end
            continue
        end

        % fprint
        s=regexp(tline,'^\s*fprintf\((?<string>.*)\);\s*(?<comment>%.*)?$','names');
        if ~isempty(s)
            if workflow.verboseLevel>0
                fprintf('fprintf(%s); ''%s''\n',s.string,s.comment);
            end
            continue
        end

        % fprint
        s=regexp(tline,'^\s*clear\s+parameters;?\s*(?<comment>%.*)?$','names');
        if ~isempty(s)
            if workflow.verboseLevel>0
                fprintf('clear parameters; ''%s''\n',s.comment);
            end
            continue
        end

        % parameters{???}.??? = createPedigree(???,parameters{???}); % ....
        s=regexp(tline,'^\s*parameters{(?<findex>\w+)}\.(?<vname>\w+)\s*=\s*createPedigree\((?<value>.*),parameters{(?<findex1>\w+)}\);\s*(?<comment>%.*)?$','names');
        if ~isempty(s) && strcmp(s.findex,s.findex1)
            if workflow.verboseLevel>0
                fprintf('parameters{%s}.%s = createPedigree(%s,parameters{%s}); ''%s''\n',s.findex,s.vname,s.value,s.findex,s.comment);
            end
            [workflow,i,j]=findVariable(workflow,s.findex,s.vname);
            workflow.functions{i}.parameters{j}.assign.type='pedigree';
            workflow.functions{i}.parameters{j}.assign.value=s.value;
            continue
        end

        % parameters{???}.??? = regexprep(parameters{???}.???,???,???); % ....
        s=regexp(tline,'^\s*parameters{(?<findex>\w+)}\.(?<vname>\w+)\s*=\s*regexprep\(\s*parameters{(?<findex1>\w+)}\.(?<vname1>\w+)\s*,\s*(?<regexp>''[^'']*'')\s*,\s*(?<rep>''[^'']*'')\);\s*(?<comment>%.*)?$','names');
        if ~isempty(s)
            if workflow.verboseLevel>0
                fprintf('parameters{%s}.%s = regexp(parameters{%s}.%s,%s,%s) (inherit); ''%s''\n',s.findex,s.vname,s.findex1,s.vname1,s.regexp,s.rep,s.comment);
            end
            [workflow,i,j]=findVariable(workflow,s.findex,s.vname);
            workflow.functions{i}.parameters{j}.assign.type='inherit&rep';
            workflow.functions{i}.parameters{j}.assign.inheritFunction=str2num(s.findex1);
            workflow.functions{i}.parameters{j}.assign.inheritVariable=s.vname1;
            workflow.functions{i}.parameters{j}.assign.regexp=s.regexp;
            workflow.functions{i}.parameters{j}.assign.rep=s.rep;
            continue
        end

        % parameters{???}.??? = parameters{???}.???; % ....
        s=regexp(tline,'^\s*parameters{(?<findex>\w+)}\.(?<vname>\w+)\s*=\s*parameters{(?<findex1>\w+)}\.(?<vname1>\w+);\s*(?<comment>%.*)?$','names');
        if ~isempty(s)
            if workflow.verboseLevel>0
                fprintf('parameters{%s}.%s = parameters{%s}.%s (inherit); ''%s''\n',s.findex,s.vname,s.findex1,s.vname1,s.comment);
            end
            [workflow,i,j]=findVariable(workflow,s.findex,s.vname);
            workflow.functions{i}.parameters{j}.assign.type='inherit';
            workflow.functions{i}.parameters{j}.assign.inheritFunction=str2num(s.findex1);
            workflow.functions{i}.parameters{j}.assign.inheritVariable=s.vname1;
            continue
        end

        % parameters{???}.??? = ???; % ....
        s=regexp(tline,'^\s*parameters{(?<findex>\w+)}\.(?<vname>\w+)\s*=\s*(?<value>.*);\s*(?<comment>%.*)?$','names');
        if ~isempty(s)
            if workflow.verboseLevel>0
                fprintf('parameters{%s}.%s = %s; ''%s''\n',s.findex,s.vname,s.value,s.comment);
            end
            [workflow,i,j]=findVariable(workflow,s.findex,s.vname);
            workflow.functions{i}.parameters{j}.assign.type='value';
            workflow.functions{i}.parameters{j}.assign.value=s.value;
            continue
        end

        % if ???
        s=regexp(tline,'^\s*if\s+(?<expression>\d+)\s*(?<comment>%.*)?$','names');
        if ~isempty(s)
            if workflow.verboseLevel>0
                fprintf('if (%s) ''%s''\n',s.expression,s.comment);
            end
            ifexecute(end+1)=str2num(s.expression);
            continue
        end

        % if ???
        s=regexp(tline,'^\s*if\s+(?<expression>.+)\s*(?<comment>%.*)?$','names');
        if ~isempty(s)
            if workflow.verboseLevel>0
                fprintf('if (%s) ''%s''\n',s.expression,s.comment);
            end
            ifexecute(end+1)=1;
            continue
        end

        % end
        s=regexp(tline,'^\s*end\s*(?<comment>%.*)?$','names');
        if ~isempty(s)
            if workflow.verboseLevel>0
                fprintf('end (if) ''%s''\n',s.comment);
            end
            ifexecute(end)=[];
            continue;
        end

        % ???('parametersStructure',parameters{???});'
        s=regexp(tline,'^\s*(?<fname>\w+)\(''parametersStructure'',parameters{(?<findex>\w+)}\);\s*(?<comment>%.*)?$','names');
        if ~isempty(s)
            if workflow.verboseLevel>0
                fprintf('%s(''parametersStructure'',parameters{%s}); ''%s''\n',s.fname,s.findex,s.comment);
            end
            i=str2num(s.findex);
            workflow.functions{i}.name=s.fname;
            workflow.functions{i}.execute=all(ifexecute);
            if length(workflow.functions)<i
                workflow.functions{i}.parameters={};
            end
            workflow=getFunctionDefaults(workflow,i);
            continue
        end

        fprintf('load: UNKNOWN LINE ''%s''\n',tline);

    end

    fclose(fid);
    if workflow.verboseLevel>0
        fprintf('  done loading\n');
    end

    set(gcf,'UserData',workflow);
end

function [workflow,i,j]=findVariable(workflow,findex,vname)
    i=str2num(findex);
    if length(workflow.functions)<i
        workflow.functions{i}.parameters={};
    end
    variables=cellfun(@(x)getfield(x,'VariableName'),workflow.functions{i}.parameters,'UniformOutput',0);
    j=find(strcmp(vname,variables));
    if isempty(j)
        workflow.functions{i}.parameters{end+1}.VariableName=vname;
        j=length(workflow.functions{i}.parameters);
    end
end

function str=value2str(value)

    if isnumeric(value)
        str=mat2str(value);
    elseif ischar(value)
        str=['''',value,''''];
    elseif iscell(value)
        str='{';
        for i=1:size(value,1)
            if i>1
                str=[str,';'];
            end
            for j=1:size(value,2)
                if j==1
                    str=[str,value2str(value{i,j})];
                else
                    str=[str,',',value2str(value{i,j})];
                end
            end
        end
    end
end
