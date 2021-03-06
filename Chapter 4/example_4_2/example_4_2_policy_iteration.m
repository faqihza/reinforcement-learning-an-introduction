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
max_car_transfer = 5;
cost_transfer = 2;

[Pa,Ra] = jacks_car_rental_probability_and_reward(1,false,max_car,request_a,return_a);
[Pb,Rb] = jacks_car_rental_probability_and_reward(2,false,max_car,request_b,return_b);

state_location_a = 0:max_car;
state_location_b = 0:max_car;

%% initialize
% state-value function
Vpi = zeros(max_car+1);
% policy
Pi = zeros(max_car+1);
% gamma
gamma = 0.9;
% not in-place parameter
V_buffer = zeros(max_car+1);
Pi_buffer = zeros(max_car+1);

fig_num = 3;
figure(fig_num);
surface(state_location_a,state_location_b,Pi);
xlabel("#cars at second location");
ylabel("#cars at first location");
colorbar;

%% Computation
% looping parameters
convergence_threshold = 0.0001;
maximum_iteration = 100;
iteration = 0;
delta = 1e10;
policy_stable = false;

while ~policy_stable 
    
    iteration = 0;
    delta = 1e10;
    %% Policy Evaluation
    while (delta > convergence_threshold && iteration <= maximum_iteration)
        delta = 0;
        
        % loop for each state [cars in a, cars in b]
        for s_a = 1:length(state_location_a)
            for s_b = 1:length(state_location_b)
%                 str = sprintf('state a = %d, state b = %d\n',s_a,s_b);
%                 disp(str);
                
                % get old state value function
                Vs = Vpi(s_a,s_b);
                v = Vs;
                
                % get old policy of transfer car
                pi_s = Pi(s_a,s_b);
                
                % transfer cars
                % -5 < number transfer < +5
                number_car_in_a = state_location_a(s_a);
                number_car_in_b = state_location_b(s_b);
                num_car_transfer = max(-number_car_in_b,min(pi_s,number_car_in_a)); % for car < maximum transfer
                num_car_transfer = max(-max_car_transfer, min(max_car_transfer,num_car_transfer)); % for car > maximum transfer
                
                % calculate cars in the morning
                number_car_in_a_morning = number_car_in_a - num_car_transfer;
                number_car_in_b_morning = number_car_in_b + num_car_transfer;
                
                morning_state_a = number_car_in_a_morning + 1;
                morning_state_b = number_car_in_b_morning + 1;
                
                % calculate all possible next state
                % Pa[morning,evening];
                
                reward_a = Ra(number_car_in_a_morning + 1);
                reward_b = Rb(number_car_in_b_morning + 1);
                
                cost_trans = 2*abs(num_car_transfer);
                
                % calculate state value function 
                Vs = -cost_trans;
                for evening_state_a = 1:length(state_location_a)
                    for evening_state_b = 1:length(state_location_b)
                        p_a_next = Pa(morning_state_a, evening_state_a);
                        p_b_next = Pb(morning_state_b, evening_state_b);
                        Vs = Vs + p_a_next*p_b_next*(reward_a + reward_b + gamma*Vpi(evening_state_a,evening_state_b));
                    end
                end
                
                V_buffer(s_a,s_b) = Vs;
                delta = max([delta, abs(v - Vs)]);
                disp('delta');
                disp(delta);
            end
        end
        iteration = iteration + 1;
        Vpi = V_buffer;
    end
    
    
    %% Policy Improvement
    policy_stable = true;
    for s_a = 1:length(state_location_a)
        for s_b = 1:length(state_location_b)
            old_pi = Pi(s_a,s_b);
            
            % transfer car
            number_car_in_a = state_location_a(s_a);
            number_car_in_b = state_location_b(s_b);
            available_car_transfer_a = min(number_car_in_a,max_car_transfer);
            available_car_transfer_b = min(number_car_in_b,max_car_transfer);
            
            available_action_in_state = -available_car_transfer_b:available_car_transfer_a;
            number_action = length(available_action_in_state);
            Qpi_all = zeros(number_action,1);
            for i = 1:number_action
                num_car_transfer = available_action_in_state(i);
                                
                % calculate cars in the morning
                number_car_in_a_morning = max(0,min(max_car,number_car_in_a - num_car_transfer));
                number_car_in_b_morning = max(0,min(max_car,number_car_in_b + num_car_transfer));
                
                morning_state_a = number_car_in_a_morning + 1;
                morning_state_b = number_car_in_b_morning + 1;
                
                % calculate all possible next state
                % Pa[morning,evening];
                
                reward_a = Ra(morning_state_a);
                reward_b = Rb(morning_state_b);
                
                cost_trans = 2*abs(num_car_transfer);
                
                % calculate state value function 
                Qpi = -cost_trans;
                for evening_state_a = 1:length(state_location_a)
                    for evening_state_b = 1:length(state_location_b)
                        p_a_next = Pa(morning_state_a, evening_state_a);
                        p_b_next = Pb(morning_state_b, evening_state_b);
                        Qpi = Qpi + p_a_next*p_b_next*(reward_a + reward_b + gamma*Vpi(evening_state_a,evening_state_b));
                    end
                end
                Qpi_all(i) = Qpi;
            end
            
            [value,loc] = max(Qpi_all);
            
            new_pi = available_action_in_state(loc);
            Pi_buffer(s_a,s_b) = new_pi;
            
            if old_pi ~= new_pi
                policy_stable = false;
            end
        end
    end
    
    Pi = Pi_buffer;
    fig_num = fig_num + 1;
    figure(fig_num);
    surface(state_location_a,state_location_b,Pi);
    xlabel("#cars at second location");
    ylabel("#cars at first location");
    colorbar;
    
    drawnow;
    if policy_stable
        break
    end
end
