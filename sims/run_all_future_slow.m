%load masters.mat;

h = 0.02;
taus = 0.2:0.2:2;
%future_limits = [4*h, 1:4];
future_limits = h:2*h:12*h;

x = zeros(length(taus),length(future_limits),7501,5);

for mtau=1:length(future_limits)
    for tau=1:length(taus)
		disp(['(' num2str(taus(tau)) ',' num2str(future_limits(mtau)) ')']);
		lags = [taus(tau)+future_limits(mtau) h:h:future_limits(mtau)];
		K = (2/pi) * atan(1./(h:h:future_limits(mtau)));
		subplot(3,1,1);plot(K,'.-');
        subplot(3,1,2);plot(lags,'.-');
		drawnow;
        tic
		[t,x(tau,mtau,:,:)] = sim_as_fn_future_slow(lags, future_limits(mtau), 300, h, K);
        toc
        subplot(3,1,3);plot(t,squeeze(x(tau,mtau,:,1)),t,squeeze(x(tau,mtau,:,4)));
    end;
end;

%exp(-ns+1)
%exp(ns)/exp(ns(end))
%(-exp(ns)+exp(ns(end)))/exp(ns(end)

%(exp(-x)*z-exp(-x)+exp(-1)-z*exp(-n))/(-exp(-n)+exp(-1));

