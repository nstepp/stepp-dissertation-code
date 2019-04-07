function [taus,corrs,xcorrs,obs_taus,sims,tau_corrs,pvals] = extract_corrs(subj,blocks,h,skip)

trials = size(subj.taus,2);
trial_len = size(subj.master,3);

m=zeros(trials,trial_len);
s=zeros(trials,trial_len);

taus = zeros(blocks,trials);
corrs = zeros(blocks,trials);
xcorrs = zeros(blocks-skip,trials);
sims = zeros(blocks,trials);

[B,A] = butter(4,2*4*h);



for b=1:blocks-skip
	m(:,:)=subj.master(b+skip,:,:,1);
	s(:,:)=subj.slave(b+skip,:,:,1);
	
	m_detr = filtfilt(B,A,m');
	s_detr = filtfilt(B,A,s');
	
	%plot((xcov(m_detr(:,1),s_detr(:,1),'coeff')));
	%pause;
	%m_detr = m';
	%s_detr = s';
	C = corr(m_detr,s_detr);

	
	for j=1:trials
		disp(['(' int2str(b) ',' int2str(j) ')']);
		%xc(:,j) = xcov(m_detr(:,j),s_detr(:,j),'coeff');
        
        [xcstats(j,:) interestingStates goodStates emptyStates] = analyze_xc(m_detr(:,j), s_detr(:,j));
        
		tau_corrs(b,j) = corr(m_detr(1:end-round(subj.taus(b,j)/h)+1,j), s_detr(round(subj.taus(b,j)/h):end,j));
	%	tic;
		%sim(:,j) = similarity(m_detr(:,j), s_detr(:,j), (-300:300));
	%	toc
        if abs(xcstats(j,2)) > abs(xcstats(j,4))
            xcmi(j) = xcstats(j,1);
            mx(j) = xcstats(j,2);
        else
            xcmi(j) = xcstats(j,3);
            mx(j) = xcstats(j,4);
        end;
	end;
	
	
	[taus(b,:), ix] = sort(subj.taus(b+skip,:));

	%[mx, xcmi] = max(xc);
	%[mn, smi] = min(sim);
	obs_taus(b,:) = xcmi(ix)-trial_len;
	corrs(b,:) = C(b,ix);
	xcorrs(b,:) = mx(ix);
	
	tau_corrs(b,:) = tau_corrs(b,ix);

	
	for j=1:size(obs_taus,2)
		m_shifted = circshift( m_detr(:,ix(j)), -obs_taus(b,j) );
		[R,P] = corrcoef( m_shifted, s_detr(:,ix(j)) );
		pvals(b,j) = P(1,2);
		%figure;plot(m_shifted, s_detr(:,ix(j)),'.');
		%title(['obs_tau=' num2str(obs_taus(b,j)) ', r=' num2str(R(1,2)) ', p=' num2str(P(1,2),7)]);
	end;
	
	%sims(b,:) = sqrt(mn(ix));
end;

