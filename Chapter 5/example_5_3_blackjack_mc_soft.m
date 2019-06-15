clear
clc

%% Blackjack Game Play

TOTAL_GAMES = 5e7;

% states
player_possible_sum = 12:21;
dealer_showing_card = 1:10; % consider 11,12,13 as 10
ace_status = [1 2]; % ["not usable","usable"];

% actions
player_actions = ["stick","hit"];

%% Monte Carlo Exploring Starts Method 

% Initialization

% Monte Carlo parameters

% our initial epsilon-soft policy
Pi = 0.5*ones(length(player_possible_sum), length(dealer_showing_card), length(ace_status), length(player_actions)); 
Pi_optimal = ones(length(player_possible_sum), length(dealer_showing_card), length(ace_status)); 

Q = zeros(length(player_possible_sum), length(dealer_showing_card), length(ace_status), length(player_actions));
% Q = -1 + (1+1).*rand(length(player_possible_sum), length(dealer_showing_card), length(ace_status), length(player_actions));
V = zeros(length(player_possible_sum), length(dealer_showing_card), length(ace_status));

Returns = zeros(length(player_possible_sum), length(dealer_showing_card), length(ace_status), length(player_actions));
Counts = zeros(length(player_possible_sum), length(dealer_showing_card), length(ace_status), length(player_actions));
Q_matrix_size = [length(player_possible_sum), length(dealer_showing_card), length(ace_status), length(player_actions)];
state_matrix_size = [length(player_possible_sum), length(dealer_showing_card), length(ace_status)];

% Epsilon-soft policy
% epsilon = 0; % full greedy
epsilon = 0.05; % e-soft
% epsilon = 1; % random exploring

%% Computation

V_non_usable_ace = V(:,:,1);
V_usable_ace = V(:,:,2);

Pi_optimal_non_usable_ace = flip(Pi_optimal(:,:,1));
Pi_optimal_usable_ace = flip(Pi_optimal(:,:,2));
str = sprintf("usable ace: %d Episodes",0);

figure(1)
subplot(2,1,1);
v_ace = mesh(dealer_showing_card,player_possible_sum,V_usable_ace);
xlabel( 'dealer showing' ); ylabel( 'player sum' ); axis xy; view([33,39]);
v_title = title( str );
subplot(2,1,2);
v_non_ace = mesh(dealer_showing_card,player_possible_sum,V_non_usable_ace);
xlabel( 'dealer showing' ); ylabel( 'player sum' ); axis xy; view([33,39]);
title( 'no usable ace' );

figure(2)
subplot(2,1,1);
pi_ace = imagesc(dealer_showing_card,player_possible_sum,Pi_optimal_usable_ace); colorbar;
yticklabels(fliplr(player_possible_sum));
xlabel( 'dealer showing' ); ylabel( 'player sum' )
pi_title = title( str );
subplot(2,1,2);
pi_non_ace = imagesc(dealer_showing_card,player_possible_sum,Pi_optimal_non_usable_ace);  colorbar;
yticklabels(fliplr(player_possible_sum));
xlabel( 'dealer showing' ); ylabel( 'player sum' )
title( 'no usable ace' );

