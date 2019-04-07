function [xy score loop_delays ts] = pointertrack_simmed(tau, k, x, h, title)
%function [xy score loop_delays ts] = pointertrack_simmed(tau, k, x, h, title)
%
% Display a moving target as well as the subject's mouse movements.
%
%   tau - number of samples to delay subject's movement
%     k - coupling strength
%     x - 2D master time series
%     h - Sample time (sample rate is 1/h)
% title - String to display at beginning of trial
%
% Nigel Stepp <stepp@atistar.net>
% $Id: pointertrack_simmed.m 706 2011-11-26 21:15:44Z stepp $

do_graphics = false;

if dim(x) ~= 2
	error('Input time series must be 2 dimensional.');
end;

xsize = size(x);

if xsize(2) > xsize(1)
	x = x';
	xsize = size(x);
end;

len = xsize(1);

if xsize(2) ~= 2
	error('Input vectors should have dim = 2');
end;

if tau < 1 || tau > len-1
	error('tau has a strange value... bailing.');
end;

xy = zeros(len,2);
y = zeros(len,1);
z = zeros(len,1);

scoreInc = 5;
bonusMult = 5;

bonusInc = bonusMult * scoreInc;



if do_graphics
    mainWindow = Screen('OpenWindow',0,[200 200 200]);
    HideCursor;
    Screen('DrawText', mainWindow, title, 0,0);
    Screen('Flip',mainWindow);
    pause(4);
    
    screen_rect = Screen('Rect',mainWindow);
else
    screen_rect = [0 0 1280 800];
end;

xpadding=0.25*screen_rect(3);
ypadding=0.45*screen_rect(4);

target_height = 0.2*screen_rect(4);
ship_height = 0.8*screen_rect(4);

ts(:,1) = x(:,1);
ts(:,1) = ts(:,1) - min(ts(:,1));
ts(:,1) = (screen_rect(3)-2*xpadding)*ts(:,1)/max(ts(:,1)) + xpadding;

%ts(:,2) = x(:,2);
%ts(:,2) = ts(:,2) - min(ts(:,2));
%ts(:,2) = (screen_rect(4)-2*ypadding)*ts(:,2)/max(ts(:,2)) + ypadding;
ts(:,2) = target_height;

target_dist = ship_height - target_height;

pix_per_samp = target_dist/tau;

zeroX = floor((screen_rect(3)-screen_rect(1))/2);
zeroY = floor((screen_rect(4)-screen_rect(2))/2);

ibi = ceil((1-k) * tau);
if ibi < 1
	ibi = 1;
end;

pix_per_bullet = pix_per_samp * ibi;

num_bullets = floor(target_dist/pix_per_bullet);


%bullet_heights = linspace(0,target_dist-1,num_bullets);
bullet_heights = 0:ceil(target_dist/num_bullets):target_dist;
if length(bullet_heights) > num_bullets
	bullet_heights = bullet_heights(1:end-1);
