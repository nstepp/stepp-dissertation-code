function [symrho symtau] = doxcovs_mpi_chunk(tseries_fname)
% function [symrho symtau] = doxcovs_mpi_chunk(tseries_fname)
%
% compute maximum cross covariances and the corresponding lags
% This one is chunked so we can deal with memory issues.
%
% $Id: doxcovs_mpi_chunk.m 716 2011-12-02 04:55:34Z stepp $

	MPI_Init();
	mpiComm = MPI_Comm_Load('doxcovs');

	mpiRank = MPI_Comm_rank(mpiComm);
	mpiSize = MPI_Comm_size(mpiComm);
	mpiAllNodes = 1:mpiSize-1;

	mpiIdStr = ['[Node ' int2str(mpiRank) '] '];

	if mpiRank == 0
		mpi_disp(mpiIdStr,'Loading tseries');
		tseries0 = load(tseries_fname);
		tseries = center(tseries0(2*floor(end/3):end, 2:end));
		clear tseries0;
		mpi_disp(mpiIdStr,'Sending tseries');
		for rank = mpiAllNodes
			info = MPI_Send(tseries, rank, 0, mpiComm);
		end;
	else
		mpi_disp(mpiIdStr,'Waiting for tseries');
		tseries = MPI_Recv(0, 0, mpiComm);
	end;

	sim_len = size(tseries,1);
	num_states = size(tseries,2);
	maxlag = 700;

	xcov_pad_post = 2^nextpow2(sim_len+maxlag);
	xcov_pad_pre = sim_len + maxlag;


	% Calculate the work to be done by each node
%	mpiChunkSize = num_states/mpiSize;

	for i=1:mpiSize
		%rankNeurons{i} = ceil((i-1)*mpiChunkSize+0.5):floor(i*mpiChunkSize+0.5);
		rankNeurons{i} = i:mpiSize:num_states;
	end;

	myNeurons = rankNeurons{mpiRank+1};

	numMyNeurons = length(myNeurons);


	%rho = zeros(num_states,num_states);
	%tau = zeros(num_states,num_states);
    xcstats = zeros(num_states,num_states,8);

	% It's faster to do the redundant (symmetric) computations
	% than to do slicing into this matrix!! Chunking is
	% compromise between the two.
	post = conj(fft(postpad(tseries, xcov_pad_post)));
	xc_len = 2*maxlag+1;

	for i=myNeurons
		mpi_disp(mpiIdStr,['i = ' int2str(i)]);
		fflush(stdout);
		tic;

		% These are the "j" states that we will consider for this "i" state
		posts = i:size(tseries,2);

		% If the number is large enough, we will break the range up into
		% smaller chunks. Doing it all at once takes up too much memory when
		% multiple processes are active.
		if length(posts) >= 99
			chunksize = length(posts)/3;
		else
			chunksize = length(posts);
		end;

		% These will be the chunk boundaries
		chunklims = ceil(1:chunksize:length(posts));

		if chunklims(end) ~= length(posts)
			chunklims = [chunklims length(posts)];
		end;


		% Begin xcov code. This is implemented here because a) HRL does not have
		% many stat package licenses, b) octave doesn't have one that operates
		% in vector-matrix mode like this (thereby being extremely slow doing
		% many vector-vector xcovs).

		% Pre factor 
		pre = fft(postpad( prepad(tseries(:,i), xcov_pad_pre), xcov_pad_post));

		% For each chunk...
		for chunk = 2:length(chunklims)
			chunkrange = posts(chunklims(chunk-1):chunklims(chunk));

			if chunk-1 ~= 1
				chunkrange = chunkrange(2:end);
			end;

			% ...compute normalization factor and covariance function
			L = sqrt(sumsq(tseries(:,i)) .*  sumsq(tseries(:,chunkrange)));
			R = real(ifft( repmat(pre, 1, length(chunkrange)) .* post(:,chunkrange)));

			% normalize and slice down to non-redundant size
			R = R(1:xc_len,:) ./ repmat(L,xc_len,1);

			% We measure the maximum cross covariance and the lag at which that max occurred.
			%[rho(i,chunkrange) tau(i,chunkrange)] = max(R);
            xcstats(i,chunkrange,:) = analyze_extrema(R, sim_len)';
		end;

		mpi_disp(mpiIdStr,[int2str(i) ' took ' num2str(toc) 's']);
	end;

	if mpiRank == 0
		mpi_disp(mpiIdStr,'Gathering results');
        for rank = mpiAllNodes
			%mesg = MPI_Recv(rank, 0, mpiComm);
			%rho(rankNeurons{rank+1},:) = mesg(rankNeurons{rank+1},:);
			%clear mesg;

			%mesg = MPI_Recv(rank, 1, mpiComm);
			%tau(rankNeurons{rank+1},:) = mesg(rankNeurons{rank+1},:);
			%clear mesg;

            mesg = MPI_Recv(rank, 0, mpiComm);
			xcstats(rankNeurons{rank+1},:,:) = mesg(rankNeurons{rank+1},:,:);
			clear mesg;
       end;
	else
		mpi_disp(mpiIdStr,'Sending results');
		%info = MPI_Send(rho, 0, 0, mpiComm);
		%info = MPI_Send(tau, 0, 1, mpiComm);
		info = MPI_Send(xcstats, 0, 0, mpiComm);
		mpi_disp(mpiIdStr,'Done');
		MPI_Finalize();
		return;
	end;

	mpi_disp(mpiIdStr,'Processing');
