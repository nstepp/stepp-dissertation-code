function rho = frobcorr(A, B)

A = A - frobmean(A);
B = B - frobmean(B);

rho = trace(A'*B)/sqrt(trace(A'*A)*trace(B'*B));

    function mu = frobmean(A)
        mu = trace(A')/length(diag(A'));
    end

end