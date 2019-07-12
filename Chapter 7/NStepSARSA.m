classdef NStepSARSA < handle
    %NSTEPSARSA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Q % Action-State value
        policy % eGreedy policy
        G % complete return
        episodeState % record for state
        episodeAction % record for state
        episodeReward % record for state
        epsilonGreedy
        
        stepSize
        discountFactor
        nStep
        
        linePolicy
    end
    
    methods
        function self = NStepSARSA(stateNum,actionNum,nStep,epsilonGreedy,discountFactor,stepSize)
            self.Q = zeros(stateNum,actionNum);
            self.policy = ones(stateNum,actionNum)./actionNum;
            self.epsilonGreedy = epsilonGreedy;
            self.discountFactor = discountFactor;
            self.nStep = nStep;
            self.stepSize = stepSize;
        end
        
        function value = getQvalue(self,state,action)
            value = self.Q(state,action);
        end

        function reset(self)
            self.episodeState  =[]; % record for state
            self.episodeAction = [];% record for state
            self.episodeReward = [];% record for state
        end
        
        function action = getGreedyAction(self,state)
            actionValueAtState = self.Q(state,:);
            
            [actionValue,~] = max(actionValueAtState);
            
            % check other greedy action
            temp = ones(1,length(actionValueAtState))*actionValue;
            status = ismember(actionValueAtState,actionValue);

            % put temporary index on the value with true status
            tempIndex = zeros(1,length(status));
            index = 1;
            for i = 1:length(status)
                if status(i)
                    tempIndex(i) = index;
                    index = index + 1;
                else
                    tempIndex(i) = 0;
                end
            end

            numberOfGreedyAction = max(tempIndex);
            % if more than one greedy action

            % put equal probability
            actionIndex = randi(numberOfGreedyAction);
            [~,location] = ismember(actionIndex,tempIndex);
            action = location;
            
        end
        
        function [greedyStatus,action] = getAction(self,state)
            actionValueAtState = self.Q(state,:);

            if rand < self.epsilonGreedy % non greedy random
               nAction = length(actionValueAtState);
               actionToTake = unidrnd(nAction);
               greedyStatus = "not greedy";
            else % greedy
                [actionValue,~] = max(actionValueAtState);
            
                % check other greedy action
                temp = ones(1,length(actionValueAtState))*actionValue;
                status = ismember(actionValueAtState,actionValue);

                % put temporary index on the value with true status
                tempIndex = zeros(1,length(status));
                index = 1;
                for i = 1:length(status)
                    if status(i)
                        tempIndex(i) = index;
                        index = index + 1;
                    else
                        tempIndex(i) = 0;
                    end
                end

                numberOfGreedyAction = max(tempIndex);
                % if more than one greedy action

                % put equal probability
                actionIndex = randi(numberOfGreedyAction);
                [~,location] = ismember(actionIndex,tempIndex);
                actionToTake = location;
                greedyStatus = "greedy";
            end
            action = actionToTake;
        end
        
        function learn(self,tau,T)
            
            % get last n-steps
            index = (tau): min(tau+self.nStep-1,T);
            
            % calculate n-step return
            self.G = 0;
            for i = index
                reward_i = self.episodeReward(i);
                self.G = self.G + reward_i*self.discountFactor^(i-tau);
            end
            
            % calculate the rest estimate if last state is not terminal

            if (tau+self.nStep) < T
                state_tn = self.episodeState(tau+self.nStep);
                action_tn = self.episodeAction(tau+self.nStep);
                actions = ["up","down","right","left"];
                [~,action_tn_index] = ismember(action_tn,actions);
                self.G = self.G + self.Q(state_tn,action_tn_index)*self.discountFactor^self.nStep;
            end
            
            state_tau = self.episodeState(tau);
            actions = ["up","down","right","left"];
            [~,action_tau] = ismember(self.episodeAction(tau),actions);
            self.Q(state_tau,action_tau) = self.Q(state_tau,action_tau) + self.stepSize*(self.G - self.Q(state_tau,action_tau));
%             fprintf(sprintf("update tau-%d, state-%d, action-%d, value = %f\n",tau,state_tau,action_tau,self.Q(state_tau,action_tau)));
        end
        
        function recordState(self,state)
            if isempty(self.episodeState)
                self.episodeState = state;
            else
                self.episodeState(end+1) = state;
            end
        end
        
        function recordAction(self,action)
            if isempty(self.episodeAction)
                self.episodeAction = action;
            else
                self.episodeAction(end+1) = action;
            end
        end
        
        function recordReward(self,reward)
            if isempty(self.episodeReward)
                self.episodeReward = reward;
            else
                self.episodeReward(end+1) = reward;
            end
        end
        
        
    end
    
end

