cd data

for i=1:16
	s = load(['exp2-subj' int2str(i+2) '.mat']);
    r = s.this_run;
    
    if size(r.trial_order,1) < s.blocks
        for b=1:s.blocks
            [~, ix] = sort(r.taus(b,:));
            for j=1:length(ix)
                r.trial_order(b,j) = find(ix==j);
            end;
        end;
    end;
    
	subj(i) = r;
end;

cd ..

clear ix i s r b j;
