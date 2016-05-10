function [  ] = run_dtwave_super( dir, weight, net, labels, tstep, winl, compexp )
% number of window frame to set sounds chunks
% winl length in second of window frame

% load data
syllab = encodeWavlist(dir,[],[],[],1);

% find the numebr of outputs for the network
outputlayerid = net.outputConnect>0 ;
numout = net.outputs{outputlayerid}.size ;

for s=1:size(syllab,2)
    % get distance vector to first layer
    a = 1 ;
    b = 1 ;
    y = zeros(numout,ceil(size(syllab(s).seqvect,2)/tstep)) ; % contains recognition output
    for ws=1:ceil(size(syllab(s).seqvect,2)/tstep) % every time step
        x = zeros(size(weight,2),1) ; % contains the distance vector to all weight of the layer
        a = max(a,b) ;
        b = min(a+tstep-1,size(syllab(s).seqvect,2)) ; 
        for w=1:size(weight,2)
             x(w) = DTWaverage(weight{w},syllab(s).seqvect(:,a:b),[],0,compexp) ;
        end
        % run neural net recognition
        y(:,ws) = net(x) ;
    end
    % output recognition results
    export_dtwave_super(y,tstep*winl,labels,syllab(s).filename) ;
end

%figure; plot(y(1,:));
