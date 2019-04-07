function [sol_tvec,x,sol] = sim_as_fn_future(master_sol, lag, future_limit, tmax, h, ks, inits, parms)

% for the case of U_\infty S_1, lags(1) corresponds to slave delay.
% lags(2:end) is a piece of the master.

if nargin < 7
    inits = [1, 0]';
end;

if nargin < 8
    parms = [1]';
end;

sol = dde23(@(t,y,Z) spring(t,y,Z,parms,ks,master_sol,future_limit), lag, inits, [0 tmax], inits);

sol_tvec = (ceil(tmax/2):h:tmax)';
x = deval(sol,sol_tvec)';




    function dy = spring(t,y,Z,p,ks,master_sol,future_t)
        
        w = p(1);
        
        dy = zeros(2,1);
 
        % Rossler part
        %dy(1) = -y(2) - y(3);
        %dy(2) = y(1) + a*y(2);
        %dy(3) = b + y(3)*(y(1)-c);
        
        
		% coupling function

		% for U_\infty S_1,
		% h = \int_0^\infty K(u) * ( x(t+u) - y(t-\tau) ) du

        hu = quad(@(u)(ks(u) .* (deval(master_sol,t+u,1) - Z(1))),0,future_t);
        
        % Spring part
        dy(1) = y(2) + hu;
        dy(2) = -w*y(1);
        
    end


end