end;
bullets = [ repmat(zeroX,num_bullets,1) bullet_heights' ];

score = 0;
hit_decay = 0;
textColor = [0 0 0];
target_color = [0 0 255];

loop_delays = zeros(1,len);
if do_graphics
    tbegin = GetSecs;
end;
for j=1:len

%	[xy(j,1),xy(j,2)] = GetMouse(mainWindow);
	if j>tau
		[maxby,maxbi] = max(bullets(:,2));
		%xy(j,1) = xy(j-1,1) + ts(j,1)-ts(j-1,1) + 1.5*h*(ts(j,1) - bullets(maxbi,1));

		% dy/dt = g(y) + k1*(x-y_tau1) + k2*(x-y_tau2) + ... + kn*(x-y_taun)
		% k1 == k2 == ... == kn => (k/n)*[ x - y_tau1 + x - y_tau2 ... ]
		% (k/n)*[ n*x - (y_tau1 + y_tau2 + ... + y_taun) ]
		% dy/dt = g(y) + k*x - (k/n)*(y_tau1 + ... + ytau_n)
		bullet_times = ceil(height2samp(bullets(:,2), pix_per_samp));
		%ship_taus = sort(xy(j - bullet_times,1),'descend');
		ship_taus = sort(xy(j - bullet_times,1),'ascend');

        %bullet_win = logspace(1,0,length(ship_taus))/10;
        %bullet_win = logspace(1,0,length(ship_taus))/5;
        bullet_win = linspace(1,0,length(ship_taus));
        %bullet_win = linspace(0,1,length(ship_taus));
        %bullet_win = linspace(0.5,0,length(ship_taus))+0.5;
        % bullet_win = exp(-(0:length(ship_taus)-1));
        %bullet_win = exp(-(length(ship_taus)-1:-1:0));
        %bullet_win = exp(0:length(ship_taus)-1)/exp(length(ship_taus)-1);
        %bullet_win = 0.5*exp(-(0:length(ship_taus)-1))+0.5;
        %bullet_win = cos((0:num_bullets-1)*(pi/num_bullets));
        % Just the sum of ship_taus provides anticipation
        %bullet_win = ones(1,length(ship_taus))/length(ship_taus);
        %bullet_win = zeros(1,length(ship_taus));
		%xy(j,1) = xy(j-1,1) + h*( (zeroX-xy(j-1,1)) + sum(bullet_win)*ts(j,1) - dot(ship_taus,bullet_win)  );
        
        %xy(j,1) = xy(j-1,1) + h*( y(j-1) + sum(bullet_win)*ts(j,1) - dot(ship_taus,bullet_win) );
        %xy(j,1) = xy(j-1,1) + h*( y(j-1)  );
        %y(j) = y(j-1) + h*( (zeroX - xy(j-1,1)) );
        %y(j) = y(j-1) + h*( (zeroX - xy(j-1,1)) + sum(bullet_win)*ts(j,1) - dot(ship_taus,bullet_win) );
        
        % do sim in centered coordinate system then transform back
        
        cx = (xy(j-1,1) - zeroX)/zeroX;
        cts = (ts(j,1) - zeroX)/zeroX;
        ctaus = (ship_taus-zeroX)/zeroX;
        
%        xy(j,1) = cx + h*( y(j-1) + sum(bullet_win)*cts - dot(ctaus,bullet_win) );
%        y(j) = y(j-1) + h*( -12*pi*cx );

        % runge-kutta one step (slow, but euler doesn't work :/)
%        [tn,xn] = ode23(@(t,y) linearspring(t,y,sum(bullet_win)*cts - dot(ctaus,bullet_win)), [j-1 j]*h, [cx y(j-1)]);
        [tn,xn] = ode23(@(t,y) rossler_fn(t,y,sum(bullet_win)*cts - dot(ctaus,bullet_win)), [j-1 j]*h, [cx y(j-1) z(j-1)]);

        % scale back to screen
        xy(j,1) = xn(end,1)*zeroX + zeroX;
        y(j) = xn(end,2);
        z(j) = xn(end,3);

        
		if xy(j,1) > screen_rect(3)
			xy(j,1) = screen_rect(3);
		elseif xy(j,1) < 0
			xy(j,1) = 0;
		end;
	else
		xy(j,1) = zeroX;
        y(j) = 3;
        z(j) = 20.9;
	end;
	
	xy(j,2) = ship_height;

	bullet_dots(1,:) = bullets(:,1);
	bullet_dots(2,:) = ship_height - bullets(:,2);
	
    if do_graphics
        Screen('DrawDots', mainWindow, [ts(j,:)' xy(j,:)'], [20 10],[target_color;0 127 0]');
        Screen('DrawDots', mainWindow, bullet_dots, 3, [0;0;0]);
        Screen('Flip', mainWindow);	
    end;
	
	% I'm not using mod here, because I want to do
	% some things when we roll over
	bullets(:,2) = round(bullets(:,2) + pix_per_samp);

	over = find(bullets(:,2) > target_dist);
	
	bullets(over,2) = mod(bullets(over,2),target_dist);
	
	hits = sum(abs(bullets(over,1)-ts(j,1)) <= 10);
	if hits > 0
		target_color = [255 0 0];
		score = score + hits*scoreInc;
		if do_graphics
            Screen('DrawText', mainWindow, num2str(score), ts(j,1)-10, target_height-35, [127 0 0]);
        end;
		hit_decay = 30;
	else
		if hit_decay > 0
			r = -2.433*hit_decay+200;
			gb = -6.666*hit_decay+200;
			if do_graphics
                Screen('DrawText', mainWindow, num2str(score), ts(j,1)-10, target_height-35, [r gb gb]);
            end;
			hit_decay = hit_decay - 1;
		end;
		target_color = [0 0 255];
	end;
	
	bullets(over,1) = xy(j,1);	
	
	if do_graphics
        loop_delay = GetSecs - tbegin;
        loop_delays(j) = loop_delay;
        WaitSecs(h-loop_delay);
        tbegin = GetSecs;
    end;
end;

if do_graphics
    Screen('DrawText',mainWindow,['Score: ' num2str(score)],0,0,[127 0 0]);
    Screen('Flip',mainWindow);
    pause(4);

    ShowCursor(0);
    Screen('Close',mainWindow);
end;

	function xy = mapPixel2Axis(pos)
		xy(1) = 2.4 * ((pos(1)-minX)/width) - 1.2;
		xy(2) = 2.4 * ((pos(2)-minY)/height) - 1.2;
	end

	function times = height2samp(heights, pix_per_samp)
		times = (heights ./ pix_per_samp);
	end
	function times = height2time(heights, pix_per_samp, h)
		times = height2samp(heights,pix_per_samp) .* h;
	end

end
