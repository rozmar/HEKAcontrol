function hiba=HEKA_exporttreeinfo_main(hekafnames)
locations=marcicucca_locations;
overwrite=0;
savepath=['MATLABdata/TreeData'];
hekafiledirs={[locations.tgtardir,'HEKAdata']};
%%
if nargin<1
    
    
    cd(char(hekafiledirs));
    hekafiledirs=uipickfiles;
    prevdirnum=length(hekafiledirs)-1;
    while length(hekafiledirs)>prevdirnum
        prevdirnum=length(hekafiledirs);
        for i=1:length(hekafiledirs) %% megnézzük, hogy hány mappa van a kiválasztott mappákon belül
            hekafiledir=char(hekafiledirs(i));
            
            cd(hekafiledir);
            temp=dir;
            for j=1:length(temp)
                if temp(j).isdir==1 & ~or(strcmp(temp(j).name,'.'),strcmp(temp(j).name,'..')) & ~any(strcmp([hekafiledir,'/',temp(j).name],hekafiledirs))
                    hekafiledirs{length(hekafiledirs)+1}=[hekafiledir,'/',temp(j).name];
                end
            end
            
        end
    end
    hekafnames=[];
    for i=1:length(hekafiledirs)
        hekafiledir=char(hekafiledirs(i));
        cd(hekafiledir);
        temp=dir;
        for j=1:length(temp)
            if temp(j).isdir==0 & temp(j).name(end-2:end)=='dat'
                tempdb=size(hekafnames,1)+1;
                hekafnames{tempdb,1}=hekafiledir;
                hekafnames{tempdb,2}=temp(j).name;
                hekafnames{tempdb,3}=datenum(char(temp(j).date),0);
                if length(temp(j).name)>9 & ~isempty(str2num(temp(j).name(1:6)))
                    hekafnames{tempdb,4}=datenum(temp(j).name(1:6),'yymmdd');
                    hekafnames{tempdb,5}=abs(cell2mat(hekafnames(tempdb,3))-cell2mat(hekafnames(tempdb,4)));
                else
                    hekafnames{tempdb,4}='NaN';
                    hekafnames{tempdb,5}=0;
                end
            end
        end
    end
    clear temp tempdb prevdirnum i j
end

for i=1:size(hekafnames,1)
%     if ~ischar(cell2mat(hekafnames(i,4))) % ezt kiszedtem... nem tudom,
%     miert volt benne.. valami hotfix..
        dirname=char(hekafnames(i,1));
        windirname=dirname;
        windirname(strfind(dirname,'/'))='\';
        windirname=[locations.tgtarwindir,windirname(length(locations.tgtardir)+1:end)];
        fname=char(hekafnames(i,2));
        savepathnow=[savepath,dirname(strfind(dirname,'HEKAdata')+length('HEKAdata'):end)];
        savepathnow(strfind(savepathnow,'\'))='/';
        cd([locations.tgtardir,savepathnow]);
        if isempty(dir([fname(1:end-4),'.mat'])) || overwrite==1
            [seriesnums,seriesdata,hiba]=HEKA_exporttreeinfo(windirname,fname);
            if ~isempty(seriesnums)
                save([locations.tgtardir,savepathnow,'/',fname(1:end-4)],'seriesnums','seriesdata');
            end
        end
%     end
%     progressbar((i-1)/size(hekafnames,1),0);
end

