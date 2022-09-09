module eightbit_reg
(
    input  logic       clk,
    input  logic [7:0] in,
    input  logic [7:0] out,
);

    logic [7:0] in_reg;
    always @( posedge clk ) begin
        in_reg <= in;
    end

    assign out = in_reg;

    `ifdef FORMAL

    logic f_past_valid = 0;

    always @( posedge clk ) begin
        f_past_valid <= 1;
        if( f_past_valid )
            assert( out==$past(in) );
    end

    `endif // FORMAL

endmodule