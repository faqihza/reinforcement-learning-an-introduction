clear
clc


gridworld = GridWorld(10,10,64);

% add new player in gridworld
player = Player(gridworld);
% put player on state 10
player.setState(27);

player.moveUp();
player.moveDown();
player.moveLeft();
player.moveRight();
