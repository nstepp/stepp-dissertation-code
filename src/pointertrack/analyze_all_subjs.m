function data = analyze_all_subjs(subj)

subjs = length(subj);


for i=1:subjs
	disp([subj(i).subj_id '...']);
	[taus,corrs,xcorrs,obs_taus,sims,tau_corrs] = extract_corrs(subj(i),subj(i).blocks,subj(i).samplerate,1);
	data.corrs(i,:) = mean(corrs);
	data.xcorrs(i,:) = mean(xcorrs);
	data.obstaus(i,:) = mean(obs_taus);
	[~,ix] = sort(subj(i).taus');
	ix = ix';
	for j=1:subj(i).blocks
		if isfield(subj(i), 'score')
			score(j,:) = subj(i).score(j,ix(j,:));
		else
			score(j,:) = 0;
		end;
% This is now done in extract_xcorrs
%		stau_corrs(j,:) = tau_corrs(j,ix(j,:));
	end;
	data.scores(i,:) = mean(score);
	data.tau_corrs(i,:) = mean(tau_corrs);
	
	data.ks(i,:) = subj(i).ks(1,ix(1,:));
end;

%data.mncorrs = mean(data.xcorrs);
%data.secorrs = std(data.xcorrs)/sqrt(subjs);
data.mncorrs = mean(data.tau_corrs);
data.secorrs = std(data.tau_corrs)/sqrt(subjs);
data.mnobs = mean(data.obstaus);
data.seobs = std(data.obstaus)/sqrt(subjs);

