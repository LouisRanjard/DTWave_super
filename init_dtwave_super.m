function [ x, t, labels ] = init_dtwave_super( dir, nu, tstep, winl )
% need one wav file per class

% load training data
syllab = encodeWavlist(dir,[],[],[],1);

% create labels (class)
labels = {syllab(:).filename} ;

% isolate chunks of sound according to their label
chunk = isolate_chunk(syllab,dir,winl) ;

% initialise neural net layer
[ weight ] = layer_dtwave_super( syllab, nu, tstep ) ;

% compute distances
compexp = 1 ; % use compression/expansion

%%% need to get the total number of time windows to initialise x and t sizes here
x = [] ; % contains, for each window of time step length, the distance vector to all weight of the layer
t = [] ; % contains label

c = 0 ;
for s=1:size(syllab,2)
    a = 1 ;
    b = 1 ;
    for ws=1:ceil(size(syllab(s).seqvect,2)/tstep) % every time step
        t(1:size(syllab,2),ws+c) = 0 ;
        a = max(a,b) ;
        b = min(a+tstep-1,size(syllab(s).seqvect,2)) ; 
        for w=1:nu
             x(w,ws+c) = DTWaverage(weight{w},syllab(s).seqvect(:,a:b),[],0,compexp) ;
        end
        t(s,ws+c) = 1 ;
    end
    c = c+ceil(size(syllab(s).seqvect,2)/tstep) ;
end

%fprintf(1,'%f',x) ;


