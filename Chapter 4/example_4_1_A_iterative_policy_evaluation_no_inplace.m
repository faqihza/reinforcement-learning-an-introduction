clear
clc


% policy evaluation (prediction)
%% gridworld 4 x 4
[grid,states,size_x,size_y] = gridworld(4,4);

%% Initialization 
% state-value function = Vpi
Vpi = zeros(size_x,size_y);
% uniform policy
policy_probability = 0.25;
% discount factor
gamma = 1;
% not in place parameter
V_buffer = zeros(size_x,size_y);

%% Computation
% looping parameters
convergence_threshold = 0.0001;
iteration = 0;
delta = 1e10;

while (delta > convergence_threshold)
    delta = 0;
    
    
    % loop for each state
    for i = 1:size_x
        for j = 1:size_y
            
            % access V(s)
            Vs = Vpi(i,j);
            
            v = Vs;
            Vs = 0;
            
            str_state = sprintf("grid.state_%d",states(i,j));
            state_s = eval(str_state);
            
            if ~state_s.terminate
                 
                all_reward = [state_s.up.reward;
                              state_s.down.reward;
                              state_s.left.reward;
                              state_s.right.reward];
                all_next_state_value =  [Vpi(state_s.up.next_state_row,state_s.up.next_state_col);
                                        Vpi(state_s.down.next_state_row,state_s.down.next_state_col);
                                        Vpi(state_s.left.next_state_row,state_s.left.next_state_col);
                                        Vpi(state_s.right.next_state_row,state_s.right.next_state_col)];
                
                Vs = sum(policy_probability*(all_reward + gamma*all_next_state_value));
            end
            V_buffer(i,j) = Vs;
            delta = max([delta, abs(v - Vs)]);
        end
    end
    iteration = iteration + 1;
    Vpi = V_buffer;
    
    disp("iteration - " + iteration);
    disp("delta - " + delta);
    disp(round(Vpi,3,'decimals'));
end
