`timescale 1ns / 1ps

module wd6522(
    input cs,           // Chip select. The real VIA has CS1 and nCS2. You can get the same functionality by defining this cs to be (cs1 & !cs2)
    input phi2,         // Phase 2 Internal Clock
    input nReset,       // Reset (active low)
    input [3:0]rs,      // Register select
    input rWb,          // read (high) write (low)

    inout[7:0]data,

    inout [7:0]pa,      // Peripheral data port A
    inout [7:0]pb,      // Peripheral data port B

    output nIrq);       // Interrupt request

reg [7:0]dataReg;
assign data = dataReg;
reg irqReg;
assign nIrq = irqReg;

reg [7:0]peripheralA;
reg [7:0]peripheralADirection;

for( genvar i=0; i<8; i = i+1 ) begin
    assign pa[i] = peripheralADirection[i] ? peripheralA[i] : 1'bZ;
end

reg [7:0]peripheralB;
reg [7:0]peripheralBDirection;

for( genvar i=0; i<8; i = i+1 ) begin
    assign pb[i] = peripheralBDirection[i] ? peripheralB[i] : 1'bZ;
end

initial begin
    reset();
end

always@(posedge phi2)
begin
    if( cs & nReset )
    begin
        case( rs )
        4'd0: begin
            // Peripheral B data 
        end
        4'd1: begin
            // Peripheral A data
        end
        4'd2: begin
            // Peripheral B data direction
        end
        4'd3: begin
            // Peripheral A data direction
        end
        default: begin
            // All other registers are not yet implemented
        end
        endcase
    end else
        dataReg = 7'bZ;
end

always@(negedge nReset)
begin
    reset();
end

task reset();
begin
    dataReg = 7'bZ; // High impedance on start
    irqReg = 1;     // Don't request interrupt
    
    peripheralA = 0;
    peripheralADirection = 0;
    peripheralB = 0;
    peripheralBDirection = 0;
end
endtask

endmodule