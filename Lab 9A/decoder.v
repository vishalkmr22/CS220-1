`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:05:11 04/01/2024 
// Design Name: 
// Module Name:    decoder 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module decoder(
    clk,btn,leds
);
    input clk;
    input btn;
    output reg [7:0] leds;
    reg [2:0] encodedvalues [7:0];
    reg [7:0] decodedvalues [7:0];
    reg [7:0] xor_result;
    reg parity;

    reg [4:0] rowpointer = 3'b000;
    reg [5:0] counter = 6'b0;
    
    initial begin
        encodedvalues[0] = 3'b011;
        encodedvalues[1] = 3'b100;
        encodedvalues[2] = 3'b111;
        encodedvalues[3] = 3'b010;
        encodedvalues[4] = 3'b011;
        encodedvalues[5] = 3'b101;
        encodedvalues[6] = 3'b000;
        encodedvalues[7] = 3'b010;
    end

    always @(posedge clk) begin
        case (rowpointer)
            3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111: begin
                case (encodedvalues[rowpointer])
                    3'b000: decodedvalues[rowpointer] <= 8'b00000001;
                    3'b001: decodedvalues[rowpointer] <= 8'b00000010;
                    3'b010: decodedvalues[rowpointer] <= 8'b00000100;
                    3'b011: decodedvalues[rowpointer] <= 8'b00001000;
                    3'b100: decodedvalues[rowpointer] <= 8'b00010000;
                    3'b101: decodedvalues[rowpointer] <= 8'b00100000;
                    3'b110: decodedvalues[rowpointer] <= 8'b01000000;
                    3'b111: decodedvalues[rowpointer] <= 8'b10000000;
                    default: decodedvalues[rowpointer] <= 8'b00000000;
                endcase
                rowpointer <= rowpointer + 1;
            end
        endcase
    end
    
    // XOR Calculation
    always @ (posedge clk) begin
        xor_result = decodedvalues[0] ^ decodedvalues[1] ^ decodedvalues[2] ^ decodedvalues[3]
                    ^ decodedvalues[4] ^ decodedvalues[5] ^ decodedvalues[6] ^ decodedvalues[7];
    end
    
    // Parity Calculation
    always @ (posedge clk) begin
        parity = xor_result[0] ^ xor_result[1] ^ xor_result[2] ^xor_result[3] ^xor_result[4] ^xor_result[5] ^xor_result[6] ^xor_result[7];
    end

    // LED output
    always @ (posedge clk) begin
        if (btn == 1'b0)
            leds = xor_result[7:0];
        else
            leds = {6'b000000,parity};
    end

endmodule
