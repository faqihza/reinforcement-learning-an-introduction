clear
clc


% policy evaluation (prediction)
%% gridworld 4 x 4
row_number = 4;
column_number = 4;
[grid,states,row_size,column_size] = gridworld(row_number, column_number);

%% Initialization 
% state-value function = Vpi
Vpi = zeros(row_size,column_size);
% uniform policy
policy_probability = 0.25;
% discount factor
gamma = 1;

%% Computation
% looping parameters
convergence_threshold = 0.0001;
iteration = 0;
delta = 1e10;

while (delta > convergence_threshold)
    delta = 0;
    
    
    % loop for each state
    for row = 1:row_size
        for column = 1:column_size
            
            % access V(s)
            v = Vpi(row,column);
            
            str_state = sprintf("grid.state_%d",states(row,column));
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
                
                Vpi(row,column) = sum(policy_probability*(all_reward + gamma*all_next_state_value));
            end
            delta = max([delta, abs(v - Vpi(row,column))]);
        end
    end
    iteration = iteration + 1;
    
    disp("iteration - " + iteration);
    disp("delta - " + delta);
    disp("Vpi = ");
    disp(round(Vpi,3,'decimals'));
end
