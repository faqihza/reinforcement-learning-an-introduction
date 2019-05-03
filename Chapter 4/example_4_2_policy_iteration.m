clear
clc


%% setup lambda
% location a
request_a = 3;
return_a = 3;
% location b
request_b = 4;
return_b = 2;

lambda_request = [3 4]; 
lambda_return = [3 2];

max_car = 20;

[Pa,Ra] = jacks_car_rental_probability_and_reward(max_car,request_a,return_a);
[Pb,Rb] = jacks_car_rental_probability_and_reward(max_car,request_b,return_b);

state_location_a = 0:max_car;
state_location_b = 0:max_car;

%% initialize
% state-value function
Vpi = zeros(max_car+1);
% policy
Pi = zeros(max_car+1);

figure(1);
surface(state_location_a,state_location_b,Pi);
xlabel("#cars at second location");
ylabel("#cars at first location");
colorbar;

%% Computation
% looping parameters
convergence_threshold = 0.0001;
iteration = 0;
delta = 1e10;
policy_stable = false;

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

                Qpi =  (all_reward + gamma*all_next_state_value);
                value = max(Qpi);
                position_action = ismember(Qpi,value)';

                new_Pi_at_s = position_action/sum(position_action);
                Pi_next(row,column,:) = new_Pi_at_s;

                new_policy = string;
                for k = 1:length(position_action)
                    if position_action(k)
                        new_policy = new_policy + actions(k);
                    end
                end
                policy(row,column) = new_policy;
                
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
