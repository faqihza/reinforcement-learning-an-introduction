classdef Player < handle
    %PLAYER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        posX
        posY
        state
        arena
        canvas
    end
    
    methods
        
        function self = Player(arena)
            self.arena = arena;
        end
        
        function setState(self,state)
            self.state = state;
            [self.posY,self.posX] = ind2sub(self.arena.size,state);
            initDraw(self);
        end
        
        function moveUp(self)
            dY = 0;
            newPosY = self.posY + 1;
            if newPosY <= self.arena.sizeY
                self.posY = newPosY;
                dY = 1;
            end
            updateDraw(self,0,dY);
            self.state = self.arena.getState(self.posX,self.posY);
        end
        
        function moveDown(self)
            dY = 0;
            newPosY = self.posY - 1;
            if newPosY > 0
                self.posY = newPosY;
                dY = -1;
            end
            updateDraw(self,0,dY);
            self.state = self.arena.getState(self.posX,self.posY);
        end
        
        function moveRight(self)
            dX = 0;
            newPosX = self.posX + 1;
            if newPosX <= self.arena.sizeX
                self.posX = newPosX;
                dX = 1;
            end
            updateDraw(self,dX,0);
            self.state = self.arena.getState(self.posX,self.posY);
        end
        
        function moveLeft(self)
            dX = 0;
            newPosX = self.posX - 1;
            if newPosX > 0
                self.posX = newPosX;
                dX = -1;
            end
            updateDraw(self,dX,0);
            self.state = self.arena.getState(self.posX,self.posY);
        end
        
        function initDraw(self)
            self.canvas = patch();
            
            angle = linspace(0,2*pi,20);
            radius = 0.3;
            self.canvas.XData = radius*sin(angle) + self.posX - 0.5;
            self.canvas.YData = radius*cos(angle) + self.posY - 0.5;
            self.canvas.FaceColor = 'red';
            self.canvas.FaceAlpha = 0.3;
            self.canvas.EdgeAlpha = 0;
        end
        
        function updateDraw(self,x,y)
            self.canvas.XData = self.canvas.XData + x;
            self.canvas.YData = self.canvas.YData + y;
        end
    end
end

