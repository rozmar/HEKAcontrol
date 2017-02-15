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
    answer.ans{1,2}=[];
    while ~strcmp(['"',windirname,'\',fname,'.dat"'],answer.ans{1,2})
    order=['OpenFile read ',windirname,'\',fname];
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
    pause(3);
    order='GetParameters DataFile';
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
    pause(3);
    disp(['file needed: ',windirname,'\',fname,'.dat   file opened: ',answer.ans{1,2}]);
    end
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
                readbinaryfileaswell=1; % for the first sweep the length of the sweep is checked
                for sweepnum=1:sweepdb    
                    %%
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
                    %%
                    if readbinaryfileaswell==1
                        order=['SetTarget ',num2str(groupnum),' ',num2str(seriesnum),' ',num2str(sweepnum),' ',num2str(1),' 3  TRUE TRUE'];
                        [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                        order=['SweepInfoExt'];
                        [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                        tracedb=(length(answer.ans)-3)/12;
                        tracenums=[];
                        for tracedbi=1:tracedb
                            tracenumtemp=answer.ans{(tracedbi-1)*12+4};
                            tracenumtemp(tracenumtemp==',' |tracenumtemp==';')=[];
                            tracenums(tracedbi)=str2num(tracenumtemp);
                        end
                        tracenumidx=find(tracenums==rawdata(NEXT).tracenumber);
                        offsetfrombeginningoffileinbytes=answer.ans{12*(tracenumidx-1)+10};
                        offsetfrombeginningoffileinbytes(offsetfrombeginningoffileinbytes==',' |offsetfrombeginningoffileinbytes==';')=[];
                        offsetfrombeginningoffileinbytes=str2num(offsetfrombeginningoffileinbytes);
                        datalength=answer.ans{12*(tracenumidx-1)+5};
                        datalength(datalength==',' |datalength==';')=[];
                        datalength=str2num(datalength);
                        datafactor=answer.ans{12*(tracenumidx-1)+7};
                        datafactor(datafactor==',' |datafactor==';')=[];
                        datafactor=str2num(datafactor);
                        datatype=answer.ans{12*(tracenumidx-1)+13};
                        datatype(datatype==',' |datatype==';')=[];
                        datatype=str2num(datatype);
                        
                        
                        
                        if datatype==0
                            datatypestr='int16';
                            byteszorzo=1;
                        elseif datatype==1
                            datatypestr='int32';
                            byteszorzo=2;
                        elseif datatype==2
                            datatypestr='float32';
                            byteszorzo=2;
                        elseif datatype==3
                            datatypestr='float64';
                            byteszorzo=3;
                        end
                        
                        interleaveblocksize=answer.ans{12*(tracenumidx-1)+11};
                        interleaveblocksize(interleaveblocksize==',' |interleaveblocksize==';')=[];
                        interleaveblocksize=str2num(interleaveblocksize);
                        
                        interleaveskipbytes=answer.ans{12*(tracenumidx-1)+12};
                        interleaveskipbytes(interleaveskipbytes==',' |interleaveskipbytes==';')=[];
                        interleaveskipbytes=str2num(interleaveskipbytes);
                        
                        
                        endiantype=answer.ans{12*(tracenumidx-1)+14};
                        endiantype(endiantype==',' |endiantype==';')=[];
                        endiantype=str2num(endiantype);
                        if endiantype==0
                            endiantypestr='b';
                        else
                            endiantypestr='l';
                        end
                        if size(tempdata,1)<datalength | sweepnum>1 % if the first sweep is well exported it won't go sweep by sweep, the data is exported from the binary file if there is a length mismatch
                            disp(['group:',num2str(groupnum),' series:',num2str(seriesnum),' sweep:',num2str(sweepnum),'  is exported from binary - probably a continuous trace']);
                            %%
                            readedfrombinary=[];
                            fileID = fopen([locations.tgtardir,'HEKAdata/',setupname,'/',fname,'.dat'],'r',endiantypestr);
                            fseek(fileID,offsetfrombeginningoffileinbytes,'bof');
                            if interleaveblocksize>0
                                while length(readedfrombinary)<datalength
                                    readedfrombinary=[readedfrombinary;fread(fileID, min(interleaveblocksize/2^(byteszorzo),datalength- length(readedfrombinary)),datatypestr)*datafactor];
                                    fseek(fileID,(interleaveskipbytes-interleaveblocksize),'cof');
%                                     plot(readedfrombinary)%[1:datalength]*mode(diff(tempdata(:,1))),
                                    %                              pause
                                end
                            else
                                readedfrombinary=[fread(fileID, datalength- length(readedfrombinary),datatypestr)*datafactor];
                            end
                            fclose(fileID);
                            rawdata(NEXT).y=readedfrombinary';
                            figure(3)
                            clf
                            plot([1:datalength]*mode(diff(tempdata(:,1))),readedfrombinary)%
                            %%
%                             pause
                        else
                            rawdata(NEXT).y=tempdata(:,2)';
                            readbinaryfileaswell=0;
                        end
                    else
                        rawdata(NEXT).y=tempdata(:,2)';
                    end
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