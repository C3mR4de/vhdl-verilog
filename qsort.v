module qsort
(
    input clk,
    input rst,
    input start,
    input [31:0] in0, in1, in2, in3, in4, in5, in6, in7,
    output reg [31:0] out0, out1, out2, out3, out4, out5, out6, out7,
    output reg done
);
:
    reg [31:0] data [0:7];
    reg [2:0] stack_ptr;
    reg [3:0] stack_lo [0:7];
    reg [3:0] stack_hi [0:7];
    reg [3:0] lo, hi;
    reg [3:0] i, j;
    reg [31:0] pivot;
    reg [1:0] state;
    reg init_done;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            stack_ptr <= 3'd0;
            lo <= 4'd0;
            hi <= 4'd0;
            i <= 4'd0;
            j <= 4'd0;
            state <= 2'd0;
            done <= 1'b0;
            init_done <= 1'b0;

            out0 <= 32'd0;
            out1 <= 32'd0;
            out2 <= 32'd0;
            out3 <= 32'd0;
            out4 <= 32'd0;
            out5 <= 32'd0;
            out6 <= 32'd0;
            out7 <= 32'd0;
        end else begin
            case (state)
                2'd0: begin
                    if (start && !init_done) begin
                        data[0] <= in0;
                        data[1] <= in1;
                        data[2] <= in2;
                        data[3] <= in3;
                        data[4] <= in4;
                        data[5] <= in5;
                        data[6] <= in6;
                        data[7] <= in7;

                        stack_lo[0] <= 4'd0;
                        stack_hi[0] <= 4'd7;
                        stack_ptr <= 3'd1;
                        init_done <= 1'b1;
                        state <= 2'd1;
                    end
                end

                2'd1: begin
                    if (stack_ptr > 0) begin

                        stack_ptr <= stack_ptr - 1;
                        lo <= stack_lo[stack_ptr-1];
                        hi <= stack_hi[stack_ptr-1];

                        if (data[lo] <= data[(lo+hi)>>1] && data[(lo+hi)>>1] <= data[hi])
                            pivot <= data[(lo+hi)>>1];
                        else if (data[(lo+hi)>>1] <= data[lo] && data[lo] <= data[hi])
                            pivot <= data[lo];
                        else
                            pivot <= data[hi];

                        i <= lo;
                        j <= hi;
                        state <= 2'd2;
                    end else begin

                        done <= 1'b1;
                        out0 <= data[0];
                        out1 <= data[1];
                        out2 <= data[2];
                        out3 <= data[3];
                        out4 <= data[4];
                        out5 <= data[5];
                        out6 <= data[6];
                        out7 <= data[7];
                    end
                end

                2'd2: begin
                    if (i <= j) begin
                        if (data[i] < pivot) begin
                            i <= i + 1;
                        end else if (data[j] > pivot) begin
                            j <= j - 1;
                        end else if (i <= j) begin

                            data[i] <= data[j];
                            data[j] <= data[i];
                            i <= i + 1;
                            j <= j - 1;
                        end
                    end else begin

                        if (lo < j) begin
                            stack_lo[stack_ptr] <= lo;
                            stack_hi[stack_ptr] <= j;
                            stack_ptr <= stack_ptr + 1;
                        end

                        if (i < hi) begin
                            stack_lo[stack_ptr] <= i;
                            stack_hi[stack_ptr] <= hi;
                            stack_ptr <= stack_ptr + 1;
                        end

                        state <= 2'd1;
                    end
                end
            endcase
        end
    end
endmodule
