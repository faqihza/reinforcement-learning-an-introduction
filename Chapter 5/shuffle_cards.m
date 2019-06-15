function deck = shuffle_cards()
cards_index = randperm(52); % 52 total of cards

deck = mod(cards_index - 1,13) + 1;
% maps card index to (1:13) 10,11,12,13 -> 10
deck = min(deck,10);
end

