function h=make_figure_pcolor(array,lat,lon,latlim,lonlim,contours,maskland_yn,varargin)
%addpath ~/Dropbox/matlab/downloaded_scripts
%clf
lat=double(lat); lon=double(lon);

% % lindex=lat>latlim(1) & lat < latlim(2);
% % loindex=lon>lonlim(1) & lon < lonlim(2);
% % 

worldmap([latlim(1),latlim(2)],[lonlim(1),lonlim(2)]);
if min(abs(latlim))<=65
    %setm(gca,'mapprojection','behrmann')
    %setm(gca,'mapprojection','gortho')
    setm(gca,'mapprojection','trystan')
end
if length(varargin)>2
    setm(gca,'mapprojection',varargin{3}); 
end

pcolorm(lat,lon,array');

if maskland_yn==0
    geoshow('landareas.shp','facecolor','k')
elseif maskland_yn==2
else
    geoshow('landareas.shp','facecolor','none')
end

if isempty(varargin) || isempty(varargin{1})
%     cmap1=cbrewer('seq','BuPu',(length(contours)+1)/2+1);
%     cmap2=cbrewer('seq','OrRd',(length(contours)+1)/2+1);
%     cmap=cat(1,flipud(cmap1(3:end,:)),ones(2,3)*.9999,cmap2(3:end,:));

    cmap1 = cbrewer('seq','YlOrRd',(length(contours)+1)/2+1) ;
    cmap2 = cbrewer('seq','PuBuGn',(length(contours)+1)/2+1) ;
    cmap=cat(1,flipud(cmap2(3:end,:)),ones(2,3)*.9999,cmap1(3:end,:));
else
    cmap=varargin{1};
end

colormap(cmap1);
caxis([contours(1)-(contours(2)-contours(1)),contours(end)+(contours(2)-contours(1))]);
if length(varargin)>1
    location=varargin{2};
else
    location='southoutside';
end
if strcmp(location,'none')==0
    h=colorbar(location);
    set(h,'fontsize',16)
%     if max(abs(contours))<100
%         set(h,'ytick',-70:20:70)
%     else
%         set(h,'ytick',(-70:20:70)*6)
%     end
end
setm(gca,'meridianlabel','off','parallellabel','off')
%setm(gca,'plabellocation',30,'mlabellocation',90,'mlabelparallel',90)
% setm(gca,'labelformat','none')
% setm(gca,'mlinelocation',90,'plinelocation',30,'gcolor','k','glinestyle','--','glinewidth',.25)
setm(gca,'mlinelocation',lonlim,'plinelocation',latlim)
%setm(gca,'mlinelocation',[],'plinelocation',[])
