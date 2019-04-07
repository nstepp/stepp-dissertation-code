
h = 0.02;
taus = 0.1:0.5:2;
future_limits = 1:10;

x = zeros(length(taus),length(future_limits),3001,5);

for tau=1:length(taus)
    for mtau=1:length(future_limits)
		disp(['(' num2str(taus(tau)) ',' num2str(future_limits(mtau)) ')']);
		lags = [taus(tau)+future_limits(mtau) (future_limits(mtau)-h):-h:h];
		K = (2/pi) * atan(1./(future_limits(mtau)-lags(2:end)));
		subplot(2,1,1);plot(lags,'.-');
		subplot(2,1,2);plot(K,'.-');
		drawnow;
        tic
		[t,x(tau,mtau,:,:)] = sim_as_fn_future(lags, 120, h, K);
        toc
    end;
end;

%exp(-ns+1)
%exp(ns)/exp(ns(end))
%(-exp(ns)+exp(ns(end)))/exp(ns(end)

%(exp(-x)*z-exp(-x)+exp(-1)-z*exp(-n))/(-exp(-n)+exp(-1));

