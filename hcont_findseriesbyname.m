function [IVs,names]=hcont_findseriesbyname(potentialnames,excludenames,signature,lastsignature,lastmodify)
IVs=[];
names=struct;
%potentialnames={'iv','IV'};
%excludename={'pp'};
order='GetChildren 1 1 1 1 0';
[answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
groupnum=str2double(cell2mat(answer.ans(2)));
for groupi=1:groupnum;
    order=['GetChildren ',num2str(groupi),' 1 1 1 1'];
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
    seriesnum=str2double(cell2mat(answer.ans(2)));
    for seriesi=1:seriesnum
        order=['GetLabel ',num2str(groupi),' ',num2str(seriesi),' 1 1 2'];
        [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
        goon=0;
        
        if iscell(potentialnames)
            for tempii=1:length(potentialnames)
                nameneeded=char(potentialnames(tempii));
                if any(strfind(char(answer.ans(2)),nameneeded));
                    goon=1;
                end
            end
        else
            if any(strfind(char(answer.ans(2)),potentialnames))
                goon=0;
            end
        end
        if isempty(potentialnames)
            goon=1;
        end
        if iscell(excludenames)
            for tempiii=1:length(excludenames)
                if any(strfind(char(answer.ans(2)),char(excludenames(tempiii))))
                    goon=0;
                end
            end
        else
            if any(strfind(char(answer.ans(2)),excludenames))
                goon=0;
            end
        end
        
        if goon==1;
            IVs(size(IVs,1)+1,1)=groupi;
            IVs(size(IVs,1),2)=seriesi;
            ttemp=char(answer.ans(2));
            ttemp(strfind(ttemp,''''))=[];
            ttemp(strfind(ttemp,','))=[];
            ttemp(strfind(ttemp,';'))=[];
            ttemp(strfind(ttemp,'"'))=[];
            names(size(IVs,1)).seriesname=ttemp;
            order=['GetChildren ',num2str(groupi),' ',num2str(seriesi),' 1 1 2'];
            [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
            IVs(size(IVs,1),3)=str2double(cell2mat(answer.ans(2)));
            order=['GetChildren ',num2str(groupi),' ',num2str(seriesi),' 1 1 3'];
            [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
            IVs(size(IVs,1),4)=str2double(cell2mat(answer.ans(2)));
            
            for channelnum=1:IVs(size(IVs,1),4);
                order=['GetLabel ',num2str(groupi),' ',num2str(seriesi),' 1 ',num2str(channelnum),' 4'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                ttemp=char(answer.ans(2));
                ttemp(strfind(ttemp,''''))=[];
                ttemp(strfind(ttemp,','))=[];
                ttemp(strfind(ttemp,';'))=[];
                ttemp(strfind(ttemp,'"'))=[];
                names(size(IVs,1)).tracename{channelnum}=ttemp;
                order=['SetTarget ',num2str(groupi),' ',num2str(seriesi),' 1 ',num2str(channelnum),' 2 FALSE FALSE'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                order=['SetTarget ',num2str(groupi),' ',num2str(seriesi),' 1 ',num2str(channelnum),' 3 FALSE FALSE'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                order=['SetTarget ',num2str(groupi),' ',num2str(seriesi),' 1 ',num2str(channelnum),' 4 TRUE FALSE'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
%                 pause(.3);
                order=['SweepInfo']; % megnézzük, hogy milyen csatira van felvéve az IV
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                names(size(IVs,1)).tracenum(channelnum)=str2double(cell2mat(answer.ans(2+(channelnum-1)*5)));
%                 tttemp=char(names(size(IVs,1)).tracename(channelnum));
%                 if ~(names(size(IVs,1)).tracenum(channelnum)==str2num(tttemp(end)))
%                     pause
%                     disp('asdasdasdasdsa');
%                 else
%                     disp([names(size(IVs,1)).tracenum(channelnum),str2num(tttemp(end))])
%                 end
            end

            order=['SetTarget ',num2str(groupi),' ',num2str(seriesi),' 1 1 3 TRUE TRUE'];
            [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
            pause(.1);
            order='GetParameters SweepTime';
            [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
            rawtime=char(answer.ans(2));
            dodots=strfind(rawtime,':');
            dot=strfind(rawtime,'.');
            time=str2num(rawtime(1:dodots(1)-1))*3600+str2num(rawtime(dodots(1)+1:dodots(2)-1))*60+str2num(rawtime(dodots(2)+1:end));
            names(size(IVs,1)).realtime=time;

        end
    end
end