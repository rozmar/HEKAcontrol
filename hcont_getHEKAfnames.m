%% nevek es datumok becuppantasa

hekafiledirs={'/media/gtamas/Elements/HEKAdata'};
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
            if length(temp(j).name)>9
                hekafnames{tempdb,4}=datenum(temp(j).name(1:6),'yymmdd');
                hekafnames{tempdb,5}=abs(cell2mat(hekafnames(tempdb,3))-cell2mat(hekafnames(tempdb,4)));
            else
                hekafnames{tempdb,4}='NaN';
                hekafnames{tempdb,5}=0;
            end
        end
    end
end
%% jok-e az idok:
timediff=[];
for tempi=1:size(hekafnames,1)
    
end
%% valogatas
badnames={};
all=[];
setup.twoptg1=[];
setup.twoptg2=[];
setup.twop3dao=[];
setup.setup1=[];
setup.setup2=[];
experimenter.cs=[];
experimenter.rm=[];
experimenter.s=[];
experimenter.j=[];
experimenter.mg=[];
experimenter.fm=[];
experimenter.ls=[];
experimenter.ls=[];
experimenter.unknown=[];
for i=1:size(hekafnames,1)
    neededdate=cell2mat(hekafnames(i,4));
    neededdate2=cell2mat(hekafnames(i,3));
    if ischar(neededdate)
        neededdate=str2num(neededdate);
    end
    if isnan(neededdate);
        badnames(length(badnames)+1)=hekafnames(i,2);
    end
    
    if any(strfind(char(hekafnames(i,1)),'Setup-1'));
        setup.setup1(size(setup.setup1,1)+1,1)=neededdate;
        setup.setup1(size(setup.setup1,1),2)=neededdate2;
        all(size(all,1)+1,1)=neededdate;
        all(size(all,1),2)=neededdate2;
    elseif any(strfind(char(hekafnames(i,1)),'Setup-2'));
        setup.setup2(size(setup.setup2,1)+1,1)=neededdate;
        setup.setup2(size(setup.setup2,1),2)=neededdate2;
        all(size(all,1)+1,1)=neededdate;
        all(size(all,1),2)=neededdate2;
    elseif any(strfind(char(hekafnames(i,1)),'2PTG-1'));
        setup.twoptg1(size(setup.twoptg1,1)+1,1)=neededdate;   
        setup.twoptg1(size(setup.twoptg1,1),2)=neededdate2;
        all(size(all,1)+1,1)=neededdate;
        all(size(all,1),2)=neededdate2;
    elseif any(strfind(char(hekafnames(i,1)),'2PTG-2'));
        setup.twoptg2(size(setup.twoptg2,1)+1,1)=neededdate;
        setup.twoptg2(size(setup.twoptg2,1),2)=neededdate2;
        all(size(all,1)+1,1)=neededdate;
        all(size(all,1),2)=neededdate2;
    elseif any(strfind(char(hekafnames(i,1)),'2P3DAO'));
        setup.twop3dao(size(setup.twop3dao,1)+1,1)=neededdate;
        setup.twop3dao(size(setup.twop3dao,1),2)=neededdate2;
        all(size(all,1)+1,1)=neededdate;
        all(size(all,1),2)=neededdate2;
    end
    
    
    if isempty(cell2mat(hekafnames(i,2)))
    else
        fname=cell2mat(hekafnames(i,2));
        fname=char(fname);
        fname=fname(1:end-4);
        if any(strfind(fname,'cst'))
        elseif any(strfind(fname,'ls'))
            experimenter.ls(length(experimenter.ls)+1)=neededdate;
        elseif any(strfind(fname,'mg'))
            experimenter.mg(length(experimenter.mg)+1)=neededdate;
        elseif any(strfind(fname,'fm'))
            experimenter.fm(length(experimenter.fm)+1)=neededdate;
        elseif any(strfind(fname,'noe'))
        elseif any(strfind(fname,'cs'))
            experimenter.cs(length(experimenter.cs)+1)=neededdate;
        elseif any(strfind(fname,'rm'))
            experimenter.rm(length(experimenter.rm)+1)=neededdate;
        elseif any(strfind(fname,'szv'))
        elseif any(strfind(fname,'kg'))
        elseif any(strfind(fname,'e'))
        elseif any(strfind(fname,'pi'))
        elseif any(strfind(fname,'s'))
            experimenter.s(length(experimenter.s)+1)=neededdate;
        elseif any(strfind(fname,'j'))
            experimenter.j(length(experimenter.j)+1)=neededdate;
        else
            experimenter.unknown(length(experimenter.unknown)+1)=neededdate;
        end
    end
end

%% plottolas
startdate='01-Jan-1999';
enddate='01-Dec-2013';
napatlag=31;
setups=fieldnames(setup);

figure;
tohist=all;
subplot(3,1,1)
%hist(tohist(:,1),(max(tohist(:,1))-min(tohist(:,1))/napatlag),'b')
hist(tohist(:,1),datenum(startdate):napatlag:datenum(enddate))
xlim([datenum(startdate) datenum(enddate)]);
datetick('x','yy-mmm-dd','keepticks')
title('all')
tempy1=get(gca,'Ylim');
tempx1=get(gca,'Xlim');
subplot(3,1,2)
hist(tohist(:,2),datenum(startdate):napatlag:datenum(enddate))
xlim([datenum(startdate) datenum(enddate)]);
datetick('x','yy-mmm-dd','keepticks')
title('all')
tempy2=get(gca,'Ylim');
tempx2=get(gca,'Xlim');
subplot(3,1,3)
plot(tohist(:,1),tohist(:,2),'o');
datetick('x','yy-mmm-dd','keepticks')
datetick('y','yy-mmm-dd','keepticks')

for tempi=1:length(setups)
    setupname=char(setups(tempi));
    
    figure;
    tohist=setup.(setupname);
    subplot(3,1,1)
    hist(tohist(:,1),datenum(startdate):napatlag:datenum(enddate))
    xlim([datenum(startdate) datenum(enddate)]);
    datetick('x','yy-mm-dd','keepticks')
    title(['setup: ',setupname]);
    set(gca,'xlim',tempx1);
    set(gca,'ylim',tempy1);
    subplot(3,1,2)
    hist(tohist(:,2),datenum(startdate):napatlag:datenum(enddate))
    xlim([datenum(startdate) datenum(enddate)]);
    datetick('x','yy-mm-dd','keepticks')
    title(['setup: ',setupname]);
    set(gca,'xlim',tempx2);
    set(gca,'ylim',tempy2);
    subplot(3,1,3)
    plot(tohist(:,1),tohist(:,2),'o');
    datetick('x','yy-mmm-dd','keepticks')
    datetick('y','yy-mmm-dd','keepticks')
    
end
%% pipöl
experimenters={'s','j','mg','cs','rm','ls','unknown'};

napatlag=1;
figure;
hist(all,(max(all)-min(all))/napatlag);
% xlim([datenum('01-Jan-1999') datenum('01-Dec-2013')]);
datetick('x','yy-mm-dd','keepticks')
title('all')
%ylim([0 max(tempa)]);
tempy=get(gca,'Ylim');
tempx=get(gca,'Xlim');

for tempi=1:length(experimenters)
    exp=char(experimenters(tempi));
figure;
hist(experimenter.(exp),(max(experimenter.(exp))-min(experimenter.(exp)))/napatlag)
% xlim([datenum('01-Jan-1999') datenum('01-Dec-2013')]);
datetick('x','yy-mmm-dd','keepticks')
title(['experimenter: ',exp]);
set(gca,'xlim',tempx);
set(gca,'ylim',tempy);
end

