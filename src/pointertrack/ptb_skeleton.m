function [out pu ts] = ptb_skeleton(in, pu, ts)
% function [out pu ts] = ptb_skeleton(in, pu, ts)
%
% PsychToolbox skeleton

% Begin screen initialization
% This opens a window full screen with a light gray background
mainWindow = Screen('OpenWindow',0,[200 200 200]);
% If you don't want the cursor showing
HideCursor;
% Put up some title text
Screen('DrawText', mainWindow, 'Some text', 0,0);
% Whenever we want to show what we've draw, flip the screen
Screen('Flip',mainWindow);
pause(4);

% We might want to do something with the screen size
screen_rect = Screen('Rect',mainWindow);

% Such as this:
% These will be the center of the screen
zeroX = floor((screen_rect(3)-screen_rect(1))/2);
zeroY = floor((screen_rect(4)-screen_rect(2))/2);

% Get pointer position
xy = GetMouse(mainWindow);

% Draw a 10x10 pixel square there
Screen('DrawDots', mainWindow, xy, 10,[0 127 0]');

% remember you have to flip
Screen('Flip', mainWindow);	
	
% Maybe put up some more text
Screen('DrawText',mainWindow,['Score: 100000'],0,0,[127 0 0]);
Screen('Flip',mainWindow);
pause(4);

% Put cursor back and close the window
ShowCursor(0);
Screen('Close',mainWindow);


end
