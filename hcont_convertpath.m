% function path=hcont_convertpath(path, hekaormatlab);
% [locations]=marcicucca_locations;
% matlabstartdir='/data/Userek/';
% matlabstartdir=locations.hekawindir;
% hekastartdir='x:\';
% hekastartdir='c:\stuff\HEKA\';
% hekastartdir='e:\';
% if (strcmp(hekaormatlab,'heka') || strcmp(hekaormatlab,'h')) && any(strfind(path,matlabstartdir))
%     path=path(length(matlabstartdir)+1:end);
%     path(findstr(path,'/'))='\';
%     path=[hekastartdir, path];
% elseif (strcmp(hekaormatlab,'matlab') || strcmp(hekaormatlab,'m')) && any(strfind(path,hekastartdir))
%     path=path(length(hekastartdir)+1:end);
%     path(findstr(path,'\'))='/';
%     path=[matlabstartdir,path];
% else
%     %disp('ajjaj itt gáz van a konvertálással :S')
% end
% 
% end