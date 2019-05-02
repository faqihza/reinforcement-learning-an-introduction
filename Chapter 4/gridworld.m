function [grid,states,size_x,size_y] = gridworld(size_x,size_y)

%% creating Environment GridWorld
    
    number_of_states = size_x*size_y;
    states = reshape(0:(number_of_states-1),[size_x,size_y])';

    grid = struct();
    for i=1:size_x
        for j=1:size_y

            str_state = sprintf("grid.state_%d",states(i,j));
            if (i == 1 && j == 1) || (i == size(states,1) && j == size(states,2))
                eval(str_state +".terminate = true;");
                continue;
            end

            top_row = 1;
            bottom_row = size(states,1);
            left_col = 1;
            right_col = size(states,2);

            eval(str_state +".terminate = false;");
            %% ACTION - UP
            up = struct();

            if ( i == top_row) % top row
                up.reward = -1;
                up.next_state_row = i;
                up.next_state_col = j;
            elseif (i == (top_row + 1) && j == left_col) % second row move to termination (state-4) 
                up.reward = -1;
                up.next_state_row = i-1;
                up.next_state_col = j;
            else % other states
                up.reward = -1;
                up.next_state_row = i-1;
                up.next_state_col = j;
            end

            %% ACTION - DOWN
            down = struct();
            if ( i == bottom_row) % bottom row
                down.reward = -1;
                down.next_state_row = i;
                down.next_state_col = j;
            elseif (i == bottom_row - 1 && j == right_col) % second bottom row move to termination (state-11) 
                down.reward = -1;
                down.next_state_row = i+1;
                down.next_state_col = j;
            else % other states
                down.reward = -1;
                down.next_state_row = i+1;
                down.next_state_col = j;
            end

            %% ACTION - LEFT
            left = struct();
            if ( j == left_col) % most left col
                left.reward = -1;
                left.next_state_row = i;
                left.next_state_col = j;
            elseif (i == top_row && j == left_col + 1) % second most left col move to termination (state-1) 
                left.reward = -1;
                left.next_state_row = i;
                left.next_state_col = j-1;
            else % other states
                left.reward = -1;
                left.next_state_row = i;
                left.next_state_col = j-1;
            end

            %% ACTION - RIGHT
            right = struct();
            if ( j == right_col) % most right col
                right.reward = -1;
                right.next_state_row = i;
                right.next_state_col = j;
            elseif (i == bottom_row && j == left_col - 1) % second most right col move to termination (state-14) 
                right.reward = -1;
                right.next_state_row = i;
                right.next_state_col = j+1;
            else % other states
                right.reward = -1;
                right.next_state_row = i;
                right.next_state_col = j+1;
            end

            eval(str_state + ".up = up;");
            eval(str_state + ".down = down;");
            eval(str_state + ".left = left;");
            eval(str_state + ".right = right;");
        end
    end

end

