function [reward, status] = calculate_reward(player_value,dealer_value)
%CALCULATE_REWARD Summary of this function goes here
%   Detailed explanation goes here

% player goes bust
if player_value > 21
    reward = -1;
    status = "player goes bust";
    return;
end

% dealer goes bust
if dealer_value > 21
    reward = 1;
    status = "dealer goes bust";
    return;
end

% a tie
if player_value == dealer_value
    reward = 0;
    status = "tie game";
    return;
end

% no one busted and no tie
if player_value > dealer_value
    reward = 1;
    status = "player wins";
else
    reward = -1;
    status = "dealer wins";
end

end