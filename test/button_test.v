module button_test(
    input clk,
    input rst,
    input btn,
    output [7:0] seg
);
    wire pulse;
    reg [2:0] count;
    button_pulse btn_pulse(
        .clk(clk),
        .rst(rst),
        .btn(btn),
        .pulse(pulse)
    );

    seg seg1(
        .num({1'b0, count}),
        .led(seg)
    );
    always @(posedge clk) begin
        if (rst) begin
            count <= 3'h0;
        end else if (pulse) begin
            count <= count + 1;
        end
    end

endmodule