function hcont_setPMconfig(signature,lastsignature,lastmodify)
order=['Set  @  ExportTarget    "MatLab"'];
[answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
order=['Set   @  ExportTarget    "Trace Time relative to Sweep"'];
[answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
order=['Get  @  ExportMode      "Traces"'];
if isfield(answer,'ans')
    answer=rmfield(answer,'ans');
end
while ~isfield(answer,'ans')
[answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
end
if any(cell2mat(strfind(answer.ans, 'Not')))
    order=['Set  @  ExportMode      "Traces"'];
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
end
order=['Get  @  ExportMode      "Analysis - All"'];
[answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
if any(cell2mat(strfind(answer.ans, 'Not')))
    order=['Set  @  ExportMode      "Analysis - All"'];
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
end
order=['Get  @  ExportMode      "Analysis - All"'];
[answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
if any(cell2mat(strfind(answer.ans, 'Not')))
    order=['Set  @  ExportMode      "Analysis - All"'];
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
end
order=['Get  @  Display         "Subtract Zero Offset"'];
[answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
while ~any(cell2mat(strfind(answer.ans, 'Not')))
    order=['Set  @  Display         "Subtract Zero Offset"'];
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
    order=['Get  @  Display         "Subtract Zero Offset"'];
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
end

for tempi=0:5
    order=['Set  O  DispTrace       ',num2str(tempi),''];
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
    order=['Set  O  DFilter  0'];
    [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order,signature,lastsignature,lastmodify);
end
end