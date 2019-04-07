function dy = rossler_fn(t, y, cfn)

dy = zeros(3,1);

a = 0.1;
b = 0.1;
c = 14;

dy(1) = -y(2) - y(3) + cfn;
dy(2) = y(1) + a*y(2);
dy(3) = b + y(3)*(y(1)-c);

end
