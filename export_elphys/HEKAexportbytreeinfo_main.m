function rawdata=HEKAexportbytreeinfo_main(fname,setupname,seriesnums,seriesdata,neededseriesnums)

if any(strfind(fname,'.dat'))
    fname(strfind(fname,'.dat'):end)=[];
end
% %%
% fname='1305031rm.dat';
% setupname='2P3DAO';
% channel=3;
% starttime=5.883148679743893E+04;
% endtime=6.370328935729154E+04;

locations=marcicucca_locations;
exportdir=[locations.tgtardir,'ANALYSISdata/marci/Exportdir/'];
winexportdir=[locations.tgtarwindir,'ANALYSISdata\marci\Exportdir\'];
windirname=[locations.tgtarwindir,'HEKAdata\',setupname];

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
rawdata=struct;

pause(1)
order=['OpenOnlineFile "anyexport.onl"'];
[answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
order='GetParameters DataFile';
[answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
if isfield(answer,'ans') && length(answer.ans)>2 && any(strfind(answer.ans{2},fname))
    disp(['file already open, exporting by tree info from : ' ,fname]);
else
    order=['OpenFile read ',windirname,'\',fname];
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
    pause(1);
    order='GetParameters DataFile';
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
    disp(['exporting by tree info from : ' ,fname]);
end
%%
%     rawdata=struct;
for i=1:length(neededseriesnums)
    potsnum=neededseriesnums(i);
    for tracenum=1:seriesnums(potsnum,4)
        tracename=char(seriesdata(potsnum).tracename(tracenum));
        groupnum=find(unique(seriesnums(:,1))==seriesnums(potsnum,1));%if a group was deleted, this is how you find its index.. old one:%seriesnums(potsnum,1);
        seriesnum=find(seriesnums(seriesnums(:,1)==seriesnums(potsnum,1),2)==seriesnums(potsnum,2));%if a series was deleted, this is how you find its index.. old one:%seriesnums(potsnum,2);
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
            for notebooki=1:length(NotebookRaw)
                if any(strfind(char(NotebookRaw(notebooki)),'EPC'))
                    epcfound=1;
                    amplsfound=amplsfound+1;
                    temptext=char(NotebookRaw(notebooki));
                    temptext(strfind(temptext,','))=[];
                    AmplifierID{amplsfound}=temptext;
                    temptext=char(NotebookRaw(notebooki+1));
                    temptext(strfind(temptext,','))=[];
                    AmplifierMode{amplsfound}=temptext;
                    temptext=char(NotebookRaw(notebooki+2));
                    temptext(strfind(temptext,','))=[];
                    Amplifierholding(amplsfound)=str2num(temptext);
                end
            end
        end
        %%% tree info begyujtese
        %%
        order=['SetTarget ',num2str(groupnum),' ',num2str(seriesnum),' ',num2str(1),' ',num2str(1),' 2 TRUE TRUE'];
        [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
        pause(.1);
        order=['Set A  OA',num2str(seriesdata(potsnum).tracenum(tracenum)),' TRUE'];
        [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
        order=['Export overwrite "',winexportdir,'temp"'];
        [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
        pause(.1);
        temp=load([exportdir,'temp']);
        exportbinaryfromallsweeps=0;
        %%
        if length(fieldnames(temp))<2 % in  case of bug only first trace is exported workaround comes here
            %%
            while length(fieldnames(temp))<2
                fieldnev=fieldnames(temp);
                si=mode(diff(temp.(fieldnev{1})(:,1)));
                order=['Get  @  ExportMode      "Traces"'];
                if isfield(answer,'ans')
                    answer=rmfield(answer,'ans');
                end
                while ~isfield(answer,'ans') | ~any(cell2mat(strfind(answer.ans, 'Not')))
                    if ~isfield(answer,'ans')
                        order=['Set  @  ExportMode      "Traces"'];
                        [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                        order=['Get  @  ExportMode      "Traces"'];
                    end
                    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                end
                %%
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                order=['Export overwrite "',winexportdir,'temp"'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                pause(.1);
                temp=load([exportdir,'temp']);
            end
            %%
            temptest=temp;
            while length(fieldnames(temptest))>2
                order=['Get  @  ExportMode      "Traces"'];
                if isfield(answer,'ans')
                    answer=rmfield(answer,'ans');
                end
                while ~isfield(answer,'ans') | any(cell2mat(strfind(answer.ans, 'Not')))
                    if ~isfield(answer,'ans')
                        order=['Set  @  ExportMode      "Traces"'];
                        [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                        order=['Get  @  ExportMode      "Traces"'];
                    end
                    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                end
                %%
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                order=['Export overwrite "',winexportdir,'temp"'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                pause(.1);
                temptest=load([exportdir,'temp']);
            end
            exportbinaryfromallsweeps=1;
        end
        
        segmenttime=[];
        segmentampl=[];
        %%
        fieldnamek=fieldnames(temp);
        fieldname=fieldnamek{1};
        hyps=strfind(fieldname,'_');
        groupnum_for_export=str2num(fieldname(hyps(1)+1:hyps(2)-1));
        seriesnum_for_export=str2num(fieldname(hyps(2)+1:hyps(3)-1));
        if groupnum_for_export~=groupnum
            disp(['group number mismatch - using the exported: ',num2str(groupnum_for_export),' vs the original: ',num2str(groupnum)]);
        end
        if seriesnum_for_export~=seriesnum
            disp(['series number mismatch - using the exported: ',num2str(seriesnum_for_export),' vs the original: ',num2str(seriesnum)]);
        end
%%
        for analnum=1:21
            analname=['Analysis_',num2str(groupnum_for_export),'_',num2str(seriesnum_for_export),'_'];
            if mod(analnum,2)==0;
                segmenttime=[segmenttime,temp.([analname,num2str(analnum)])];
            else
                segmentampl=[segmentampl,temp.([analname,num2str(analnum)])];
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
                    rawdata(NEXT).timertime=segmentampl(sweepnum,end-1);
                    rawdata(NEXT).bridgedRS=segmentampl(sweepnum,end);
                    if exportbinaryfromallsweeps==0
                        tempdata=temp.(['Trace_',num2str(groupnum),'_',num2str(seriesnum),'_',num2str(sweepnum),'_',num2str(rawdata(NEXT).tracenumber)]); %ez a lényeg
                        si=mode(diff(tempdata(:,1)));
                    else % if there is a bug, there is no Trace field
                        tempdata=[];
                    end
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
                        if exportbinaryfromallsweeps==1 | size(tempdata,1)<datalength | sweepnum>1 % if the first sweep is well exported it won't go sweep by sweep, the data is exported from the binary file if there is a bug (see above) or a length mismatch
                            disp(['group:',num2str(groupnum),' series:',num2str(seriesnum),' sweep:',num2str(sweepnum),'  is exported from binary - probably a continuous trace']);
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
                            plot([1:datalength]*si,readedfrombinary)%
                        else
                            rawdata(NEXT).y=tempdata(:,2)';
                            readbinaryfileaswell=0;
                        end
                    else
                        rawdata(NEXT).y=tempdata(:,2)';
                    end
                    rawdata(NEXT).si=si;
                    rawdata(NEXT).AmplifierID=AmplifierID;
                    rawdata(NEXT).AmplifierMode=AmplifierMode;
                    rawdata(NEXT).Amplifierholding=Amplifierholding;
                end
        
%         for sweepnum=1:sweepdb
%             if isempty(fieldnames(rawdata))
%                 NEXT=1;
%             else
%                 NEXT=length(rawdata)+1;
%             end
%             segmentborders=[find(segmenttime(sweepnum,:)==0,1,'first'),find(segmenttime(sweepnum,:)>0,2,'last')];
%             if length(segmentborders)==3
%                 segmentborders(3)=[];
%             end
%             rawdata(NEXT).segmenttimes=segmenttime(sweepnum,segmentborders(1):segmentborders(2));
%             rawdata(NEXT).segmentamplitudes=segmentampl(sweepnum,segmentborders(1):segmentborders(2));
%             rawdata(NEXT).seriesnums=seriesnums(potsnum,:);
%             rawdata(NEXT).channellabel=tracename;
%             rawdata(NEXT).tracenumber=seriesdata(potsnum).tracenum(tracenum);
%             rawdata(NEXT).seriesname=seriesdata(potsnum).seriesname;
%             rawdata(NEXT).realtime=segmenttime(sweepnum,end);
%             rawdata(NEXT).timertime=segmentampl(sweepnum,end);
%             tempdata=temp.(['Trace_',num2str(groupnum),'_',num2str(seriesnum),'_',num2str(sweepnum),'_',num2str(rawdata(NEXT).tracenumber)]);
%             rawdata(NEXT).y=tempdata(:,2)';
%             rawdata(NEXT).si=mode(diff(tempdata(:,1)));
%             rawdata(NEXT).AmplifierID=AmplifierID;
%             rawdata(NEXT).AmplifierMode=AmplifierMode;
%             rawdata(NEXT).Amplifierholding=Amplifierholding;
%         end
    end
end