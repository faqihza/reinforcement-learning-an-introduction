classdef Player < handle
    %PLAYER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        posX
        posY
        state
        action
        actions
        reward
        arena
        canvas
        trail
        RL
        
        
        n
        T
        
        linePolicy
    end
    
    methods
        
        function self = Player(arena,epsilonGreedy,discountFactor,nStep,stepSize)
            self.actions = ["up","down","right","left"];
            self.arena = arena;
            stateNum = length(arena.stateIDs);
            actionNum = 4;
            self.RL = NStepSARSA(stateNum,actionNum,nStep,epsilonGreedy,discountFactor,stepSize);
        end
        
        function reset(self,state)
            self.RL.reset();
            self.state = state;
            [~,actionIndex] = self.RL.getAction(self.state);
            self.action = self.actions(actionIndex);
            
            [self.posY,self.posX] = ind2sub(self.arena.size,self.state);
            angle = linspace(0,2*pi,20);
            radius = 0.3;
            self.canvas.XData = radius*sin(angle) + self.posX - 0.5;
            self.canvas.YData = radius*cos(angle) + self.posY - 0.5;
            
            self.trail.XData = [self.posX-0.5 self.posX-0.5];
            self.trail.YData = [self.posY-0.5 self.posY-0.5];           
            
            % state and reward at timeStep = 1
            self.RL.recordState(self.state);
            self.RL.recordAction(self.action);
            self.T = inf;
        end
        
        function initState(self,state)
            self.state = state;
            [~,actionIndex] = self.RL.getAction(self.state);
            self.action = self.actions(actionIndex);
            
            initDraw(self);

            % state and reward at timeStep = 1
            self.RL.recordState(self.state);
            self.RL.recordAction(self.action);
            self.T = inf;
        end
        
        function isFinish = greedyMove(self)
            self.RL.reset();
            actionIndex = self.RL.getGreedyAction(self.state);
            self.action = self.actions(actionIndex);
            switch self.action
                case "up"
                    moveUp(self);
                case "down"
                    moveDown(self);
                case "left"
                    moveLeft(self);
                case "right"
                    moveRight(self);
                otherwise
                    disp("wrong move");
            end
            updateTrail(self)
            % update player state and check reward from environment
            self.state = self.arena.getState(self.posX,self.posY);
            
            isFinish = self.arena.checkTerminalState(self.state); 
        end
        
        function isFinish = move(self,timeStep)
            if timeStep < self.T
                % Take action at timeStep
                switch self.action
                    case "up"
                        moveUp(self);
                    case "down"
                        moveDown(self);
                    case "left"
                        moveLeft(self);
                    case "right"
                        moveRight(self);
                    otherwise
                        disp("wrong move");
                end
                updateTrail(self);

                % update player state and check reward from environment
                self.state = self.arena.getState(self.posX,self.posY);
                self.reward = self.arena.getReward(self.state);
                
                % record reward and state
                self.RL.recordReward(self.reward);
                self.RL.recordState(self.state)
                
                isTerminal = self.arena.checkTerminalState(self.state);
                if isTerminal
                    self.T = timeStep;
                else
                    % take next action and record
                    [~,actionIndex] = self.RL.getAction(self.state);
                    self.action = self.actions(actionIndex);
                    self.RL.recordAction(self.action);
                end
            end

            tau = timeStep - self.RL.nStep + 1;
            
            if tau > 0
                self.RL.learn(tau,self.T);
            end
            
            isFinish = (tau == self.T);
            
        end
        
        function moveUp(self)
            dY = 0;
            newPosY = self.posY + 1;
            if newPosY <= self.arena.sizeY
                self.posY = newPosY;
                dY = 1;
            end
            
            updateDraw(self,0,dY);
        end
        
        function moveDown(self)
            dY = 0;
            newPosY = self.posY - 1;
            if newPosY > 0
                self.posY = newPosY;
                dY = -1;
            end
            updateDraw(self,0,dY);
        end
        
        function moveRight(self)
            dX = 0;
            newPosX = self.posX + 1;
            if newPosX <= self.arena.sizeX
                self.posX = newPosX;
                dX = 1;
            end
            updateDraw(self,dX,0);
        end
        
        function moveLeft(self)
            dX = 0;
            newPosX = self.posX - 1;
            if newPosX > 0
                self.posX = newPosX;
                dX = -1;
            end
            updateDraw(self,dX,0);
        end
        
        function initDraw(self)
            [self.posY,self.posX] = ind2sub(self.arena.size,self.state);
            self.canvas = patch();
            
            angle = linspace(0,2*pi,20);
            radius = 0.3;
            self.canvas.XData = radius*sin(angle) + self.posX - 0.5;
            self.canvas.YData = radius*cos(angle) + self.posY - 0.5;
            self.canvas.FaceColor = 'red';
            self.canvas.FaceAlpha = 0.3;
            self.canvas.EdgeAlpha = 0;
            
            self.trail = line;
            self.trail.Color = 'red';
            self.trail.LineWidth = 1;
            self.trail.XData = [self.posX-0.5 self.posX-0.5];
            self.trail.YData = [self.posY-0.5 self.posY-0.5];
        end
        
        function updateTrail(self)
            self.trail.XData(end+1) = self.posX-0.5;
            self.trail.YData(end+1) = self.posY-0.5;
        end
        
        function updateDraw(self,x,y)
            self.canvas.XData = self.canvas.XData + x;
            self.canvas.YData = self.canvas.YData + y;
        end
        
    end
end

