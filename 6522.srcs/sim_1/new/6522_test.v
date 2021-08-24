`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/18/2021 01:35:47 PM
// Design Name: 
// Module Name: wd6522_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module via6522_test(inout [7:0]dataExt);
    
reg cs;
reg clock;
reg nReset;

reg [3:0]registerSelect;

reg rw;
wire [7:0]data;
wire [7:0]pb;

reg [7:0]dataInput;
reg [7:0]paInput;
reg [7:0]pbInput;

assign dataExt = data;
assign dataExt = dataInput;

via6522 via(
    .cs( cs ),
    .phi2( clock ),
    .nReset( nReset ),
    .rs( registerSelect ),
    .rWb( rw ),
    
    .dataOut( data ),
    .dataIn( dataExt ),
    .paOut( pa ),
    .paIn( pa ),
    .pbOut( pb ),
    .pbIn( pbInput )
);

initial begin
    clock = 0;
    
    forever begin
        #35.5 clock = ~clock;
    end
end

initial begin
    cs = 0;
    nReset = 1;
    registerSelect = 0;
    rw = 1;
    dataInput = {8{1'bz}};
    
    pbInput = 8'b11010110;
    paInput = 8'b00001000;
    
    #100 cs=1;
    #200 cs=0;
    #250
    
    pbInput = 0;
    cs=1;
    rw=0;
    dataInput = 7'b01110011;
    #71
    registerSelect = 2;
end

endmodule
