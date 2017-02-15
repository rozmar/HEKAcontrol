function [seriesnums,seriesdata,hiba]=HEKA_exporttreeinfo(windirname,fname)
% close all

locations=marcicucca_locations;
exportdir=[locations.tgtardir,'ANALYSISdata/marci/Exportdir/'];
winexportdir=[locations.tgtarwindir,'ANALYSISdata\marci\Exportdir\'];
% windirname=[locations.tgtarwindir,'HEKAdata\',setupname];

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
% hcont_setPMconfig(signature,lastsignature,lastmodify);
% pause(.1);
% hcont_setPMconfig(signature,lastsignature,lastmodify);
fnameold=fname;
vesszohely=strfind(fnameold,',');
for filenumber=1:length(vesszohely)+1
    if isempty(vesszohely)
        fname=fnameold;
    else
        vesszohelyuj=[0,vesszohely,length(fnameold)+1];
        fname=fnameold(vesszohelyuj(filenumber)+1:vesszohelyuj(filenumber+1)-1);
    end
    pause(1)
    order=['OpenOnlineFile "anyexansport.onl"'];
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);

    
%     [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
%     pause(.2);
%     order='GetParameters DataFile';
%     [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
    if any(strfind(fname,'á'))|any(strfind(fname,'é'))|any(strfind(fname,'í'))|any(strfind(fname,'ő'))|any(strfind(fname,'ű'))|any(strfind(fname,'ü'))
        disp(['bad filename: ',fname])
        seriesnums=[];
        seriesdata=[];
    else
        hiba=[];
        while ~isfield(answer,'ans') | ~((length(answer.ans)==2 && strcmp(answer.ans{2},['"',windirname,'\',fname,'"'])) | (length(answer.ans)==2 && strcmp(answer.ans{2},['""']))) % nem mindig tölti be a filet, ezért ellenőrizni kell | strcmp(answer.ans{1},['error_open_failed']) |
            order=['OpenFile read ',windirname,'\',fname];
            [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
            hiba=answer;
            pause(.2);
            order='GetParameters DataFile';
            [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
        end
        if length(answer.ans)>1&strcmp(answer.ans{2},['"',windirname,'\',fname,'"'])
            disp(['exporting tree info from: ',fname]);
            [seriesnums,seriesdata]=hcont_findseriesbyname({},{},signature,lastsignature,lastmodify);
        else
            seriesnums=[];
            seriesdata=[];
            disp(['failed to open:', fname])
        end
    end
    order=['Set  @  File            "Close"'];
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
end