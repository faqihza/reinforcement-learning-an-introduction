clear
clc


gridworld = GridWorld(10,10,64,1);

% add new player in gridworld
epsilonGreedy = 0.1;
discountFactor = 0.1;
nStep = 10;
stepSize = 0.5;
player = Player(gridworld,epsilonGreedy,discountFactor,nStep,stepSize);
% put player on state 10


actions = ["up","down","right","left"];

player.initState(27);

totalEpisode = 1000;
updateView = 10;
countView = 0;
frameCount = 0;

for i=1:totalEpisode
    timeStep = 1;
    isFinish = false;
    player.reset(27);
    
    while (~isFinish)
        isFinish = player.move(timeStep);
        timeStep = timeStep + 1;
    end
    
    countView = countView + 1;
    if countView == updateView
        frameCount = frameCount + 1;
        drawnow;
        pause(0.1);
        u.Value = frameCount;
        updateView = updateView + 10;
    end
end

% optimal policy
isFinish = false;
player.reset(27);
while (~isFinish)
    isFinish = player.greedyMove();
end

