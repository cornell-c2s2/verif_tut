module sliding_tile_fast
(
    input logic       clk,
    input logic       reset,
    input logic [1:0] direction
);

    // Define the semantics of direction
    
    localparam LEFT  = 2'b00;
    localparam RIGHT = 2'b01;
    localparam UP    = 2'b10;
    localparam DOWN  = 2'b11;

    // Instantiate game representation
    
    logic [3:0] top_left;
    logic [3:0] top_middle;
    logic [3:0] top_right;
    logic [3:0] middle_left;
    logic [3:0] middle_middle;
    logic [3:0] middle_right;
    logic [3:0] bottom_left;
    logic [3:0] bottom_middle;
    logic [3:0] bottom_right;

    logic [3:0] space_loc;

    // Determine reset state
    
    logic design_was_reset = 1'b0;

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

    assign space_loc_left  = {space_loc[3:2]        , (space_loc[1:0] - 2'b01)};
    assign space_loc_right = {space_loc[3:2]        , (space_loc[1:0] + 2'b01)};
    assign space_loc_up    = {(space_loc[3:2]-2'b01), space_loc[1:0]          };
    assign space_loc_down  = {(space_loc[3:2]+2'b01), space_loc[1:0]          };

    // Swapping values in game representation whenever a move happens

    always @( posedge clk ) begin
        if( reset ) begin
            top_left      <= 4'd2;
            top_middle    <= 4'd5;
            top_right     <= 4'd6;
            middle_left   <= 4'd1;
            middle_middle <= 4'd7;
            middle_right  <= 4'd8;
            bottom_left   <= 4'd4;
            bottom_middle <= 4'd3;
            bottom_right  <= 4'd0;
        
            space_loc     <= 4'b1010;

            design_was_reset <= 1'b1;
        end
        else if( move_valid ) begin
            case (direction)
                LEFT   : space_loc <= space_loc_left;
                RIGHT  : space_loc <= space_loc_right;
                UP     : space_loc <= space_loc_up;
                DOWN   : space_loc <= space_loc_down;
                default: space_loc <= space_loc;
            endcase
            case (space_loc)
                4'b0000: begin // Top left
                            case (direction)
                                RIGHT  : begin
                                            // Swap top left and top middle
                                            top_middle <= top_left;
                                            top_left   <= top_middle;
                                            $display("Move the space RIGHT");
                                end
                                DOWN   : begin
                                            // Swap top left and middle left
                                            middle_left <= top_left;
                                            top_left    <= middle_left;
                                            $display("Move the space DOWN");
                                end
                                default: top_left <= 4'bxxxx;
                            endcase
                end
                4'b0001: begin // Top middle
                            case (direction)
                                RIGHT  : begin
                                            // Swap top middle and top right
                                            top_middle <= top_right;
                                            top_right  <= top_middle;
                                            $display("Move the space RIGHT");
                                end
                                DOWN   : begin
                                            // Swap top middle and middle middle
                                            top_middle    <= middle_middle;
                                            middle_middle <= top_middle;
                                            $display("Move the space DOWN");
                                end
                                LEFT   : begin
                                            // Swap top middle and top left
                                            top_middle <= top_left;
                                            top_left   <= top_middle;
                                            $display("Move the space LEFT");
                                end
                                default: top_middle <= 4'bxxxx;
                            endcase
                end
                4'b0010: begin // Top right
                            case (direction)
                                LEFT   : begin
                                            // Swap top middle and top right
                                            top_middle <= top_right;
                                            top_right  <= top_middle;
                                            $display("Move the space LEFT");
                                end
                                DOWN   : begin
                                            // Swap top right and middle right
                                            top_right    <= middle_right;
                                            middle_right <= top_right;
                                            $display("Move the space DOWN");
                                end
                                default: top_right <= 4'bxxxx;
                            endcase
                end
                4'b0100: begin // Middle left
                            case (direction)
                                UP     : begin
                                            // Swap top left and middle left
                                            middle_left <= top_left;
                                            top_left    <= middle_left;
                                            $display("Move the space UP");
                                end
                                RIGHT  : begin
                                            // Swap middle left and middle middle
                                            middle_left   <= middle_middle;
                                            middle_middle <= middle_left;
                                            $display("Move the space RIGHT");
                                end
                                DOWN   : begin
                                            // Swap middle left and bottom left
                                            middle_left <= bottom_left;
                                            bottom_left <= middle_left;
                                            $display("Move the space DOWN");
                                end
                                default: middle_left <= 4'bxxxx;
                            endcase
                end
                4'b0101: begin // Middle middle
                            case (direction)
                                UP     : begin
                                            // Swap top middle and middle middle
                                            top_middle    <= middle_middle;
                                            middle_middle <= top_middle;
                                            $display("Move the space UP");
                                end
                                LEFT   : begin
                                            // Swap middle left and middle middle
                                            middle_left   <= middle_middle;
                                            middle_middle <= middle_left;
                                            $display("Move the space LEFT");
                                end
                                RIGHT  : begin
                                            // Swap middle right and middle middle
                                            middle_right  <= middle_middle;
                                            middle_middle <= middle_right;
                                            $display("Move the space RIGHT");
                                end
                                DOWN   : begin
                                            // Swap bottom middle and middle middle
                                            bottom_middle <= middle_middle;
                                            middle_middle <= bottom_middle;
                                            $display("Move the space DOWN");
                                end
                                default: middle_middle <= 4'bxxxx;
                            endcase
                end
                4'b0110: begin // Middle right
                            case (direction) 
                                UP     : begin
                                            // Swap top right and middle right
                                            top_right    <= middle_right;
                                            middle_right <= top_right;
                                            $display("Move the space UP");
                                end
                                LEFT   : begin
                                            // Swap middle right and middle middle
                                            middle_right  <= middle_middle;
                                            middle_middle <= middle_right;
                                            $display("Move the space LEFT");
                                end
                                DOWN   : begin
                                            // Swap middle right and bottom right
                                            middle_right <= bottom_right;
                                            bottom_right <= middle_right;
                                            $display("Move the space DOWN");
                                end
                                default: middle_right <= 4'bxxxx;
                            endcase
                end
                4'b1000: begin // Bottom left
                            case (direction)
                                UP     : begin
                                            // Swap middle left and bottom left
                                            middle_left <= bottom_left;
                                            bottom_left <= middle_left;
                                            $display("Move the space UP");
                                end
                                RIGHT  : begin
                                            // Swap bottom middle and bottom left
                                            bottom_middle <= bottom_left;
                                            bottom_left   <= bottom_middle;
                                            $display("Move the space RIGHT");
                                end
                                default: bottom_left <= 4'bxxxx;
                            endcase
                end
                4'b1001: begin // Bottom middle
                            case (direction)
                                UP     : begin
                                            // Swap bottom middle and middle middle
                                            bottom_middle <= middle_middle;
                                            middle_middle <= bottom_middle;
                                            $display("Move the space UP");
                                end
                                RIGHT  : begin
                                            // Swap bottom middle and bottom right
                                            bottom_middle <= bottom_right;
                                            bottom_right  <= bottom_middle;
                                            $display("Move the space RIGHT");
                                end
                                LEFT   : begin
                                            // Swap bottom middle and bottom left
                                            bottom_middle <= bottom_left;
                                            bottom_left   <= bottom_middle;
                                            $display("Move the space LEFT");
                                end
                                default: bottom_middle <= 4'bxxxx;
                            endcase
                end
                4'b1010: begin // Bottom right
                            case (direction)
                                UP     : begin
                                            // Swap middle right and bottom right
                                            middle_right <= bottom_right;
                                            bottom_right <= middle_right;
                                            $display("Move the space UP");
                                end
                                LEFT   : begin
                                            // Swap bottom middle and bottom right
                                            bottom_middle <= bottom_right;
                                            bottom_right  <= bottom_middle;
                                            $display("Move the space LEFT");
                                end
                                default: bottom_right <= 4'bxxxx;
                            endcase
                end
            endcase

        end
    end

    // Define binary state of game

    logic [8:0] game_state; // This tells us how many tiles are currently in their correct spot

    assign game_state = {
        (top_left      == 4'd1),
        (top_middle    == 4'd2),
        (top_right     == 4'd3),
        (middle_left   == 4'd4),
        (middle_middle == 4'd5),
        (middle_right  == 4'd6),
        (bottom_left   == 4'd7),
        (bottom_middle == 4'd8),
        (bottom_right  == 4'd0)
    };

    `ifdef FORMAL

    logic f_past_valid = 0;

    initial assume(reset);

    always @( posedge clk ) begin
        cover((game_state==9'b111111111) && design_was_reset);

        if( design_was_reset ) begin
            assume(!reset);
        end
        
        if(direction==LEFT) begin
            assume(space_loc[1:0] > 2'd0);
        end

        if(direction==RIGHT) begin
            assume(space_loc[1:0] < 2'd2);
        end

        if(direction==UP) begin
            assume(space_loc[3:2] > 2'd0);
        end

        if(direction==DOWN) begin
            assume(space_loc[3:2] < 2'd2);
        end

        f_past_valid <= 1;
        
        if(f_past_valid) begin
            if($past(direction)==LEFT) begin
                assume(direction!=RIGHT);
            end
            if($past(direction)==RIGHT) begin
                assume(direction!=LEFT);
            end
            if($past(direction)==UP) begin
                assume(direction!=DOWN);
            end
            if($past(direction)==DOWN) begin
                assume(direction!=UP);
            end
        end
    end

    `endif // FORMAL

endmodule