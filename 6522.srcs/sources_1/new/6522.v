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
    if( cs && nReset && rWb )
    begin
        case( rs )
        4'd0: begin
            readPb();
        end
        4'd1: begin
            readPa();
        end
        4'd2: begin
            readPbDir();
        end
        4'd3: begin
            readPaDir();
        end
        default: begin
            // All other registers are not yet implemented
        end
        endcase
    end else begin
        // If we're not selected or we're in write mode, deassert the data line
        dataReg = {8{1'bZ}};
    end
end

always@(negedge phi2)
begin
    if( cs && nReset )
    begin
        if( !rWb ) begin
            // Write mode
            case( rs )
            4'd0: begin
                writePb();
            end
            4'd1: begin
                writePa();
            end
            4'd2: begin
                writePbDir();
            end
            4'd3: begin
                writePaDir();
            end
            default: begin
                // All other registers are not yet implemented
            end
            endcase
        end
    end else begin
        // If we're not selected deassert the data line
        dataReg = {8{1'bZ}};
    end
end

always@(negedge nReset)
begin
    reset();
end

task readPb();
begin 
    // Read. Give true input where applicable, and *desired* output elsewhere. See section 2.1 of the datasheet
    dataReg = (pb & ~peripheralBDirection) | (peripheralB & peripheralBDirection);
end
endtask

task writePb();
    peripheralB = data;
endtask

task readPa();
    dataReg = pa;
endtask

task writePa();
    peripheralA = data;
endtask

task readPbDir();
    dataReg = peripheralBDirection;
endtask

task writePbDir();
    peripheralBDirection = data;
endtask

task readPaDir();
    dataReg = peripheralADirection;
endtask

task writePaDir();
    peripheralADirection = data;
endtask

task reset();
begin
    dataReg = 8'bZ; // High impedance on start
    irqReg = 1;     // Don't request interrupt
    
    peripheralA = 0;
    peripheralADirection = 0;
    peripheralB = 0;
    peripheralBDirection = 0;
end
endtask

endmodule