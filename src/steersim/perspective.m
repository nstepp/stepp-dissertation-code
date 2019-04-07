function newX = perspective(X,pos,th,near,far)

%fov = 0.2;

fov = 45 * pi/180;

f = tan(fov/2);

aspect=1;
%X(:,3) = X(:,3)*3;

%{

viewXfrm = [         cos(th),            0,             sin(th),            0;
                        0,               1,                0,               0;
                    -sin(th),            0,             cos(th),            0;
         -pos(1)*cos(th)+pos(3)*sin(th), 0, -pos(1)*sin(th)-pos(3)*cos(th), 1];

perspXfrm = [ 1/f,  0,           0,            0;
               0,  1/f,          0,            0;
               0,   0,     far/(far-near),     1;
               0,   0, -(near*far)/(far-near), 0];

homX = [X, ones(size(X,1),1)];
           
newX = perspXfrm * viewXfrm * homX';

%}
%{
viewXfrm = [         cos(th),            0,             sin(th),            0;
                        0,               1,                0,               0;
                    -sin(th),            0,             cos(th),            0;
         -pos(1)*cos(th)+pos(3)*sin(th), 0, -pos(1)*sin(th)-pos(3)*cos(th), 1];
%}
viewXfrm = [         cos(th),            0,             sin(th), -pos(1)*cos(th)-pos(3)*sin(th);
                        0,               1,                0,               0;
                    -sin(th),            0,             cos(th), +pos(1)*sin(th)-pos(3)*cos(th);
         0, 0, 0, 1];

viewX = (viewXfrm*[X, ones(size(X,1),1)]')';

viewX(viewX(:,3)<0,:) = [];

newX(:,1) = viewX(:,1)./(aspect*f*viewX(:,3));
newX(:,2) = viewX(:,2)./(f*viewX(:,3));



