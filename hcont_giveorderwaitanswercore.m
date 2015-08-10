function [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswercore(order, signature,lastsignatureold,lastmodifyold)
[locations]=marcicucca_locations;
%%%file megadása
topatchmaster=[locations.hekabatch,'E9Batch.In'];
frompatchmaster=[locations.hekabatch,'E9Batch.Out'];

%%%file megadása



temp=dir(frompatchmaster);
if isempty(temp) %% ha nincs output file, akkor csinál input filet a patchmasternek
    outfile = fopen(topatchmaster, 'wt' ); % ,'b','UTF-7');
    fprintf(outfile,'%s\r\n', num2str(-1),'acknowledged aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
    fclose(outfile);
    outfile = fopen(topatchmaster,'r+'); % ,'b','UTF-7');;
    fwrite(outfile, '+');
    fclose(outfile);
end
while isempty(temp) %% vár az output filera a patchmastertől
    temp=dir(frompatchmaster);
end
% infile = fopen(frompatchmaster);
% lastmodify=temp.date;

%%% megcsinálja az egyedi parancsazonosítót
    lastsignature=signature;
%     while lastsignature==signature
%         signature=round(rand(1)*10+1);
%     end
    signature=signature+1;
    if signature>10
        signature=1;
    end
%%% megcsinálja az egyedi parancsazonosítót

%%%% parancs fileba írása
outfile = fopen(topatchmaster, 'wt'); % ,'b','UTF-7');
%fileba={ num2str(signature), order};
fprintf(outfile, '%s\r\n', num2str(-signature), order);
fclose(outfile);
outfile = fopen(topatchmaster,'r+'); % ,'b','UTF-7');;
fwrite(outfile, '+');
fclose(outfile);
%%%% parancs fileba írása

%%% várakozás a válaszra
tempp=textread(frompatchmaster,'%s');
while isempty(tempp) | str2num(char(tempp(1)))<0 | abs(str2num(char(tempp(1))))==abs(lastsignature) %% megvárja míg az output file signature-ja megváltozik és pozitív előjelű nem lesz
    tempp=textread(frompatchmaster,'%s');
end
temp=dir(frompatchmaster);
lastmodify=temp.date;
%%% várakozás a válaszra

%%%% válasz beolvasása
clear temp;
clear answer;
temp=textread(frompatchmaster,'%s');
answer.full=temp;
answer.signature=str2num(cell2mat(answer.full(1)));
for tempi=2:length(answer.full)
    answer.ans{tempi-1}=char(answer.full(tempi));
end
%%%% válasz beolvasása
%abs(answer.signature)==signature
end