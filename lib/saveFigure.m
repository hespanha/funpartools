function varargout=saveFigure(varargin);
% To get help, type saveFigure('help')
%
% This file is part of Tencalc.
%
% Copyright (C) 2012-21 The Regents of the University of California
% (author: Dr. Joao Hespanha).  All rights reserved.

    declareParameter(...
        'Help', {
            'This script saves a figure in a desired format.'
                });


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    declareParameter(...
        'VariableName','folder',...
        'DefaultValue','.',...
        'Description', {
            'Folder where the figure(s) should be created (with respect to the current folder).'
                       });

    declareParameter(...
        'VariableName','createFolder',...
        'AdmissibleValues',{false,true},...
        'DefaultValue',false,...
        'Description', {
            'When true, creates the folder where the figure(s) should be created if it does not exist.';
            ' ';
            'ATTENTION: include path (even if just ''./'') to help saveFigure making sure it can detect';
            '           if the folder exists where you want it'
                       });

    declareParameter(...
        'VariableName','eraseFigures',...
        'AdmissibleValues',{false,true,'force'},...
        'DefaultValue',false,...
        'Description', {
            'When true, removes all image files from the folder where the'
            'figure(s) should be created before saving them.'
            'When ''force'', the figures are erased without asking.'
                       });

    declareParameter(...
        'VariableName','filename',...
        'DefaultValue','',...
        'Description', {
            'Filename for the figure (without extension). When empty, the name is derived'
            'from the name of the figure.'
                       });

    declareParameter(...
        'VariableName','figureNumber',...
        'DefaultValue',0,...
        'Description', {
            'Array with the numbers of the figure to be saved.'
            '0 corresponds to the current figure.'
                       });

    declareParameter(...
        'VariableName','fontScaling',...
        'DefaultValue',1,...
        'Description', {
            'Scaling value for font scaling. All font size''s are multiplied by';
            '''fontScaling'' prior to printing.';
            'The fontsizes are restored to their normal values after printing.'
                       });

    declareParameter(...
        'VariableName','dpi',...
        'DefaultValue',150,...
        'Description', {
            'Dots-per-inch resolution.';
            'A value of 0, defaults to the screen resolution.'
                       });

    declareParameter(...
        'VariableName','renderer',...
        'AdmissibleValues',{'auto','painters','opengl'},...
        'DefaultValue','auto',...
        'Description', {
            'Algorithm used to render the image for screen and printer.';
            '  painter - fully respects sort order, but slow on images with many objects';
            '  opengl  - faster for complex figure and shows lines always in front';
            '            but resolution is limited by the screen resolution';
            '            (even if the paper size is much larger than the screen)';
            '  auto - matlab selects the algorithm based on figure complexity';
            'As of matlab 2014b, bitmap vs vector format is decided'
            'by the print command.'
                       });

    declareParameter(...
        'VariableName','saveFormat',...
        'DefaultValue','eps',...
        'Description', {
            'Format used to save the figure:'
            '  fig  - .fig matlab file'
            '  fig6 - .fig matlab file, loaddable by versions prior to MATLAB 7'
            '  png  - png image'
            '  tiff - tiff image'
            '  jpeg - jpeg image'
            '  eps  - encapsulated postscript with color'
            '  pdf  - pdf file'
            '  svg  - xml-based scalable vector graphics'
            '  all  - saves in all formats'
            '  none - does not save the figure'
            'May be a cell of strings, to save under multiple formats'
                       });

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Outputs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    declareOutput(...
        'VariableName','filename',...
        'Description', {
            'Filename (including path) where the figure was save.'
                       });

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Retrieve parameters and inputs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [stopNow,params]=setParameters(nargout,varargin);
    if stopNow
        return
    end

    if ischar(saveFormat)
        saveFormat={saveFormat};
    end

    if ~exist(folder,'dir')
        if createFolder
            fprintf('saveFigure: creating folder ''%s'' (currently does not exist).\n',folder);
            mkdir(folder);
        else
            error('saveFigure: folder ''%s'' does not exist\n',folder);
        end
    end

    if isequal(eraseFigures,'force')
        eraseFigure=true;
        rm='rm -f %s';
    else
        rm='rm -i %s';
    end

    dpi=sprintf('-r%d',dpi);

    if isequal(renderer,'auto')
        renderer='';
    else
        renderer=['-',renderer];
    end

    if isequal(eraseFigures,'force') || isequal(eraseFigures,true)
        fprintf('saveFigure: erasing figures in folder ''%s''.\n',folder);
        erasename=fullfile(folder,'*.fig');
        cmd=sprintf(rm,erasename);fprintf('   %s\n',cmd);
        system(cmd);
        erasename=fullfile(folder,'*.png');
        cmd=sprintf(rm,erasename);fprintf('   %s\n',cmd);
        system(cmd);
        erasename=fullfile(folder,'*.jpeg');
        cmd=sprintf(rm,erasename);fprintf('   %s\n',cmd);
        system(cmd);
        erasename=fullfile(folder,'*.tif');
        cmd=sprintf(rm,erasename);fprintf('   %s\n',cmd);
        system(cmd);
        erasename=fullfile(folder,'*.png');
        cmd=sprintf(rm,erasename);fprintf('   %s\n',cmd);
        system(cmd);
        erasename=fullfile(folder,'*.pdf');
        cmd=sprintf(rm,erasename);fprintf('   %s\n',cmd);
        system(cmd);
        erasename=fullfile(folder,'*.eps');
        cmd=sprintf(rm,erasename);fprintf('   %s\n',cmd);
        system(cmd);
        erasename=fullfile(folder,'*.svg');
        cmd=sprintf(rm,erasename);fprintf('   %s\n',cmd);
        system(cmd);
    end

    %verboseLevel=4;

    for i=1:length(figureNumber)

        if figureNumber(i)==0
            figureNumber(i)=gcf;
        else
            figure(figureNumber(i));
        end

        % for debug
        %set(figureNumber(i),'InvertHardcopy','off','renderer','painters','GraphicsSmoothing','off');

        if isempty(filename)
            thisname=get(figureNumber(i),'name');
            % remove from name "forbidden" characters
            thisname=regexprep(thisname,'[\\ /,:]','_');
            thisname=regexprep(thisname,'[\[\(]','{');
        thisname=regexprep(thisname,'[\]\)]','}');
        thisname=regexprep(thisname,'[.]','_');
        else
            thisname=filename;
        end

        thisname=fullfile(folder,thisname);

        if fontScaling~=1
            resizeFontSize(figureNumber(i),fontScaling);
        end

        if any(ismember({'fig','all'},saveFormat))
            drawnow
            rgb2cm(); % to enable painters mode

            nameext=[thisname,'.fig'];
            fprintf('saving %d as .fig ''%s''...',figureNumber(i),nameext);t0=clock;
            savefig(figureNumber(i),nameext);
            fprintf('done (%dK %.2f sec)\n',fileSize(nameext),etime(clock,t0));
        end

        if any(ismember({'fig6','all'},saveFormat))
            drawnow
            rgb2cm(); % to enable painters mode

            nameext=[thisname,'.fig'];
            fprintf('saving %d as .fig (-v6) ''%s''...',figureNumber(i),nameext);t0=clock;
            hgsave(figureNumber(i),nameext,'-v6');
            fprintf('done (%dK %.2f sec)\n',fileSize(nameext),etime(clock,t0));
        end

        %% Raster formats
        if any(ismember({'png','all'},saveFormat))
            drawnow

            nameext=[thisname,'.png'];
            fprintf('saving %d as .png ''%s''...',figureNumber(i),nameext);t0=clock;
            print(figureNumber(i),...
                  ...%'-loose',...;
            dpi,...
                renderer,...
                '-dpng',nameext);
            fprintf('done (%dK %.2f sec)\n',fileSize(nameext),etime(clock,t0));
        end

        if any(ismember({'jpeg','all'},saveFormat))
            drawnow

            nameext=[thisname,'.jpeg'];
            fprintf('saving %d as .jpeg ''%s''...',figureNumber(i),nameext);t0=clock;
            print(figureNumber(i),...
                  ...%'-loose',...
            dpi,...
                renderer,...
                '-djpeg',nameext);
            fprintf('done (%dK %.2f sec)\n',fileSize(nameext),etime(clock,t0));
        end

        if any(ismember({'tiff','all'},saveFormat))
            drawnow

            nameext=[thisname,'.tif'];
            fprintf('saving %d as .tif ''%s''...',figureNumber(i),nameext);t0=clock;
            if 1
                print(figureNumber(i),...
                      ...%'-loose',...
                dpi,...
                    renderer,...
                    '-dtiff',nameext);
            elseif 0
                export_fig(nameext,'-tiff','-cmyk',renderer,figureNumber(i));
            else
                saveas(figureNumber(i),nameext,'tiff');
            end
            fprintf('done (%dK %.2f sec)\n',fileSize(nameext),etime(clock,t0));
        end

        %% Vector formats
        if any(ismember({'pdf','all'},saveFormat))
            drawnow
            rgb2cm(); % to enable painters mode

            nameext=[thisname,'.pdf'];
            fprintf('saving %d as .pdf ''%s''...',figureNumber(i),nameext);t0=clock;
            if 1
                print(figureNumber(i),...
                      ...%'-loose',...;
                '-bestfit',...
                    dpi,...
                    renderer,...
                    '-dpdf','-cmyk',nameext);
            elseif 0
                export_fig(nameext,'-pdf','-cmyk',renderer,figureNumber(i));
            else
                saveas(figureNumber(i),nameext,'pdf');
            end
            fprintf('done (%dK %.2f sec)\n',fileSize(nameext),etime(clock,t0));
        end

        if any(ismember({'eps','all'},saveFormat))
            drawnow
            rgb2cm(); % to enable painters mode

            nameext=[thisname,'.eps'];
            fprintf('saving %d as .eps ''%s''...',figureNumber(i),nameext);t0=clock;
            if 1
                print(figureNumber(i),...
                      ...%'-loose',...
                dpi,...
                    renderer,...
                    '-depsc','-cmyk',nameext);
            elseif 0
                export_fig(nameext,'-eps','-cmyk',renderer,figureNumber(i));
            else
                saveas(figureNumber(i),nameext,'eps');
            end
            fprintf('done (%dK %.2f sec)\n',fileSize(nameext),etime(clock,t0));
        end

        if any(ismember({'svg','all'},saveFormat))
            drawnow
            rgb2cm(); % to enable painters mode

            nameext=[thisname,'.svg'];
            fprintf('saving %d as .svg ''%s''...',figureNumber(i),nameext);t0=clock;
            if 0
                plot2svg(nameext);
            else
                saveas(figureNumber(i),nameext,'svg');
            end
            fprintf('done (%dK %.2f sec)\n',fileSize(nameext),etime(clock,t0));
        end

        if fontScaling~=1
            resizeFontSize(figureNumber(i),1/fontScaling);
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Set outputs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    varargout=setOutputs(nargout,params);
end

function oldSize=resizeFontSize(fig,scale)
    h=findobj(fig,'-property','fontsize');
    for i=1:length(h)
        oldSize=get(h(i),'FontSize');
        set(h(i),'FontSize',scale*oldSize);
    end
end

function sz=fileSize(filename)
    s=dir(filename);
    if isempty(s)
        sz=nan;
    else
        sz=ceil(s.bytes/1000);
    end
end
