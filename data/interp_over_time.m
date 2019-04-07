function new_x = interp_over_time(new_t,t,x)

        if size(new_t,1) == 1
            new_t = new_t';
        end;

        new_x = zeros(length(new_t),1);
        left_inds = zeros(length(new_t),1);
        right_inds = zeros(length(new_t),1);
        for i=1:length(new_t)            
            % find two original time points that surround
            % the new one, checking for edge conditions
            left_ind = find(t < new_t(i), 1, 'last');
            if isempty(left_ind)
                left_ind = 1;
            end;
            left_inds(i) = left_ind;
            
            right_ind = find(t >= new_t(i), 1, 'first');
            if isempty(right_ind)
                right_ind = length(t);
            end;

            if right_ind == left_ind
                new_x(i) = x(left_ind);
                continue;
            end;
            right_inds(i) = right_ind;
        end;
        
        to_interp = right_inds > 0;
        
        right_inds = right_inds(to_interp);
        left_inds = left_inds(to_interp);
        t_rinterp = t(right_inds);
        t_linterp = t(left_inds);
        x_rinterp = x(right_inds);
        x_linterp = x(left_inds);
        
        % do a linear interpolation to find a value
        dt = t_rinterp - t_linterp;
        dx = x_rinterp - x_linterp;

        new_x(to_interp) = (dx./dt .* (new_t(to_interp)-t_linterp)) + x_linterp;
end


