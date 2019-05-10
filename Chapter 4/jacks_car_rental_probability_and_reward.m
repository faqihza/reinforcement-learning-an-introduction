function [probability_possible_car_morning,possible_average_reward] = jacks_car_rental_probability_and_reward(fig,show,max_car,request_rate,return_rate)
    
    possible_car = 0:max_car;

    % calculate probability of car at the end of the day
    probability_request = poisspdf(possible_car,request_rate);
    probability_return = poisspdf(possible_car,return_rate);
    probability_possible_car_morning = zeros(length(possible_car),length(possible_car));
    
    for possible_car_morning = possible_car
        for number_request = 0:max_car
            for number_return = 0:max_car
                approve_request = min(possible_car_morning,number_request);
                final_possible_car = max(0, min(max_car, possible_car_morning + number_return - approve_request));
                probability_final_possible_car = probability_request(number_request+1)*probability_return(number_return+1);
                probability_possible_car_morning(possible_car_morning + 1, final_possible_car + 1) = probability_possible_car_morning(possible_car_morning + 1, final_possible_car + 1) + probability_final_possible_car;
            end
        end 
    end

    % calculate expected reward based on available car in the morning
    possible_average_reward = zeros(1,length(possible_car));

    for possible_car_morning = possible_car
        expected_money = 0;
        for number_request = 0:max_car
            for number_return = 0:max_car
                approve_request = min(possible_car_morning + number_return,number_request);

                expected_money = expected_money + 10*approve_request*probability_request(number_request+1)*probability_return(number_return+1);
            end
        end
        clc
        possible_average_reward(possible_car_morning+1) = expected_money;
    end
    
    if show
        figure(fig)
        subplot(1,2,1);
        surface(0:max_car,0:max_car,probability_possible_car_morning);
        colorbar;
        xlabel('num at the end of the day');
        ylabel('num in the morning');
        subplot(1,2,2);
        plot(possible_car,possible_average_reward)
        xlabel('num car in the morning');
        ylabel('expected money earned');
    end
end