%{
	% Generate a lower triangular matrix
	% (probably a better way to do this)
	tri = ones(size(tau));
	for i=1:num_states
		for j=i:num_states
			tri(i,j) = 0;
		end;
	end;
	tri = tri';

	% Make tau antisymmetric
	symtau = tau - maxlag;
	symtau = symtau .* tri;
	symtau = symtau - symtau';

	% rho is just plain symmetric
	symrho = rho + rho' - eye(size(rho));
%}

    interesting = xcstats(1,:,2) > 0 & (abs(xcstats(1,:,2)) > abs(xcstats(1,:,4)));

    good = xcstats(1,:,2) > 0.5 & (xcstats(1,:,2) > abs(xcstats(1,:,4)))...
        & abs(xcstats(2,:,2) - xcstats(2,:,6)) < 1e-5;
    
    interestingStates = find(interesting);
    
    goodStates = find(good)

    
    
    mpi_disp(mpiIdStr,'Saving');
	%save -v7 covs.mat symrho symtau rho tau;
    save -v6 xcstats.mat xcstats interestingStates goodStates
    
	mpi_disp(mpiIdStr,'Done');
	MPI_Finalize();

	function mpi_disp(id, str)
		disp([ id str ]);
    end


end

function xcstats = analyze_extrema(xc, tsLen)
    dxc = diff(xc);

    ispeak = dxc(2:end,:) <= 0 & dxc(1:end-1,:) > 0;
    isvalley = dxc(2:end,:) >= 0 & dxc(1:end-1,:) < 0;

    noextrema = ~any(ispeak) | ~any(isvalley); 
    
    if any(noextrema)
        warning(['some states have no peaks or valleys.']);
    end;

    emptyStates = find(noextrema);

    nStates = size(ispeak,2);
    
    % find peak values for each column
    for i=1:nStates
        extrema{i} = find(ispeak(:,i) | isvalley(:,i)) + 1;
    end;

    firstAntExtremum = cellfun(@(x) (find(x >= tsLen-1, 1, 'first')), extrema, 'UniformOutput', false); 
    firstLagExtremum = cellfun(@(x) (find(x < tsLen-1, 1, 'last')), extrema, 'UniformOutput', false);
    
    firstAntPeak = cellzip( @(x,ind) ( x(ind) ), extrema, firstAntExtremum);
    firstLagPeak = cellzip( @(x,ind) ( x(ind) ), extrema, firstLagExtremum);

    
    for i=1:nStates
        firstAntVal{i} = xc(firstAntPeak{i},i);
        firstLagVal{i} = xc(firstLagPeak{i},i);
    
        [mx{i}, mxi{i}] = max(xc(extrema{i},i));
        [mn{i}, mni{i}] = min(xc(extrema{i},i));
    end;
    
    globalMaxPeak = cellzip( @(x,ind) ( x(ind) ), extrema, mxi);
    globalMinPeak = cellzip( @(x,ind) ( x(ind) ), extrema, mni);
    
    xcstatcell = [firstAntPeak; firstAntVal;...
        firstLagPeak; firstLagVal;...
        globalMaxPeak; mx;...
        globalMinPeak; mn ];
    %xcstatcell(:,noextrema) = num2cell(nan(8,length(emptyStates)));
    emptyStats = cellfun(@isempty, xcstatcell);
    xcstatcell(emptyStats) = num2cell(nan);
    
    xcstats = cell2mat(xcstatcell);
    
    xcstats([1,3,5,7],:) = xcstats([1,3,5,7],:) - tsLen;
end


function fca = cellzip(fn, ca1, ca2)

    len = length(ca1);
    if len ~= length(ca2)
        error('cellzip: cannot zip unequal length arrays');
    end;
    
    fca = cell(1,len);
    
    for i=1:len
        fca{i} = fn(ca1{i},ca2{i});
    end;

end