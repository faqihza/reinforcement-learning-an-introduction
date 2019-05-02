clear
clc


% policy evaluation (prediction)
%% gridworld 4 x 4
[grid,states,size_x,size_y] = gridworld(4,4);

%% Initialization 
% state-value function = Vpi
Vpi = zeros(size_x,size_y);
% uniform policy
Pi = 0.25*ones(size_x,size_y,4);
% discount factor
gamma = 1;
% not in place parameter
V_buffer = zeros(size_x,size_y);

%% Computation
% looping parameters
convergence_threshold = 0.0001;
iteration = 0;
delta = 1e10;

policy_stable = false;
Pi_next = zeros(size_x,size_y,4);
policy = string(zeros(size_x,size_y));
policy(:,:) = "UpBottomLeftRight";
actions = ["Up","Down","Left","Right"];

while ~policy_stable 
    
    %% Policy Evaluation
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
                    policy_at_s = reshape(Pi(i,j,:),[1,4]);
                    Vs = policy_at_s*(all_reward + gamma*all_next_state_value);
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
    
    
    %% Policy Improvement
    policy_stable = true;
    old_policy = policy;
    for i = 1:size_x
        for j = 1:size_y
            old_Pi_at_s = reshape(Pi(i,j,:),[4,1]);

            value = max(old_Pi_at_s);
            
            position_action = ismember(old_Pi_at_s,value)';

            old_policy = string;
            for k = 1:length(position_action)
                if position_action(k)
                    old_policy = old_policy + actions(k);
                end
            end
            
            
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

                Qpi =  (all_reward + gamma*all_next_state_value);
                value = max(Qpi);
                position_action = ismember(Qpi,value)';

                new_Pi_at_s = position_action/sum(position_action);
                Pi_next(i,j,:) = new_Pi_at_s;

                new_policy = string;
                for k = 1:length(position_action)
                    if position_action(k)
                        new_policy = new_policy + actions(k);
                    end
                end
                policy(i,j) = new_policy;
                
                % check if policy at each state is stable
                if old_policy ~= policy(i,j)
                    policy_stable = false;
                end
            else
                policy(i,j) = "";
            end
        end
    end
    
    
    Pi = Pi_next;
    
    if policy_stable
        break
    end
end

disp("V* = ")
disp(Vpi)
disp("pi* = ")
disp(policy)




