function sim_subj = experiment2_sim(subj)

% experiment design:
% for all subjects s, 3 blocks of 8 trials
% each trial is 80 seconds.
% each trial has (x0,tau)
% taus are randomized for each block
% x0 is randomly chosen from uniform distribution
% for each trial


% Initialize experiment
mastermdl = 'mastersys';
mastersub = 'mastersys/master';
%h = 0.01;
% Try 50 hz because of video performance
h = 0.02;

% tau conditions
%taus = [ 0.1 0.2 0.4 0.6 0.8 1.0 ];
%taus = (h:.04:1);
taus = linspace(0.1,0.8,8);
tau_n = length(taus);

ks = linspace(0.2,0.9,8);
k_n = length(ks);

% Generate parameter orderings
% The idea is to spread different
% (k,tau) combinations among many participants
% such that each participant get all possible
% ks and all possible taus.
% Skip by 3 so that there is not a strong correlation
% between k and tau for any participant.
for i=1:k_n
	k_orders(i,:) = i*ones(1,tau_n) + (3*((1:tau_n)-1));
end;
k_orders = mod(k_orders-1, k_n) + 1;


for s = 1:length(subj)

    blocks = subj(s).blocks;

    rand('twister', sum(100*clock));

    % Start filling in the structure describing this run
    this_run.subj_id = subj(s).subj_id;
    this_run.subj_order = subj(s).subj_order;

    if this_run.subj_order < 1 || this_run.subj_order > 8
        error('Parameter ordering index is not in range [1,8].');
    end;

    this_run.blocks = blocks;
    this_run.trials = length(taus);
    this_run.samplerate = h;

    % Initialize blocks
    for block=1:blocks
        % trial order is randomized per block
        trial_pos = order_from_taus(subj(s).taus(block,:));
        this_run.trial_order(block,trial_pos) = 1:subj(s).trials;
    end;
    this_run.taus = subj(s).taus;
    this_run.ks = subj(s).ks;
    % x0 taken randomly (uniform) from [18.5, 19.5] per trial
    this_run.x0s = subj(s).x0s;


    % Loop though all conditions
    for block = 1:blocks
        disp(['Block ' int2str(block)]);
        for trial = 1:tau_n
            tau = this_run.taus(block,trial);
            k = this_run.ks(block,trial);
            x0 = this_run.x0s(block,trial);
            disp(['  Trial ' int2str(trial) ' ready (' num2str(tau) ',' num2str(k) ',' num2str(x0) ')...']);

            % generate time series
            x = squeeze(subj(s).master(block,trial,:,:));
            
            disp('  Running...');
            tic
            [xy,score] = pointertrack_simmed(floor(tau/h), k, x(:,[1,2]), h, '');
            toc
            
            % Save Data
            this_run.notes{block,trial} = 'simmed';
            this_run.master(block,trial,:,:) = x;
            this_run.slave(block,trial,:,:) = xy;
            this_run.score(block,trial) = score;

            % Save data to file every time because I'm paranoid
            % about losing data
            %if ~isempty(this_run.subj_id)
            %    save(['exp2-' this_run.subj_id '-sim.mat'], 'blocks', 'this_run');
            %end;
        end;
    end;
    
    sim_subj(s) = this_run;
    
end;

end
