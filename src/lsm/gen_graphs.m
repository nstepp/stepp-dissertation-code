function [nodeAdj, pathLens, inDeg, outDeg, actualArcProb, actualNegProb] = gen_graphs(nnodes, edgeProb, negProb)
% function [nodeAdj, pathLens, inDeg, outDeg, actualArcProb, actualNegProb] = gen_graphs(nnodes, edgeProb, negProb)



    % Randomly connect nodes
    nodeAdj = double(rand(nnodes,nnodes) <= edgeProb);

    % We don't want any self-connections
    % XXX there's probably a better way to do this
    for i=1:nnodes
        nodeAdj(i,i) = 0;
    end;
    
    % Minumum in and out degree should be 1
    outDeg = sum(nodeAdj,2);
    
    zeroDegree = find(outDeg == 0)';
    for i = zeroDegree
        ind = randi(nnodes);
        if ind == i
            ind = mod(ind+1,nnodes)+1;
        end;
        nodeAdj(i,ind) = 1;
    end;

    inDeg = sum(nodeAdj,1);
    zeroDegree = find(inDeg == 0);
    for i = zeroDegree
        ind = randi(nnodes);
        if ind == i
            ind = mod(ind+1,nnodes)+1;
        end;
        nodeAdj(ind,i) = 1;
    end;
    
    inDeg = sum(nodeAdj,1);
    outDeg = sum(nodeAdj,2);    
        
    
    makeNeg = rand(nnz(nodeAdj),1) <= negProb;

    % this doesn't work, but I'm not sure why.
    % nodeAdj(nodeAdj ~= 0) = nodeAdj(nodeAdj ~= 0) - 2*makeNeg;
    
    nonzero = find(nodeAdj ~= 0);
    
    for i=1:length(nonzero)
        if makeNeg(i)
            nodeAdj(nonzero(i)) = -1 * nodeAdj(nonzero(i));
        end;
    end;

    % now that we have a graph, place it in our 4 dimensional property
    % space.
    %
    % We are measuring:
    % - Shortest closed directed walk (simple/non-simple)
    % - Mean degree
    % - Arc probability
    % - Negative gain probability
    % The last two are specified prior to graph creation
    % but I would still like to check (and they are quick)
    
    % Shortest closed directed walk
    % Switch to Johnson if this is too slow
    pathLens = abs(nodeAdj);
    pathLens(pathLens == 0) = inf;

    for k = 1:nnodes
        for i = 1:nnodes
            for j = 1:nnodes
                pathLens(i,j) = min(pathLens(i,j), pathLens(i,k)+pathLens(k,j));
            end;
        end;
    end;

    % Arc probability. What is the probability that a possible arc
    % is an actual arc.
    numArcs = sum(sum(abs(nodeAdj)));
    actualArcProb = numArcs/(nnodes^2 - nnodes);
    
    % And probability of a negative arc
    actualNegProb = length(find(nodeAdj<0))/numArcs;

end