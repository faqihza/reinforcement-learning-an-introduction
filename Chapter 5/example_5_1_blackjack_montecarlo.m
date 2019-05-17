clear
clc

%% Blackjack Game Play


TOTAL_GAMES = 500000;
TEST_EPISODE = 100000;

% states
player_possible_sum = 12:21;
dealer_showing_card = 1:13;
ace_status = [1 2]; %["not usable","usable"];

state_matrix_size = [length(player_possible_sum), length(dealer_showing_card), length(ace_status)];

n_states = length(player_possible_sum)*length(dealer_showing_card)*length(ace_status);

% actions
player_actions = ["hit","stick"];


%% Monte Carlo Method 

% Initialization

% Policy
player_sticks_at = [20 21];
Policy_player = string(zeros(length(player_possible_sum),1));

for i=1:length(player_possible_sum)
    if ismember(player_possible_sum(i),player_sticks_at)
        Policy_player(i) = player_actions(2);
    else
        Policy_player(i) = player_actions(1);
    end
end

% To be a State-value function
Sreturns = zeros(length(player_possible_sum), length(dealer_showing_card), length(ace_status));
Scounts = zeros(length(player_possible_sum), length(dealer_showing_card), length(ace_status));


%% Computation


for game_num = 1:TOTAL_GAMES
    
    % initialize deck per game
    deck = shuffle_cards();
    
    % player gets first two cards  
    player_cards = deck(1:2);
    [player_value, usable_ace] = hands_value(player_cards);
    deck(1:2) = []; % remove cards from deck
    
    % dealer gets two cards
    dealer_cards = deck(1:2);
    dealer_value = hands_value(dealer_cards);
    dealer_showing = dealer_cards(1);
    deck(1:2) = []; % remove cards from deck
    
    % player with less than 12 always hits
    while player_value < 12
        player_cards(end + 1) = deck(1); % hit
        deck(1) = []; % remove card from deck
        [player_value, usable_ace] = hands_value(player_cards);
    end
    
    % state depends on current player sum, dealer show card, usable ace
    state_visits = []; % start with empty history
    state_visits(1,:) = [player_value, dealer_showing, usable_ace];
    
    % policy at player_value in (12-21)
    policy_at_state = Policy_player(player_value - 11);
    
    while (policy_at_state == "hit" && player_value < 22)
        player_cards(end + 1) = deck(1);
        deck(1) = [];
        player_value = hands_value(player_cards);
        state_visits(end+1,:) = [player_value, dealer_showing, usable_ace];
        
        if player_value > 21
            break;
        else
            policy_at_state = Policy_player(player_value - 11);
        end
    end
    
    % policy at dealer (hit until hand value is 17)
    
    while (dealer_value < 17)
        dealer_cards(end + 1) = deck(1);
        deck(1) = [];
        dealer_value = hands_value(dealer_cards);
    end
    
    % calculate rewards
    reward = calculate_reward(player_value,dealer_value);
    
    n_state_visited = size(state_visits,1);
    

    for si = 1:n_state_visited
        
        player_value_at_state = state_visits(si,1);
        dealer_showing_at_state = state_visits(si,2);
        usable_ace_at_state = state_visits(si,3);
        
        if player_value_at_state >= 12 && player_value_at_state <= 21
            state_index = sub2ind(state_matrix_size,...
                                  player_value_at_state - 11,...
                                  dealer_showing_at_state,...
                                  usable_ace_at_state);
           
            Scounts(state_index) = Scounts(state_index) + 1;
            Sreturns(state_index) = Sreturns(state_index) + reward; 
        end
    end
    
    if game_num == TEST_EPISODE
        Vpi = Sreturns./Scounts;

        Vpi_non_usable_ace = Vpi(:,:,1);
        Vpi_usable_ace = Vpi(:,:,2);

        figure(1)
        subplot(2,1,1);
        mesh(dealer_showing_card,player_possible_sum,Vpi_usable_ace);
        xlabel( 'dealer showing' ); ylabel( 'player sum' ); axis xy; view([33,39]);
        title( 'usable ace: 100000 Episodes' )
        subplot(2,1,2);
        mesh(dealer_showing_card,player_possible_sum,Vpi_non_usable_ace);
        xlabel( 'dealer showing' ); ylabel( 'player sum' ); axis xy; view([33,39]);
        title( 'no usable ace' );
    
    end
end

Vpi = Sreturns./Scounts;

Vpi_non_usable_ace = Vpi(:,:,1);
Vpi_usable_ace = Vpi(:,:,2);


figure(2)
subplot(2,1,1);
mesh(dealer_showing_card,player_possible_sum,Vpi_usable_ace);
xlabel( 'dealer showing' ); ylabel( 'player sum' ); axis xy; view([33,39]);
title( 'usable ace: 500000 Episodes' )
subplot(2,1,2);
mesh(dealer_showing_card,player_possible_sum,Vpi_non_usable_ace);
xlabel( 'dealer showing' ); ylabel( 'player sum' ); axis xy; view([33,39]);
title( 'no usable ace' );

















