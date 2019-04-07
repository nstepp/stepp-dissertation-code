
ns = 1:15;
taus = 0.1:0.1:2;

x = zeros(length(ns),length(taus),3001,5);

for n=ns
    for tau=1:length(taus)
        disp(['(' int2str(n) ',' num2str(tau) ')']);
        lags = linspace(0,taus(tau),n+1);
        lags = lags(2:end)';
        [t,x(n,tau,:,:)] = sim_as_fn(lags, 120, 0.02, ones(n,1)/n);
    end;
end;

%exp(-ns+1)
%exp(ns)/exp(ns(end))
%(-exp(ns)+exp(ns(end)))/exp(ns(end)

%(exp(-x)*z-exp(-x)+exp(-1)-z*exp(-n))/(-exp(-n)+exp(-1));

