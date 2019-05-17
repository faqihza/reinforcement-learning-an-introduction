function reward = calculate_reward(player_value,dealer_value)
%CALCULATE_REWARD Summary of this function goes here
%   Detailed explanation goes here

% player goes bust
if player_value > 21
    reward = -1;
    return;
end

% dealer goes bust
if dealer_value > 21
    reward = 1;
    return;
end

% a tie
if player_value == dealer_value
    reward = 0;
    return;
end

% no one busted and no tie
if player_value > dealer_value
    reward = 1;
else
    reward = -1;
end

end