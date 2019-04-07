function [t,x,sol] = sim_as_fn(lags, tmax, h, ks, inits, parms)

if nargin < 5
    inits = [18.68, 3.432, 20.9, 1, 0]';
end;

if nargin < 6
    parms = [0.1, 0.1, 14, 1]';
end;

sol = dde23(@(t,y,Z) rossler_spring(t,y,Z,parms,ks), lags, ones(5,1), [0 tmax], inits);

t = (ceil(tmax/2):h:tmax)';
x = deval(sol,t)';




    function dy = rossler_spring(t,y,Z,p,ks)
       
        n = length(Z);
        
        a = p(1);
        b = p(2);
        c = p(3);
        w = p(4);
        
        dy = zeros(5,1);
        
        % Rossler part
        dy(1) = -y(2) - y(3);
        dy(2) = y(1) + a*y(2);
        dy(3) = b + y(3)*(y(1)-c);
        
        % Spring part
        dy(4) = y(5) + sum(ks)*y(1) - dot(ks,Z(4,:));
        dy(5) = -w*y(4);
        
    end


end


