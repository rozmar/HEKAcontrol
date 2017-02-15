%% nevek es datumok becuppantasa
clear all
FaultyFileList={'1702103og.dat','1411121kb.dat','140223001br.dat','1105161ls.dat','1611042kb.dat','1610141kb.dat','1610043kb.dat','1610031kb.dat','1609211kb.dat','1606291kb.dat','1606172kb.dat','1606091kb.dat','1604211og.dat','1607251og.dat','1610291og.dat','1608122og.dat','1611041og.dat','1610252og.dat','1509112og.dat','1611251og.dat','1510022og.dat','1608022oa.dat','1609072oa.dat','1610202oa.dat'};
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
%% új megközelítés -
% return
potentialnames={'iv','IV'};
excludename={'pp','+'};
[locations]=marcicucca_locations;
overwriteIVs=0;
savepath=['MATLABdata/IV'];
treepath=['MATLABdata/TreeData'];
progressbar('overall progress');
hibasidxes=[];
for i=1:size(hekafnames,1)
    hiba=false;
    progressbar((i)/size(hekafnames,1));
    if ~ischar(cell2mat(hekafnames(i,4)))
        dirname=char(hekafnames(i,1));
        setupname=dirname(strfind(dirname,'HEKAdata')+length('HEKAdata')+1:end);
        windirname=dirname;
        windirname(strfind(dirname,'/'))='\';
        windirname=[locations.tgtarwindir,windirname(length(locations.tgtardir)+1:end)];
        fname=char(hekafnames(i,2));
        savepathnow=[savepath,'/',setupname];
        cd([locations.tgtardir,savepathnow]);
        exporteda=dir([fname(1:end-4),'.mat']);
        if any(strcmp(fname,FaultyFileList))
            disp([fname, 'not processed because it is blacklisted'])
            hiba_ok='blacklisted';
            hiba=true;
        else
            if isempty(exporteda) || overwriteIVs==1 || exporteda.bytes<5000
                a=dir([locations.tgtardir,treepath,'/',setupname,'/',fname(1:end-4),'.mat']);
                if isempty(a)
                    hiba_ok=HEKA_exporttreeinfo_main(hekafnames(i,:));
                end
                a=dir([locations.tgtardir,treepath,'/',setupname,'/',fname(1:end-4),'.mat']);
                if ~isempty(a)
                    load([locations.tgtardir,treepath,'/',setupname,'/',fname(1:end-4)]);
                    neededseriesnums=[];
                    for seriesi=1:length(seriesdata)
                        neededseriesnums(seriesi)=false;
                        for potentiali=1:length(potentialnames)
                            if any(strfind(seriesdata(seriesi).seriesname,potentialnames{potentiali}))
                                neededseriesnums(seriesi)=true;
                            end
                        end
                        for exludei=1:length(excludename)
                            if any(strfind(seriesdata(seriesi).seriesname,excludename{exludei}))
                                neededseriesnums(seriesi)=false;
                            end
                        end
                    end
                    neededseriesnums=find(neededseriesnums);
                    if ~isempty(neededseriesnums)
                        rawdata=HEKAexportbytreeinfo_main(fname,setupname,seriesnums,seriesdata,neededseriesnums);
                        iv=struct;
                        IDX=0;
                        for seriesii=1:length(neededseriesnums)
                            seriesi=neededseriesnums(seriesii);
                            for channeli=1:seriesnums(seriesi,4)
                                ivnow=struct;
                                si=rawdata(1).si;
                                startIDX=IDX+1;
                                currents=[];
                                for sweepnum=1:seriesnums(seriesi,3)
                                    IDX=IDX+1;
                                    ivnow.realtime=rawdata(IDX).realtime;
                                    ivnow.timertime=rawdata(IDX).timertime;
                                    ivnow.(['v',num2str(sweepnum)])=rawdata(IDX).y';
                                    currents(sweepnum,:)=round(rawdata(IDX).segmentamplitudes*10^12);
                                end
                                ivnow.channellabel=rawdata(IDX).channellabel;
                                ivnow.preamplnum=str2num(ivnow.channellabel(end));
                                if isempty(ivnow.preamplnum) % in very early files the channellabel is only Voltage with no channel number..
                                    ivnow.preamplnum=1;
                                end
                                ivnow.recordingmode=rawdata(IDX).AmplifierMode{ivnow.preamplnum};
                                ivnow.AmplifierID=rawdata(IDX).AmplifierID{ivnow.preamplnum};
                                ivnow.sweepnum=seriesnums(seriesi,3);
                                ivnow.timertime=[rawdata(startIDX:IDX).timertime]';
                                ivnow.realtime=[rawdata(startIDX:IDX).realtime]';
                                ivnow.seriesname=rawdata(IDX).seriesname;
                                currdifi=diff(currents');
                                ivnow.time=[1:length(ivnow.v1)]'*si;
                                ivnow.segment=[diff(rawdata(IDX).segmenttimes)];
                                ivnow.segment=[ivnow.segment,ivnow.time(end)-sum(ivnow.segment)]*1000;
                                ivnow.holding=currents(1);
                                ivnow.realcurrent=currents(:,2);
                                ivnow.current=currdifi(1,:)';
                                iv.(['g',num2str(seriesnums(seriesi,1)),'_s',num2str(seriesnums(seriesi,2)),'_c',num2str(rawdata(IDX).tracenumber)])=ivnow;
                            end
                        end
                        
                        save([locations.tgtardir,savepathnow,'/',fname(1:end-4)],'iv');
                    end
                else
                    disp([fname,' tree file not found.. skipping'])
                    hiba=true;
                    if ~isfield(hiba_ok,'ans')
                        hiba_ok=HEKA_exporttreeinfo_main(hekafnames(i,:));
                    end
                        hiba_ok=hiba_ok.ans;
                end
            end
        end
    end
    if hiba
        
        hibasidxes=[hibasidxes,i];
        hibaok{length(hibasidxes)}=hiba_ok;
        disp(['error : ',hiba_ok])
    end
end
progressbar(1);
% %% zúúúzás - régi módi
% [locations]=marcicucca_locations;
% overwriteIVs=0;
% error=[];
% if ~exist('signature','var')
%     signature=round(rand(1)*10000);
% end
% if ~exist('lastsignature','var')
%     lastsignature=round(rand(1)*10000);
% end
% if ~exist('lastmodify','var')
%     lastmodify=0;
% end
% exportfnames={'preiv','postiv'};
%
% hcont_setPMconfig(signature,lastsignature,lastmodify);
%
% % hekawindir='/data/mount/PHYS44_WIN/Data/';
% savepath=['MATLABdata/IV'];
% % exportdir='/data/Userek/marci/analizis/HEKAdata/export/';
% exportdir=[locations.tgtardir,'ANALYSISdata/marci/Exportdir/'];
% winexportdir=[locations.tgtarwindir,'ANALYSISdata\marci\Exportdir\'];
%  savecounter=0;
% prevhekafname=[];
%     progressbar('overall progress','current file');
%
%
% for i=1:size(hekafnames,1)
%
%     if ~ischar(cell2mat(hekafnames(i,4)))
%     dirname=char(hekafnames(i,1));
%     windirname=dirname;
%     windirname(strfind(dirname,'/'))='\';
%     windirname=[locations.tgtarwindir,windirname(length(locations.tgtardir)+1:end)];
%     fname=char(hekafnames(i,2));
%     savepathnow=[savepath,dirname(strfind(dirname,'HEKAdata')+length('HEKAdata'):end)];
%     cd([locations.tgtardir,savepathnow]);
%     if isempty(dir([fname(1:end-4),'.mat'])) || overwriteIVs==1
%     %%%HEKA dat file bemásolása a windows mappába
% %     cd(hekawindir);
% %     delete('temp.*')
% %     disp(['copiing file: ',fname]);
% %     copyfile([dirname,'/',fname],[hekawindir,'temp.dat']);
% %     tempexts={'pgf','pul','amp'};
% %     cd(dirname);
% %     for tempextnum=1:length(tempexts)
% %         tempext=char(tempexts(tempextnum));
% %         tempname=[fname(1:end-3),tempext];
% %         if ~isempty(dir(tempname))
% %             copyfile([dirname,'/',tempname],[hekawindir,'temp.',tempext]);
% %         end
% %     end
%     %%%HEKA dat file bemásolása a windows mappába
%
%     %%%% file megnyitása és csekkolása
%
% %     order=['OpenFile read temp.dat'];
%     order=['OpenFile read ',windirname,'\',fname];
%     [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
%     pause(.2);
%     order='GetParameters DataFile';
%     [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
%     disp(fname);
%     order=['OpenOnlineFile "IVexport.onl"'];
%     [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
%     %%%% file megnyitása és csekkolása
%
%      [IVs,~]=hcont_findseriesbyname({'iv','IV'},{'pp','+'},signature,lastsignature,lastmodify);
%
%     iv=struct;
%     for tempi=1:size(IVs,1)
%         if IVs(tempi,3)>2
%             groupi=IVs(tempi,1);
%             seriesi=IVs(tempi,2);
%             for tracei=1:IVs(tempi,4)
%                 tracenum=1;
%                 pause(.1);
%                 order=['SetTarget 1 1 1 1 0 FALSE FALSE'];
%                 [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
%                 pause(.3);
%                 order=['Set R  UnmarkIt'];
%                 [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
%                 pause(.1);
%                 order=['SetTarget ',num2str(groupi),' ',num2str(seriesi),' 1 ',num2str(tracei),' 4 TRUE TRUE'];
%                 [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
%                 pause(.1);
%                 order=['SweepInfo']; % megnézzük, hogy milyen csatira van felvéve az IV
%                 [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
%                 tracenum=str2double(cell2mat(answer.ans(2+(tracei-1)*5)));
%                 order=['Set A  OA',num2str(tracenum),' TRUE'];
%                 [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
%
%                 order=['SetTarget ',num2str(groupi),' ',num2str(seriesi),' 1 ',num2str(tracenum),' 4 FALSE FALSE'];
%                 [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
%                 order=['Set A  OA',num2str(tracenum),' TRUE'];
%                 [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
%                 order=['SetTarget ',num2str(groupi),' ',num2str(seriesi),' 1 ',num2str(tracenum),' 2 FALSE FALSE'];
%                 [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
%                 pause(1);
% %                 temppath=hcont_convertpath(exportdir, 'heka');
%
%                 order=['Export overwrite "',winexportdir,'temp"'];
%                 [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
%                 pause(.1);
%                 [iv.(['g',num2str(groupi),'_s',num2str(seriesi),'_c',num2str(tracenum)]),isok]=hcont_readexportediv([exportdir,'temp.mat'],tracenum);
%                 if isok==0
%                     iv=rmfield(iv,['g',num2str(groupi),'_s',num2str(seriesi),'_c',num2str(tracenum)]);
%                     disp([['g',num2str(groupi),'_s',num2str(seriesi),'_c',num2str(tracenum)],'  torolve'])
%                 end
%             end
%         end
%         progressbar((i-1)/size(hekafnames,1),tempi/size(IVs,1));
%     end
%     save([locations.tgtardir,savepathnow,'/',fname(1:end-4)],'iv');
%     %end
%     order=['Set  @  File            "Close"'];
%     [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
%
%     end
%
%     end
%     progressbar((i-1)/size(hekafnames,1),0);
% end

