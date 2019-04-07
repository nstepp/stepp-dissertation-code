function allstats = analyze_everything

%nodesets = {'50nodes', '500nodes'};
graphsets = {'graphset1', 'graphset2', 'graphset3'};
nodesets = {'500nodes'};
%graphsets = {'graphset3'};

for nodeset = 1:length(nodesets)
    cd(nodesets{nodeset});
    for graphset = 1:length(graphsets)
        cd(graphsets{graphset});
        
        edgeprobs = load('edgeprobs.txt');
        negprobs = load('negprobs.txt');
        
        for edgeprob = 1:length(edgeprobs)
            for negprob = 1:length(negprobs)
                
                disp([nodesets{nodeset} '-' graphsets{graphset} '-' int2str(edgeprob) '-' int2str(negprob)]);
                
                ts = load(['sim-' int2str(edgeprob) '-' int2str(negprob) '-ts.txt']);
                
                gr = load(['graph-' int2str(edgeprob) '-' int2str(negprob) '.txt']);
                
                % Compute laplacian spectrum, eig(deg matrix - adj matrix)
                % Do both in and out-laplacians.
                % Ignore negative weights for now, just connectivity.
                inEig = eig(diag(sum(abs(gr), 1)) - abs(gr));
                outEig = eig(diag(sum(abs(gr), 2)) - abs(gr));
                
                
                % sliding window covariances
                cs = zeros(size(ts,1)-50, size(ts,2)-6, size(ts,2)-6);
                tsEig = zeros(size(ts,1)-50, 6);
                for i=1:size(ts,1)-50
                    cs(i,:,:) = cov(ts(i:i+50,7:end));
                    tsEig(i,:) = eigs(squeeze(cs(i,:,:)));
                end;
                
                [xcstats interestingStates goodStates emptyStates] = analyze_xc(ts(floor(2*end/3):end,2), ts(floor(2*end/3):end,7:end));
                
                allstats{nodeset,graphset,edgeprob,negprob} = {xcstats, interestingStates, goodStates, emptyStates, tsEig, inEig, outEig};
                
            end;
        end;
        
        cd('..');
    end;
    
    cd('..');
end;

%for i=1:2, for j=1:3, for k=1:10, for l=1:10, good(i,j,k,l) = length(allstats{i,j,k,l}{3}); end; end; end; end;
%for i=1:2, for j=1:3, for k=1:10, for l=1:10, interest(i,j,k,l) = length(allstats{i,j,k,l}{2}); end; end; end; end;

end
