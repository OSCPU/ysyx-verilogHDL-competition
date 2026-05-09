module seg_test (
    input clk,
    input rst,
    input incr,
    output [7:0] seg
);
reg [2:0] num;
wire [7:0] led;
wire A,B,C,D,E,F,G,P;

seg seg1(
    .num({1'b0, num}),
    .led(led)
);
assign {A,B,C,D,E,F,G,P} = led;
assign seg = led;

always @(posedge clk) begin
    if(rst) begin
        num <= 3'd0;
    end else if(incr) begin
        num <= num + 1;
    end else begin
        num <= num;
    end
end

`ifndef HAS_NVBOARD

always @(incr) begin
    $display("A = %b; B = %b; C = %b; D = %b; E = %b; F = %b; G = %b; P = %b;", A, B, C, D, E, F, G, P);
end

`endif // HAS_NVBOARD

endmodule