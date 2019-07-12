classdef GridWorld < handle
    %GRIDWORLD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sizeX;
        sizeY;
        size;
        terminalState;
        stateIDs;
        rewards;
        canvas;
    end
    
    methods
        function self = GridWorld(sizeX,sizeY,terminalPoint,reward)
            self.sizeX = sizeX;
            self.sizeY = sizeY;
            self.size = [sizeX sizeY];
            self.terminalState = terminalPoint;
            self.stateIDs = 1:sizeX*sizeY;
            self.rewards = zeros(sizeX*sizeY,1);
            self.rewards(self.terminalState) = reward;
            initDraw(self);
        end
        
        function totalState = getTotalState(self)
            totalState = length(self.stateIDs);
        end
        
        function stateID = getState(self,posX,posY)
           stateID = sub2ind(self.size,posY,posX);
        end
        
        function reward = getReward(self,state)
           reward = self.rewards(state);
        end
        
        function isTerminal = checkTerminalState(self,state)
            isTerminal = (self.terminalState == state);
        end
        
        function initDraw(self)
            figure(1);
            clf(self.canvas);
            drawGrid(self)
        end
        
        function drawGrid(self)
            self.canvas = patch();
            self.canvas.XData = [0,self.sizeX,self.sizeX,0];
            self.canvas.YData = [0,0,self.sizeY,self.sizeY];
            self.canvas.FaceColor = 'none';
            self.canvas.LineWidth = 3;
            self.canvas.EdgeAlpha = 0.5;
            self.canvas.EdgeColor = [0,0,0];
            
            ax = gca;
            ax.PlotBoxAspectRatio = [1,1,1];
            ax.DataAspectRatio = [1,1,1];
            axis(ax,'off');
            
            for i=1:self.sizeX
                line([i i],[0 self.sizeY]);
            end
            
            for i=1:self.sizeY
                line([0 self.sizeX],[i i]);
            end
            
            index = 1;
            offset =  0.5;
            for i=1:self.sizeX
                for j = 1:self.sizeY
                    if index == self.terminalState
                        patch([i-1, i, i, i-1],[j-1, j-1, j, j],'black');
                        stateIndex = text(i+offset-1,j+offset-1,'G');
                        stateIndex.Color = [1 1 1];
                        stateIndex.FontWeight = 'bold';
                    else
                        stateIndex = text(i+offset-1,j+offset-1,string(index));
                        stateIndex.Color = [0.3010 0.7450 0.9330];
                    end
                    
                    stateIndex.HorizontalAlignment = 'center';
                    stateIndex.VerticalAlignment = 'middle';
                    
                    index = index + 1;
                end
            end
        end
  
    end
end

