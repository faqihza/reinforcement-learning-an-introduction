function [greedy_status, action_to_take] = soft_policy(available_action, epsilon)

    [~,greedy_action] = max(available_action);
    nAction = length(available_action);
    
    if rand < epsilon % non greedy random
       action_to_take = unidrnd(nAction);
       greedy_status = "not greedy";
    else % greedy
       action_to_take = greedy_action;
       greedy_status = "greedy";
    end

end