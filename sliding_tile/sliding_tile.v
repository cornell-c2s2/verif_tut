module sliding_tile
(
    input logic       clk,
    input logic       reset,
    input logic [1:0] direction
);

    // Define the semantics of direction
    
    localparam LEFT  = 2'b00
    localparam RIGHT = 2'b01
    localparam UP    = 2'b10
    localparam DOWN  = 2'b11

    // Instantiate game representation
    
    logic [4:0] top_left;
    logic [4:0] top_middle;
    logic [4:0] top_right;
    logic [4:0] middle_left;
    logic [4:0] middle_middle;
    logic [4:0] middle_right;
    logic [4:0] bottom_left;
    logic [4:0] bottom_middle;
    logic [4:0] bottom_right;

    logic [4:0] space_loc;

    // Determine reset state
    
    logic design_was_reset = 1'b0;

    always @( posedge clk ) begin
        if( reset ) begin
            top_left      <= 4'd5;
            top_middle    <= 4'd1;
            top_right     <= 4'd6;
            middle_left   <= 4'd2;
            middle_middle <= 4'd7;
            middle_right  <= 4'd3;
            bottom_left   <= 4'd8;
            bottom_middle <= 4'd4;
            bottom_right  <= 4'd0;
        
            space_loc     <= 4'b1010;

            design_was_reset <= 1'b1;
        end
    end

    // Determine move validity

    logic move_right_valid;
    logic move_left_valid;
    logic move_up_valid;
    logic move_down_valid;
    logic move_valid;

    assign move_right_valid = (direction==RIGHT) && (space_loc[1:0] < 2'd2);
    assign move_left_valid  = (direction==LEFT)  && (space_loc[1:0] > 2'd0);
    assign move_up_valid    = (direction==UP)    && (space_loc[3:2] > 2'd0);
    assign move_down_valid  = (direction==DOWN)  && (space_loc[3:2] < 2'd2);
    assign move_valid = (move_right_valid || move_left_valid || move_up_valid || move_down_valid);

    // Shifting space_loc whenever a move happens

    logic [3:0] space_loc_left;
    logic [3:0] space_loc_right;
    logic [3:0] space_loc_up;
    logic [3:0] space_loc_down;

    assign space_loc_left  = {space_loc[3:2]    , (space_loc[1:0]-1)};
    assign space_loc_right = {space_loc[3:2]    , (space_loc[1:0]+1)};
    assign space_loc_up    = {(space_loc[3:2]-1), space_loc[1:0]    };
    assign space_loc_down  = {(space_loc[3:2]+1), space_loc[1:0]    };

    always @( posedge clk ) begin
        if( move_valid ) begin
            case (direction)
                LEFT   : space_loc <= space_loc_left;
                RIGHT  : space_loc <= space_loc_right;
                UP     : space_loc <= space_loc_up;
                DOWN   : space_loc <= space_loc_down;
                default: space_loc <= space_loc;
            endcase
        end
    end

    // Swapping values in game representation whenever a move happens

    always @( posedge clk ) begin
        if( move_valid ) begin
            case (space_loc)
                4'b0000: begin // Top left
                            case (direction)
                                RIGHT  : begin
                                            // Swap top left and top middle
                                            top_middle <= top_left;
                                            top_left   <= top_middle;
                                end
                                DOWN   : begin
                                            // Swap top left and middle left
                                            middle_left <= top_left;
                                            top_left    <= middle_left;
                                end
                                default: space_loc = 4'bxxxx;
                            endcase
                end
                4'b0001: begin // Top middle
                            case (direction)
                                RIGHT  : begin
                                            // Swap top middle and top right
                                            top_middle <= top_right;
                                            top_right  <= top_middle;
                                end
                                DOWN   : begin
                                            // Swap top middle and middle middle
                                            top_middle    <= middle_middle;
                                            middle_middle <= top_middle;
                                end
                                LEFT   : begin
                                            // Swap top middle and top left
                                            top_middle <= top_left;
                                            top_left   <= top_middle;
                                end
                                default: space_loc = 4'bxxxx;
                            endcase
                end
                4'b0010: begin // Top right
                            case (direction)
                                LEFT   : begin
                                            // Swap top middle and top right
                                            top_middle <= top_right;
                                            top_right  <= top_middle;
                                end
                                DOWN   : begin
                                            // Swap top right and middle right
                                            top_right    <= middle_right;
                                            middle_right <= top_right;
                                end
                                default: space_loc = 4'bxxxx;
                            endcase
                end
                4'b0100: begin // Middle left
                            case (direction)
                                UP     : begin
                                            // Swap top left and middle left
                                            middle_left <= top_left;
                                            top_left    <= middle_left;
                                end
                                RIGHT  : begin
                                            // Swap middle left and middle middle
                                            middle_left   <= middle_middle;
                                            middle_middle <= middle_left;
                                end
                                DOWN   : begin
                                            // Swap middle left and bottom left
                                            middle_left <= bottom_left;
                                            bottom_left <= middle_left;
                                end
                                default: space_loc = 4'bxxxx;
                            endcase
                end
                4'b0101: begin // Middle middle
                            case (direction)
                                UP     : begin
                                            // Swap top middle and middle middle
                                            top_middle    <= middle_middle;
                                            middle_middle <= top_middle;
                                end
                                LEFT   : begin
                                            // Swap middle left and middle middle
                                            middle_left   <= middle_middle;
                                            middle_middle <= middle_left;
                                end
                                RIGHT  : begin
                                            // Swap middle right and middle middle
                                            middle_right  <= middle_middle;
                                            middle_middle <= middle_right;
                                end
                                DOWN   : begin
                                            // Swap bottom middle and middle middle
                                            bottom_middle <= middle_middle;
                                            middle_middle <= bottom_middle;
                                end
                                default: space_loc = 4'bxxxx;
                            endcase
                end
                4'b0110: begin // Middle right
                            case (direction) 
                                UP     : begin
                                            // Swap top right and middle right
                                            top_right    <= middle_right;
                                            middle_right <= top_right;
                                end
                                LEFT   : begin
                                            // Swap middle right and middle middle
                                            middle_right  <= middle_middle;
                                            middle_middle <= middle_right;
                                end
                                DOWN   : begin
                                            // Swap middle right and bottom right
                                            middle_right <= bottom_right;
                                            bottom_right <= middle_right;
                                end
                                default: space_loc = 4'bxxxx;
                            endcase
                end
                4'b1000: begin // Bottom left
                            case (direction)
                                UP     : begin
                                            // Swap middle left and bottom left
                                            middle_left <= bottom_left;
                                            bottom_left <= middle_left;
                                end
                                RIGHT  : begin
                                            // Swap bottom middle and bottom left
                                            bottom_middle <= bottom_left;
                                            bottom_left   <= bottom_middle;
                                end
                                default: space_loc = 4'bxxxx;
                            endcase
                end
                4'b1001: begin // Bottom middle
                            case (direction)
                                UP     : begin
                                            // Swap bottom middle and middle middle
                                            bottom_middle <= middle_middle;
                                            middle_middle <= bottom_middle;
                                end
                                RIGHT  : begin
                                            // Swap bottom middle and bottom right
                                            bottom_middle <= bottom_right;
                                            bottom_right  <= bottom_middle;
                                end
                                LEFT   : begin
                                            // Swap bottom middle and bottom left
                                            bottom_middle <= bottom_left;
                                            bottom_left   <= bottom_middle;
                                end
                                default: space_loc = 4'bxxxx;
                            endcase
                end
                4'b1010: begin // Bottom right
                            case (direction)
                                UP     : begin
                                            // Swap middle right and bottom right
                                            middle_right <= bottom_right;
                                            bottom_right <= middle_right;
                                end
                                LEFT   : begin
                                            // Swap bottom middle and bottom right
                                            bottom_middle <= bottom_right;
                                            bottom_right  <= bottom_middle;
                                end
                                default: space_loc = 4'bxxxx;
                            endcase
                end
                default: space_loc <= 4'bxxxx
            endcase

        end
    end

endmodule