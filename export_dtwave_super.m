function [  ] = export_dtwave_super(y,nsec,labels,filename)
% nsec is the number of seconds a window lasts, each column of y


[~,id]=max(y) ;
timestamp = [find(diff([-1 id 1]) ~= 0)] ; % track change of ids
runlength = diff(timestamp) ; % length of each chunk

T = table(cumsum([0 runlength(1:end-1)]*nsec)', cumsum(runlength*nsec)', labels(id(timestamp(1:end-1)))') ;

writetable(T,[filename '.label.txt'],'Delimiter','\t','WriteVariableNames',false) ;
