clear
clc

% policy evaluation (prediction)
%% gridworld 5 x 4 with only active state at row 5 and column 2
row_number = 5;
column_number = 4;
[grid,states,row_size,column_size] =  exercise_4_2_gridworld(row_number,column_number);

%% Initialization 
% state-value function = Vpi
Vpi = zeros(row_size,column_size);
% uniform policy
Pi = 0.25*ones(row_size,column_size,4); %"Up","Down","Left","Right"
% action-value function = Qpi
Qpi = zeros(row_size,column_size,4); 
% discount factor
gamma = 1;
% not in place parameter
V_buffer = zeros(row_size,column_size);

%% Computation
% looping parameters
convergence_threshold = 0.0001;
iteration = 0;
delta = 1e10;

policy_stable = false;
Pi_next = zeros(row_size,column_size,4);
policy = string(zeros(row_size,column_size));
policy(:,:) = "UpBottomLeftRight";
actions = ["Up","Down","Left","Right"];

while ~policy_stable 
    
    %% Policy Evaluation
    while (delta > convergence_threshold)
        delta = 0;
        % loop for each state
        for row = 1:row_size
            for column = 1:column_size

                % access V(s)
                Vs = Vpi(row,column);

                v = Vs;
                Vs = 0;

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
                    policy_at_s = reshape(Pi(row,column,:),[1,4]);
                    Vs = policy_at_s*(all_reward + gamma*all_next_state_value);
                end
                V_buffer(row,column) = Vs;
                delta = max([delta, abs(v - Vs)]);
            end
        end
        iteration = iteration + 1;
        Vpi = V_buffer;

        disp("iteration - " + iteration);
        disp("delta - " + delta);
        disp("Vpi = ");
        disp(round(Vpi,3,'decimals'));
    end
    
    
    %% Policy Improvement
    policy_stable = true;
    old_policy = policy;
    for row = 1:row_size
        for column = 1:column_size
            old_Pi_at_s = reshape(Pi(row,column,:),[4,1]);

            value = max(old_Pi_at_s);
            
            position_action = ismember(old_Pi_at_s,value)';

            old_policy = string;
            for k = 1:length(position_action)
                if position_action(k)
                    old_policy = old_policy + actions(k);
                end
            end
            
            
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

                Qpi_at_s =  (all_reward + gamma*all_next_state_value);
                Qpi(row,column,:) = Qpi_at_s;
                value = max(Qpi_at_s);
                position_action = ismember(Qpi_at_s,value)';

                new_Pi_at_s = position_action/sum(position_action);
                Pi_next(row,column,:) = new_Pi_at_s;

                new_policy = string;
                for k = 1:length(position_action)
                    if position_action(k)
                        new_policy = new_policy + actions(k);
                    end
                end
                
                if (row == row_size && column ~= 2)
                    policy(row,column) = "";
                    old_policy = "";
                else
                    policy(row,column) = new_policy;
                end
                % check if policy at each state is stable
                if old_policy ~= policy(row,column)
                    policy_stable = false;
                end
            else
                policy(row,column) = "";
            end
        end
    end
    
    Pi = Pi_next;
    
    if policy_stable
        break
    end
end

disp("Result");
disp("V* = ")
disp(Vpi)
disp("policy* = ")
disp(policy)

disp("Answer");
disp("Vpi(15) = " + Vpi(5,2));




