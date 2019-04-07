function [xy score loop_delays ts] = pointertrack_galaga(tau, k, x, h, title)
%function [xy score loop_delays ts] = pointertrack_galaga(tau, k, x, h, title)
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
% $Id: pointertrack_galaga.m 697 2011-11-19 00:56:57Z stepp $

if dim(x) ~= 2
	error('Input time series must be 2 dimensional.');
end;

% We want the time series to be in columns
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

% This is where we will store the input
xy = zeros(len,2);

scoreInc = 5;
bonusMult = 5;

bonusInc = bonusMult * scoreInc;


% Begin screen initialization
mainWindow = Screen('OpenWindow',0,[200 200 200]);
HideCursor;
Screen('DrawText', mainWindow, title, 0,0);
Screen('Flip',mainWindow);
pause(4);

% We don't want to use the whole screen, set
% some padding based on screen size
screen_rect = Screen('Rect',mainWindow);
xpadding=0.25*screen_rect(3);
ypadding=0.45*screen_rect(4);

% These will be the center of the screen
zeroX = floor((screen_rect(3)-screen_rect(1))/2);
zeroY = floor((screen_rect(4)-screen_rect(2))/2);

% Vertical heigh of target and ship are fixed
target_height = 0.2*screen_rect(4);
ship_height = 0.8*screen_rect(4);

% Map the master time series to on-screen coordinates
ts(:,1) = x(:,1);
ts(:,1) = ts(:,1) - min(ts(:,1));
ts(:,1) = (screen_rect(3)-2*xpadding)*ts(:,1)/max(ts(:,1)) + xpadding;

ts(:,2) = target_height;

target_dist = ship_height - target_height


% Calculate the properties of the bullet train coming
% from the ship. A bullet leaving the ship should take
% tau samples to get to the target (causing the ship
% to be ahead by tau in order to shoot the target)
pix_per_samp = target_dist/tau;

% Coupling strength scales the inter bullet interval
% A continuous stream is considered strong coupling.
% ibi is the number of samples between bullets,
% ranging from 1 to tau (which is the number of samples
% it takes for a bullet to get from ship to target)
ibi = ceil((1-k) * tau)
if ibi < 1
	ibi = 1;
end;

pix_per_bullet = pix_per_samp * ibi

% All of this results in a constant number of bullets on-screen
num_bullets = floor(target_dist/pix_per_bullet)


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


% Animation loop, keep track of loop delays
% and adjust loop sleep time to keep a constant
% sample rate.

loop_delays = zeros(1,len);
tbegin = GetSecs;
for j=1:len

	[xy(j,1),xy(j,2)] = GetMouse(mainWindow);
	xy(j,2) = ship_height;

	% Create bullet coordinates
	bullet_dots(1,:) = bullets(:,1);
	bullet_dots(2,:) = ship_height - bullets(:,2);
	
	Screen('DrawDots', mainWindow, [ts(j,:)' xy(j,:)'], [20 10],[target_color;0 127 0]');
	Screen('DrawDots', mainWindow, bullet_dots, 3, [0;0;0]);
	Screen('Flip', mainWindow);	
	
	% I'm not using mod here, because I want to do
	% some things when we roll over
	bullets(:,2) = round(bullets(:,2) + pix_per_samp);

	over = find(bullets(:,2) > target_dist);
	
	bullets(over,2) = mod(bullets(over,2),target_dist);
	
	% Hit when the horizontal distance of the bullets that pass the ship
	% is less than 10 pixels.
	hits = sum(abs(bullets(over,1)-ts(j,1)) <= 10);

	% Increase score on a hit, show the score above the target
	% The score will fade out over hit_decay iterations.
	if hits > 0
		target_color = [255 0 0];
		score = score + hits*scoreInc;
		Screen('DrawText', mainWindow, num2str(score), ts(j,1)-10, target_height-35, [127 0 0]);
		hit_decay = 30;
	else
		if hit_decay > 0
			% These formulae fade from dark red to the background color
			r = -2.433*hit_decay+200;
			gb = -6.666*hit_decay+200;
			Screen('DrawText', mainWindow, num2str(score), ts(j,1)-10, target_height-35, [r gb gb]);
			hit_decay = hit_decay - 1;
		end;
		target_color = [0 0 255];
	end;
	
	% bullets emanate from the location of the ship
	bullets(over,1) = xy(j,1);	
	
	% Try to hit a target sample rate, h
	loop_delay = GetSecs - tbegin;
	loop_delays(j) = loop_delay;
	WaitSecs(h-loop_delay);
	tbegin = GetSecs;
end;

Screen('DrawText',mainWindow,['Score: ' num2str(score)],0,0,[127 0 0]);
Screen('Flip',mainWindow);
pause(4);

ShowCursor(0);
Screen('Close',mainWindow);

	function xy = mapPixel2Axis(pos)
		xy(1) = 2.4 * ((pos(1)-minX)/width) - 1.2;
		xy(2) = 2.4 * ((pos(2)-minY)/height) - 1.2;
	end
		
end
