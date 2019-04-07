function graph_subj_data(subj,swidth)

subjs = length(subj);

if nargin < 2
    swidth = 1280;
end;

for i = 1:subjs
	t = (1:size(subj(i).master,3))*subj(i).samplerate;
	for block=1:subj(i).blocks
		figure;
		for trial = 1:subj(i).trials
			tau = subj(i).taus(block,trial);
			m = subj(i).master(block,trial,:,1);
			m = reshape(m,1,size(m,3));
			
			m = map2screen(m,swidth);
			
			s = subj(i).slave(block,trial,:,1);
			s = reshape(s,1,size(s,3));
			
			subplot(2,4,trial);
			plot(t,m,t,s);
			title([subj(i).subj_id ' Block ' num2str(block) ' \tau = ' num2str(tau)]);
		end;
	end;
end;
			
function newts = map2screen(ts,swidth)
%	xpadding=0.25*1280;
%	xpadding=0.25*800;
	xpadding=0.25*swidth;

	newts = ts;
	newts = newts - min(newts);
%	newts = (1280-2*xpadding)*newts/max(newts) + xpadding;
%	newts = (800-2*xpadding)*newts/max(newts) + xpadding;
	newts = (swidth-2*xpadding)*newts/max(newts) + xpadding;
end

end
