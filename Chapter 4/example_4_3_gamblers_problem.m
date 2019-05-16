clear
clc


%% environement variables

probability_heads = 0.4;
probability_tails = 1 - probability_heads;

% amount of money as states
states = 0:100; 
num_states = length(states);

rewards = zeros(num_states,1);
rewards(end) = 1;

%% Value Iteration

% initialize state value function
Vpi = zeros(num_states,1);
Vpi(end) = 0;
gamma = 1; % undiscounted

% iteration parameter
thetaThreshold = 1e-8;
iteration_sweep = [1 2 3 32];
index_sweep = 1;
delta = +inf;
iteration = 0;

% initialize figure
figure(1)
clf
xlabel('Capital')
ylabel('Value estimates');

while delta > thetaThreshold
    iteration = iteration + 1;
    delta = 0;
    
    % loop for each state Non Terminal
    for Si = 2:100
        % Vs old
        Vs = Vpi(Si);
        v = Vs;
        
        state = states(Si);
        
        available_actions = 1:min(state,100-state); 
        
        Qpi = zeros(length(available_actions),1);
        % Vs new, calculate state value function for each actions
        for Ai = 1:length(available_actions)
            
            stakes = available_actions(Ai);
            % changing state
            state_next_heads = min(100,state + stakes);
            state_next_tails = max(0,state - stakes);
            
            next_heads_index = state_next_heads + 1;
            next_tails_index = state_next_tails + 1;
            
            Vpi_heads = Vpi(next_heads_index);
            Vpi_tails = Vpi(next_tails_index);
            
            % get reward
            reward_next_heads = rewards(next_heads_index);
            reward_next_tails = rewards(next_tails_index);
            
            p_heads = probability_heads;
            p_tails = probability_tails;            
            
            Qpi(Ai) =   p_heads * (reward_next_heads + gamma*Vpi_heads) + ...
                        p_tails * (reward_next_tails + gamma*Vpi_tails);
        end
        
        Vs = max(Qpi);
        Vpi(Si) = Vs;
        delta = max(delta,abs(v - Vs));
    end
    
    if index_sweep <= length(iteration_sweep) && iteration == iteration_sweep(index_sweep)
        index_sweep = index_sweep + 1;

        figure(1)
        hold on
        plot(states(2:100),Vpi(2:100))
        hold off
        
    end
end

figure(1)
hold on
plot(states(2:100),Vpi(2:100));
legend('sweep 1','sweep 2','sweep 3','final value function');
hold off

%% output a deterministic policy, Greedy policy

epsilon = 1e-8;
Policy_stakes = zeros(num_states-2,1);

% loop for each state
for Si = 2:100
    
    % Vs old
    Vs = Vpi(Si);
    v = Vs;

    state = states(Si);

    available_actions = 1:min(state,100-state); 

    Qpi = zeros(length(available_actions),1);
    best_value = -Inf;
    best_index = 0;
    % Vs new, calculate state value function for each actions
    for Ai = 1:length(available_actions)

        stakes = available_actions(Ai);
        % changing state
        state_next_heads = min(100,state + stakes);
        state_next_tails = max(0,state - stakes);

        next_heads_index = state_next_heads + 1;
        next_tails_index = state_next_tails + 1;

        Vpi_heads = Vpi(next_heads_index);
        Vpi_tails = Vpi(next_tails_index);

        % get reward
        reward_next_heads = rewards(next_heads_index);
        reward_next_tails = rewards(next_tails_index);

        p_heads = probability_heads;
        p_tails = probability_tails;            

        
        Qpi(Ai) =   p_heads * (reward_next_heads + gamma*Vpi_heads) + ...
                    p_tails * (reward_next_tails + gamma*Vpi_tails);
                
        if (best_value < (Qpi(Ai) - epsilon) )
            best_value = Qpi(Ai);
            best_index = Ai;
        end
    end
    Policy_stakes(Si) = available_actions(best_index);
end

figure(2)
stairs(states(2:100),Policy_stakes(2:100));
xlabel('Capital');
ylabel(sprintf('Final\npolicy\n(stake)'), 'Rotation',0,'Position',[-10,22,-1]);






