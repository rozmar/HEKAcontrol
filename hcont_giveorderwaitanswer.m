function [answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswer(order, signature,lastsignature,lastmodify)
[answer,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswercore(order,signature,lastsignature,lastmodify);
% answerr=answer;
% while ~isfield(answerr,'ans') | ~strcmp(answerr.ans,'Query_Idle')
%     orderr=['Query'];
%     [answerr,signature,lastsignature,lastmodify]=hcont_giveorderwaitanswercore(orderr,signature,lastsignature,lastmodify);
% end
end