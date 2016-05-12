%% nevek es datumok becuppantasa
[locations]=marcicucca_locations;
hekafiledirs={[locations.tgtardir,'HEKAdata']};
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
%% zúúúzás
[locations]=marcicucca_locations;
overwriteIVs=0;
error=[];
if ~exist('signature','var')
    signature=round(rand(1)*10000);
end
if ~exist('lastsignature','var')
    lastsignature=round(rand(1)*10000);
end
if ~exist('lastmodify','var')
    lastmodify=0;
end
exportfnames={'preiv','postiv'};

hcont_setPMconfig(signature,lastsignature,lastmodify);

% hekawindir='/data/mount/PHYS44_WIN/Data/';
savepath=['MATLABdata/IV'];
% exportdir='/data/Userek/marci/analizis/HEKAdata/export/';
exportdir=[locations.tgtardir,'ANALYSISdata/marci/Exportdir/'];
winexportdir=[locations.tgtarwindir,'ANALYSISdata\marci\Exportdir\'];
 savecounter=0;
prevhekafname=[];
    progressbar('overall progress','current file');


for i=1:size(hekafnames,1)
    
    if ~ischar(cell2mat(hekafnames(i,4)))
    dirname=char(hekafnames(i,1));
    windirname=dirname;
    windirname(strfind(dirname,'/'))='\';
    windirname=[locations.tgtarwindir,windirname(length(locations.tgtardir)+1:end)];
    fname=char(hekafnames(i,2));
    savepathnow=[savepath,dirname(strfind(dirname,'HEKAdata')+length('HEKAdata'):end)];
    cd([locations.tgtardir,savepathnow]);
    if isempty(dir([fname(1:end-4),'.mat'])) || overwriteIVs==1
    %%%HEKA dat file bemásolása a windows mappába
%     cd(hekawindir);
%     delete('temp.*')
%     
% 
%     
%     
%     disp(['copiing file: ',fname]);
%     copyfile([dirname,'/',fname],[hekawindir,'temp.dat']);
%     tempexts={'pgf','pul','amp'};
%     cd(dirname); 
%     for tempextnum=1:length(tempexts)
%         tempext=char(tempexts(tempextnum));
%         tempname=[fname(1:end-3),tempext];
%         if ~isempty(dir(tempname))
%             copyfile([dirname,'/',tempname],[hekawindir,'temp.',tempext]);
%         end
%         
%     end
    %%%HEKA dat file bemásolása a windows mappába
    
    %%%% file megnyitása és csekkolása
    
%     order=['OpenFile read temp.dat'];
    order=['OpenFile read ',windirname,'\',fname];
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
    pause(.2);
    order='GetParameters DataFile';
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
    disp(fname);
    order=['OpenOnlineFile "IVexport.onl"'];
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
    %%%% file megnyitása és csekkolása

     [IVs,~]=hcont_findseriesbyname({'iv','IV'},{'pp','+'},signature,lastsignature,lastmodify);    
    
    iv=struct;
    for tempi=1:size(IVs,1)
        if IVs(tempi,3)>2
            groupi=IVs(tempi,1);
            seriesi=IVs(tempi,2);
            for tracei=1:IVs(tempi,4)
                tracenum=1;
                pause(.1);
                order=['SetTarget 1 1 1 1 0 FALSE FALSE'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                pause(.3);
                order=['Set R  UnmarkIt'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                pause(.1);
                order=['SetTarget ',num2str(groupi),' ',num2str(seriesi),' 1 ',num2str(tracei),' 4 TRUE TRUE'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                pause(.1);
                order=['SweepInfo']; % megnézzük, hogy milyen csatira van felvéve az IV
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                tracenum=str2double(cell2mat(answer.ans(2+(tracei-1)*5)));
                order=['Set A  OA',num2str(tracenum),' TRUE'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                
                order=['SetTarget ',num2str(groupi),' ',num2str(seriesi),' 1 ',num2str(tracenum),' 4 FALSE FALSE'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                order=['Set A  OA',num2str(tracenum),' TRUE'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                order=['SetTarget ',num2str(groupi),' ',num2str(seriesi),' 1 ',num2str(tracenum),' 2 FALSE FALSE'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                pause(1);
%                 temppath=hcont_convertpath(exportdir, 'heka');

                order=['Export overwrite "',winexportdir,'temp"'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                pause(.1);
                [iv.(['g',num2str(groupi),'_s',num2str(seriesi),'_c',num2str(tracenum)]),isok]=hcont_readexportediv([exportdir,'temp.mat'],tracenum);
                if isok==0
                    iv=rmfield(iv,['g',num2str(groupi),'_s',num2str(seriesi),'_c',num2str(tracenum)]);
                    disp([['g',num2str(groupi),'_s',num2str(seriesi),'_c',num2str(tracenum)],'  torolve'])
                end
            end
        end
        progressbar((i-1)/size(hekafnames,1),tempi/size(IVs,1));
    end
    save([locations.tgtardir,savepathnow,'/',fname(1:end-4)],'iv');
    %end
    order=['Set  @  File            "Close"'];
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
    
    end
    
    end
    progressbar((i-1)/size(hekafnames,1),0);
end
progressbar(1);
