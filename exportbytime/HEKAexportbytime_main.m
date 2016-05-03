function rawdata=HEKAexportbytime_main(fname,setupname,channel,starttime,endtime)
% %%
% fname='1305031rm.dat';
% setupname='2P3DAO';
% channel=3;
% starttime=5.883148679743893E+04;
% endtime=6.370328935729154E+04;

%%
close all
locations=marcicucca_locations;
exportdir=[locations.tgtardir,'ANALYSISdata/marci/Exportdir/'];
winexportdir=[locations.tgtarwindir,'ANALYSISdata\marci\Exportdir\'];
windirname=[locations.tgtarwindir,'HEKAdata\',setupname];
treeinfodir=[locations.tgtardir,'MATLABdata/TreeData/',setupname];

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
hcont_setPMconfig(signature,lastsignature,lastmodify);
pause(.1);
hcont_setPMconfig(signature,lastsignature,lastmodify);
fnameold=fname;
vesszohely=strfind(fnameold,',');
rawdata=struct;
for filenumber=1:length(vesszohely)+1
    if isempty(vesszohely)
        fname=fnameold;
    else
        vesszohelyuj=[0,vesszohely,length(fnameold)+1];
        fname=fnameold(vesszohelyuj(filenumber)+1:vesszohelyuj(filenumber+1)-1);
    end
    a=dir([treeinfodir,'/',fname,'.mat']);
    
    
    order=['OpenOnlineFile "anyexport.onl"'];
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
    order=['OpenFile read ',windirname,'\',fname];
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
    pause(.2);
    order='GetParameters DataFile';
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
    disp(fname);
    if isempty(a)
        pause(1)
        [seriesnums,seriesdata]=hcont_findseriesbyname({},{},signature,lastsignature,lastmodify);
        save([treeinfodir,'/',fname,'.mat'],'seriesnums','seriesdata');
    else
        load([treeinfodir,'/',fname,'.mat']);
        
    end
    %%
    potentialtracenames{1}=['Vmon-',num2str(channel)];
    potentialtracenames{2}=['Imon-',num2str(channel)];
    if starttime<endtime
        potseriesnums=find([seriesdata.realtime]>=starttime & [seriesdata.realtime]<=endtime);
    else
        potseriesnums=find([seriesdata.realtime]>=starttime | [seriesdata.realtime]<=endtime);
    end
%     rawdata=struct;
    for i=1:length(potseriesnums)
        potsnum=potseriesnums(i);
        for tracenum=1:seriesnums(potsnum,4)
            tracename=char(seriesdata(potsnum).tracename(tracenum));
            if any(strcmp(tracename,potentialtracenames));
                groupnum=seriesnums(potsnum,1);
                seriesnum=seriesnums(potsnum,2);
                sweepdb=seriesnums(potsnum,3);
                
                epcfound=0;
                while epcfound==0
                    %%% tree info begyujtese
                    order='Set @  Notebook      "Clear"';
                    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                    pause(.1)
                    order=['SetTarget ',num2str(groupnum),' ',num2str(seriesnum),' ',num2str(1),' ',num2str(1),' 2 TRUE TRUE'];
                    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                    pause(.1)
                    order='Set @  Notebook      "Save"';
                    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                    pause(.5)
                    NotebookRaw=textread([exportdir,'Notebook_',date,'.txt'],'%s');
                    pause(.5)
                    amplsfound=0;
                    clear AmplifierID AmplifierMode Amplifierholding
                    for i=1:length(NotebookRaw)
                        if any(strfind(char(NotebookRaw(i)),'EPC'))
                            epcfound=1;
                            amplsfound=amplsfound+1;
                            temptext=char(NotebookRaw(i));
                            temptext(strfind(temptext,','))=[];
                            AmplifierID{amplsfound}=temptext;
                            temptext=char(NotebookRaw(i+1));
                            temptext(strfind(temptext,','))=[];
                            AmplifierMode{amplsfound}=temptext;
                            temptext=char(NotebookRaw(i+2));
                            temptext(strfind(temptext,','))=[];
                            Amplifierholding(amplsfound)=str2num(temptext);
                            
                        end
                    end
                end
                %%% tree info begyujtese
                
                order=['SetTarget ',num2str(groupnum),' ',num2str(seriesnum),' ',num2str(1),' ',num2str(1),' 2 TRUE TRUE'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                pause(.1);
                order=['Set A  OA',num2str(seriesdata(potsnum).tracenum(tracenum)),' TRUE'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                order=['Export overwrite "',winexportdir,'temp"'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                pause(.1);
                temp=load([exportdir,'temp']);
                segmenttime=[];
                segmentampl=[];
                for analnum=1:20
                    analname=['Analysis_',num2str(groupnum),'_',num2str(seriesnum),'_'];
                    if mod(analnum,2)==0;
                        if isfield(temp,([analname,num2str(analnum)])) % kókányolás egy hibás file miatt 1512082rm
                            segmenttime=[segmenttime,temp.([analname,num2str(analnum)])]; %csak ez a lényeg
                        else
                            analname=['Analysis_',num2str(groupnum),'_',num2str(seriesnum+1),'_'];% kókányolás egy hibás file miatt 1512082rm
                            segmenttime=[segmenttime,temp.([analname,num2str(analnum)])];% kókányolás egy hibás file miatt 1512082rm
                        end   % kókányolás egy hibás file miatt 1512082rm
                    else
                        if isfield(temp,([analname,num2str(analnum)])) % kókányolás egy hibás file miatt 1512082rm
                            segmentampl=[segmentampl,temp.([analname,num2str(analnum)])]; %csak ez a lényeg
                        else
                            analname=['Analysis_',num2str(groupnum),'_',num2str(seriesnum+1),'_'];% kókányolás egy hibás file miatt 1512082rm
                            segmentampl=[segmentampl,temp.([analname,num2str(analnum)])];% kókányolás egy hibás file miatt 1512082rm
                        end   % kókányolás egy hibás file miatt 1512082rm
                    end
                end
                for sweepnum=1:sweepdb
                    if isempty(fieldnames(rawdata))
                        NEXT=1;
                    else
                        NEXT=length(rawdata)+1;
                    end
                    segmentborders=[find(segmenttime(sweepnum,:)==0,1,'first'),find(segmenttime(sweepnum,:)>0,2,'last')];
                    if length(segmentborders)==3
                        segmentborders(3)=[];
                    end
                    rawdata(NEXT).segmenttimes=segmenttime(sweepnum,segmentborders(1):segmentborders(2));
                    rawdata(NEXT).segmentamplitudes=segmentampl(sweepnum,segmentborders(1):segmentborders(2));
                    rawdata(NEXT).seriesnums=seriesnums(potsnum,:);
                    rawdata(NEXT).channellabel=tracename;
                    rawdata(NEXT).tracenumber=seriesdata(potsnum).tracenum(tracenum);
                    rawdata(NEXT).realtime=segmenttime(sweepnum,end);
                    rawdata(NEXT).timertime=segmentampl(sweepnum,end);
                    if isfield(temp,(['Trace_',num2str(groupnum),'_',num2str(seriesnum),'_',num2str(sweepnum),'_',num2str(rawdata(NEXT).tracenumber)])) % kókányolás egy hibás file miatt 1512082rm
                        tempdata=temp.(['Trace_',num2str(groupnum),'_',num2str(seriesnum),'_',num2str(sweepnum),'_',num2str(rawdata(NEXT).tracenumber)]); %ez a lényeg
                    else % kókányolás egy hibás file miatt 1512082rm
                        tempdata=temp.(['Trace_',num2str(groupnum),'_',num2str(seriesnum+1),'_',num2str(sweepnum),'_',num2str(rawdata(NEXT).tracenumber)]);  % kókányolás egy hibás file miatt 1512082rm
                    end % kókányolás egy hibás file miatt 1512082rm
                    rawdata(NEXT).y=tempdata(:,2)';
                    rawdata(NEXT).si=mode(diff(tempdata(:,1)));
                    rawdata(NEXT).AmplifierID=AmplifierID;
                    rawdata(NEXT).AmplifierMode=AmplifierMode;
                    rawdata(NEXT).Amplifierholding=Amplifierholding;
                    %                 disp(AmplifierMode)
                end
            end
        end
    end
end