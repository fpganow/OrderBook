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

    // Output indicators
    wire [1046:0] out_OrderBook_Variables;
    wire [311:0]  out_OrderBook_Result;
    wire [0:0]    out_Ready_For_OrderBook_Command;
    wire [0:0]    out_Output_Valid;

    // Input controls
    reg [0:0]    in_ready_for_output;  // Ready for Output
    reg [311:0]  in_orderbook_command; // OrderBook.Command
    reg [0:0]    in_input_valid;       // Input Valid

    // OrderBook.Command consists of:
    //   CommandType = {AddOrder, OrderExecuted, ReduceSize, ModifyOrder, DeleteOrder, Get.All.Orders, Get.Top}
    //   Side (U8) 
    //   Order Id (U64)
    //   Quantity (U32)
    //   Symbool (U64)
    //   Price (U64)
    //   Executed Quantity (U32)
    //   Cancelled Quantity (U32)

    NiFpgaIPWrapper_orderbook_ip UUT (
		.reset(0),
        .enable_in(1),
        .enable_out(),
        .enable_clr(0),

        .ctrlind_00_Ready_for_Output(in_ready_for_output),              // in std_logic_vector(0 downto 0);
        .ctrlind_03_Reset(0),                                           // in std_logic_vector(0 downto 0);
        .ctrlind_05_Input_Valid(in_input_valid),                        // in std_logic_vector(0 downto 0);
		.ctrlind_06_OrderBook_Command(in_orderbook_command),            // in std_logic_vector(311 downto 0);
        .ctrlind_01_Output_Valid(out_Output_Valid),                     // out std_logic_vector(0 downto 0);
        .ctrlind_02_OrderBook_Result(out_OrderBook_Result),             // out std_logic_vector(311 downto 0);
        .ctrlind_04_OrderBook_Variables(out_OrderBook_Variables),       // out std_logic_vector(1046 downto 0);
    	.ctrlind_07_Ready_for_Input(out_Ready_For_OrderBook_Command),   // out std_logic_vector(0 downto 0);

        .Clk40Derived2x1I0MHz(clk)
    );

    reg [ 7:0]   command_type;
    reg [ 7:0]   side;
    reg [63:0]   order_id;
    reg [31:0]   quantity;
    reg [63:0]   symbol;
    reg [63:0]   price;
    reg [31:0]   executed_quantity;
    reg [31:0]   cancelled_quantity;

    reg [ 7:0]  result_order_book_result;
    reg [ 7:0]  result_side;
    reg [63:0]  result_order_id;
    reg [31:0]  result_quantity;
    reg [63:0]  result_symbol;
    reg [63:0]  result_price;
    reg [31:0]  result_other_1;
    reg [31:0]  result_other_2;

    initial
    begin
        // Initial defaults
        in_ready_for_output = 1'b0;
        in_orderbook_command = 311'b0;
        in_input_valid = 1'b0;

        // Now wait for UUT to say it is ready for a command
        // (and ignore the initial value which is usually 1)
        #(duty_cycle * 10);

        // Wait for IP to be ready
        wait(out_Ready_For_OrderBook_Command);

        // Now wait one more clock cycle
        #(duty_cycle * 2);
        
        // And set up the first orderbook command
        command_type        =          8'h0; // Add.Order = 0
        side                =         8'h42; 
        order_id            =  64'h22001100;
        quantity            =        32'h7d;
        symbol              =      64'h7169;
        price               =      64'h2653;
        executed_quantity   =         32'h0;
        cancelled_quantity  =         32'h0;

        in_orderbook_command = {
                                command_type,
                                side,
                                order_id,
                                quantity,
                                symbol,
                                price,
                                executed_quantity,
                                cancelled_quantity
                               };
        in_input_valid = 1'b1;
        in_ready_for_output = 1'b1;

        #(duty_cycle * 2);
        #(duty_cycle * 2);
        in_input_valid = 1'b0;

        // Now wait a few clock cycles
        #(duty_cycle * 20);

        command_type        =          8'h5; // Get.All.Orders = 5
        side                =         8'h42; 
        order_id            =  64'h00000000;
        quantity            =         32'h0;
        symbol              =      64'h7169;
        price               =         64'h0;
        executed_quantity   =         32'h0;
        cancelled_quantity  =         32'h0;

        in_orderbook_command = {
                                command_type,
                                side,
                                order_id,
                                quantity,
                                symbol,
                                price,
                                executed_quantity,
                                cancelled_quantity
                               };
        in_input_valid = 1'b1;
        in_ready_for_output = 1'b1;

        #(duty_cycle * 2);
        #(duty_cycle * 2);
        in_input_valid = 1'b0;

        wait(out_Output_Valid);

        {
            result_order_book_result,
            result_side,
            result_order_id,
            result_quantity,
            result_symbol,
            result_price,
            result_other_1,
            result_other_2
        } = out_OrderBook_Result;

        #(duty_cycle * 2);
        $finish;
    end

endmodule