function [grid,states,row_size,column_size] = exercise_4_2_gridworld(row_size,column_size)

%% creating Environment GridWorld
    
    number_of_states = row_size*column_size;
    states = reshape(0:(number_of_states-1),[column_size,row_size])';
    
    

    grid = struct();
    for row=1:row_size
        for column=1:column_size

            str_state = sprintf("grid.state_%d",states(row,column));
            if (row == 1 && column == 1) || (row == (size(states,1)-1) && column == size(states,2))
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
            elseif (row == bottom_row && column ~= 2) % neglected state
                up.reward = 0;
                up.next_state_row = row;
                up.next_state_col = column;
            elseif (row == bottom_row && column == 2) % additional state
                up.reward = -1;
                up.next_state_row = row-1;
                up.next_state_col = column;
            elseif (row < bottom_row)
                up.reward = -1;
                up.next_state_row = row-1;
                up.next_state_col = column;
            end

            %% ACTION - DOWN
            down = struct();
            if ( row == (bottom_row - 1)) % bottom row
                down.reward = -1;
                if (column == 2)
                    down.next_state_row = row+1;
                else
                    down.next_state_row = row;
                end
                down.next_state_col = column;
            elseif (row == bottom_row - 1 && column == right_column) % second bottom row move to termination (state-11) 
                down.reward = -1;
                down.next_state_row = row+1;
                down.next_state_col = column;
            elseif (row == bottom_row  && column ~= 2) % neglected state
                down.reward = 0;
                down.next_state_row = row;
                down.next_state_col = column;
            elseif (row == bottom_row && column == 2) % additional state
                down.reward = -1;
                down.next_state_row = row;
                down.next_state_col = column;
            elseif (row <= bottom_row)
                down.reward = -1;
                down.next_state_row = row+1;
                down.next_state_col = column;
            end

            %% ACTION - LEFT
            left = struct();
            if ( column == left_column && row ~= bottom_row) % most left col
                left.reward = -1;
                left.next_state_row = row;
                left.next_state_col = column;
            elseif (row == top_row && column == left_column + 1 && row ~= bottom_row) % second most left col move to termination (state-1) 
                left.reward = -1;
                left.next_state_row = row;
                left.next_state_col = column-1;
            elseif (row == bottom_row  && column ~= 2) % neglected state
                left.reward = 0;
                left.next_state_row = row;
                left.next_state_col = column;
            elseif (row == bottom_row && column == 2) % additional state
                left.reward = -1;
                left.next_state_row = row;
                left.next_state_col = column;
            elseif (row < bottom_row)
                left.reward = -1;
                left.next_state_row = row;
                left.next_state_col = column-1;
            end

            %% ACTION - RIGHT
            right = struct();
            if ( column == right_column && row ~= bottom_row) % most right col
                right.reward = -1;
                right.next_state_row = row;
                right.next_state_col = column;
            elseif (row == bottom_row && column == (right_column - 1) && row ~= bottom_row) % second most right col move to termination (state-14) 
                right.reward = -1;
                right.next_state_row = row;
                right.next_state_col = column+1;
            elseif (row == bottom_row  && column ~= 2) % neglected state
                right.reward = 0;
                right.next_state_row = row;
                right.next_state_col = column;
            elseif (row == bottom_row && column == 2) % additional state
                right.reward = -1;
                right.next_state_row = row;
                right.next_state_col = column;
            elseif (row < bottom_row)
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

