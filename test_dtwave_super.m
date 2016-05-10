
addpath('/home/louis/Documents/Matlab/mfiles') ;

addpath(genpath('/home/louis/Documents/Projects/DTWave/SVNdtwave/trunk/dtwave_super/')) ;
addpath(genpath('/home/louis/Documents/Projects/DTWave/SVNdtwave/trunk/dtwave_cluster/')) ;

compexp = 1 ;

x = syllab(1).seqvect ;
W_1 = syllab(2).seqvect ;

% pull neuron weight W toward training sample x 
[ dist, W_2 ] = DTWaverage(x,W_1,[], 0.1, compexp) ;
fprintf(1,'%f\n',dist) ;
% dist = 11.2178
DTWaverage(x,W_2,[], 0, compexp)
% ans = 9.8754

% push neuron weight W away from training sample x 
[ dist, W_2 ] = DTWaverage(x,W_1,[], -0.1, compexp) ;
fprintf(1,'%f\n',dist) ;
% dist = 11.2178
DTWaverage(x,W_2,[], 0, compexp)
% ans = 11.9712


%% test dtwave_super 
nu = 10 ; % 10 neurons
tstep = 100 ; % 100 samples per data point, == 1 second
winl = 0.01 ; % window size in seconds
% initialise the training set data structures
[x,t,labels] = init_dtwave_super('/home/louis/Documents/Projects/DTWave/test/Burgess_super/train2', nu, tstep, winl) ;

% declare neural net with 10 units in 1 hidden layer
net = patternnet(10) ;

% training on all training set
[net,tr] = train(net,x,t) ;
view(net)

% ALT, training one sample at a time and collect gradient
net.trainParam.epochs = 1 ; % we want to train on 1 training data sample only
net.trainFcn = 'traingd' ; % use gradient descent for testing, trainscg should be faster
num_epoch = 5;
for e = 1:num_epoch % following need to be checked/completed
    for s = 1:numel(x)
        [net,] = train(net,x(:,1),t(:,1)) ;
    end
end

% run network on test file
run_dtwave_super('/home/louis/Documents/Projects/DTWave/test/Burgess_super/test', weight, net, labels, tstep, winl, compexp );
