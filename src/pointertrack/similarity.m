function s = similarity(x, y, tau)

s = zeros(1,length(tau));

x2 = x.^2;
y2 = y.^2;


len = length(x) - max(tau) - 1;
mid = floor(len/2);
mids = mid + tau;
ends = len - tau;

for t=1:length(tau)
	d = y(mids(t):len) - x(mid:ends(t));
	xt = x2(mid:ends(t));
	yt = y2(mid:ends(t));
%{
	if tau(t) > 0
		d = y(1+tau(t):end) - x(1:end-tau(t));
		xt = x2(1:end-tau(t));
		yt = y2(1:end-tau(t));
	else
		taup = -tau(t);
		d = y(1:end-taup) - x(1+taup:end);
		xt = x2(1+taup:end);
		yt = y2(1+taup:end);
	end;
%}	
	s(t) = mean(d.^2) / sqrt( mean(xt) * mean(yt) );
end;

