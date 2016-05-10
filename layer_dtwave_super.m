function [ weight ] = layer_dtwave_super( syllab, nu, tstep )
% create input layer that output distance to weight matrices
% nu : number of unit
% tstep : number of samples for weight matrix (fixed time length)

% initialise weight matrices by randomly choosing values from training matrices
idxs = ceil(numel(syllab).*rand(1,min(100,numel(syllab)))) ; % avoid extrem values
vals = reshape([syllab(idxs).seqvect],1,[]) ;
xax = size([syllab.seqvect],1) ; % frequency/mfcc axis size

%%% need to preallocate weight matrices here
%weight =  ;

for w=1:nu
    rindex = 1 + round((size(vals,2)-1)*rand(xax,tstep)) ;
    weight{w} = vals(rindex) ; % +1 because weight(1) is the root
end
