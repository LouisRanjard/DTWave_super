function [chunk] = isolate_chunk( syllab, labdir, winl )
% isolate chunks of sound according to their label files (label.txt)
%  winl length in second of window frame, i.e. each column of
%  syllab.seqvect

if nargout>0
    chunk = struct('seqvect',{},'label','') ;
end
labfiles = dir(fullfile(labdir,'*.label')) ;

chk = 1;
for sy=1:numel(syllab)
    tmp=regexprep(syllab(sy).filename(end:-1:1),'vaw.','lebal.','once');tmp=tmp(end:-1:1); % allows to replace just once, the last one
    fid=fopen(tmp, 'r'); % this is error message for reading the file
    if fid == -1 
        error('File could not be opened, check name or path.')
    end
    tline = fgetl(fid);
    while ischar(tline) % reads a line of data from file.
        lim = sscanf(tline, '%f %f %*s') ;
        lim = round( lim/winl ) ; % samples
        lab = sscanf(tline, '%*f %*f %s') ;
        chunk(chk).label = lab ;
        chunk(chk).seqvect = syllab(sy).seqvect(:,lim(1):lim(2)) ;
        
        chk = chk+1 ;
        tline = fgetl(fid);
    end
    fclose(fid);
end
