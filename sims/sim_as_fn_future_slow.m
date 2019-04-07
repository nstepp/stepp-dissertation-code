function [sol_tvec,x,sol] = sim_as_fn_future(lags, future_limit, tmax, h, ks, inits, parms)

% for the case of U_\infty S_1, lags(1) corresponds to slave delay.
% lags(2:end) is a piece of the master.

if nargin < 6
    inits = [18.68, 3.432, 20.9, 1, 0]';
end;

if nargin < 7
    %parms = [0.1, 0.1, 14, 1]';
    %parms = [0.2, 0.2, 5.7, 1]';
    parms = [0.1, 0.1, 11, 1]';
end;

sol = dde23(@(t,y,Z) spring(t,y,Z,parms,ks), lags, zeros(5,1), [-future_limit tmax], inits);

sol_tvec = (ceil(tmax/2):h:tmax)';
%sol_tvec = (0:h:tmax)';
x = deval(sol,sol_tvec)';




    function dy = spring(t,y,Z,p,ks)
        
		a = p(1);
		b = p(2);
		c = p(3);
        w = p(4);

        dy = zeros(5,1);
 
 		slave_lag = Z(4,1);
		y_now = Z(:,end);


        % Rossler part
        dy(1) = -y(2) - y(3);
        dy(2) = y(1) + a*y(2);
        dy(3) = b + y(3)*(y(1)-c);
        
        
		% coupling function

		% for U_\infty S_1,
		% h = \int_0^\infty K(u) * ( x(t+u) - y(t-\tau) ) du

        
		%h_kern = master(master_t:master_end,1) - Z(1);
        %if length(h_kern) > length(ks)
        %    h_kern = h_kern(1:length(ks));
        %end;
		%hu = dot(ks, h_kern);

        
        % Spring part
        if t > 150
            h_kern = Z(1,2:end) - slave_lag;
            hu = dot(ks, h_kern*h);
        else
            hu = 0;
        end;

        dy(4) = y_now(5) + hu;
        dy(5) = -w*y_now(4) - 0.4*y_now(5);
 
    end


end


