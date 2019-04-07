function [t,x,sol] = sim_as_masters(tmax, h, inits, parms)

% for the case of U_\infty S_1, lags(1) corresponds to slave delay.
% lags(2:end) is a piece of the master.

if nargin < 3
    inits = [18.68, 3.432, 20.9]';
end;

if nargin < 4
    parms = [0.1, 0.1, 14]';
end;

sol = ode23(@(t,y,Z) rossler(t,y,parms), [0 tmax], inits);

t = (0:h:tmax)';
x = deval(sol,t)';




    function dy = rossler(t,y,p)
       
        
        a = p(1);
        b = p(2);
        c = p(3);
        
        dy = zeros(3,1);


        % Rossler part
        dy(1) = -y(2) - y(3);
        dy(2) = y(1) + a*y(2);
        dy(3) = b + y(3)*(y(1)-c);
                
    end


end


