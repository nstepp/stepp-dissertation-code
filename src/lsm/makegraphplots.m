function makegraphplots(allstats)

nNodesets = size(allstats,1);
nGraphsets = size(allstats,2);
nEdgeprobs = size(allstats,3);
nNegprobs = size(allstats,4);

for nodeset = 1:nNodesets
    for graphset = 1:nGraphsets
        
        for edgeprob = 1:nEdgeprobs
            for negprob = 1:nNegprobs
                
                theseStats = allstats{nodeset,graphset,edgeprob,negprob};
                                
                % xc stats
                
                xcstats = theseStats{1};
                
                % compute anticipation index
                tauStar = xcstats(:,1);
                rho = xcstats(:,2);
                
                antInd0(graphset,edgeprob,negprob) = mean(atanh(abs(rho)) + tauStar/100);
                antInd1(graphset,edgeprob,negprob) = mean(abs(rho) .* tauStar/100);
                antInd2(graphset,edgeprob,negprob) = mean(rho + tanh(tauStar/100));
                
                
                % spectral gap
                inEig = sort(theseStats{6});
                inEig = inEig(inEig > 0);
                outEig = sort(theseStats{7});
                outEig = outEig(outEig > 0);
                inGap(edgeprob,negprob) = inEig(1);
                outGap(edgeprob,negprob) = outEig(1);
            end;
        end;
                
%         figure(1);
%         subplot(nNodesets, nGraphsets, nodeset * graphset);
%         surf(antInd1);
%          
%         figure(2);
%         subplot(nNodesets, nGraphsets, nodeset * graphset);
%         surf(antInd2);
         figure(3);
         subplot(nNodesets, nGraphsets, nodeset * graphset);
         surf(real(inGap));
         figure(4);
         subplot(nNodesets, nGraphsets, nodeset * graphset);
         surf(real(outGap));
    end;
    figure(1);
    surf([squeeze(antInd1(1,:,:)); squeeze(antInd1(2,:,:)); squeeze(antInd1(3,:,:))]);
    
    figure(2);
    surf([squeeze(antInd2(1,:,:)); squeeze(antInd2(2,:,:)); squeeze(antInd2(3,:,:))]);

    figure(5);
    surf([squeeze(antInd0(1,:,:)); squeeze(antInd0(2,:,:)); squeeze(antInd0(3,:,:))]);
    title('ant ind 0');
    
end;


end
