function rgb2cm()
% rgb2cm - Clean up colour mapping in patches to allow Painter's mode
%
% Painter's mode rendering is required for copying a figure to the
% clipboard as an EMF (vector format) or printing to vector-format files
% such as PDF and EPS. However, if the colours of any patches in your 
% figure are represented using CData and an RGB colour code, these will not
% show in the copied figure. You may also get a warning like:
% Warning: RGB color data not yet supported in Painter's mode 
%
% One solution is to change these specific patches to use an index into the
% colormap. That's what this script does. For each patch using RGB, it adds
% those colours to the colormap and changes the patch to use a colormap
% index.
%
% Robbie Andrew, March 2012
%
% Joao Hespanha: Turned into function, Oct 2012
% Joao Hespanha: Used "unique" to minimize size of colormap, Nov 2013

patches = findall(gcf,'Type','patch') ;

cm = colormap ;
for i=1:numel(patches)
    set(patches(i),'CDataMapping','direct')
    c = get(patches(i),'FaceColor') ;
    if strcmpi('flat',c)
        c = get(patches(i),'FaceVertexCData') ;
        if size(c,2)>1
            [c,~,ic]=unique(c,'rows');
            ic=size(cm,1)+ic;
            cm = [cm; c] ;
            n = size(c,1) ;
            set(patches(i),'FaceVertexCData',ic)
        end
    end
end

colormap(cm);

