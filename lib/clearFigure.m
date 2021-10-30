function varargout=clearFigure(varargin);
% To get help, type clearFigure('help')
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

    declareParameter(...
        'Help', {
            'This script creates a figure if it does not exist and clears it if it does not.'
            'It also creates an axis within the figure.'
                });


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    declareParameter(...
        'VariableName','orientation',...
        'AdmissibleValues',{'landscape','portrait'},...
        'DefaultValue','landscape',...
        'Description', {
            'Size of the '
                       });

    declareParameter(...
        'VariableName','paperSize',...
        'DefaultValue',1,...
        'Description', {
            'Size of the figure with respect to the US letter:'
            '   1 corresponds to the US letter size'
            '   x corresponds to x times the US letter size';
            'ATTENTION: it seems that for sizes different than 1';
            '           the fontsizes are adjusted before printing';
            '           (enlarged for larger paper sizes)'
                       });

    declareParameter(...
        'VariableName','figureNumber',...
        'DefaultValue',0,...
        'Description', {
            'Desired number for the figure, 0 corresponds to the current figure.'
                       });

    declareParameter(...
        'VariableName','figureName',...
        'DefaultValue','',...
        'Description', {
            'Desired name for the figure.'
                       });

    declareParameter(...
        'VariableName','plotOrder',...
        'AdmissibleValues',{'draw','depth'},...
        'DefaultValue','draw',...
        'Description', {
            'Selects the order objects are displayed in the axis created.'
                       });

    declareParameter(...
        'VariableName','subplots',...
        'DefaultValue',1,...
        'Description', {
            'Size of a desired subplot array.'
                       });

    declareParameter(...
        'VariableName','renderer',...
        'AdmissibleValues',{'auto','painters','opengl'},...
        'DefaultValue','auto',...
        'Description', {
            'Algorithm used to render the image for screen and printer.';
            '  painter - fully respects sort order, but slow on large images';
            '  opengl  - faster for complex figure, lines always in front';
            '  auto - matlab selects the algorithm based on figure complexity';
            'As of matlab 2014b, bitmap vs vector format is decided'
            'by the print command.'
                       });

    declareParameter(...
        'VariableName','docked',...
        'AdmissibleValues',{'yes','no','nochange'},...
        'DefaultValue','nochange',...
        'Description', {
                         'Determines window style:';
                         '  yes - set widow style to docked';
                         '  no - set widow style to normal';
                         '  nochange - do not change window style';
                       });

    % Changed 'Renderer','opengl' to 'RendererMode','auto' on 5/18/2014 to
    % avoid problems with logscale

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Outputs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    declareOutput(...
        'VariableName','figureNumber',...
        'Description', {
            'Number of the figure created.'
                       });

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Retrieve parameters and inputs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [stopNow,params]=setParameters(nargout,varargin);
    if stopNow
        return
    end

    %verboseLevel=4;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Function body
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    switch orientation
      case 'landscape'
        figPosition=[1,8.5,paperSize*[11,8.5]];
        paperSize=paperSize*[11 8.5];
      case 'portrait'
        figPosition=[1,11,paperSize*[8.5,11]];
        paperSize=paperSize*[8.5 11];
    end

    %% Reset Screen DPI to default 72dpi
    %set(0,'ScreenPixelsPerInch',72);
    %% reseting to default seems to be problematic if this would cause
    %% figures to become larger than the screen

    %% Make sure paper size will fit in the physical screen
    monitor=get(0,'MonitorPositions');
    screenDPI=get(0,'ScreenPixelsPerInch');
    monitorUsefulPixels=.9*monitor(3:4);
    monitorUsefulInches=monitorUsefulPixels/screenDPI;
    scale=max(paperSize./monitorUsefulInches);
    if scale>1
        newScreenDPI=screenDPI/scale;
        fprintf('clearFigure: changing ''ScreenPixelsPerInch'' from %g to %g for paper to fit\n',...
                screenDPI,newScreenDPI);
        set(0,'ScreenPixelsPerInch',newScreenDPI);
    end

    %% Create figure

    if figureNumber>0
        if ishandle(figureNumber)
            % if figure already exists, just make it current
            set(0,'CurrentFigure',figureNumber);
        else
            figure(figureNumber);
        end
    else
        figureNumber=gcf.Number;
    end

    if ~isempty(figureName)
        set(figureNumber,'name',figureName);
    end

    zoom reset;
    zoom off
    clf

    props={;
    % paper size/position options
           'paperunits';'inches';
           'paperorientation';'portrait'; % so that no rotation is needed
           'papersize';paperSize;
           ...%'paperposition';[0,0,paperSize]; % but dimensions are letter landscape
           ...%'PaperPositionMode';'auto';
              % screen size/position options
           'units';'inches';
           ...%'position';figPosition;
          };

    % docked?
    switch (docked)
      case 'yes'
        set(figureNumber,'WindowStyle','docked');
      case 'no'
        set(figureNumber,'WindowStyle','normal');
    end
    
    % prevent warning from docked window
    s=warning('off','MATLAB:Figure:SetPosition');
    set(figureNumber,props{:},'color','w')
    % restore warning
    warning(s);
    switch (renderer)
      case 'auto'
        set(figureNumber,'RendererMode','auto');
      case 'opengl'
        set(figureNumber,'RendererMode','manual','Renderer','opengl');
      case 'painters'
        set(figureNumber,'RendererMode','manual','Renderer','painters');
    end

    for i=1:prod(subplots)
        if length(subplots)>1
            subplot(subplots(1),subplots(2),i);
        end
        axes;
        %axis equal - very slow
        %axis off - very slow

        zoom reset;
        zoom off;

        %% Drawing based on depth (seems to be buggy for text, but needed for patches)
        %set(gca,'DrawMode','normal');
        %set(gca,'DrawMode','fast'); % MATLAB 2013b
        set(gca,'SortMethod','childorder'); % MATLAB 2014

    end

    clf

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Set outputs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    varargout=setOutputs(nargout,params);
end
