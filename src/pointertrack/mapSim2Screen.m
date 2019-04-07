function ts = mapSim2Screen(x,w)

xpadding=0.25*w;

ts = x(:,1);
ts = ts - min(ts);
ts = (w-2*xpadding)*ts/max(ts) + xpadding;

end

