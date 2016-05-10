function [syllab] = encodeWavlist( wavdir, analysisdir, coeffdir, normavec, transpos, savesig, varargin )
% encode the wav files in wavdir according to the coding parameters of the configuration files in analysisdir
% if there is more than one configuration file, each one is used and the vector sequences are merged
% the final vector sequence is saved in coeffdir with .vect extension instead of .wav
% need VOICEBOX for writing and reading HTK file format
    if ~exist('normavec','var') || isempty(normavec), normavec=[]; end
    if ~exist('coeffdir','var') || isempty(coeffdir), coeffdir=wavdir; end
    if ~exist('transpos','var') || isempty(transpos), transpos=0; end
    if ~exist('savesig','var')  || isempty(savesig), savesig=0; end
    if ~exist('analysisdir','var') || isempty(analysisdir), analysisdir=''; end
    [wintime1, hoptime1, numcep1, lifterexp1, sumpower1, preemph1, dither1, ...
     minfreq1, maxfreq1, nbands1, bwidth1, dcttype1, fbtype1, usecmp1, modelorder1, broaden1] = ...
             process_options(varargin, 'wintime', 0.025, 'hoptime', 0.010, ...
                  'numcep', 13, 'lifterexp', -22, 'sumpower', 1, 'preemph', 0.97, ...
                  'dither', 0, 'minfreq', 300, 'maxfreq', 20000, ...
                  'nbands', 26, 'bwidth', 1.0, 'dcttype', 3, ...
                  'fbtype', 'htkmel', 'usecmp', 0, 'modelorder', 0, 'broaden', 0);
    if nargout>0
        syllab = struct('seqvect',{},'filename','') ;
    end
    wavfiles = dir(fullfile(wavdir,'*.wav')) ;
    % check wav files found
    if isempty(wavfiles)==1 
        fprintf(1,'No wavfiles found in %s\n',wavdir); return
    end
    for sylf=1:numel(wavfiles)
        seqvect = [] ;
        sylfilename0 = fullfile(wavdir,wavfiles(sylf).name) ;
        syllab(sylf).filename = wavfiles(sylf).name ;
        if ~isempty(analysisdir) % use HTK:HCopy to encode files
            conffiles = dir(fullfile(analysisdir,'*')) ;
            for cff=1:numel(conffiles)
                if isdir(fullfile(analysisdir,conffiles(cff).name)), continue; end % avoid directories
                tmp=regexprep(wavfiles(sylf).name(end:-1:1),'vaw.','kth.','once');tmp=tmp(end:-1:1); % allows to replace just once, the last one
                sylfilename1 = fullfile(coeffdir,tmp) ;
                system(['HCopy -A -C ' fullfile(analysisdir,conffiles(cff).name) ' ' sylfilename0 ' ' sylfilename1]) ;
                [coeffseq,fp] = readhtk(sylfilename1) ;
                seqvect = [seqvect coeffseq]; % matrix transposed with readhtk (compared to readmfcc)
                delete(sylfilename1);
            end
        else % use calc_mfcc
            [seqvect] = calc_mfcc(sylfilename0, '', 'wintime', wintime1, 'hoptime', hoptime1,...
                                    'numcep', numcep1, 'lifterexp', lifterexp1, 'sumpower', sumpower1,...
                                    'preemph', preemph1, 'dither', dither1, 'minfreq', minfreq1,...
                                    'maxfreq', maxfreq1, 'nbands', nbands1, 'bwidth', bwidth1,... 
                                    'dcttype', dcttype1, 'fbtype', fbtype1, 'usecmp', usecmp1,...
                                    'modelorder', modelorder1, 'broaden', broaden1) ;
            fp = hoptime1;
        end
        % fprintf(1,'%i %i\n',size(seqvect,1),size(seqvect,2)) ;
        if numel(normavec)>0
            % normalise from0 to 1 according to a vector giving the structure, e.g. [1 12; 13 13; 14 25]
            % seqvect = norma_seqvect(seqvect',[1 12; 13 13; 14 25]) ; % NEED TO TRANSPOSE THE MATRIX
            seqvect = norma_seqvect(seqvect',normavec) ; % NEED TO TRANSPOSE THE MATRIX
            seqvect = seqvect' ;
        end
        tc = 9 ; % always use USER data format for HTK, required for reading the data later
        if nargout==0
            tmp=regexprep(wavfiles(sylf).name(end:-1:1),'vaw.','kth.','once');tmp=tmp(end:-1:1); % allows to replace just once, the last one
            writehtk(fullfile(coeffdir,tmp),seqvect,fp,tc); % NEED TO TRANSPOSE THE MATRIX BACK
        else
            if transpos==1
                syllab(sylf).seqvect = seqvect' ;
            else
                syllab(sylf).seqvect = seqvect ;
            end
        end
        if savesig==1
             [syllab(sylf).signal, syllab(sylf).Fs] = wavread(sylfilename0) ;
        end
    end
end