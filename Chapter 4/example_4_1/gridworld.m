function [grid,states,row_size,column_size] = gridworld(row_size,column_size)

%% creating Environment GridWorld
    
    number_of_states = row_size*column_size;
    states = reshape(0:(number_of_states-1),[column_size,row_size])';

    grid = struct();
    for row=1:row_size
        for column=1:column_size

            str_state = sprintf("grid.state_%d",states(row,column));
            if (row == 1 && column == 1) || (row == size(states,1) && column == size(states,2))
                eval(str_state +".terminate = true;");
                continue;
            end

            top_row = 1;
            bottom_row = size(states,1);
            left_column = 1;
            right_column = size(states,2);

            eval(str_state +".terminate = false;");
            %% ACTION - UP
            up = struct();

            if ( row == top_row) % top row
                up.reward = -1;
                up.next_state_row = row;
                up.next_state_col = column;
            elseif (row == (top_row + 1) && column == left_column) % second row move to termination (state-4) 
                up.reward = -1;
                up.next_state_row = row-1;
                up.next_state_col = column;
            else % other states
                up.reward = -1;
                up.next_state_row = row-1;
                up.next_state_col = column;
            end

            %% ACTION - DOWN
            down = struct();
            if ( row == bottom_row) % bottom row
                down.reward = -1;
                down.next_state_row = row;
                down.next_state_col = column;
            elseif (row == bottom_row - 1 && column == right_column) % second bottom row move to termination (state-11) 
                down.reward = -1;
                down.next_state_row = row+1;
                down.next_state_col = column;
            else % other states
                down.reward = -1;
                down.next_state_row = row+1;
                down.next_state_col = column;
            end

            %% ACTION - LEFT
            left = struct();
            if ( column == left_column) % most left col
                left.reward = -1;
                left.next_state_row = row;
                left.next_state_col = column;
            elseif (row == top_row && column == left_column + 1) % second most left col move to termination (state-1) 
                left.reward = -1;
                left.next_state_row = row;
                left.next_state_col = column-1;
            else % other states
                left.reward = -1;
                left.next_state_row = row;
                left.next_state_col = column-1;
            end

            %% ACTION - RIGHT
            right = struct();
            if ( column == right_column) % most right col
                right.reward = -1;
                right.next_state_row = row;
                right.next_state_col = column;
            elseif (row == bottom_row && column == left_column - 1) % second most right col move to termination (state-14) 
                right.reward = -1;
                right.next_state_row = row;
                right.next_state_col = column+1;
            else % other states
                right.reward = -1;
                right.next_state_row = row;
                right.next_state_col = column+1;
            end

            eval(str_state + ".up = up;");
            eval(str_state + ".down = down;");
            eval(str_state + ".left = left;");
            eval(str_state + ".right = right;");
        end
    end

end

