`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2021 09:23:26 PM
// Design Name: 
// Module Name: bats_parser_tb
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


module orderbook_tb;

    // 10ns = 100 MHz
    // 20ns = 50 MHz
    // 25ns = 40MHz
    // duration for each bit = 20 * timescale = 20 * 1 ns = 20 ns
    localparam period = 20;
    localparam duty_cycle = period / 2;

    reg clk;

    always
    begin
        clk = 1'b1;
        #duty_cycle;

        clk = 1'b0;
        #duty_cycle;
    end

//    // UDP Payload related signals/registers
//    reg data_valid_in;
//    reg [7:0]data2_in;
//    reg[7:0] bats_data;
//    wire [15:0] orderbook_command;
//    wire orderbook_command_valid;
//    wire [31:0] cancelled_quantity;
//    wire [31:0] executed_quantity;
//    wire [63:0] price;
//    wire [63:0] symbol;
//    wire [31:0] quantity;
//    wire [63:0] order_id;
//    wire [7:0] side;

    
//    NiFpgaIPWrapper_orderbook UUT (
//		.reset(0),
//        .enable_in(1),
//        .enable_out(),
//        .enable_clr(0),
//        .ctrlind_00_Reset(0),
//        .ctrlind_01_Ready_For_OrderBook_Result(1),
//		.ctrlind_02_OrderBook_Command(), // : in std_logic_vector(311 downto 0);
//		.ctrlind_03_OrderBook_Command_Valid(0), // : in std_logic_vector(0 downto 0);
//		.ctrlind_04_OrderBook_Variables(), // : out std_logic_vector(1046 downto 0);
//		.ctrlind_05_OrderBook_Entry(), // : out std_logic_vector(311 downto 0);
//		.ctrlind_06_Ready_For_OrderBook_Command(), // : out std_logic_vector(0 downto 0);
//		.ctrlind_07_OrderBook_Result_Valid(), // : out std_logic_vector(0 downto 0);
//        .Clk40Derived2x1I0MHz(clk)
//    );

//    integer fptr;
//    integer scan_faults;

    reg [5:0]large_variable;
    reg [1:0] left_side;
    reg [3:0] right_side;
    
    reg [7:0]command_type;
    reg [7:0] side;
    reg [63:0] order_id;
    reg [31:0]quantity;
    reg [63:0]symbol;
    reg [63:0]price;
    reg [31:0]executed_quantity;
    reg [31:0]cancelled_quantity;
    
    initial
    begin
        left_side <= 2'b10;
        right_side <= 4'b1000;
//        large_variable = {2'b11, 4'b1111};

        #(duty_cycle * 2);
        // Join 2 variables
        large_variable = {left_side, right_side};

// TODO: Is the order of each command correct? I think I remember a case where it was not...
// OrderBook.Command
// CommandType = {AddOrder, OrderExecuted, ReduceSize, ModifyOrder, DeleteOrder, Get.All.Orders, Get.Top}
// Side (U8) 
// Order Id (U64)
// Quantity (U32)
// Symbool (U64)
// Price (U64)
// Executed Quantity (U32)
// Cancelled Quantity (U32)

//        fptr = $fopen("raw.pitch.dat", "rb");
//        if(fptr == 0)
//        begin
//            $display("raw.pitch.dat was NULL");
//            $finish;
//        end
//        while (!$feof(fptr))
//        begin
//            scan_faults = $fread(bats_data, fptr);
//            data2_in = bats_data;
//            data_valid_in = 1'b1;
//            #period;           
//        end
//        $fclose(fptr); // Close file before finish

//        $finish;
    end

endmodule