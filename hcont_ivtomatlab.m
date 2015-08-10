nem műűűxiiiik


% progress=0;
%[fnames, path, FI]=uigetfile({'*.dat'},'MultiSelect','on');
% %savepath='/data/Userek/marci/analizis/_neuron taxonomy/FS_vs_AAC/processed_DATA_IVl/';
% 
% 
% if class(fnames)=='char'
%     fnames=cellstr(fnames);
% end
% progressbar('analysing files');
% for i=1:size(fnames,2)
%     fname=cell2mat(fnames(i));
%     cellname=fname(1:findstr(fname,'.')-1)
%     cellname=['elfiz',cellname];
%     iv.(cellname) = mreadfile(fname, path, FI); %beolvasom az IV-t
%     iv.(cellname).current = startampl:stepampl:((stepampl*iv.(cellname).sweepnum+startampl-stepampl));
%     
%     data.(cellname).pass= mpassive(iv.(cellname),cellname);
%     data.(cellname).HH = mHH(iv.(cellname));
%     data.(cellname)=offsetvoltage(data.(cellname), iv.(cellname));
%     datasum.(cellname)= calculateelfiz(iv.(cellname),data.(cellname));
%     cellname
%     progress=progress+1;
%     progress/length(fnames)
% %     pause(2);
% %     if mod(progress,10)==0
% %         close all;
% %     end
%     plotiv(cellname, iv, datasum, data, 1, 0);
%     saveas(gcf,[cellname,'.jpg']);
%     close(gcf);
%     
%     save([savepath,'data_iv_',fname], 'data', 'iv');
%     progressbar(i/size(fnames,2));
%     data=rmfield(data,cellname);
%     iv=rmfield(iv,cellname);
%     datasum=rmfield(datasum,cellname);
%     pack;
% end