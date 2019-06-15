function [cards_sum_value,usable_ace] = hands_value(cards)
%HANDS_VALUE Summary of this function goes here
%   Detailed explanation goes here

% mapping faces to 10;
cards_sum_value = sum(cards);

% check if usable ace is exist
if (any(cards==1)) && (cards_sum_value<=11)
    cards_sum_value = cards_sum_value + 10;
    usable_ace = 2;
else
    usable_ace = 1;
end


end

