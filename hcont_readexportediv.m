function [iv,isok]=hcont_readexportediv(fullname,tracenum)
isok=1;
% fullname=hcont_convertpath(fullname, 'm');

%fullname=[exportdir,fname(1:end-4),'_',num2str(groupi),'_',num2str(seriesi),'_',num2str(tracenum),'.mat'];

temp=load(fullname); 
tempnames=fieldnames(temp);
sweepnum=0;
for i=1:length(tempnames)
    sweepname=char(tempnames(i));
    tempsepar=strfind(sweepname,'_');
    if strfind(sweepname,'Trace')
        tempp=temp.(sweepname);
        if str2double(sweepname(tempsepar(4)+1:end))==tracenum
            sweep=str2double(sweepname(tempsepar(3)+1:tempsepar(4)-1));
            iv.(['v',num2str(sweep)])(:,1)=tempp(:,2);
            sweepnum=sweepnum+1;
            sampleinterval=tempp(3,1)-tempp(2,1);
            hossz=size(tempp,1);
            if ~isfield(iv, 'time')
                iv.time=tempp(:,1);
                firsttime=iv.time(1);
            end
        end

    elseif strfind(sweepname,'Analysis')
        analnum=str2double(sweepname(tempsepar(3)+1:end));
        tempp=temp.(sweepname);
        if analnum==1
            iv.holding=round(tempp(1)*1000000000000);
        elseif analnum==2
            iv.realcurrent=round(tempp*1000000000000);
        elseif analnum==3
            iv.segment(1)=tempp(1)*1000;
        elseif analnum==4
            iv.segment(2)=tempp(1)*1000;
        elseif analnum==5
            iv.segment(3)=tempp(1)*1000;
        elseif analnum==6
            iv.timertime=tempp;
        end
    end
end
if exist('iv','var') & isfield(iv,'realcurrent')
    iv.current=iv.realcurrent-iv.holding;
    iv.sweepnum=sweepnum;
    iv.segment(1)=iv.segment(1)+iv.time(end)*1000-sum(iv.segment);
else
    isok=0;
    iv=[];
end

end