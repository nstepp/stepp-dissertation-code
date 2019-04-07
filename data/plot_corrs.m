function plot_corrs(xcstats, titleStr)

taus = (0.05:0.05:0.8)';

% xcstats indices
firstAntPeakIdx = 2;
firstLagPeakIdx = 4;
globalMaxIdx = 6;
firstAntPeakShiftIdx = 1;
firstLagPeakShiftIdx = 3;
globalMaxShiftIdx = 5;

tsLenIdx = 9;

% analysis value
peakIdx = globalMaxIdx;
peakShiftIdx = globalMaxShiftIdx;

% compute means and standard errors
mnxc = (squeeze(mean(xcstats(:,:,peakIdx),1)))';
sdxc = (squeeze(std(xcstats(:,:,peakIdx),1)))';
sdexc = sdxc/sqrt(size(xcstats,1));

mnxct = (squeeze(mean(xcstats(:,:,peakShiftIdx)-xcstats(:,:,tsLenIdx),1)))';
sdxct = (squeeze(std(xcstats(:,:,peakShiftIdx)-xcstats(:,:,tsLenIdx),1)))';
sdexct = sdxct/sqrt(size(xcstats,1));

%mnrt = mean(rho_tau)';
%sdrt = std(rho_tau)';
%sdert = sdxct/sqrt(size(rho_tau,1));

% Plots

% best fitting cubic
[b,bint,~,~,stats] = regress(mnxc, [ones(16,1) taus taus.^2 taus.^3]);
disp(['Rho Cubic:: R^2: ' num2str(stats(1)) ', F: ' num2str(stats(2)) ', p: ' num2str(stats(3))]);
disp(['    Cubic B: (' num2str(bint(4,1)) ',' num2str(bint(4,2)) ')']);

% rho - maximum cross correlation
figure;
errorbar(taus,mnxc,sdexc,'k','linewidth',3);
hold on; plot(taus, b(1) + b(2)*taus + b(3)*taus.^2 + b(4)*taus.^3,'k--','linewidth',3); hold off;
%hold on; plot(taus, bint(1,1) + bint(2,1)*taus + bint(3,1)*taus.^2 + bint(4,1)*taus.^3,'r--'); hold off;
%hold on; plot(taus, bint(1,2) + bint(2,2)*taus + bint(3,2)*taus.^2 + bint(4,2)*taus.^3,'r--'); hold off;

set(gca,'fontsize',16);
xlabel('\tau (s)','fontsize',18);
ylabel('\rho','fontsize',18);
if ~isempty(titleStr)
    title([titleStr ': Max Cross Correlation'],'fontsize',18);
end;

figure;
plot(taus,sdxc,'k','linewidth',3);
set(gca,'fontsize',16);
xlabel('\tau (s)','fontsize',18);
ylabel('s_{\rho}','fontsize',18);
if ~isempty(titleStr)
    title([titleStr ': Standard Deviation'],'fontsize',18);
end;



% tau^* lag at rho
figure;
errorbar(taus,mnxct,sdexct,'k','linewidth',3);

%n=8;
%[b,bint,~,~,stats] = regress(mnxct(1:n), [ones(n,1), taus(1:n) taus(1:n).^2]);
%disp(['Tau First 8 Quadratic:: R^2: ' num2str(stats(1)) ', F: ' num2str(stats(2)) ', p: ' num2str(stats(3))]);
%disp(['    Quadratic B: (' num2str(bint(3,1)) ',' num2str(bint(3,2)) ')']);
%hold on; plot(taus(1:n), mnxct(1:n), 'r.'); hold off;
%hold on; plot(taus, b(1) + b(2)*taus + b(3)*taus.^2,'r'); hold off;

%hold on; plot(taus, bint(1,1) + bint(2,1)*taus + bint(3,1)*taus.^2,'r--'); hold off;
%hold on; plot(taus, bint(1,2) + bint(2,2)*taus + bint(3,2)*taus.^2,'r--'); hold off;

n=6;
[b,bint,~,~,stats] = regress(mnxct(1:n), [ones(n,1), taus(1:n)]);
disp(['Tau First ' int2str(n) ' Linear:: R^2: ' num2str(stats(1)) ', F: ' num2str(stats(2)) ', p: ' num2str(stats(3))]);
disp(['    Linear B: (' num2str(bint(2,1)) ',' num2str(bint(2,2)) ')']);
hold on; plot(taus(1:n), mnxct(1:n), 'ko'); hold off;
hold on; plot(taus, b(1) + b(2)*taus,'k--','linewidth',3); hold off;

set(gca,'fontsize',16);
xlabel('\tau (s)','fontsize',18);
ylabel('\tau^* (World Units)','fontsize',18);
if ~isempty(titleStr)
    title([titleStr ': Cross Correlation Shift'],'fontsize',18);
end;

figure;
n=10;
errorbar(taus(1:n),mnxct(1:n),sdexct(1:n),'k','linewidth',3);
[b,bint,~,~,stats] = regress(mnxct(1:n), [ones(n,1), taus(1:n)]);
disp(['Tau First ' int2str(n) ' Linear:: R^2: ' num2str(stats(1)) ', F: ' num2str(stats(2)) ', p: ' num2str(stats(3))]);
disp(['    Linear B: (' num2str(bint(2,1)) ',' num2str(bint(2,2)) ')']);
set(gca,'fontsize',16);
xlabel('\tau (s)','fontsize',18);
ylabel('\tau^* (World Units)','fontsize',18);
if ~isempty(titleStr)
    title([titleStr ': Cross Correlation Shift (zoom)'],'fontsize',18);
end;


figure;
plot(taus,sdxct,'k','linewidth',3);
set(gca,'fontsize',16);
xlabel('\tau (s)','fontsize',18);
ylabel('s_{\tau^*}  (World Units)','fontsize',18);
if ~isempty(titleStr)
    title([titleStr ': Standard Deviation'],'fontsize',18);
end;


%figure;
%errorbar(taus,mnrt,sdert);

end

