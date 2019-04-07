function [k, g, u, z] = decompose_generic_var(master, slave, h)
% [k, g, u, z] = decompose_generic_var(master, slave, h)
%
% Decompose deterministic and stochastic components of syncrhonization
% variability.
%
% The model assumed is that of two delay-coupled systems:
%
% x(t) = f(x)
% y(t) = f(x) + k*(x(t) - y(t-tau)) + g*w(t)
%
% w(t) is a stochastic fluctuating force.

xc=fftshift(xcov(master,slave,'coeff'));

[maxv,maxi]=max(xc(1:floor(end/2)))

tausamp=maxi;

[B,A] = butter(4, (5/2*h));
fslave = filtfilt(B,A,slave);

dot_slave = deriv(fslave,1/h);
%plot(ddot_slave);

startsamp=tausamp+100;
%u = fslave(startsamp+1:end) - fslave(startsamp:end-1); %- h*dot_slave(startsamp:end-1);
u = h*dot_slave(startsamp:end-1);
z = master(startsamp:end-1) - fslave(startsamp-tausamp:end-tausamp-1);

[b,bint,r,rint,stats] = regress(u,[ ones(length(z),1) (h*z) ]);
plot(u,h*z,'.');

disp(['R^2=' num2str(stats(1)) ' F=' num2str(stats(2)) ' p=' num2str(stats(3))]);
bint

k = b(2);
g = mean( (u - (k * h * z)).^2 ) / h;

