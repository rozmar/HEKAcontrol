function HEKA_exportIVs_main(missingfiles)
%HEKA_exportIVs_main.m uses batch communication to control a Fitmaster
%instance and import .dat elphys files to matlab. With the missingfiles
%argument the user can export IVs only selected files.
% The main exporting script is HEKAexportbytreeinfo_main.m
if nargin<1
    missingfiles={};
    overwriteIVs=0;
else
    overwriteIVs=1;
end

% clear all
FaultyFileList={'1709051og.dat','1707061og.dat','1707041og.dat','1706272oa.dat','1705201og.dat','1707311ma.dat','1609211kb.dat','0512151mga2.dat','0512052mga2.dat','0512051mga2.dat','0512023mga2.dat','0511222mga2.dat','0511221mga2.dat','0511241cs.dat','0511212mga2.dat','0511221cs.dat','0511182mga2.dat','0511171mga2.dat','0511151mga2.dat','0312172ja2.dat','0511181mga2.dat','0511161mga2.dat','0511142mga2.dat','0403051ja2.dat','0402021ja2.dat','0511172mga2.dat','0511152mga2.dat','0511141mga2mga2.dat','0511113mga2.dat','0509072s.dat','0507081j.dat','0311073j.dat','0310093j.dat','0309292j.dat','1702103og.dat','1411121kb.dat','140223001br.dat','1105161ls.dat','1611042kb.dat','1610141kb.dat','1610043kb.dat','1610031kb.dat','1609211kb.dat','1606291kb.dat','1606172kb.dat','1606091kb.dat','1604211og.dat','1607251og.dat','1610291og.dat','1608122og.dat','1611041og.dat','1610252og.dat','1509112og.dat','1510022og.dat','1608022oa.dat','1609072oa.dat','1610202oa.dat'};
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
%% export

potentialnames={'iv','IV','Long square','long square','Long Square','Long','long'};
excludename={'pp','+'};
[locations]=marcicucca_locations;

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
            if (isempty(missingfiles) | any(strcmp([fname(1:end-4)],missingfiles))) & (isempty(exporteda) || overwriteIVs==1 || exporteda.bytes<5000) 
                a=dir([locations.tgtardir,treepath,'/',setupname,'/',fname(1:end-4),'.mat']);
                hiba_ok=struct;
                while isempty(a) & ~isfield(hiba_ok,'ans')
                    hiba_ok=HEKA_exporttreeinfo_main(hekafnames(i,:));
                    a=dir([locations.tgtardir,treepath,'/',setupname,'/',fname(1:end-4),'.mat']);
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
%%
                        iv=struct;
                        IDX=0;
                        %%
                        for seriesii=1:length(neededseriesnums)
                            seriesi=neededseriesnums(seriesii);
                            for channeli=1:seriesnums(seriesi,4)
                                ivnow=struct;
                                
                                startIDX=IDX+1;
                                si=rawdata(startIDX).si;
                                currents=[];
                                %%
                                for sweepnum=1:seriesnums(seriesi,3)
                                    IDX=IDX+1;
                                    ivnow.realtime=rawdata(IDX).realtime;
                                    ivnow.timertime=rawdata(IDX).timertime;
                                    ivnow.(['v',num2str(sweepnum)])=rawdata(IDX).y';
                                    currents(sweepnum,:)=round(rawdata(IDX).segmentamplitudes*10^12);
                                end
                                %%
                                ivnow.channellabel=rawdata(IDX).channellabel;
                                ivnow.preamplnum=str2num(ivnow.channellabel(end));
                                if isempty(ivnow.preamplnum) |  ivnow.preamplnum==0% in very early files the channellabel is only Voltage with no channel number..
                                    ivnow.preamplnum=1;
                                end
                                ivnow.recordingmode=rawdata(IDX).AmplifierMode{ivnow.preamplnum};
                                ivnow.AmplifierID=rawdata(IDX).AmplifierID{ivnow.preamplnum};
                                ivnow.sweepnum=seriesnums(seriesi,3);
                                ivnow.timertime=[rawdata(startIDX:IDX).timertime]';
                                ivnow.realtime=[rawdata(startIDX:IDX).realtime]';
                                ivnow.bridgedRS=[rawdata(startIDX:IDX).bridgedRS]';
%                                 ivnow.seriesname=rawdata(IDX).seriesname;
%%
                                currdifi=diff(currents');
                                if size(currents,1)==1
                                    segmentwithcurrinj=find(currdifi(:,1)~=0,1,'first')+1;
                                else
                                    segmentwithcurrinj=find(currents(1,:)~=currents(2,:),1,'first');
                                    if segmentwithcurrinj==1 %% hotfix due to error in HEKA... can be removed
                                       segmentwithcurrinj=find(currents(2,:)~=currents(3,:),1,'first');
                                    end
                                end
                                ivnow.time=[1:length(ivnow.v1)]'*si;
                                ivnow.segment=[diff(rawdata(IDX).segmenttimes)];
                                %%
                                ivnow.segment=[ivnow.segment,ivnow.time(end)-sum(ivnow.segment)]*1000;
                                %%
                                ivnow.segment=[sum(ivnow.segment(1:segmentwithcurrinj-1)),ivnow.segment(segmentwithcurrinj:end)];
                                ivnow.holding=currents(1,segmentwithcurrinj-1);
                                ivnow.realcurrent=currents(:,segmentwithcurrinj);
                                ivnow.current=currdifi(segmentwithcurrinj-1,:)';
                                iv.(['g',num2str(seriesnums(seriesi,1)),'_s',num2str(seriesnums(seriesi,2)),'_c',num2str(rawdata(IDX).tracenumber)])=ivnow;
                            end
                        end
                        save([locations.tgtardir,savepathnow,'/',fname(1:end-4)],'iv');

                    end
                else
                    disp([fname,' tree file not found.. skipping'])
                    hiba=true;
                    hiba_ok=hiba_ok.ans{1};
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