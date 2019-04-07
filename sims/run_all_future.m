
h = 0.02;
taus = 0.2:0.2:1;
future_limits = 1:10;

x = zeros(length(taus),length(future_limits),3001,2);


for mtau=1:length(future_limits)
    master_sol = ode45(@rossler_fn,[0 120+future_limits(mtau)+h],[18.68, 3.432, 20.9]');
    for tau=1:length(taus)
		disp(['(' num2str(taus(tau)) ',' num2str(future_limits(mtau)) ')']);
		%K = [1 (2/pi) * atan(1./(h:h:future_limits(mtau)))];
		%plot(K,'.-');
        K = @(u)( (2/pi) * atan(1./u) );
        plot((0:h:future_limits(mtau)), K(0:h:future_limits(mtau)));
        drawnow;
        tic
		[t,x(tau,mtau,:,:)] = sim_as_fn_future(master_sol, taus(tau), future_limits(mtau), 120, h, K);
        toc
    end;
end;

%exp(-ns+1)
%exp(ns)/exp(ns(end))
%(-exp(ns)+exp(ns(end)))/exp(ns(end)

%(exp(-x)*z-exp(-x)+exp(-1)-z*exp(-n))/(-exp(-n)+exp(-1));