step_for_display = 10000;
count_for_display = 0;
tic
fprintf("Game Number | Player Value | Dealer Value | Reward | status\n");
fprintf("------------+--------------+--------------+--------+-------\n");
for game_num = 0:TOTAL_GAMES
    
    % initialize deck per game
    deck = shuffle_cards();
    
    % player gets first two cards  
    player_cards = deck(1:2);
    [player_value, usable_ace] = hands_value(player_cards);
    deck(1:2) = []; % remove cards from deck
    
    % dealer gets two cards
    dealer_cards = deck(1:2);
    dealer_value = hands_value(dealer_cards);
    dealer_showing = dealer_cards(1); % turn 11,12,13 -> 10
    deck(1:2) = []; % remove cards from deck
    
    % player with less than 12 always hits
    while player_value < 12
        player_cards(end + 1) = deck(1); % hit
        deck(1) = []; % remove card from deck
        [player_value, usable_ace] = hands_value(player_cards);
    end
    
    % action and state depends on current player sum, dealer show card, usable ace
    action_state_visits = []; % start with empty history
    greedy_status = string();
    available_action(:) = Pi(player_value - 11, dealer_showing, usable_ace,:);
    [greedy_status(end), action_to_take] = soft_policy(available_action, epsilon);
    action_state_visits(1,:) = [player_value, dealer_showing, usable_ace, action_to_take];
    
    %% Next Move
    while (action_state_visits(end,4) == 2 && player_value < 22)
        
        % take next card
        player_cards(end + 1) = deck(1); % hit one card
        deck(1) = []; % remove card from deck
        [player_value, usable_ace] = hands_value(player_cards); % calculate current player hand value 
        action_state_visits(end+1,:) = [player_value, dealer_showing, usable_ace, 1]; % default action to stick
        
        if player_value <= 21 % take next policy if the player value is less than 21
            available_action(:) = Pi(player_value - 11, dealer_showing, usable_ace,:);
            [greedy_status(end + 1), action_to_take] = soft_policy(available_action, epsilon);
            action_state_visits(end,4) = action_to_take;
        end
        
    end
    
    %% policy at dealer (hit until hand value is 17)

    while (dealer_value < 17)
        dealer_cards(end + 1) = deck(1);
        deck(1) = [];
        dealer_value = hands_value(dealer_cards);
    end
    
    %% calculate rewards
    [reward, status] = calculate_reward(player_value,dealer_value);
    
    %% policy evaluation and Policy Improvement (GPI) per episode or game
    n_action_state_visited = size(action_state_visits,1);
    for state_number = 1:n_action_state_visited
        
        % get state and action in current episode
        player_value_in_episode = action_state_visits(state_number,1);
        
        % evaluate only for possible player sum
        if player_value_in_episode >= 12 && player_value_in_episode <= 21
            
            dealer_showing_in_episode = action_state_visits(state_number,2);
            usable_ace_in_episode = action_state_visits(state_number,3);
            action_taken_in_episode = action_state_visits(state_number,4);
            
            a = player_value_in_episode - 11;
            b = dealer_showing_in_episode;
            c = usable_ace_in_episode;
            d = action_taken_in_episode;
           
            Counts(a,b,c,d) = Counts(a,b,c,d) + 1;          % <- visited times for each state 
            Returns(a,b,c,d) = Returns(a,b,c,d) + reward;   % <- accumulated reward for each state
            Q(a,b,c,d) = Returns(a,b,c,d)/Counts(a,b,c,d);  % <- average for each state
                                
            % Q(a,b,c,1) <- Stick action
            % Q(a,b,c,2) <- Hit action
            % max(Q(a,b,c,:)) <- get maximum action-state value, and its
            % maximum action
            [Q_at_greedy_action, greedy_action] = max(Q(a,b,c,:)); % get maximum between 2 actions
            
            % |A(s)| <-- cardinality = number of member in a set A(s)
            num_action = length(Q(a,b,c,:));
            for action = 1:num_action
                if action == greedy_action
                    Pi(a,b,c,action) = 1 - epsilon + (epsilon/num_action);
                else
                    Pi(a,b,c,action) = (epsilon/num_action);
                end
            end
            
            %% policy improvement
            [action_value, optimal_action] = max(Pi(a,b,c,:));
            Pi_optimal(a,b,c) = optimal_action;  
            
            %% optimal state value 
            V(a,b,c) = Q_at_greedy_action;
        end          
    end    
    
    %% reporting
    
    if count_for_display == game_num
        pi_non_ace.CData = flip(Pi_optimal(:,:,1));
        pi_ace.CData = flip(Pi_optimal(:,:,2));
        v_ace.ZData = V(:,:,1);
        v_ace.CData = V(:,:,1);
        v_non_ace.ZData = V(:,:,2);
        v_non_ace.CData = V(:,:,2);
        str = sprintf("usable ace: %d Episodes",game_num);
        v_title.String = str;
        pi_title.String = str;
        drawnow;
        count_for_display = count_for_display + step_for_display;
        fprintf(sprintf("%12d|      %d      |      %d      |   %+d   | %s\n",game_num,player_value,dealer_value,reward,status));
    end

end

toc