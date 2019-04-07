function gen_graphset(nnodes, eprobs, negprobs)


neprobs = length(eprobs);
nnegprobs = length(negprobs);

nodeAdj = zeros(neprobs, nnegprobs, nnodes, nnodes);
pathLens = zeros(neprobs, nnegprobs, nnodes, nnodes);
inDeg = zeros(neprobs, nnegprobs, nnodes);
outDeg = zeros(neprobs, nnegprobs, nnodes);
arcProb = zeros(neprobs, nnegprobs);
negProb = zeros(neprobs, nnegprobs);

meanIn = zeros(neprobs, nnegprobs);
meanOut = zeros(neprobs, nnegprobs);
meanCW = zeros(neprobs, nnegprobs);
minCW = zeros(neprobs, nnegprobs);
maxCW = zeros(neprobs, nnegprobs);

for ep=1:10
    for np=1:10
        disp(['Generating graph (' num2str(eprobs(ep)) ', ' num2str(negprobs(np)) ')']);
        tic; 
        [nodeAdj(ep,np,:,:), pathLens(ep,np,:,:), inDeg(ep,np,:), outDeg(ep,np,:),...
            arcProb(ep,np), negProb(ep,np)] = gen_graphs(nnodes, eprobs(ep), negprobs(np));
        toc
    end;
end;

for ep=1:neprobs
    for np=1:nnegprobs
        
        disp('Calculating mean in and out degrees');
        meanIn(ep,np) = mean(inDeg(ep,np,:));
        meanOut(ep,np) = mean(outDeg(ep,np,:));
        
        disp('Analyzing closed walks');
        cw = diag(squeeze(pathLens(ep,np,:,:)));
        meanCW(ep,np) = mean(cw(~isinf(cw)));
        maxCW(ep,np) = max(cw(~isinf(cw)));
        minCW(ep,np) = min(cw(~isinf(cw)));
        
        disp('Saving adjacency matrix');
        adj = squeeze(nodeAdj(ep,np,:,:));
        save(['graph-' int2str(ep) '-' int2str(np) '.txt'],'adj','-ascii','-tabs');
        
    end;
end;

save 'edgeprobs.txt' -ascii -tabs eprobs
save 'negprobs.txt' -ascii -tabs negprobs
save graphs.mat
