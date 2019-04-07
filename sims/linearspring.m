function dy = linearspring(t, y, cfn)

dy = zeros(2,1);

dy(1) = y(2) + cfn; %sum(bullet_win)*x - dot(taus,bullet_win);
dy(2) = -2*y(1);

end
