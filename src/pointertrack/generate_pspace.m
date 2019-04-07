function [pspace_rho, pspace_rhot, pspace_tau, num_bullets] = generate_pspace(subj,data)

taus = 0.1:0.1:0.8;
ks = 0.2:0.1:0.9;

tau_n = length(taus);
k_n = length(ks);

for i=1:k_n
	k_orders(i,:) = i*ones(1,tau_n) + (3*((1:tau_n)-1));
end;
k_orders = mod(k_orders-1, k_n) + 1;

target_height = 0.2*600;
ship_height = 0.8*600;

target_dist = ship_height - target_height;


for s = 1:length(subj)
    k_order = k_orders(subj(s).subj_order,:);
    for tau_i = 1:size(data.xcorrs,2)
        
        pix_per_samp = target_dist/(taus(tau_i)/0.02);

        % Coupling strength scales the inter bullet interval
        % A continuous stream is considered strong coupling.
        % ibi is the number of samples between bullets,
        % ranging from 1 to tau (which is the number of samples
        % it takes for a bullet to get from ship to target)
        ibi = ceil((1-ks(k_order(tau_i))) * (taus(tau_i)/0.02));
        if ibi < 1
        	ibi = 1;
        end;

        pix_per_bullet = pix_per_samp * ibi;
        num_bullets(k_order(tau_i),tau_i,s) = floor(target_dist/pix_per_bullet);

        
        
        pspace_rho(k_order(tau_i),tau_i,s) = data.xcorrs(s,tau_i);
        pspace_rhot(k_order(tau_i),tau_i,s) = data.tau_corrs(s,tau_i);
        pspace_tau(k_order(tau_i),tau_i,s) = data.obstaus(s,tau_i)*subj(s).samplerate;
    end;
end;


end
