%% alapváltozók legyártása

if ~exist('signature','var')
    signature=round(rand(1)*10000);
end
if ~exist('lastsignature','var')
    lastsignature=round(rand(1)*10000);
end
if ~exist('lastmodify','var')
    lastmodify=0;
end

filedir='x:\marci\analizis\HEKAdata\';
exportdir='x:\marci\analizis\HEKAdata\export\';


fname='1209085rm.dat';
%% file megnyitása és csekkolása
order=['OpenFile read ',filedir,fname];
[answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
order='GetParameters DataFile';
[answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
if ~any(strfind( char(answer.ans(2)),fname))
    disp('Nem azt a filet nyitotta meg, amit meg kellett volna...')
else
    disp('file opened');
end
%% series keresése
IVs=[];
potentialnames={'iv','IV'};
clear groupnum seriesnum  sweepnum tracenum groupi seriesi
order='GetChildren 1 1 1 1 0';
[answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
groupnum=str2double(cell2mat(answer.ans(2)));
for groupi=1:groupnum;
    order=['GetChildren 1 ',num2str(groupi),' 1 1 1'];
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
    seriesnum=str2double(cell2mat(answer.ans(2)));
    for seriesi=1:seriesnum
        order=['GetLabel ',num2str(groupi),' ',num2str(seriesi),' 1 1 2'];
        [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
        for tempii=1:length(potentialnames)
            nameneeded=char(potentialnames(tempii));
            if strfind(char(answer.ans(2)),nameneeded);
                IVs(size(IVs,1)+1,1)=groupi;
                IVs(size(IVs,1),2)=seriesi;
                order=['GetChildren ',num2str(groupi),' ',num2str(seriesi),' 1 1 2'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                IVs(size(IVs,1),3)=str2double(cell2mat(answer.ans(2)));
                order=['GetChildren ',num2str(groupi),' ',num2str(seriesi),' 1 1 3'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                IVs(size(IVs,1),4)=str2double(cell2mat(answer.ans(2)));
            end
        end
    end
end
%% exportáláshoz beállítások
hcont_setPMconfig(signature,lastsignature,lastmodify)

%% IV kiexportálása online analízissel



exportdir=hcont_convertpath(exportdir, 'h');

if ~isempty(IVs)  
    order=['OpenOnlineFile "IVexport.onl"'];
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
    for ivnum=1:size(IVs,1)
        groupi=IVs(ivnum,1);
        seriesi=IVs(ivnum,2);
        sweepnum=IVs(ivnum,3);
        tracenums=IVs(ivnum,4);
        if sweepnum>5
            for tracei=1:tracenums
                order=['SetTarget 1 1 1 1 0 FALSE FALSE'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                order=['Set R  UnmarkIt'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                order=['SetTarget ',num2str(groupi),' ',num2str(seriesi),' 1 ',num2str(tracei),' 4 FALSE FALSE'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                order=['SweepInfo']; % megnézzük, hogy milyen csatira van felvéve az IV
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                
                tracenum=str2double(cell2mat(answer.ans(2+(tracei-1)*5)));
                expname=['exp_',fname(1:end-4),'_',num2str(groupi),'_',num2str(seriesi),'_',num2str(tracenum)];
                
                order=['Set A  OA',num2str(tracenum),' TRUE'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                order=['Set R  NameString Vmon-',num2str(tracenum)];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                order=['SetTarget ',num2str(groupi),' ',num2str(seriesi),' 1 ',num2str(tracei),' 2 FALSE FALSE'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                order=['Set R  MarkByName'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                order=['Export overwrite "',exportdir,'temp"'];
                [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
                iv.(expname)=hcont_readexportediv([exportdir,'temp.mat'],tracenum);
            end
        end
    end
end


%% test
order=['OpenPgfFile ',filedir,fname];
order=['GetLabel ',num2str(groupi),' ',num2str(seriesi),' 1 1 4'];
order=['SweepInfoExt'];
order=['Set   @  Replay          "Show PGF-Template"'];
order=['GetSettings'];
order=['GetParameters Online-0, Online-1, Online-2, Online-3, Online-4, Online-5'];
order=['Set R  MarkIt'];


order=['Set R  NameString Vmon-3'];
order=['Set R  MarkByName'];
order=['Set R  ShowIt'];
order=['Export overwrite "',exportdir,'temp"'];
[answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
%% test2
order=['OpenOnlineFile "IVexport.onl"'];
order=['Set A  OA1 TRUE'];
[answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
%     order=['']
%     [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);

%% egyéb
%%% parancs megadása
order='MakeAnError';
order='GetTime';
order='SweepInfo';
%%% parancs megadása
%orders={'OpenFile read X:\marci\analizis\HEKAdata\1209085rm.dat','GetParameters DataFile','GetTarget','GetLabel 1 1 1 1 0', 'GetParameters SweepName'};
orders={'GetParameters DataFile','GetTarget','GetLabel 1 1 1 1 0', 'GetParameters SweepName','GetChildren 1 1 1 1 0'};
for i=1:length(orders)
    order=char(orders(i))
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
    if isfield(answer, 'ans')
        answer.ans
    else
        disp(['no answer']);
    end
end

