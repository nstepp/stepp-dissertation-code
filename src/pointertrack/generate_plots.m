function generate_plots(data)


subs = [1:12,14:16];

taus = (0.1:0.1:0.8);
ks = (0.2:0.1:0.9);
mncorrs = mean(data.xcorrs(subs,:));
secorrs = std(data.xcorrs(subs,:))/sqrt(length(subs));
mntcorrs = mean(data.tau_corrs(subs,:));
setcorrs = std(data.tau_corrs(subs,:))/sqrt(length(subs));
mnobs = mean(data.obstaus(subs,:)*0.02);
seobs = std(data.obstaus(subs,:)*0.02)/sqrt(length(subs));


figure;
figPos = get(gcf,'Position');
set(gcf,'Position',[figPos(1) figPos(2) 1000 300])

subplot(1,3,1);
errorbar(taus,mncorrs,secorrs,'k','linewidth',2);
%axis square;
set(gca,'fontsize',16)
xlabel('\tau (s)','fontsize',18);
ylabel('\rho','fontsize',18);
axis([0 0.9 0.4 1]);
set(gca,'Position',[0.1 0.2 0.2 0.6])

subplot(1,3,2);
errorbar(taus,mntcorrs,setcorrs,'k','linewidth',2);
%axis square;
set(gca,'fontsize',16)
xlabel('\tau (s)','fontsize',18);
ylabel('\rho_\tau','fontsize',18);
axis([0 0.9 0.1 0.7]);
set(gca,'Position',[0.4 0.2 0.2 0.6])

subplot(1,3,3);
errorbar(taus,mnobs,seobs,'k','linewidth',2);
%axis square;
set(gca,'fontsize',16)
xlabel('\tau (s)','fontsize',18);
ylabel('\tau^* (s)','fontsize',18);
%axis([0 1.1 -12 14]);
set(gca,'Position',[0.7 0.2 0.2 0.6])
hold on; plot([0.1 0.7], [0.05 0.35], 'k--', 'linewidth',2); hold off;

%{
subplot(1,3,3);
errorbar(taus(1:5),mnobs(1:5),seobs(1:5),'k','linewidth',2);
%axis square;
set(gca,'fontsize',16)
xlabel('\tau (s)','fontsize',18);
ylabel('\tau^* (s)','fontsize',18);
axis([0 0.5 -.1 .3]);
set(gca,'Position',[0.7 0.2 0.2 0.6])
%}


end
